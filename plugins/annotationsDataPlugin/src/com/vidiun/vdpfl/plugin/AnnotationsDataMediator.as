package com.vidiun.vdpfl.plugin
{
	import com.vidiun.VidiunClient;
	import com.vidiun.commands.annotation.AnnotationList;
	import com.vidiun.events.VidiunEvent;
	import com.vidiun.vdpfl.model.MediaProxy;
	import com.vidiun.vdpfl.model.ServicesProxy;
	import com.vidiun.vdpfl.model.type.NotificationType;
	import com.vidiun.vdpfl.model.type.StreamerType;
	import com.vidiun.vdpfl.plugin.strings.NotificationStrings;
	import com.vidiun.vdpfl.plugin.strings.SortOrderString;
	import com.vidiun.vdpfl.view.media.VMediaPlayerMediator;
	import com.vidiun.vo.VidiunAnnotation;
	import com.vidiun.vo.VidiunAnnotationFilter;
	import com.vidiun.vo.VidiunFilter;
	
	import flash.events.Event;
	import flash.utils.setTimeout;
	
	import org.osmf.events.MediaPlayerCapabilityChangeEvent;
	import org.osmf.events.TimelineMetadataEvent;
	import org.osmf.media.MediaPlayer;
	import org.osmf.metadata.TimelineMarker;
	import org.osmf.metadata.TimelineMetadata;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.mediator.Mediator;
	
	public class AnnotationsDataMediator extends Mediator
	{
		public static const NAME : String = "retrieveAnnotationsMediator";
		
		private var _player : MediaPlayer;
		
		private var _mediaProxy : MediaProxy;
		
		private var _timelineMetadata : TimelineMetadata;
		
		private var _delayedSkipTime : Number = 0;
		
		public function AnnotationsDataMediator(viewComponent:Object=null)
		{
			super(NAME, viewComponent);
		}
		
		override public function listNotificationInterests():Array
		{
			var arr : Array = [NotificationStrings.RETRIEVE_ANNOTATIONS, NotificationStrings.SKIP_TO_CHAPTER, 
				NotificationType.MEDIA_LOADED, NotificationType.LAYOUT_READY, NotificationType.PLAYER_UPDATE_PLAYHEAD, NotificationType.PLAYER_PLAYED];
			return arr;
		}
		
		override public function handleNotification(notification:INotification):void
		{
			
			switch (notification.getName())
			{
				case NotificationType.LAYOUT_READY:
					if (!_player)
						_player = (facade.retrieveMediator(VMediaPlayerMediator.NAME) as VMediaPlayerMediator).player
					if (!_mediaProxy)
						_mediaProxy = facade.retrieveProxy(MediaProxy.NAME) as MediaProxy;
					break;
				case NotificationStrings.RETRIEVE_ANNOTATIONS:
					
					retrieveAnnotationGroup (viewComponent.rootAnnotationId);
					
					break;
				case NotificationStrings.SKIP_TO_CHAPTER:
					
					attemptSkipToChapter(notification.getBody().id)
					
					break;
				case NotificationType.MEDIA_LOADED:
					if ((viewComponent as AnnotationsDataPluginCode).annotationsGroup && (viewComponent as AnnotationsDataPluginCode).annotationsGroup.length) 
					{
						//Basing on the assumption that all the annotation group's annotations must belong to the same entry id.
						var firstAnnotation : VidiunAnnotation = (viewComponent as AnnotationsDataPluginCode).annotationsGroup[0];
						(viewComponent as AnnotationsDataPluginCode).activeChapterId = firstAnnotation.id;
						//Hot Fix for Akmai hd-network plugin
						if (_player && _player.media &&  _mediaProxy.vo.entry.id == firstAnnotation.entryId && _mediaProxy.vo.deliveryType == StreamerType.HDNETWORK)
						{
							_player.addEventListener(MediaPlayerCapabilityChangeEvent.CAN_SEEK_CHANGE, onCanSeekChange );
						}
					}
					break;
				case NotificationType.PLAYER_UPDATE_PLAYHEAD:
					var latestStartTime : int = (viewComponent as AnnotationsDataPluginCode).annotationsGroup[0].startTime;
					var latestStartTimeAnnotationId : String = (viewComponent as AnnotationsDataPluginCode).annotationsGroup[0].id;
					for each(var annotation : VidiunAnnotation in (viewComponent as AnnotationsDataPluginCode).annotationsGroup )
					{
						if ( annotation.startTime <= Number(notification.getBody() ) && annotation.startTime > latestStartTime )
						{
							latestStartTimeAnnotationId = annotation.id;
						}
					}
					
					if ((viewComponent as AnnotationsDataPluginCode).activeChapterId != latestStartTimeAnnotationId )
						(viewComponent as AnnotationsDataPluginCode).activeChapterId = latestStartTimeAnnotationId;
					
					break;
				case NotificationType.PLAYER_PLAYED:
					if (_delayedSkipTime && _mediaProxy.vo.deliveryType != StreamerType.HDNETWORK)
					{
						startChapter ();
						
					}
					break;
			}
		}
		
		private function onCanSeekChange (e : Event) : void
		{
			if (_player.media != null )
			{		
				if (_mediaProxy.vo.deliveryType == StreamerType.HDNETWORK)
				{
					//initialSeekPerformed = true;
					setTimeout(startChapter, 100 );
				}
			}
		}
		
		private function startChapter () : void
		{
			var tempSkipTime : Number = _delayedSkipTime;
			_delayedSkipTime = 0;
			sendNotification(NotificationType.DO_SEEK, tempSkipTime);
		}
		
		private function initTimelineMetadata () : void
		{
			_timelineMetadata = new TimelineMetadata(_player.media);
			_timelineMetadata.addEventListener(TimelineMetadataEvent.MARKER_TIME_REACHED, changeActiveAnnotationId );
		}
		
		private function createTimeBasedData () : void
		{
			for each(var annotation : VidiunAnnotation in (viewComponent as AnnotationsDataPluginCode).annotationsGroup)
			{
				_timelineMetadata.addMarker(new TimelineMarker(annotation.startTime, _player.duration) );
				
			}
		}
		
		private function changeActiveAnnotationId (e : TimelineMetadataEvent) : void
		{
			for each (var annotation : VidiunAnnotation in  (viewComponent as AnnotationsDataPluginCode).annotationsGroup )
			{
				if (Math.round(annotation.startTime) == Math.round(e.marker.time) )
				{
					(viewComponent as AnnotationsDataPluginCode).activeChapterId = annotation.id;
				}
			}
		}
		
		private function retrieveAnnotationGroup (groupId : String) : void
		{	
			var vc : VidiunClient = (facade.retrieveProxy(ServicesProxy.NAME) as ServicesProxy).vidiunClient;
			
			var annotationsListFilter : VidiunAnnotationFilter = new VidiunAnnotationFilter();
			
			annotationsListFilter.parentIdEqual = groupId;
			
			var listAnnotationGroup : AnnotationList = new AnnotationList(annotationsListFilter);
			
			listAnnotationGroup.addEventListener(VidiunEvent.COMPLETE, onAnnotationGroupLoaded);
			
			listAnnotationGroup.addEventListener(VidiunEvent.FAILED, onAnnotationGroupLoadFailed );
			
			vc.post(listAnnotationGroup);
			
		}
		
		private function onAnnotationGroupLoaded (e : VidiunEvent) : void
		{
			var vidiunAnnotationsArr : Array = new Array();
			for each(var annotation : VidiunAnnotation in e.data.objects)
			{
				vidiunAnnotationsArr.push(annotation);
			}
			
			(viewComponent as AnnotationsDataPluginCode).annotationsGroup = vidiunAnnotationsArr;
			
			if ((viewComponent as AnnotationsDataPluginCode).sortOrder)
			{
				sortArray ((viewComponent as AnnotationsDataPluginCode).sortOrder);
			}
			
			sendNotification( NotificationStrings.ANNOTATIONS_LOADED );
			
			(viewComponent as AnnotationsDataPluginCode).activeChapterId = (viewComponent as AnnotationsDataPluginCode).annotationsGroup[0].id;
		}
		
		private function onAnnotationGroupLoadFailed ( e : VidiunEvent) : void
		{
			
		}
		
		private function sortArray (sortType : String) : void
		{
			if ((viewComponent as AnnotationsDataPluginCode).annotationsGroup && (viewComponent as AnnotationsDataPluginCode).annotationsGroup.length)
			{
				switch (sortType)
				{
					case SortOrderString.START_TIME:
						(viewComponent as AnnotationsDataPluginCode).annotationsGroup.sortOn("startTime");
						break;
					case SortOrderString.TEXT:
						(viewComponent as AnnotationsDataPluginCode).annotationsGroup.sortOn("text");
						break;
				}
			}
			
		}
		
		private function attemptSkipToChapter (id : String) : void
		{
			if ((viewComponent as AnnotationsDataPluginCode).annotationsGroup && (viewComponent as AnnotationsDataPluginCode).annotationsGroup.length)
			{
				for each (var annotation : VidiunAnnotation in (viewComponent as AnnotationsDataPluginCode).annotationsGroup)
				{
					if (annotation.id == id)
					{
						
						if (_player.media && _mediaProxy.vo.entry.id == annotation.entryId)
						{
							(viewComponent as AnnotationsDataPluginCode).activeChapterId = id;
							sendNotification (NotificationType.DO_SEEK, annotation.startTime);
						}
						else
						{
							_delayedSkipTime = annotation.startTime;
							sendNotification (NotificationType.DO_PLAY);
						}
						return;
					}
				}
			}
			sendNotification(NotificationStrings.ACTIVE_CHAPTER_CHANGE_FAILED);
		}
		
	}
}