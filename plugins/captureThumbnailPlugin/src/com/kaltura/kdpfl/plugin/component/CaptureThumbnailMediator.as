package com.vidiun.vdpfl.plugin.component
{
	import com.adobe.images.JPGEncoder;
	import com.vidiun.VidiunClient;
	import com.vidiun.commands.baseEntry.BaseEntryUpdateThumbnailJpeg;
	import com.vidiun.commands.media.MediaUpdateThumbnailFromSourceEntry;
	import com.vidiun.commands.thumbAsset.ThumbAssetAddFromImage;
	import com.vidiun.commands.thumbAsset.ThumbAssetGenerate;
	import com.vidiun.commands.thumbAsset.ThumbAssetSetAsDefault;
	import com.vidiun.events.VidiunEvent;
	import com.vidiun.vdpfl.model.type.NotificationType;
	import com.vidiun.vdpfl.view.controls.AlertMediator;
	import com.vidiun.vdpfl.view.media.VMediaPlayerMediator;
	import com.vidiun.net.VidiunCall;
	import com.vidiun.types.VidiunMediaType;
	import com.vidiun.types.VidiunThumbAssetStatus;
	import com.vidiun.vo.VidiunEntryContextDataResult;
	import com.vidiun.vo.VidiunMediaEntry;
	import com.vidiun.vo.VidiunMixEntry;
	import com.vidiun.vo.VidiunThumbAsset;
	import com.vidiun.vo.VidiunThumbParams;
	import com.yahoo.astra.fl.managers.AlertManager;
	
	import fl.controls.Button;
	
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.geom.Matrix;
	import flash.ui.Mouse;
	import flash.ui.MouseCursor;
	import flash.utils.ByteArray;
	
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.mediator.Mediator;

	public class CaptureThumbnailMediator extends Mediator
	{
		///////////////////////// Variables ////////////////////////
		public static const NAME:String = "CaptureThumbnailMediator";
	
		private var bitmapData:BitmapData;
		/////////////////////////////////////////////
		
		public function CaptureThumbnailMediator(mediatorName:String=null, viewComponent:Object=null)
		{
			super(NAME, viewComponent);
		}
		
		override public function listNotificationInterests():Array
		{
			return [
					 "captureThumbnail"
					];
		} 
		
		override public function handleNotification(note:INotification):void
		{
			switch(note.getName())
			{
				case "captureThumbnail":
					var servicesProxy : Object =  facade.retrieveProxy("servicesProxy");
					var vc : VidiunClient = servicesProxy.vidiunClient;
					var mediaProxy : Object = facade.retrieveProxy("mediaProxy");
					var playerMediator:VMediaPlayerMediator = facade.retrieveMediator(VMediaPlayerMediator.NAME) as VMediaPlayerMediator;
					var player : Object = playerMediator.player;
					var playerView : DisplayObject;
					if( mediaProxy.vo.entry is VidiunMediaEntry &&
						((mediaProxy.vo.entry as VidiunMediaEntry).mediaType == VidiunMediaType.IMAGE || 
					    (mediaProxy.vo.entry as VidiunMediaEntry).mediaType == VidiunMediaType.AUDIO ||
						(mediaProxy.vo.entry as VidiunMediaEntry).mediaType == VidiunMediaType.LIVE_STREAM_FLASH))
					{	
						sendNotification("alert",{message:viewComponent.capture_thumbnail_not_supported,title:viewComponent.capture_thumbnail_success_title});
					}
					else
					{
						if( player && player.displayObject)
							 playerView = facade.retrieveMediator( "vMediaPlayerMediator" )["player"].displayObject;
						else 
							return; //can't capture the player if the view is unreachable
						
						var updateThumbnailJpeg : VidiunCall;
						if (mediaProxy.vo.entry is VidiunMixEntry)
						{
							var videoWidth : Number = playerView["videoWidth"];
							var videoHeight : Number = playerView["videoHeight"]
							
							bitmapData  = new BitmapData( videoWidth  , videoHeight , false , 0x000000);
							var a : Number = videoWidth/(playerView.width/playerView.scaleX); // videoWidth/unscaledWidth
							var d : Number = videoHeight/(playerView.height/playerView.scaleY);// videoHeight/unscaledHeight
							var matrix : Matrix = new Matrix( a , 0 , 0 , d );
							bitmapData.draw( playerView , matrix , null , null, null , true);
							var encoder : JPGEncoder = new JPGEncoder(85);
							var thumbnail : ByteArray = encoder.encode( bitmapData );
							updateThumbnailJpeg  = new ThumbAssetAddFromImage (mediaProxy.vo.entry.id, thumbnail);
						}
						else
						{
							var thumbParams : VidiunThumbParams = new VidiunThumbParams();
							thumbParams.videoOffset = playerMediator.getCurrentTime();
							thumbParams.quality = 75;
							updateThumbnailJpeg = new ThumbAssetGenerate(mediaProxy.vo.entry.id, thumbParams);
						}
						updateThumbnailJpeg.addEventListener( "complete" , result );
						updateThumbnailJpeg.addEventListener( "failed" , fault );
						vc.post( updateThumbnailJpeg );
						
						//sendNotification( NotificationType.ENABLE_GUI ,{guiEnabled: false , enableType:'full'} );
						AlertManager.showButtonIfEmpty = false;
						sendNotification( NotificationType.ALERT, {message: viewComponent.capture_thumbnail_process, title: viewComponent.capture_thumbnail_process_title} );
					}
				break;
			}	
		}

		
		private function result( data : Object ) : void
		{
			onServiceReturn ()
			sendNotification("thumbnailSaved");
			sendNotification( NotificationType.REMOVE_ALERTS );
			AlertManager.showButtonIfEmpty = true;
			if (bitmapData)
				bitmapData.dispose();
			
			var thumb:VidiunThumbAsset = data.data as VidiunThumbAsset;
			if (thumb.status == VidiunThumbAssetStatus.ERROR)
			{
				sendNotification("thumbnailFailed");
				sendNotification("alert",{message:viewComponent.error_capture_thumbnail,title:viewComponent.error_capture_thumbnail_title});
			}
			else if ((viewComponent as captureThumbnailPluginCode).shouldSetAsDefault == "true")
			{
				var servicesProxy : Object =  facade.retrieveProxy("servicesProxy");
				var vc : VidiunClient = servicesProxy.vidiunClient;
				var setThumbnailAsDefault : ThumbAssetSetAsDefault = new ThumbAssetSetAsDefault(thumb.id );
				setThumbnailAsDefault.addEventListener(VidiunEvent.COMPLETE, setAsDefaultResult);
				setThumbnailAsDefault.addEventListener( VidiunEvent.FAILED, setAsDefaultFault );
				vc.post(setThumbnailAsDefault);
			}
			else
			{
				sendNotification("alert",{message:viewComponent.capture_thumbnail_success,title:viewComponent.capture_thumbnail_success_title});
			}
		}
		
		private function fault( data : Object ) : void
		{
			onServiceReturn ()
			sendNotification("thumbnailFailed");
			sendNotification("alert",{message:viewComponent.error_capture_thumbnail,title:viewComponent.error_capture_thumbnail_title});
		}
		
		private function setAsDefaultResult (e : VidiunEvent) : void
		{
			onServiceReturn ()
			sendNotification("alert",{message:viewComponent.set_as_default_success,title:viewComponent.capture_thumbnail_success_title});
			trace('set as default success!');
		}
		
		private function setAsDefaultFault (e : VidiunEvent ) : void
		{
			onServiceReturn ()
			trace('set as default failed!');
			switch (e.error.errorCode)
			{
				case "SERVICE_FORBIDDEN":
					sendNotification("alert",{message:(viewComponent as captureThumbnailPluginCode).capture_thumbnail_service_forbidden,title:viewComponent.capture_thumbnail_service_forbidden_title});
					break;
				default:
					sendNotification("alert",{message:(viewComponent as captureThumbnailPluginCode).error_capture_thumbnail,title:viewComponent.error_capture_thumbnail_title});
					break;
			}
		}
		
		private function onServiceReturn () : void
		{
			AlertManager.showButtonIfEmpty = true;
			sendNotification( NotificationType.ENABLE_GUI ,{guiEnabled: true , enableType:'full'} );
			sendNotification( NotificationType.REMOVE_ALERTS );
		}
	}
}