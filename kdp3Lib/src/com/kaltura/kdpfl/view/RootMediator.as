package com.vidiun.vdpfl.view
{
	import com.vidiun.vdpfl.model.type.NotificationType;
	import com.vidiun.vdpfl.view.controls.BufferAnimation;
	import com.vidiun.vdpfl.view.controls.BufferAnimationMediator;
	import com.vidiun.vdpfl.view.controls.VTrace;
	
	import flash.display.DisplayObjectContainer;
	import flash.display.Loader;
	import flash.display.StageDisplayState;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.utils.getQualifiedClassName;
	
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.mediator.Mediator;

	/**
	 * Mediator for the root component of the VDP. 
	 * @author Hila
	 * 
	 */	
	public class RootMediator extends Mediator
	{
		public static const NAME:String = 'stageMediator';
		
		private var _vdp3Preloader : BufferAnimation;
		
		/**
		 * Constructor 
		 * @param viewComponent
		 * 
		 */		
		public function RootMediator(viewComponent:Object=null)
		{
			super(NAME, viewComponent);
			try{
				if(root.stage == root.parent)
				{
					root.stage.addEventListener(Event.RESIZE, onResize);
				}
				else
				{
					root.parent.addEventListener(Event.RESIZE, onResize);
				}
			}
			catch (e : Error)
			{
				root.dispatchEvent(new ErrorEvent(ErrorEvent.ERROR,true, false,"Parent is inaccessible"));
			}
		}
		/**
		 * Handle the notification in root interests 
		 * @param note
		 * 
		 */		
		override public function handleNotification(note:INotification):void
		{
			//trace("StageMediator - handleNotification - note.getName(): " + note.getName() );
			
			switch(note.getName())
			{
				case NotificationType.PLAYER_DIMENSION_CHANGE:
					onResize();
					break;
				case NotificationType.CLOSE_FULL_SCREEN:
					root.stage.displayState=StageDisplayState.NORMAL;
					break;
				case NotificationType.OPEN_FULL_SCREEN:
					try{
						root.stage.displayState=StageDisplayState.FULL_SCREEN;
					} catch(e:Error)
					{
						VTrace.getInstance().log("fullscrren action failed. make sure you have flash tag 'allowFullScreen' with value 'true' in your embed code");
						//trace("fullscrren action failed. make sure you have flash tag 'allowFullScreen' with value 'true' in your embed code");
					}
					break;
			}
		}
		
		/**
		 * Add views - Register mediators
		 */		
		override public function onRegister():void
		{
			onResize();
		}
		
		public function setBufferAnimation():void {
			if (root["flashvars"] && (!root["flashvars"].hasOwnProperty("disablePlayerSpinner") || root["flashvars"]["disablePlayerSpinner"]!="true"))
			{
				//TODO: add this child to the player continer so it will be in it's center and not in the root center
				_vdp3Preloader = new BufferAnimation();
				root.addChild(_vdp3Preloader);
				facade.registerMediator(new BufferAnimationMediator(_vdp3Preloader));
			}
		}
	
		/**
		 * The notification that the root need to listen to 
		 * @return 
		 * 
		 */		
		override public function listNotificationInterests():Array
		{
			return [
				NotificationType.PLAYER_DIMENSION_CHANGE,
				NotificationType.CLOSE_FULL_SCREEN,
				NotificationType.OPEN_FULL_SCREEN
			];
		}
		
		/**
		 * When the root is resize we need to whom needed resize  
		 * @param event
		 * 
		 */		
		public function onResize( event : Event = null ):void
		{
			var size : Object
			//if this is standalone application the root parent is the stage so resize by it
			if(root.stage && root.parent && root.stage == root.parent)
			{
				size = {width:root.stage.stageWidth, height:root.stage.stageHeight};
			}
			else
			{
				//if the VDP was loaded using a flex application SWFLoader get its dimensions
				if(root.parent && root.parent is Loader &&
					getQualifiedClassName(root.parent.parent).split("::")[1] == "SWFLoader")
				{
					size = {width:root.parent.parent.width, height:root.parent.parent.height};
				}
				else
				{
					// use the requested dimensions of the VDP3 as set by the loading application	 
					size = {width:root.width,height:root.height};
				}
			}
			
			if( _vdp3Preloader && root.contains(_vdp3Preloader) && (!_vdp3Preloader.width || !_vdp3Preloader.height) )
			{
				_vdp3Preloader.width = size.width;
				_vdp3Preloader.height = size.height;
			} 
			//notify whom needed that the root size have been changed
			
			//trace("SIZE ", size.width, size.height);
			sendNotification(NotificationType.ROOT_RESIZE, size);
		}
		
		
		
		/**
		 * Get a hold of the viewComponents that this class holds 
		 * @return 
		 * 
		 */		
		public function get root() : DisplayObjectContainer{
			return viewComponent as DisplayObjectContainer;
		}
		
		
	}
}