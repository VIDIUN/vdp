package com.vidiun.vdpfl.controller
{
	import com.vidiun.vdpfl.model.ConfigProxy;
	import com.vidiun.vdpfl.model.ExternalInterfaceProxy;
	import com.vidiun.vdpfl.model.FuncsProxy;
	import com.vidiun.vdpfl.model.LayoutProxy;
	import com.vidiun.vdpfl.model.MediaProxy;
	import com.vidiun.vdpfl.model.PlayerStatusProxy;
	import com.vidiun.vdpfl.model.SequenceProxy;
	import com.vidiun.vdpfl.model.ServicesProxy;
	import com.vidiun.vdpfl.model.type.NotificationType;
	import com.vidiun.vdpfl.util.Functor;
	import com.vidiun.vdpfl.view.CuePointsMediator;
	import com.vidiun.vdpfl.view.RootMediator;
	import com.vidiun.vdpfl.view.controls.AlertMediator;
	
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.command.SimpleCommand;

	/**
	 * This class is responsible for pre-initialization activities. 
	 */	
	public class StartupCommand extends SimpleCommand
	{
		/**
		 * Register all Proxies and Mediators before calling Application initialization  
		 * @param note
		 */		
		override public function execute(notification:INotification):void
		{
			//trace("StartupCommand - execute - notification: " + notification.getBody());
			
			//we set the current flashvar first and override them with stage flashvars if needed
			facade.registerProxy( new ConfigProxy( (notification.getBody()).root.loaderInfo.parameters) ); //register the config proxy
			facade.registerProxy( new ServicesProxy() ); //register the services proxy
			facade.registerProxy( new LayoutProxy() ); //register the layout proxy
			facade.registerProxy( new MediaProxy() ); //register the media proxy
			facade.registerProxy( new SequenceProxy() );
			facade.registerProxy( new ExternalInterfaceProxy() ); //register the external interface proxy
			facade.registerProxy( new PlayerStatusProxy()); 
			facade.registerMediator(new CuePointsMediator() );
			Functor.globalsFunctionsObject = new FuncsProxy(); 
			
			//register the first view mediator to non other then the root mediator
            facade.registerMediator( new RootMediator( (notification.getBody()).root ) );
            facade.registerMediator(new AlertMediator());
            //send notification to start the macro command process
            sendNotification( NotificationType.INITIATE_APP );
		}

	}
}