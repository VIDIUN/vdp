package com.vidiun.vdpfl.controller
{
	import com.vidiun.config.VidiunConfig;
	import com.vidiun.vdpfl.ApplicationFacade;
	import com.vidiun.vdpfl.model.ConfigProxy;
	import com.vidiun.vdpfl.model.MediaProxy;
	import com.vidiun.vdpfl.model.ServicesProxy;
	import com.vidiun.vdpfl.model.strings.MessageStrings;
	import com.vidiun.vdpfl.model.type.DebugLevel;
	import com.vidiun.vdpfl.model.type.SourceType;
	import com.vidiun.vdpfl.model.type.StreamerType;
	import com.vidiun.vdpfl.model.vo.ConfigVO;
	import com.vidiun.vdpfl.util.URLUtils;
	import com.vidiun.vdpfl.view.RootMediator;
	import com.vidiun.vo.VidiunMediaEntry;
	
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.command.SimpleCommand;

	/**
	 * This class syncronises between flash application parameters and parameters passed
	 * by a loading application, and saved all parameters to the config proxy. 
	 */	
	public class SaveFVCommand extends SimpleCommand
	{
		/**
		 * Set the flashvars into the Config Proxy
		 * @param note
		 * 
		 */		
		override public function execute(note:INotification):void
		{
			var mediaProxy : MediaProxy = facade.retrieveProxy( MediaProxy.NAME ) as MediaProxy;
			
			var config:ConfigProxy = facade.retrieveProxy(ConfigProxy.NAME) as ConfigProxy;
			var flashvars:Object = (config.getData() as ConfigVO).flashvars;
			// these are the main application (may be a loader) parameters (flashvars)
			
			var rm:RootMediator = facade.retrieveMediator(RootMediator.NAME) as RootMediator;
			var prop:String;
			
			
			
			
			// go over the flashvars that passed from any Flex/Flash Container, set or override as needed.
			// read the flashvars from a main container (an application which loaded vdp)
			var o:Object = rm.root["flashvars"]; 
			for(prop in o)
				flashvars[prop] = o[prop];
			

			//set all the flashvars to the Config VO
			(config.getData() as ConfigVO).flashvars = flashvars;

			// instantiate a the MessageStrings once we have the flashvars object  			
//			new MessageStrings(flashvars);
			MessageStrings.init(flashvars);
			
			if (!flashvars.httpProtocol)
			{
				var url:String = rm.root.loaderInfo.url;
				flashvars.httpProtocol = URLUtils.isHttpURL(url) ? URLUtils.getProtocol(url) : "http";  				
			}
			
			// if mediaProtocol wasnt specified implicitly and we are using http delivery use the httpProtcol
			if (!flashvars.mediaProtocol && flashvars.streamerType != StreamerType.RTMP && flashvars.streamerType != StreamerType.LIVE)
				flashvars.mediaProtocol = flashvars.httpProtocol;
			
			
			if (flashvars.httpProtocol.indexOf("://") == -1)
				flashvars.httpProtocol += "://";		
			
			
			//backward compatibility in old wrong syntax
			if(flashvars.referer && !flashvars.referrer ) flashvars.referrer = flashvars.referer;
			
			//set application flashvars to be the global flashvars
			rm.root["flashvars"] = flashvars; 
			rm.setBufferAnimation();
			//create the vidiun client by passing it the configuration object base on the flashvars
			setVidiunClientConfig( flashvars );
			

			if(flashvars.externalInterfaceDisabled == "false" || flashvars.externalInterfaceDisabled == "0")
			{
				if(!flashvars.jsCallBackReadyFunc){
					flashvars.jsCallBackReadyFunc = "jsCallbackReady";
				}
			} 
			
			if(flashvars.fileSystemMode == "true" || flashvars.fileSystemMode == "1" )
			{
				flashvars.fileSystemMode = true;
			}
			else
			{
				flashvars.fileSystemMode = false;
			}
			
			if(flashvars.disableOnScreenClick == "true" || flashvars.disableOnScreenClick == "1")
			{
				flashvars.disableOnScreenClick = true;
			}
			else
			{
				flashvars.disableOnScreenClick = false;
			}
				
			//create a new Media Entry if not exist
			if(!mediaProxy.vo.entry)
				mediaProxy.vo.entry = new VidiunMediaEntry();
					
			//set the entryId
			mediaProxy.vo.entry.id=flashvars.entryId;

			ApplicationFacade.getInstance().debugMode = (flashvars.debugMode == "true") ?  true : false;
			ApplicationFacade.getInstance().debugLevel = (flashvars.debugLevel) ?  flashvars.debugLevel : DebugLevel.LOW;
			
			if(!flashvars.aboutPlayer)	
				flashvars.aboutPlayer= "About Vidiun's Open Source Video Player";
			
			if(!flashvars.aboutPlayerLink)
				flashvars.aboutPlayerLink= "http://corp.vidiun.com/technology/video_player";
			
				
			if(!flashvars.sourceType)
				flashvars.sourceType = SourceType.ENTRY_ID;
							
			if(!flashvars.streamerType)
				flashvars.streamerType = StreamerType.HTTP;
			
			if (!flashvars.getCuePointsData || flashvars.getCuePointsData=="true")
			{
				flashvars.getCuePointsData="true";
			}
		}
		
		
		private function setVidiunClientConfig( flashvars : Object ) : void
		{
			var vidiunConfig : VidiunConfig = new VidiunConfig();
			
			if(flashvars.vs) vidiunConfig.vs = flashvars.vs;
			if(flashvars.partnerId) vidiunConfig.partnerId = flashvars.partnerId;
			// when VDP starts using a newer as3flexclient...
			if(flashvars.httpProtocol) vidiunConfig.protocol = flashvars.httpProtocol; 
			if(flashvars.host) vidiunConfig.domain = flashvars.host; 
//			if(flashvars.host) vidiunConfig.domain = flashvars.httpProtocol + flashvars.host; //TODO: Check if i need to accept the 0,1,2,3 or it's deprecated 
			if(flashvars.srvUrl) vidiunConfig.srvUrl = flashvars.srvUrl; 
			
			vidiunConfig.clientTag = "vdp:" + (facade as ApplicationFacade).vdpVersion; //set the clientTag to the current version on the vdp
			if(flashvars.clientTag) vidiunConfig.clientTag += ","+flashvars.clientTag;//if clientTag passed from flashvars concat it to the clientTag as well
			
			var serviceProxy:ServicesProxy  = facade.retrieveProxy(ServicesProxy.NAME) as ServicesProxy;
			serviceProxy.createClient( vidiunConfig );
		}
		
		
		
	}
}