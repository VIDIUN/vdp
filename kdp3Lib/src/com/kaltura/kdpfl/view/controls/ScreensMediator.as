﻿/**
 * ScreensMediator
 *
 * @langversion 3.0
 * @playerversion Flash 9.0.28.0
 * @author Eitan Avgil
 */
 package com.vidiun.vdpfl.view.controls
{
	import com.vidiun.vdpfl.ApplicationFacade;
	import com.vidiun.vdpfl.controller.media.LiveStreamCommand;
	import com.vidiun.vdpfl.model.ConfigProxy;
	import com.vidiun.vdpfl.model.LayoutProxy;
	import com.vidiun.vdpfl.model.SequenceProxy;
	import com.vidiun.vdpfl.model.type.NotificationType;
	
	import org.osmf.media.MediaPlayerState;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.mediator.Mediator;

	/**
	 * Mediator for the on-video buttons layer. 
	 * @author Hila
	 * 
	 */	
	public class ScreensMediator extends Mediator
	{
		public static const NAME:String = "ScreensMediator";
		
		public static const VDP_STARTED:String = "vdpStarted";
		public static const VDP_PLAYED:String = "vdpPlayed";
		public static const VDP_PAUSED:String = "vdpPaused";
		public static const VDP_ENDED:String = "vdpEnded";
		public static const VDP_CHANGE_PROCESS:String = "vdpChangeProcess";
	
		public var _isInDrag:Boolean;
		
		protected var _state:String;
		private var _screens:Screens;
		private	var layoutProxy: LayoutProxy = ApplicationFacade.getInstance().retrieveProxy( LayoutProxy.NAME ) as LayoutProxy;
		
		public function ScreensMediator( viewComponent:Object=null )
		{
			super( NAME, viewComponent );
			_screens = viewComponent as Screens;
			_screens.initScreens(layoutProxy.vo.screens);

		}
	
		/**
		 * Get the notification about the current status and switch the screens
		 * view accordingly.  
		 */
		override public function handleNotification( note:INotification ):void
		{
			var sequenceProxy : SequenceProxy = facade.retrieveProxy(SequenceProxy.NAME) as SequenceProxy;
			var flashvars : Object = (facade.retrieveProxy(ConfigProxy.NAME) as ConfigProxy).vo.flashvars;
			if (sequenceProxy.vo.isInSequence && note.getName() != NotificationType.PLAYER_PLAY_END)
			{
				_screens.visible = false;
				return;
			}
			switch( note.getName() )
			{
				case NotificationType.READY_TO_PLAY:
				case NotificationType.READY_TO_LOAD:
					//switch to start state
					if (note.getName() == NotificationType.READY_TO_PLAY && flashvars.autoPlay == "true")
					{
						_state = VDP_PLAYED;
					}
					else
					{
						_state = VDP_STARTED;
					}
					renderState();
				break;
				// TODO - replace this with END_ENTRY_SESSION 
				//when the pre/post mechanism is on
				case NotificationType.PLAYER_PLAY_END:
						_screens.visible = true;
						_state = VDP_ENDED;
						renderState();
				break;
				case NotificationType.PLAYER_PAUSED:
					//switch to pause state only if this is not a scrubber dragging
					if(!_isInDrag)
					{
						_state = VDP_PAUSED;
						renderState();
					} 
				break;
				case NotificationType.DO_PLAY:
					//switch to playing state
					_state = VDP_PLAYED;
					renderState();
				break;
				case NotificationType.SCRUBBER_DRAG_END:
					//set the dragging flag to false
					_isInDrag = false;
				break;
				case NotificationType.SCRUBBER_DRAG_START:
					//set the dragging flag to true
					_isInDrag = true;
				break;
				case NotificationType.LIVE_ENTRY:
					_screens.visible = false;
				break;
				case LiveStreamCommand.LIVE_STREAM_READY:
					_screens.visible = true;
				break;
				case NotificationType.PLAYER_STATE_CHANGE:
					if(note.getBody() == MediaPlayerState.PAUSED)
					{
						_screens.visible = true;
					}
					else if (note.getBody() == MediaPlayerState.PLAYING)
					{
						_state = VDP_PLAYED;
						renderState();
					}
				break;
				case NotificationType.CHANGE_MEDIA_PROCESS_STARTED:
					_state=VDP_CHANGE_PROCESS;
					renderState();
				break;
			}
		}
		
		/**
		 * Command the screen view to switch to a state
		 */
		protected function renderState():void
		{
			_screens.changeState(_state);
		}
		
		override public function listNotificationInterests():Array
		{
			return [
					NotificationType.READY_TO_PLAY,
					NotificationType.READY_TO_LOAD,
					NotificationType.PLAYER_PLAY_END,
					NotificationType.PLAYER_PAUSED,
					NotificationType.DO_PLAY,
					NotificationType.SCRUBBER_DRAG_END,
					NotificationType.SCRUBBER_DRAG_START,
					LiveStreamCommand.LIVE_STREAM_READY,
					NotificationType.LIVE_ENTRY, 
					NotificationType.PLAYER_STATE_CHANGE,
					NotificationType.CHANGE_MEDIA_PROCESS_STARTED
				   ];
		}
	}
}