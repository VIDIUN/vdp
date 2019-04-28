/**
 * PlaylistAPIMediator
 *
 * @langversion 3.0
 * @playerversion Flash 9.0.28.0
 * @author Dan Bacon / www.baconoppenheim.com
 */
package com.vidiun.vdpfl.plugin.component {

	import com.vidiun.vdpfl.model.SequenceProxy;
	import com.vidiun.vdpfl.model.type.NotificationType;
	import com.vidiun.vdpfl.plugin.type.PlaylistNotificationType;
	
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.mediator.Mediator;

	
	/**
	 * Mediator for Playlist API Plugin
	 */
	public class PlaylistAPIMediator extends Mediator {
		/**
		 * mediator name
		 */
		public static const NAME:String = "PlaylistAPIMediator";

		

		/**
		 * Constructor
		 * @param viewComponent	view component
		 */
		public function PlaylistAPIMediator(viewComponent:Object = null) {
			super(NAME, viewComponent);
		}

		
		/**
		 * sets the mediaProxy's singleAutoPlay
		 * @param value
		 */		
		public function setMediaProxySingleAutoPlay(value:Boolean):void {
			(facade.retrieveProxy("mediaProxy"))["vo"]["singleAutoPlay"] = value;
		}
		
	

		/**
		 * Mediator's registration function. 
		 * Sets VDP autoPlay value and the default image duration.
		 */
		override public function onRegister():void {
			var mediaProxy:Object = facade.retrieveProxy("mediaProxy");
			mediaProxy.vo.supportImageDuration = true;
			if (playlistAPI.autoPlay == true) {
				var flashvars:Object = facade.retrieveProxy("configProxy")["vo"]["flashvars"];
				flashvars.autoPlay = "true";
			}
		}



		/**
		 * @inheritDoc
		 */
		override public function handleNotification(note:INotification):void {
			switch (note.getName()) {
				case NotificationType.PLAYER_PLAY_END:
					if (playlistAPI.autoContinue) {
						playlistAPI.playNext();
					}
					break;
				case PlaylistNotificationType.PLAYLIST_PLAY_PREVIOUS:	// prev button in uiconf
					playlistAPI.playPrevious();
					break;
				case PlaylistNotificationType.PLAYLIST_PLAY_NEXT:		// next button in uiconf
					playlistAPI.playNext();
					break;
				case NotificationType.VDP_EMPTY:
				case NotificationType.VDP_READY:
					playlistAPI.loadFirstPlaylist();
					break;
				case PlaylistNotificationType.LOAD_PLAYLIST:
					var name:String = note.getBody().vplName;
					var url:String = note.getBody().vplUrl;
					var id:String = note.getBody().vplId;
					if ((name && url) || id)
					{
						playlistAPI.resetNewPlaylist();
						playlistAPI.clearFilters();
						if (id)
							playlistAPI.loadV3Playlist(id);
						else
							playlistAPI.loadPlaylist(name, url);
					}
					else
					{
						trace ("could not load playlist, vplName ,vplUrl or vplId values are invalid");
					}
					break;
				case NotificationType.CHANGE_MEDIA: {
					if (!(facade.retrieveProxy(SequenceProxy.NAME) as SequenceProxy).vo.isInSequence)
						playlistAPI.changeMedia(note.getBody().entryId);
					break;
				}
			}
		}


		/**
		 * @inheritDoc
		 */
		override public function listNotificationInterests():Array {
			return [
					NotificationType.PLAYER_PLAY_END,
					PlaylistNotificationType.PLAYLIST_PLAY_PREVIOUS,
					PlaylistNotificationType.PLAYLIST_PLAY_NEXT,
					NotificationType.VDP_EMPTY,
					NotificationType.VDP_READY,
					PlaylistNotificationType.LOAD_PLAYLIST,
					NotificationType.CHANGE_MEDIA
			];
		}


		/**
		 * Return mediator name
		 */
		public function toString():String {
			return (NAME);
		}

		
		/**
		 * currently used vs 
		 */		
		public function get vs():String {
			var vc:Object = facade.retrieveProxy("servicesProxy")["vidiunClient"];
			return vc.vs;
		}

		
		/**
		 * Playlist's view component
		 */
		private function get playlistAPI():playlistAPIPluginCode {
			return (viewComponent as playlistAPIPluginCode);
		}

	}
}