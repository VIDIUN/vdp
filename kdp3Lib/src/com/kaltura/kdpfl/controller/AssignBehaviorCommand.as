package com.vidiun.vdpfl.controller
{
	import com.vidiun.vdpfl.component.ComponentData;
	import com.vidiun.vdpfl.controller.media.PostSequenceEndCommand;
	import com.vidiun.vdpfl.controller.media.PreSequenceEndCommand;
	import com.vidiun.vdpfl.model.LayoutProxy;
	import com.vidiun.vdpfl.model.SequenceProxy;
	import com.vidiun.vdpfl.model.type.NotificationType;
	import com.vidiun.vdpfl.view.controls.ComboFlavorMediator;
	import com.vidiun.vdpfl.view.controls.FullscreenMediator;
	import com.vidiun.vdpfl.view.controls.FuncWrapper;
	import com.vidiun.vdpfl.view.controls.PlayMediator;
	import com.vidiun.vdpfl.view.controls.ScreensMediator;
	import com.vidiun.vdpfl.view.controls.ScrubberMediator;
	import com.vidiun.vdpfl.view.controls.TimerMediator;
	import com.vidiun.vdpfl.view.controls.VolumeMediator;
	import com.vidiun.vdpfl.view.controls.WatermarkMediator;
	import com.vidiun.vdpfl.view.media.VMediaPlayer;
	import com.vidiun.vdpfl.view.media.VMediaPlayerMediator;
	
	import flash.events.IEventDispatcher;
	import flash.events.MouseEvent;
	
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.command.SimpleCommand;

	/**
	 * This class is responsible for registering command and mediators that "come to life" after the initial load of the skin and ui components.
	 */	
	public class AssignBehaviorCommand extends SimpleCommand
	{
		/**
		 * represents a constant prefix that indicates we should registed the notification 
		 */		
		public static const NOTIFICATION_PREFIX:String = "on_";
		
		/**
		 * Goes over the visual components of the layout and registers their mediators.
		 * @param note
		 */		
		override public function execute(note:INotification):void
		{
			var layoutProxy:LayoutProxy = facade.retrieveProxy(LayoutProxy.NAME) as LayoutProxy;
			
			for each(var comp:ComponentData in layoutProxy.components)
			{
				//register mediator if needed
				switch(comp.className)
				{
					case "VMediaPlayer":
						facade.registerMediator( new VMediaPlayerMediator( VMediaPlayerMediator.NAME , comp.ui as VMediaPlayer ) );
					break;
					case "VScrubber":
						facade.registerMediator( new ScrubberMediator(comp.ui) );
					break;
					case "VTimer":
						facade.registerMediator( new TimerMediator(comp.ui) );
					break;
					case "VVolumeBar":
						facade.registerMediator( new VolumeMediator( comp.ui ) );
					break;
					case "VFlavorComboBox":
						facade.registerMediator( new ComboFlavorMediator( comp.ui ) );
					break
					case "Screens":
						facade.registerMediator( new ScreensMediator( comp.ui ) );
					break;
					case "Watermark":
						facade.registerMediator( new WatermarkMediator( comp.ui ) );
					break;
				}
				
				//If the component has a "command" attribute, register a special mediator for said component.
				switch(comp.attr["command"])
				{
					case "play":
						facade.registerMediator(new PlayMediator(comp.ui));
					break;
					case "fullScreen":
						facade.registerMediator(new FullscreenMediator(comp.ui));
					break;
				}
				//If the component has a "vClick" attribute, register a function to be executed when the component is clicked
				if(comp.attr["vClick"])
				{
					var fw:FuncWrapper = new FuncWrapper();
					fw.registerToEvent(comp.ui as IEventDispatcher, MouseEvent.CLICK, comp.attr["vClick"]);
				}
				
				for (var att : String in comp.attr)
				{
					if (att.indexOf("vevent_") != -1)
					{
						var eventFW:FuncWrapper = new FuncWrapper();
						eventFW.registerToEvent(comp.ui as IEventDispatcher, att.replace("vevent_", ""), comp.attr[att]);
					}
					//register to notification
					else if (att.indexOf(NOTIFICATION_PREFIX)==0) 
					{
						var notificationFW:FuncWrapper = new FuncWrapper();
						notificationFW.registerToNotification(att.substr(NOTIFICATION_PREFIX.length, att.length-NOTIFICATION_PREFIX.length), comp.attr[att]);
						facade.registerMediator(notificationFW);
					}
				}
			}
			
			facade.registerCommand( NotificationType.PRE_SEQUENCE_COMPLETE , PreSequenceEndCommand );

			facade.registerCommand( NotificationType.POST_SEQUENCE_COMPLETE , PostSequenceEndCommand );
			
			facade.registerCommand( NotificationType.MID_SEQUENCE_COMPLETE , MidSequenceEndCommand );
				
			//dispacth layout ready
			sendNotification(NotificationType.LAYOUT_READY);
		}	
	}
}