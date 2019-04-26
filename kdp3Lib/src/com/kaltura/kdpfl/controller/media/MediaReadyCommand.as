package com.vidiun.vdpfl.controller.media
{
	import com.vidiun.vdpfl.model.ConfigProxy;
	import com.vidiun.vdpfl.model.MediaProxy;
	import com.vidiun.vdpfl.model.SequenceProxy;
	import com.vidiun.vdpfl.model.type.EnableType;
	import com.vidiun.vdpfl.model.type.NotificationType;
	import com.vidiun.vdpfl.model.vo.SequenceVO;
	import com.vidiun.vdpfl.view.media.VMediaPlayerMediator;
	import com.vidiun.types.VidiunMediaType;
	import com.vidiun.vo.VidiunMediaEntry;
	
	import org.osmf.media.MediaPlayer;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.command.SimpleCommand;
	
	/**
	 * MediaReadyCommand is responsible for starting play or halting after media has loaded 
	 */
	public class MediaReadyCommand extends SimpleCommand
	{
		private var _player : MediaPlayer;
		private var _mediaProxy : MediaProxy;
		private var _flashvars : Object;
		private var _sequence : SequenceVO;
		
		/**
		 * Constructor 
		 * 
		 */		
		public function MediaReadyCommand()
		{
			_player = (facade.retrieveMediator(VMediaPlayerMediator.NAME) as VMediaPlayerMediator).player;
			_mediaProxy = facade.retrieveProxy(MediaProxy.NAME) as MediaProxy;
			_flashvars = (facade.retrieveProxy(ConfigProxy.NAME) as ConfigProxy).vo.flashvars;
			_sequence = (facade.retrieveProxy(SequenceProxy.NAME) as SequenceProxy).vo;
		}
		/**
		 * The command handles the MEDIA_READY notification, according to the type of entry (live or recorded),
		 * the value of the autoPlay flashvar (whether the entry should play immediately on being loaded or after the user presses play. 
		 * In the case of a live entry, the player cannot begin to play imemdiately but goes through a process which determines whether the live stream is
		 * currently on-air or offline.
		 * @param notification
		 * 
		 */				
		override public function execute(notification:INotification):void
		{
			var playerMediator : VMediaPlayerMediator = facade.retrieveMediator(VMediaPlayerMediator.NAME) as VMediaPlayerMediator;
			
			//live streaming entry.
			//In each of these cases the media within the player needs to start playing immediately.
			if (!playerMediator.isIntelliSeeking)
			{
				if (!_sequence.isInSequence)
					sendNotification( NotificationType.DO_PLAY );
			}
				
			else
			{
				if(_mediaProxy.vo.singleAutoPlay)
				{
					_mediaProxy.vo.singleAutoPlay = false;
					sendNotification( NotificationType.DO_PLAY );
				}
				else
				{
					sendNotification( NotificationType.DO_PLAY );
				}
				
			}		
			//In case of an image entry, there is no need to enable GUI
			if( _mediaProxy.vo.entry is VidiunMediaEntry && 
				(_mediaProxy.vo.entry as VidiunMediaEntry).mediaType == VidiunMediaType.IMAGE &&
				(!playerMediator.player.duration || isNaN(playerMediator.player.duration)))
			{
				sendNotification(NotificationType.ENABLE_GUI, {guiEnabled : false , enableType : EnableType.CONTROLS});
			}
		}
		
	}
}