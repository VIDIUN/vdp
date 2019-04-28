package com.vidiun.vdpfl.controller
{
	import com.vidiun.VidiunClient;
	import com.vidiun.commands.MultiRequest;
	import com.vidiun.commands.session.SessionStartWidgetSession;
	import com.vidiun.commands.uiConf.UiConfGet;
	import com.vidiun.commands.widget.WidgetGet;
	import com.vidiun.delegates.uiConf.UiConfGetDelegate;
	import com.vidiun.delegates.widget.WidgetGetDelegate;
	import com.vidiun.errors.VidiunError;
	import com.vidiun.events.VidiunEvent;
	import com.vidiun.vdpfl.model.ConfigProxy;
	import com.vidiun.vdpfl.model.LayoutProxy;
	import com.vidiun.vdpfl.model.MediaProxy;
	import com.vidiun.vdpfl.model.ServicesProxy;
	import com.vidiun.vdpfl.model.type.SourceType;
	import com.vidiun.vo.VidiunLiveStreamBitrate;
	import com.vidiun.vo.VidiunStartWidgetSessionResponse;
	import com.vidiun.vo.VidiunUiConf;
	import com.vidiun.vo.VidiunWidget;VidiunLiveStreamBitrate;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import com.vidiun.vo.VidiunLiveStreamEntry;VidiunLiveStreamEntry;
	import com.vidiun.vo.VidiunLiveStreamBitrate; VidiunLiveStreamBitrate;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.command.AsyncCommand;
	import org.puremvc.as3.patterns.proxy.Proxy;
	import com.vidiun.vo.VidiunFlavorAsset;
	import mx.utils.UIDUtil;
	import fl.core.UIComponent;
	import flash.events.ErrorEvent;
	import com.vidiun.vdpfl.util.URLUtils;
	import com.vidiun.vdpfl.plugin.PluginManager;
	import flash.sampler.DeleteObjectSample;
	import com.vidiun.vo.VidiunMetadataFilter;
	import com.vidiun.types.VidiunMetadataObjectType;
	import com.vidiun.commands.metadata.MetadataList;
	import com.vidiun.vo.VidiunMetadataListResponse;
	import com.vidiun.vdpfl.model.type.NotificationType;
	import com.vidiun.vo.VidiunMetadata;
	import com.vidiun.types.VidiunMetadataStatus;
	import com.vidiun.vo.VidiunMetadataProfile;
	import com.vidiun.types.VidiunMetadataProfileStatus;
	import com.vidiun.net.VidiunCall;
	import com.vidiun.commands.metadata.MetadataGet;
	import com.vidiun.vo.VidiunFilter;
	import com.vidiun.types.VidiunMetadataOrderBy;
	import com.vidiun.vo.VidiunFilterPager;
	import com.vidiun.vdpfl.view.controls.ToolTipManager;
	import com.yahoo.astra.fl.managers.AlertManager;
	import com.vidiun.vdpfl.view.controls.AlertMediator;
	import com.vidiun.vdpfl.model.strings.MessageStrings;
	import flash.utils.getQualifiedClassName;
	import com.yahoo.astra.containers.formClasses.RequiredIndicator;
	import com.vidiun.vdpfl.view.controls.VTrace;
	import org.osmf.utils.OSMFSettings;
	import com.vidiun.vdpfl.model.ExternalInterfaceProxy;
	import flash.external.ExternalInterface;
	import flash.net.SharedObject;
	import com.vidiun.vdpfl.model.type.StreamerType;

	/**
	 * This class handles the retrieval of the player groundwork - the VS (Vidiun Session),VWidget and the uiConf.xml
	 * @author Hila
	 * 
	 */
	public class LoadConfigCommand extends AsyncCommand implements IResponder
	{
		public static const LOCAL : String = "local";
		public static const INJECT : String = "inject";
		public static const DEFAULT_BW_INTERVAL:int = 1800;
		

		
		private var _configProxy : ConfigProxy;
		private var _layoutProxy : LayoutProxy;
		private var _mediaProxy : MediaProxy;
		private var _flashvars : Object;
		private var _vc : VidiunClient;
		private var _numPreInitPlugins : Number;
		
		/**
		 * Function tries to retrieve the uiconf from the VDP embedded data.
		 * @return true if embedded data was used and we can skip requesting the widget and uiconf from the server 
		 * 
		 */
		private function useEmbeddedData():Boolean
		{
			var embeddedWidgetData:String = _flashvars['embeddedWidgetData'];
			if (embeddedWidgetData)
			{
				var embeddedXML:XML = new XML(embeddedWidgetData);
				var xml:String = "<result>" + embeddedXML.result[1].toString() + "</result>";

				var getUiconfXml:XML = new XML(xml);
				var getUiconfDelegate:UiConfGetDelegate = new UiConfGetDelegate(null, null);
					 
				var uiConf:VidiunUiConf = getUiconfDelegate.parse(getUiconfXml);
					
				// if flashvars requested a uiconf different from the one embedded check if need to fetch uiconf from server
				if (_flashvars.uiConfId && _flashvars.uiConfId != uiConf.id)
					return false;
					
				_configProxy.vo.vuiConf = uiConf;
					
				xml = "<result>" + embeddedXML.result[0].toString() + "</result>";
				var getWidgetXml:XML = new XML(xml);
				var getWidgetDelegate:WidgetGetDelegate = new WidgetGetDelegate(null, null);
				var vw:VidiunWidget = getWidgetDelegate.parse(getWidgetXml);
				_configProxy.vo.vw = vw;
		
				return true;
			}
			
			return false;
		}
		
		/**
		 * This function uses the Vidiun Client to retrieve the VS, Widget data and UIConf from the Vidiun CMS.
		 * @param notification
		 * 
		 */		
		override public function execute(notification:INotification):void
		{
			//trace("LoadConfigCommand - execute - notification: " + notification);
			_configProxy = facade.retrieveProxy( ConfigProxy.NAME ) as ConfigProxy;
			_layoutProxy = facade.retrieveProxy( LayoutProxy.NAME ) as LayoutProxy;
			_mediaProxy = facade.retrieveProxy( MediaProxy.NAME ) as MediaProxy;

			_flashvars = _configProxy.vo.flashvars;
			
							
			// if the wrapper embedded data was valid we can immidiately start working on the layout
			// without sending a get widget request.
			// in this case an flashvar given entry will be fetched in a later stage since we dont
			// want to wait for a multirequest now but rather show the ui asap
			var usedEmbeddedData:Boolean = useEmbeddedData();
			if (usedEmbeddedData)
			{
				if (_flashvars.entryId && _flashvars.entryId != "-1")					
					_mediaProxy.vo.entry.id = _flashvars.entryId;
					
				_flashvars.widgetId = _configProxy.vo.vw.id;
				fetchLayout();
				return;
			}
			
			if(_flashvars.widgetId == null)
			{
				_configProxy.vo.vw = new VidiunWidget();
				fetchLayout();
				return;
			}	
			
			if(_flashvars.sourceType == SourceType.URL)
			{
				fetchLayout();
				return;
			} 
			
			//get a hold on the vidiun client
			_vc = ( facade.retrieveProxy( ServicesProxy.NAME ) as ServicesProxy ).vidiunClient;
			
			//start a multi request to get session if needed widget and uiconf
			var mr : MultiRequest = new MultiRequest();
				
			//if there is no vs we need to call first to create widget session
			if(!_flashvars.vs)
			{
				var ssws : SessionStartWidgetSession = new SessionStartWidgetSession( _flashvars.widgetId );
				mr.addAction( ssws );
				
				//use the vs result in Start Widget Session in the next 2 calls
				mr.addRequestParam("2:vs","{1:result:vs}");
				mr.addRequestParam("3:vs","{1:result:vs}");
				
			}
			else
			{
				_vc.vs = _flashvars.vs;
			}

			//Get Widget 
			var widgetGet:WidgetGet = new WidgetGet(_flashvars.widgetId);
			mr.addAction( widgetGet );
			
			var uiconfGet : UiConfGet;
			//if we don't have uiconfid on the flashvar try to get it from the getWidget call
			if (_flashvars.uiConfId == undefined)
			{
				uiconfGet = new UiConfGet(NaN);
				if(!_flashvars.vs)
					mr.mapMultiRequestParam(2,"uiConfId",3,"id");
				else
					mr.mapMultiRequestParam(1,"uiConfId",2,"id");
			}
			else //we have the uiconfid in flashvars
			{
				uiconfGet = new UiConfGet(int(_flashvars.uiConfId));
			}
			
			mr.addAction( uiconfGet );
 	
			
           
			mr.addEventListener( VidiunEvent.COMPLETE , result );
			mr.addEventListener( VidiunEvent.FAILED , fault );
		
			_vc.post( mr );
			/////////////////////////////////////////////	
		}
		
		/**
		 * Response to successful call to the Vidiun CMS. This function assigns the result to the value objects used
		 * by the PureMVC components comprising the player.
		 * @param data - object returned by the server.
		 * 
		 */		
		public function result(data:Object):void
		{
			var i : int = 0;
			var arr : Array = data.data as Array;
			
			var flashvars : Object = (facade.retrieveProxy(ConfigProxy.NAME) as ConfigProxy).vo.flashvars;
			
			//ifd we didn't got the vs from the flashvars we have a result on start widger session
			if(!_vc.vs)
			{
				if(arr[i] is VidiunError || (arr[i].hasOwnProperty("error")))
				{
					++i; //procced anyway
					//TODO: Trace, Report, and notify the user
					VTrace.getInstance().log("Error in Start Widget Session");
					sendNotification( NotificationType.ALERT , {message: MessageStrings.getString("SERVICE_START_WIDGET_ERROR"), title: MessageStrings.getString("SERVICE_ERROR")} );
				}
				else
				{	
					var vws : VidiunStartWidgetSessionResponse = arr[i++];
					_vc.vs = vws.vs;
				}
			}
			
			if(arr[i] is VidiunError || (arr[i].hasOwnProperty("error")))
			{
				++i; //procced anyway
				//TODO: Trace, Report, and notify the user
				trace("Error in Get Widget");
				sendNotification( NotificationType.ALERT , {message: MessageStrings.getString("SERVICE_GET_WIDGET_ERROR"), title: MessageStrings.getString("SERVICE_ERROR")} );
			}
			else
			{
				//set the config proxy with the new vidiun widget
				var vw : VidiunWidget = arr[i++];
				_configProxy.vo.vw = vw;
			}
		
			if(arr[i] is VidiunError || (arr[i].hasOwnProperty("error")))
			{
				++i; //procced anyway
				//TODO: Trace, Report, and notify the user
				VTrace.getInstance().log("Error in Get UIConf");
				sendNotification( NotificationType.ALERT , {message: MessageStrings.getString("SERVICE_GET_UICONF_ERROR"), title: MessageStrings.getString("SERVICE_ERROR")} );
			}
			else
			{
				//set the config proxy with the new vidiun uiconf 
				var vuiConf : VidiunUiConf = arr[i++];
				_configProxy.vo.vuiConf = vuiConf;
			}
				
			

			fetchLayout();			
		}
		/**
		 * Fault handler. 
		 * @param data - error object returned by the server.
		 * 
		 */		
		public function fault(data:Object):void
		{
			VTrace.getInstance().log("LoadConfigCommand==>fault");
			commandComplete(); //execute next command
		}
		
		
		/**
		 *  Resolve the retrieval of the layout xml file. It can be injected into the VDP, loaded from an external source, or it may already
		 * have been retrieved from the CMS in the multi-request created by the <code>execute</code> function.
		 * 
		 */		
		public function fetchLayout():void
		{
			//if we inject the xml through the init( vml : XML ) function in vdp3 class 
			//we can setLayout xml right away
			if( _flashvars.vml == INJECT )
			{
				setLayout( _layoutProxy.vo.layoutXML );
			}
			else if( _flashvars.vml == LOCAL ) //if we want to load local XML (DEBUG USE ONLY)
			{
				var loader : URLLoader;
				
				if(_flashvars.vmlPath == null) //if we don't have vmlPath in flashvars
					_flashvars.vmlPath = 'config.xml'
					
				
				loader = new URLLoader();
				loader.addEventListener(Event.COMPLETE, XMLLoaded ); 
				loader.addEventListener(IOErrorEvent.IO_ERROR , onIOError);
				loader.load( new URLRequest(_flashvars.vmlPath) );
				//Only after XML was loaded we move on...
			}
			else //set the layout proxy with the new uiconf xml
			{
				setLayout(XML(_configProxy.vo.vuiConf.confFile));
			}
		}
		
		//PRIVATE FUNCTIONS
		/////////////////////////////////////////////
		
		
		private function onIOError( event : Event ) : void
		{
			
		}
		
		/**
		 * Add a plugin xml (e.g. <Plugin id=tremor width="100%" ... />) into the given layout
		 * The insert position in set using the relativeTo and position parameres.
		 * If both attributes are ommited the plugin is prepended to the first child of the layout.
		 * This would be probably be a non visual plugin
		 * Builtin components can be added as well by specfying a className attribute such as Button, Label etc.. 
		 * @param layoutXML the whole vdp layout
		 * @param pluginXML the plugin xml including the relativeTo and position attributes
		 * 
		 */
		private function appendPluginToLayout(layoutXML:XML, pluginXML:XML):void
		{
			//trace(pluginXML.toXMLString());
			
			var relativeTo:String = pluginXML.@relativeTo; 
			var position:String = pluginXML.@position; 
			
			var parentNode:XML;
			
			if (relativeTo)
			{
				var className:String = pluginXML.@className;
				if (className)
				{
					pluginXML.setName(className);
					delete (pluginXML.@className);	
				}
				
				delete (pluginXML.@relativeTo);
				delete (pluginXML.@position);

				var xml:XML = layoutXML.descendants().(attribute("id") == relativeTo)[0];
				if (xml == null)
				{
					VTrace.getInstance().log("ERROR: plugin ", pluginXML.@id, " - couldnt find relativeTo component " + relativeTo);
				}
				else if (position == "before")
				{
					parentNode = xml.parent();
					parentNode.insertChildBefore(xml, pluginXML);
				}
				else if (position == "after")
				{
					parentNode = xml.parent();
					parentNode.insertChildAfter(xml, pluginXML);
				}
				else if (position == "firstChild")
				{
					xml.prependChild(pluginXML);
				}
				else if (position == "lastChild")
				{
					xml.appendChild(pluginXML);
				}
				else {
					VTrace.getInstance().log("ERROR: plugin ", pluginXML.@id, " - invalid position " + position);
				}
			}
			else
			{
				parentNode = layoutXML.children()[0];
				parentNode.prependChild(pluginXML);
			}
		}
		
		/**
		 * Append plugins to the layout from flashvars and plugins segment within the layout xml.
		 * Look for all flashvars with .plugin attribute and treat them as plugins
		 * The id of the given plugin is the flashvars prefix
		 * Insert all children of the <plugins> segment of the layout xml as well
		 * @param layoutXML the whole vdp layout
		 * 
		 */
		private function appendPluginsToLayout(layoutXML:XML):void
		{
			for each(var pluginXML:XML in layoutXML..plugins.children())
			{
				appendPluginToLayout(layoutXML, pluginXML);
			}
			
			for(var pluginName:String in _flashvars)
			{
				var pluginParams:Object = _flashvars[pluginName];
				if (pluginParams.hasOwnProperty('plugin'))
				{
					pluginXML  = new XML("<Plugin/>");
					pluginXML.@['id'] = pluginName;
					
					//trace("build plugin xml for " + pluginName);
					
					for(var s:String in pluginParams)
						pluginXML.@[s] = pluginParams[s];
						
					appendPluginToLayout(layoutXML, pluginXML);
				}
			}
		}
		
		/**
		 * Converts all flashvars with <code>host.property</code> syntax (e.g. watermark.path) to objects.
		 * 
		 */
		private function buildFlashvarsTree():void
		{
			// assemble list of all dotted vars since we shouldn't change the list while iterting it
			var dottedVars:Array = new Array();
			
			for(var s:String in _flashvars)
			{
				if (s.indexOf(".") >= 0)
					dottedVars.push(s);
			}
				
			for each(s in dottedVars)
			{				
				var subParams:Array = s.split(".");
				var root:* = _flashvars;
				for(var i:int = 0; i < subParams.length - 1; ++i)
				{
					if (!root[subParams[i]])
						root[subParams[i]] = new Object();
					
					root = root[subParams[i]];
				}
				
				root[subParams[i]] = _flashvars[s];
				delete(_flashvars[s]);
			}
		}
		
		/**
		 * Add variables from an XMLList to the flashvars array.
		 * The XMLList is of the form <var key="name" value="value" overrideFlashvar="[true/false]" />
		 * if the variable already appears in flashvars and it wasnt marked as overrideFlashvar="true"
		 * the flashvars original value will persist.
		 * @param layoutXML the layout xml 
		 * @param prefix a dotted prefix to prepend before the variable key name  
		 * 
		 */
		private function addLayoutVars(xmlList:XMLList, prefix:String = ""):void
		{
			// local uiVars overriding the original flashyvars
			for each (var uiVar:XML in xmlList)
			{
				var key:String = prefix + uiVar.@key.toString();
				var value:String = uiVar.@value.toString();
				
				//check if this variable already exists in flashvars and whether it needs to be overriden
				if (!_flashvars.hasOwnProperty(key) || uiVar.@overrideFlashvar == "true")
					_flashvars[key] = value;
			}
		}
		/**
		 * Function which parses an XMLList of key-value XMLs into an object  
		 * @param xmlList XMLList to parse into an object.
		 * @return Object which maps the XMLlist key-value pairs.
		 * 
		 */		
		private function parseKeyValuePairs ( xmlList:XMLList ) : Object
		{
			var uiVarObj : Object = new Object();
			for each (var uiVar:XML in xmlList)
			{
				var key:String = uiVar.@key.toString();
				var value:String = uiVar.@value.toString();
				
				uiVarObj[key] = value;
			}
			return uiVarObj;
		}
		/**
		 * Function which removes dotted flashvars (not UIVars) from the VDP configuration. 
		 * @return 
		 * 
		 */		
		private function removeDottedFlashvars () : void
		{
			for (var key : String in _flashvars)
			{
				if (key.indexOf(".") != -1)
				{
					delete(_flashvars[key]);
				}
			}
		} 
		
		/**
		 * override layout and proxy attributes using flashvars.
		 * Originally dotted variables are now container objects (after calling buildFlashvarsTree).
		 * these parameters override components using their id's as the first part of the flashvar dotted name
		 * if a component wasnt found we try to retrieve a proxy object with the container name (e.g. mediaProxy)   
		 * @param layoutXML the whole vdp layout
		 * 
		 */
		private function overrideAttributes(layoutXML:XML):void
		{
			for(var s:String in _flashvars)
			{
				var fvKeyObject:Object = _flashvars[s];
				if (!(fvKeyObject is String) && !fvKeyObject.hasOwnProperty('plugin'))
				{
					var xml:XML = layoutXML.descendants().(attribute("id") == s)[0];
					if (xml)
					{
						for(var key:String in fvKeyObject)  
							xml.@[key] = fvKeyObject[key]; 
					}
					else
					{
						var proxy:Proxy = facade.retrieveProxy( s ) as Proxy;
						if (proxy)
						{
							try {
								var data:Object = proxy.getData();
								for(key in fvKeyObject)  
									data[key] = fvKeyObject[key];
							}
							catch(e:Error)
							{
								VTrace.getInstance().log("overrideAttributes failed to set attribute ", s, key);
								//trace("overrideAttributes failed to set attribute ", s, key);
							}
						}
					}
				}
			}
		}
		
		/**
		 * Analyzes the layout xml:
		 * 1. Implicitly add the Akamai http-streaming plugin to the player layout, in order to support the <code>hdnetwork</code> streamer type.
		 * 2. Add strings and uiVars sections to flashvars
		 * 3. Add partner data variables from retrieved widget
		 * 4. Convert all flashvars with dot syntax (e.g. watermark.path) to objects 
		 * 5. Append plugins into actual layout from flashvars and plugins section
		 * 6. Parse parameters related to the VDP managers : TooltipManager and AlertMediator
		 * @param xml the layout xml received from either uiconf or local configuration
		 * 
		 */
		private function setLayout(xml:XML):void
		{
			// add a top level layouts node so our searches within the xml will find
			// the layout node itself (for overriding skinPath) and not only its descendants
			xml = new XML("<layouts>" + xml.toString() + "</layouts>");
			
			// if xml...doesnt include plugin with akamaiHD id
			if (xml..Plugin.(attribute("id") == "akamaiHD").length() <= 0) {
				// add the following
				var akamaiPluginTag:XML = <Plugin id="akamaiHD" width="0%" height="0%" includeInLayout="false" loadingPolicy="onDemand" />;
				//xml.layout..VBox.(attribute("id") == "player")[0].prependChild(akamaiPluginTag);
				
				var playerXMLList : XMLList = xml.layout..VBox.(attribute("id") == "player");
				
				if ( playerXMLList.length() )
				{
					playerXMLList[0].prependChild(akamaiPluginTag);
				}
			}
			
			// add the strings section of the layout to the flashvars
			addLayoutVars(xml..strings.children(), "strings.");
			
			//check whether variable which blocks the VDP from accepting plugins/layout definitions passed through the embed code is present
			var uiVars : Object = parseKeyValuePairs( xml..uiVars.children() );
			
			if ( _flashvars.blockExternalInterference || uiVars.blockExternalInterference )
			{
				removeDottedFlashvars();
			}
			
			// add variables from the uiVars section of the layout to the flashvars
			addLayoutVars(xml..uiVars.children());
			
			// add partner data variables from retrieved widget
			var vw:VidiunWidget = _configProxy.vo.vw;
			//vw.partnerData = '<xml><uiVars><var key="pageName" value="my blog post" /><var key="pageUrl" value="http://my.blog.com/blog?article=1234" /></uiVars></xml>';
			
			if (vw && vw.partnerData)
			{
				addLayoutVars(XML(vw.partnerData).uiVars.children());
			}
			
			//if the flashvars say to disable any call to the ExternalInterface API we will do it here
			var extProxy : ExternalInterfaceProxy = facade.retrieveProxy( ExternalInterfaceProxy.NAME ) as ExternalInterfaceProxy;
			//default will be without ExternalInterface. to turn this thing on we will have to get a specific flashvar
			//enabeling it 
			extProxy.vo.enabled = false;
			if(_flashvars.externalInterfaceDisabled == "false" || _flashvars.externalInterfaceDisabled == "0")
			{
				extProxy.vo.enabled = true;
				extProxy.jsCallBackReadyFunc = _flashvars.jsCallBackReadyFunc;
				extProxy.registerVDPCallbacks();
				
				if (_flashvars.jsTraces=="true")
					VTrace.getInstance().jsCallback = true;
			}
			//in this case if external interface enabled will look for referrer, otherwise referrer will be empty
			if (_flashvars.disableReferrerOverride == "true" || !_flashvars.referrer) {
				if (_flashvars.externalInterfaceDisabled == "false" || _flashvars.externalInterfaceDisabled == "0")
				{
					var foundReferer:String = ExternalInterface.call('window.location.href.toString');
					_flashvars.referrer = foundReferer ? foundReferer : "";
					
				}
				else
				{
					_flashvars.referrer = '';			
				}
			}
			
			//default should allow cookies
			if (!_flashvars.allowCookies)
			{
				_flashvars.allowCookies="true";
			}
			
			//determines whether to use enableStageVideo OSMF feature
			if (_flashvars.enableStageVideo && _flashvars.enableStageVideo=="true")
			{
				OSMFSettings.enableStageVideo = true;
			}
			else
			{
				OSMFSettings.enableStageVideo = false;
			}
			
			if (_flashvars.clientDefaultMethod)
			{
				VidiunCall.defaultMethod = _flashvars.clientDefaultMethod;
			}
			
			
			if (_flashvars.twoPhaseManifest && _flashvars.twoPhaseManifest=="true")
			{
				_mediaProxy.vo.isHds = true;
			}
			
			_mediaProxy.vo.deliveryType = _flashvars.streamerType;	
			
			///////////////////////////////////////////////////////////////////////////////
			//////Check if we should load BW detection plugin/////////////////////////////
			///////////////////////////////////////////////////////////////////////////////
			
			//indicates if BW check is required
			var doBWCheck:Boolean;
			//inidicates if we need to perform flavors comparison before BW check (in BW plugin)
			var doConditionalBWCheck:Boolean;
			
			//If BW plugin exist and its loadingPolicy="onDemand", check if we should load it
			var bwPlugin : XMLList = xml..Plugin.(@id=="bitrateDetection");
			if (bwPlugin && bwPlugin.length() && bwPlugin.@loadingPolicy=="onDemand")
			{
				doBWCheck = true;
				//Retrieval of the Bitrate cookie value.
				if (!_flashvars.disableBitrateCookie || _flashvars.disableBitrateCookie=="false")
				{
					var flavorCookie : SharedObject;
					try
					{
						flavorCookie = SharedObject.getLocal("Vidiun");
					}
					catch (e: Error)
					{
						VTrace.getInstance().log("no permissions to access partner's file system");
					}
					
					
					VTrace.getInstance().log("---check if we need BW detection");
					if(flavorCookie && flavorCookie.data.preferedFlavorBR)
					{	
						//interval between bandwidth checks, in seconds
						var bwInterval:int = _flashvars.bwInterval ? _flashvars.bwInterval : DEFAULT_BW_INTERVAL;
						if (bwInterval && flavorCookie.data.timeStamp)
							//check if the flavor cookie was saved in the confiugrable time interval
						{
							var diff:Number = (new Date()).time - flavorCookie.data.timeStamp;
							if (diff <= Number(bwInterval * 1000))
							{
								VTrace.getInstance().log("---bw interval is still valid");
								doBWCheck = false;
							}
						}
						
						if (!doBWCheck)
						{
							//check if the last detected bitrate is still relevant with the current flavor set:
							//if the last playing flavor was the highest available (with 20%  range of difference) then there might be more suitable flaor now
							if (flavorCookie.data.lastHighestBR && (Math.abs(flavorCookie.data.preferedFlavorBR - flavorCookie.data.lastHighestBR))<=(flavorCookie.data.preferedFlavorBR * 0.2))
							{
								VTrace.getInstance().log("---preferredBR was the heighest possible, might need BW check");
								//if the difference between the detected BW and the actual playing BW is too big (more than 50% out of the detected BR)
								//we should perform BW check
								if (flavorCookie.data.detectedBitrate && (0.5 * flavorCookie.data.detectedBitrate)>flavorCookie.data.preferedFlavorBR)
								{
									VTrace.getInstance().log("---difference between detected BR and preferred is too high, do BW check!");
									doConditionalBWCheck = true;
								}
							}
							
							//maybe BW check is not required, save the value from the cookie
							_mediaProxy.vo.preferedFlavorBR = flavorCookie.data.preferedFlavorBR;
						}
						
					}
				}
			}
			
			////////////////////////////////////////////////////////////////////////////////////////////
			
			
			// convert all flashvars with dot syntax (e.g. watermark.path) to objects
			buildFlashvarsTree();

			// append plugins to the layout from flashvars and plugins segment within the layout xml			
			appendPluginsToLayout(xml);
			
			if (doBWCheck || doConditionalBWCheck)
			{
				bwPlugin.@loadingPolicy = "wait";
				VTrace.getInstance().log("---------LOAD BW CHECK PLUGIN-----------");
				//we should load BW plugin, but maybe the detection is still unnecessary, tell the plugin to run check before
				if (doConditionalBWCheck)
				{
					bwPlugin.@runPreCheck = "true";
				}		
			}
			
			// override layout and proxy variables using flashvars
			overrideAttributes(xml);
			 
			_layoutProxy.vo.layoutXML = xml.child(0)[0];
			
			//Parse tooltip manager properties
			parseTooltipManager();
			//Parse AlertManager properties
			parseAlertManager();
			
			//Load plugin with loadingPolicy="preInitialize"
			loadPreInitPlugins ();
			
			
		}
		
		//on vml=local mode if we load the vml localy
		private function XMLLoaded( event : Event) : void
		{
			setLayout(new XML(event.target.data));
		}
		/**
		 * Function to load certain plugins before loading the skin.swf file. Such plugins are identified in the config.xml
		 * by the property <code>loadingPolicy</code> set to <code>preInitialize</code>.
		 * 
		 */		
		private function loadPreInitPlugins () : void
		{
			var layoutXml : XML = _layoutProxy.vo.layoutXML;
			var plugins : XMLList = layoutXml..Plugin.(attribute("loadingPolicy") == "preInitialize");
			
			var uiComponent : UIComponent;
			_layoutProxy.numPreInitPlugins = plugins.length();
			var plugin : XML;
			for ( var i:int=plugins.length()-1; i>=0; i--)
			{
				plugin=plugins[i];
				_layoutProxy.loadPreInitPlugin(plugins[i]);
				delete(plugins[i]);
			}
			
			
			var pm : PluginManager = PluginManager.getInstance();
			pm.updateAllLoaded(preInitPluginsLoaded);
			
		}
		/**
		 * Handler for the preInit plugins load complete.
		 * @param e - event received from the PluginManager class
		 * 
		 */		
		private function preInitPluginsLoaded (e : Event ) : void
		{
			e.target.removeEventListener( PluginManager.ALL_PLUGINS_LOADED , preInitPluginsLoaded );
			commandComplete();
		}
		/**
		 * Function which parses the layout xml tag which belongs tp the Tooltip manager	
		 * 
		 */		
		private function parseTooltipManager () : void
		{
			var layoutXml : XML = _layoutProxy.vo.layoutXML;
			//Only tooltip manager for now..
			var tooltipManagerXml : XML = layoutXml..manager.(attribute("id")=="tooltipManager")[0];
			
			addAttributesToManager (ToolTipManager.getInstance(), tooltipManagerXml);
			
		}
		/**
		 * Function which parses the layout xml tag which belongs to the AlertMediator
		 * 
		 */		
		private function parseAlertManager () : void
		{
			var layoutXml : XML = _layoutProxy.vo.layoutXML;
			//Only tooltip manager for now..
			var alertManagerXML : XML = layoutXml..manager.(attribute("id")=="alertManager")[0];
			
			addAttributesToManager( facade.retrieveMediator(AlertMediator.NAME) as AlertMediator, alertManagerXML );
			
		}
		
		/**
		 * Function which receives an object and an XML tag and parses the xml tag properties into the object. 
		 * @param manager - object that the xml needs to be parsed into.
		 * @param managerXML - the xml tag to be parsed into the object.
		 * 
		 */		
		private function addAttributesToManager (manager : Object, managerXML:XML) : void
		{
			if (managerXML && managerXML.attributes())
			{
				for each (var prop : XML in managerXML.attributes())
				{
					try
					{
						manager[prop.localName()] = managerXML.attribute(prop.localName())[0];
					}
					catch (e: Error)
					{
						if (_flashvars.debugMode=="true")
							VTrace.getInstance().log("LoadConfigCommand::addAttributesToManager >> property " +prop.localName()+" not found on " + getQualifiedClassName(manager));
						//	trace ("LoadConfigCommand::addAttributesToManager >> property " +prop.localName()+" not found on " + getQualifiedClassName(manager));
					}
				}
			}
		}
		
	}
}