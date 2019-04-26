package com.vidiun.vdpfl.plugin.component {
	import com.vidiun.VidiunClient;
	import com.vidiun.commands.MultiRequest;
	import com.vidiun.commands.baseEntry.BaseEntryFlag;
	import com.vidiun.commands.baseEntry.BaseEntryGet;
	import com.vidiun.events.VidiunEvent;
	import com.vidiun.vo.VidiunModerationFlag;

	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.mediator.Mediator;
	import org.puremvc.as3.patterns.proxy.Proxy;

	public class ModerationMediator extends Mediator {

		/**
		 * Mediator name. <br>
		 * The mediator will be registered with this name with the application facade
		 */
		public static const NAME:String = "ModerationMediator";


		public function ModerationMediator(viewComponent:Object = null) {
			this.viewComponent = viewComponent;
			super(NAME, viewComponent);
		}


		/**
		 * This function lists the notifications to which the plugin will respond.
		 * @return 	notifications list
		 */
		override public function listNotificationInterests():Array {
			var notify:Array = [ModerationPlugin.FLAG_FOR_REVIEW];
			return notify;
		}


		/**
		 * This function handles received notifications
		 * @param note		notification
		 */
		override public function handleNotification(note:INotification):void {
//			var data:Object = note.getBody();
			if (note.getName() == ModerationPlugin.FLAG_FOR_REVIEW) {
				mod.showScreen();
			}
		}


		/**
		 * send flagging data to server
		 * */
		public function postModeration(comments:String, type:int):void {
			var mediaProxy:Proxy = (facade.retrieveProxy("mediaProxy") as Proxy);
			var vClient:VidiunClient = facade.retrieveProxy("servicesProxy")["vidiunClient"] as VidiunClient;
			var entryId:String = mediaProxy["vo"]["entry"]["id"];
			var flag:VidiunModerationFlag = new VidiunModerationFlag();
			flag.comments = comments;
			flag.flaggedEntryId = entryId;
			flag.flagType = type;
			var flagCommand:BaseEntryFlag = new BaseEntryFlag(flag);
			flagCommand.addEventListener(VidiunEvent.COMPLETE, moderationComplete);
			flagCommand.addEventListener(VidiunEvent.FAILED, moderationFailed);
			vClient.post(flagCommand);
		}


		/**
		 * notify user success
		 * */
		private function moderationComplete(e:VidiunEvent):void {
			mod.flagComplete(true);
		}

		
		/**
		 * notify user failure
		 * */
		private function moderationFailed(e:VidiunEvent):void {
			mod.flagComplete(false);
		}


		/**
		 * cast the view component to its real type so we
		 * can use type check and autocomplete.
		 * */
		private function get mod():ModerationPlugin {
			return viewComponent as ModerationPlugin;
		}
	}
}