package com.vidiun.vdpfl.controller
{
	import com.vidiun.vdpfl.model.ConfigProxy;
	import com.vidiun.vdpfl.model.MediaProxy;
	import com.vidiun.vdpfl.model.PlayerStatusProxy;
	import com.vidiun.vdpfl.model.SequenceProxy;
	import com.vidiun.vdpfl.model.strings.MessageStrings;
	import com.vidiun.vdpfl.model.type.NotificationType;
	import com.vidiun.vdpfl.view.MainViewMediator;
	import com.vidiun.vdpfl.view.controls.VTrace;
	
	import flash.display.Loader;
	import flash.events.Event;
	import flash.net.SharedObject;
	
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.command.SimpleCommand;

	/**
	 * This class defines the actions that are taken once VDP layout is ready. 
	 */
	public class LayoutReadyCommand extends SimpleCommand
	{
		
		private var _flashvars:Object;

		public function LayoutReadyCommand()
		{
			super();
		}
		
		override public function execute(notification:INotification):void
		{
			var playerStatus : PlayerStatusProxy = facade.retrieveProxy(PlayerStatusProxy.NAME) as PlayerStatusProxy;
			playerStatus.vo.vdpStatus = "ready";
			_flashvars = (facade.retrieveProxy(ConfigProxy.NAME) as ConfigProxy).vo.flashvars;
			// remove the preloader
			var rm:Object = facade.retrieveMediator("stageMediator");
			if(rm.root.hasOwnProperty("preloader"))
				var ldr:Loader = rm.root["preloader"] as Loader; 
			if (ldr && !_flashvars.usePreloaderBufferAnimation) {
				ldr.unloadAndStop(false);
				if (ldr.parent != null) {
					rm.root.removeChild(ldr);
				}
			}
			
			var sequenceProxy : SequenceProxy = facade.retrieveProxy(SequenceProxy.NAME) as SequenceProxy;
			if (!sequenceProxy.vo.isInSequence	)
			{
				sequenceProxy.populatePrePostArr();
				sequenceProxy.initPreIndex();
			}
			(facade.retrieveMediator(MainViewMediator.NAME) as MainViewMediator).createContextMenu();
						
			//check if vdp is allowed to save cookies, do it here before flow starts and after alert buttons are available from skin
			if (_flashvars.alertForCookies && _flashvars.alertForCookies=="true")
			{
				var cookie : SharedObject;
				try
				{
					cookie = SharedObject.getLocal("VidiunCookies");
				}
				catch (e: Error)
				{
					VTrace.getInstance().log("no permissions to access partner's file system");
				}
				if (cookie && cookie.data.allowCookies && cookie.data.allowCookies==true)
				{
					_flashvars.allowCookies = "true";
				}
				else
				{
					sendNotification(NotificationType.ALERT, {title: MessageStrings.getString('ALLOW_COOKIES_TITLE'), message: MessageStrings.getString('ALLOW_COOKIES'), buttons: [MessageStrings.getString('ALLOW'), MessageStrings.getString('DISALLOW')], callbackFunction: setAllowCookies, props: {buttonSpacing: 5}});
					//don't continue the flow until user has selected
					return;
				}
			}
			
			callChangeMedia();
		}
		
		/**
		 * call changeMedia Notification 
		 * 
		 */		
		private function callChangeMedia():void
		{
			var mediaProxy : MediaProxy = facade.retrieveProxy( MediaProxy.NAME ) as MediaProxy;
			if (mediaProxy.vo.entry.id) {
				sendNotification( NotificationType.CHANGE_MEDIA, {entryId: mediaProxy.vo.entry.id, flavorId: _flashvars.flavorId });
			}
			else if (_flashvars.referenceId) {
				sendNotification( NotificationType.CHANGE_MEDIA, {referenceId: _flashvars.referenceId, flavorId: _flashvars.flavorId });
			}
			else {
				sendNotification( NotificationType.CHANGE_MEDIA, {entryId: null, flavorId: _flashvars.flavorId });
			}
		}
		
		/**
		 * callback function on "set cookies" alert.
		 * Will set allowCookies flashvar accordingly. 
		 * @param evt
		 * 
		 */		
		private function setAllowCookies(evt:Event):void 
		{
			if (evt.target.label==MessageStrings.getString('ALLOW'))
			{
				_flashvars.allowCookies = "true";
				var cookie : SharedObject;
				try
				{
					cookie= SharedObject.getLocal("VidiunCookies");
				}
				catch (e : Error)
				{
					VTrace.getInstance().log("No access to user's file system");
				}
				if (cookie)
				{
					cookie.data.allowCookies = true;
					cookie.flush();
				}
			}
			else
			{
				_flashvars.allowCookies = "false";
			}
			
			callChangeMedia();
		}
	}
	
}