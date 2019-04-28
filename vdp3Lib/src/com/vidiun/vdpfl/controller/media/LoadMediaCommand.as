package com.vidiun.vdpfl.controller.media
{
	import com.vidiun.vdpfl.model.ConfigProxy;
	import com.vidiun.vdpfl.model.LayoutProxy;
	import com.vidiun.vdpfl.model.MediaProxy;
	import com.vidiun.vdpfl.model.PlayerStatusProxy;
	import com.vidiun.vdpfl.model.SequenceProxy;
	import com.vidiun.vdpfl.model.ServicesProxy;
	import com.vidiun.vdpfl.model.strings.MessageStrings;
	import com.vidiun.vdpfl.model.type.EnableType;
	import com.vidiun.vdpfl.model.type.NotificationType;
	import com.vidiun.vdpfl.model.type.SourceType;
	import com.vidiun.vdpfl.model.type.StreamerType;
	import com.vidiun.vdpfl.plugin.Plugin;
	import com.vidiun.vo.VidiunLiveStreamEntry;
	import com.vidiun.vo.VidiunMixEntry;
	
	import flash.events.Event;
	
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.command.AsyncCommand;
	
	/**
	 * LoadMediaCommand is responsible for loading a media entry. 
	 */
	public class LoadMediaCommand extends AsyncCommand
	{	
		
		private var _flashvars : Object;
		private var _mediaProxy : MediaProxy;
		
		/**
		 * In case the sourceType of the media is not an entryId, the command constructs the url from which to load the media.
		 * In case the sourceType is entryId, the command checks for the desired flavorId (a specific quality of the desired video) and initiates the
		 * load of the video.
		 * @param notification
		 * 
		 */		
		override public function execute(notification:INotification):void
		{	
			_flashvars = (facade.retrieveProxy( ConfigProxy.NAME ) as ConfigProxy).vo.flashvars;
			_mediaProxy = (facade.retrieveProxy( MediaProxy.NAME ) as MediaProxy);
			var serviceProxy : ServicesProxy = (facade.retrieveProxy( ServicesProxy.NAME ) as ServicesProxy);
			var layoutProxy : LayoutProxy = (facade.retrieveProxy( LayoutProxy.NAME ) as LayoutProxy);
			
			var url : String;
			var singleVideoClipperFlavor : String = '1'; //Video (not a Mix)
			
			switch(_flashvars.sourceType)
			{
				case SourceType.F4M: // If the entry is a manifest url
					url = _mediaProxy.vo.entry.id;
					break;
				case SourceType.URL ://if the entry is URL
					if(_mediaProxy.vo.deliveryType !=  StreamerType.LIVE)
						url = _mediaProxy.vo.entry.id;
					else
						url = _flashvars.streamerUrl + "/" + _mediaProxy.vo.entry.id;
					break;
				case SourceType.ENTRY_ID ://if the entry is an entryId
					url = _mediaProxy.vo.entry.dataUrl;
					var flavorIndex:int;
					var preferedFlavorBR:int = _mediaProxy.vo.preferedFlavorBR;
					var selectedFlavorId:String = _mediaProxy.vo.selectedFlavorId;
					var foundFlavorBR:int = 0;
					var foundFlavorId : String = (selectedFlavorId && selectedFlavorId != "" && selectedFlavorId!= "-1") ? selectedFlavorId : null;
					
					if(_mediaProxy.vo && _mediaProxy.vo.vidiunMediaFlavorArray)
					{
						var dif : Number = preferedFlavorBR;

						for(var i:int=0;i<_mediaProxy.vo.vidiunMediaFlavorArray.length;i++)//this checks the flavorId at the vidiunMediaFlavorArray
						{
							// if a selected flavor was set (e.g. vmc preview via flashvars) search for it
							if (selectedFlavorId)
							{
								if (selectedFlavorId == _mediaProxy.vo.vidiunMediaFlavorArray[i].id)
								{
									foundFlavorBR = _mediaProxy.vo.vidiunMediaFlavorArray[i].bitrate;
									break;
								}
							}
								// if a prefered bitrate is specified search for the most closest bitrate (lower or equal)
							else if (preferedFlavorBR != 0) 
							{
								var b:Number = _mediaProxy.vo.vidiunMediaFlavorArray[i].bitrate;
								
								b = Math.round(b/100) * 100;
								if (Math.abs(b - preferedFlavorBR) <= dif )
								{
									dif = Math.abs(b - preferedFlavorBR);
									if (b <= 1.2*preferedFlavorBR )
									{
										
										foundFlavorBR = b;
										foundFlavorId = _mediaProxy.vo.vidiunMediaFlavorArray[i].id;
										flavorIndex = i;
									}
									
								}
							}
							
						}
						
						
						_mediaProxy.vo.selectedFlavorId = foundFlavorId;
						//if a stream was found set it as the new prefered height	
						if (foundFlavorBR)
							_mediaProxy.vo.preferedFlavorBR = int(foundFlavorBR);
						if (preferedFlavorBR <= 0)
						{
							_mediaProxy.vo.selectedFlavorId = null;
						}
						if (_mediaProxy.vo.entry is VidiunLiveStreamEntry)
						{
							_mediaProxy.vo.selectedFlavorId = null;
							_mediaProxy.vo.preferedFlavorBR = 0;
						}
						
					}
					
					break;		
			}
			
			
			if(_mediaProxy.vo.entry && _mediaProxy.vo.entry.id != "-1")
			{
				//_mediaProxy.vo.entry.dataUrl = "http://cdnviddev.vidiun.com/p/1/sp/100/flvclipper/entry_id/00_r4ei4ohges/version/100000"//url;
				_mediaProxy.vo.entry.dataUrl = url;
				
				//In case the entry to view is a VidiunMixEntry, the VidiunMixPlugin must be loaded. The plugin is heavy and should not be loaded 
				//unless needed for an entry. This is the reason that its loading policy is set to "on demand".
				if (_mediaProxy.vo.entry is VidiunMixEntry)
				{
					var plugin:Plugin = Plugin(facade['bindObject']['Plugin_vidiunMix']);
					
					//if we didn't find the Mix plugin we alert the user
					if(!plugin)
					{
						sendNotification(NotificationType.ALERT , {message: MessageStrings.getString('NO_MIX_PLUGIN'), title: MessageStrings.getString('NO_MIX_PLUGIN_TITLE')} );
						return;//return without continue to load media (the user will have to use change media now)
					}	
					else if(plugin && !plugin.content)
					{
						//load the media only after the Mix plugin is ready
						plugin.load();
						plugin.addEventListener( Event.COMPLETE , onPluginReady, false );
						return;
					}
				}
			}
			dispatchMediaReady ();
			commandComplete(); 
		}
		
		private function onPluginReady(e:Event):void
		{
			dispatchMediaReady();
			commandComplete(); 
		}
		/**
		 * This function resolves the subsequent mode of the player. If the entry object was empty or restricted, the player
		 * is considered in status EMPTY and the controls are disabled. If the entry is playable and was successfully loaded, the VDP is in status 
		 * READY.
		 */		
		private function dispatchMediaReady () : void
		{
			if (!_mediaProxy.vo.isMediaDisabled)
			{
				_mediaProxy.shouldWaitForElement = true;
				(facade.retrieveProxy( PlayerStatusProxy.NAME ) as PlayerStatusProxy).dispatchVDPReady();
				sendNotification( NotificationType.MEDIA_READY);
				sendNotification(NotificationType.READY_TO_PLAY);
				sendNotification(NotificationType.ENABLE_GUI, {guiEnabled : true , enableType : EnableType.CONTROLS});
				
				_mediaProxy.configurePlayback();
				
			}
			else
			{
				sendNotification(NotificationType.ENABLE_GUI,{guiEnabled : false , enableType : EnableType.CONTROLS});
				(facade.retrieveProxy( PlayerStatusProxy.NAME ) as PlayerStatusProxy).dispatchVDPEmpty();
				sendNotification(NotificationType.READY_TO_LOAD);
			}
		}
		
	}
}