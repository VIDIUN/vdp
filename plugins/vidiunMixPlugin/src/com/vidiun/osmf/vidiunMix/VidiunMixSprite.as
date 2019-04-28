package com.vidiun.osmf.vidiunMix {

	import com.vidiun.VidiunClient;
	import com.vidiun.application.VidiunApplication;
	import com.vidiun.assets.AssetsFactory;
	import com.vidiun.assets.abstracts.AbstractAsset;
	import com.vidiun.base.context.PartnerInfo;
	import com.vidiun.base.types.MediaTypes;
	import com.vidiun.base.types.TimelineTypes;
	import com.vidiun.base.vo.VidiunPluginInfo;
	import com.vidiun.commands.mixing.MixingGetReadyMediaEntries;
	import com.vidiun.components.players.eplayer.Eplayer;
	import com.vidiun.events.VidiunEvent;
	import com.vidiun.managers.downloadManagers.types.StreamingModes;
	import com.vidiun.model.VidiunModelLocator;
	import com.vidiun.osmf.vidiun.VidiunBaseEntryResource;
	import com.vidiun.plugin.types.transitions.TransitionTypes;
	import com.vidiun.roughcut.Roughcut;
	import com.vidiun.types.VidiunEntryStatus;
	import com.vidiun.utils.url.URLProccessing;
	import com.vidiun.vo.VidiunMediaEntry;
	import com.vidiun.vo.VidiunMixEntry;
	import com.quasimondo.geom.ColorMatrix;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	
	import mx.collections.ArrayCollection;
	import mx.core.MovieClipAsset;
	import mx.core.SpriteAsset;
	
	import org.osmf.traits.MediaTraitType;
	import org.puremvc.as3.interfaces.IFacade;


	public class VidiunMixSprite extends Sprite {
		// must have these classes compiled into code
		private var m:MovieClipAsset;
		private var f:SpriteAsset;
		private var c:ColorMatrix;

		/**
		 * mix plugin facade 
		 */		
		static public var facade:IFacade;
		
		private var vc:VidiunClient;

		/**
		 * mix player 
		 */		
		public var eplayer:Eplayer;

		/**
		 * entries ready
		 */		
		public var isReady:Boolean = false;

		private var _width:Number;
		private var _height:Number;

		private var vapp:VidiunApplication;
		private var mediaElement:VidiunMixElement;
		private var mixEntry:VidiunMixEntry;
		private var roughcut:Roughcut = null;

		static private var mixPluginsLoaded:Boolean = false;
		static private var pluginListLoader:URLLoader;
		
		/**
		 * @default false 
		 */		
		public var disableUrlHashing:Boolean = false;


		/**
		 * load different plugins
		 * @param data plugins data
		 */		
		public function loadPlugins(data:Object):void {
			var model:VidiunModelLocator = VidiunModelLocator.getInstance();
			var pluginsProvider:Array = data as Array;
			//var pluginsProvider:Array = data.result;
			/* pluginsProvider:   [transitionsArray, overlaysArray, textOverlaysArray, effectsArray] */
			var pinfo:VidiunPluginInfo;
			var baseUrl:String;
			var thumbUrl:String;
			var debugFromIDE:Boolean = vapp.applicationConfig.debugFromIDE;
			var pluginsUrl:String = URLProccessing.prepareURL(model.applicationConfig.pluginsFolder + "/", !debugFromIDE, false);
			for (var i:int = 0; i < pluginsProvider.length; ++i) {
				for (var j:int = 0; j < pluginsProvider[i].length; ++j) {
					pinfo = pluginsProvider[i].getItemAt(j) as VidiunPluginInfo;
					baseUrl = pluginsUrl + model.applicationConfig.transitionsFolder + "/" + pinfo.pluginId + "/";
					thumbUrl = pinfo.thumbnailUrl == '' ? baseUrl + "thumbnail.swf" : pinfo.thumbnailUrl;
					pinfo.thumbnailUrl = thumbUrl;
				}
			}
			vapp.transitions = pluginsProvider[0];
			vapp.overlays = pluginsProvider[1];
			vapp.textOverlays = pluginsProvider[2];
			vapp.effects = pluginsProvider[3];
			thumbUrl = model.applicationConfig.pluginsFolder + "/" + model.applicationConfig.transitionsFolder + "/thumbnail.swf";
			VidiunApplication.nullAsset.transitionThumbnail = URLProccessing.prepareURL(thumbUrl, true, false);
			model.logStatus = "plugins loaded and instantiated.";
			var nonePlugin:VidiunPluginInfo = model.transitions.getItemAt(0) as VidiunPluginInfo;
			AbstractAsset.noneTransitionThumbnail = nonePlugin.thumbnailUrl;
		}

		/**
		 * set plugin data before load
		 * @param data plugin data
		 */
		public function loadPlugingList(data:Object):void {
			var buildPlugin:Function = function(p:XML, media_type:uint):VidiunPluginInfo {
					var vpinf:VidiunPluginInfo = new VidiunPluginInfo(media_type, p.@plugin_id, p.@thumbnail, p.parent().@type, p.@label, p.@creator, p.description);
					return vpinf;
				}

			var pluginsXml:XML = data as XML;
			var transitionsArray:ArrayCollection = new ArrayCollection();
			var overlaysArray:ArrayCollection = new ArrayCollection();
			var textOverlaysArray:ArrayCollection = new ArrayCollection();
			var effectsArray:ArrayCollection = new ArrayCollection();
			var pinf:VidiunPluginInfo;
			var noneTransition:VidiunPluginInfo;
			var pluginXml:XML;
			for each (pluginXml in pluginsXml..transitions..plugin) {
				pinf = buildPlugin(pluginXml, MediaTypes.TRANSITION);
				if (pinf.category == "ignore")
					noneTransition = pinf;
				else
					transitionsArray.addItem(pinf);
			}
			transitionsArray.addItemAt(noneTransition, 0);
			for each (pluginXml in pluginsXml..overlays..plugin) {
				pinf = buildPlugin(pluginXml, MediaTypes.OVERLAY);
				overlaysArray.addItem(pinf);
			}
			for each (pluginXml in pluginsXml..textOverlays..plugin) {
				pinf = buildPlugin(pluginXml, MediaTypes.TEXT_OVERLAY);
				textOverlaysArray.addItem(pinf);
			}
			for each (pluginXml in pluginsXml..effects..plugin) {
				pinf = buildPlugin(pluginXml, MediaTypes.EFFECT);
				effectsArray.addItem(pinf);
			}

			loadPlugins([transitionsArray, overlaysArray, textOverlaysArray, effectsArray]);

		}

		/**
		 * get a list ready entries 
		 */
		public function getReadyEntries():void {
			var getMixReadyEntries:MixingGetReadyMediaEntries = new MixingGetReadyMediaEntries(mixEntry.id, mixEntry.version);

			getMixReadyEntries.addEventListener(VidiunEvent.COMPLETE, complete);
			getMixReadyEntries.addEventListener(VidiunEvent.FAILED, failed);
			vc.post(getMixReadyEntries);
		}


		private function failed(event:VidiunEvent):void {
			trace("getMixReadyEntries", event.toString());
		}


		private function complete(event:VidiunEvent):void {
			roughcut = new Roughcut(mixEntry);
			vapp.addRoughcut(roughcut);

			var readyEntriesResult:* = event.data;
			if (readyEntriesResult is Array) {
				var readyEntries:Array = readyEntriesResult as Array;
				var asset:AbstractAsset;
				var thumbUrl:String;
				var mediaUrl:String;
				for each (var entry:VidiunMediaEntry in readyEntries) {
					entry.mediaType = MediaTypes.translateServerType(entry.mediaType);
					asset = roughcut.associatedAssets.getValue(entry.id);
					if (asset)
						continue;
					vapp.addEntry(entry);
					if (entry.status != VidiunEntryStatus.BLOCKED && entry.status != VidiunEntryStatus.DELETED && entry.status != VidiunEntryStatus.ERROR_CONVERTING) {
						//thumbUrl = URLProccessing.hashURLforMultipalDomains (entry.thumbnailUrl, entry.id);
						mediaUrl = entry.mediaUrl;
						asset = AssetsFactory.create(entry.mediaType, 'null', entry.id, entry.name, thumbUrl, mediaUrl, entry.duration, entry.duration, 0, 0, TransitionTypes.NONE, 0, false, false, null, entry);
						asset.vidiunEntry = entry;
						asset.mediaURL = entry.dataUrl;
						asset.entryContributor = entry.creditUserName;
						asset.entrySourceCode = parseInt(entry.sourceType);
						asset.entrySourceLink = entry.creditUrl;
						roughcut.associatedAssets.put(entry.id, asset);
						roughcut.originalAssets.addItem(asset);
						roughcut.mediaClips.addItem(asset);
					}
				}
			}
			isReady = true;
			if ((mediaElement.getTrait(MediaTraitType.PLAY) as VidiunMixPlayTrait).playState == "playing") {
				loadAssets();
			}
		/* var sdl:XML = new XML (mixEntry.dataContent);
		   roughcut.parseSDL (sdl, false);

		   var Timelines2Load:int = TimelineTypes.VIDEO | TimelineTypes.TRANSITIONS | TimelineTypes.AUDIO | TimelineTypes.OVERLAYS | TimelineTypes.EFFECTS;
		   roughcut.streamingMode = StreamingModes.PROGRESSIVE_STREAM_DUAL;
		   roughcut.loadAssetsMediaSources (Timelines2Load, roughcut.streamingMode);

		   eplayer.roughcut = roughcut;
		 (mediaElement.getTrait(MediaTraitType.TIME) as VidiunMixTimeTrait).setSuperDuration(roughcut.roughcutDuration); */
		}

		/**
		 * load media sources of assets 
		 */
		public function loadAssets():void {
			var sdl:XML = new XML(mixEntry.dataContent);
			roughcut.parseSDL(sdl, false);

			var Timelines2Load:int = TimelineTypes.VIDEO | TimelineTypes.TRANSITIONS | TimelineTypes.AUDIO | TimelineTypes.OVERLAYS | TimelineTypes.EFFECTS;
			roughcut.streamingMode = StreamingModes.PROGRESSIVE_STREAM_DUAL;
			roughcut.loadAssetsMediaSources(Timelines2Load, roughcut.streamingMode);

			eplayer.roughcut = roughcut;
			(mediaElement.getTrait(MediaTraitType.TIME) as VidiunMixTimeTrait).setSuperDuration(roughcut.roughcutDuration);
			(mediaElement.getTrait(MediaTraitType.DISPLAY_OBJECT) as VidiunMixViewTrait).isSpriteLoaded = true;
		}

		/**
		 * setup the sprite ui 
		 * @param _width	sprite width
		 * @param _height	sprite height
		 */
		public function setupSprite(_width:Number, _height:Number):void {
			this._width = _width;
			this._height = _height;
			graphics.beginFill(0xff);
			graphics.drawRect(0, 0, _width, _height);

			eplayer = new Eplayer();
			addChild(eplayer);
			eplayer.updateDisplayList(_width, _height);
		}


		/**
		 * Constructor. 
		 * @param _mediaElement
		 * @param _width
		 * @param _height
		 * @param isHashDisabled
		 */		
		public function VidiunMixSprite(_mediaElement:VidiunMixElement, _width:Number, _height:Number, isHashDisabled:Boolean) {
			disableUrlHashing = isHashDisabled;
			URLProccessing.disable_hashURLforMultipalDomains = disableUrlHashing;
			vapp = VidiunApplication.getInstance();
			mediaElement = _mediaElement;
			mixEntry = VidiunBaseEntryResource(mediaElement.resource).entry as VidiunMixEntry;
			setupSprite(_width, _height);

			var servicesProxy:Object = facade.retrieveProxy("servicesProxy");
			vc = servicesProxy.vidiunClient;

			var configProxy:Object = facade.retrieveProxy("configProxy");
			var flashvars:Object = configProxy.getData().flashvars;

			var app:VidiunApplication = VidiunApplication.getInstance();
			var partnerInfo:PartnerInfo = new PartnerInfo();
			partnerInfo.partner_id = vc.partnerId;
			partnerInfo.subp_id = "0";
			app.initVidiunApplication("", null);
			vapp.partnerInfo = partnerInfo;

			URLProccessing.serverURL = flashvars.httpProtocol + flashvars.host;
			URLProccessing.cdnURL = flashvars.httpProtocol + flashvars.cdnHost;

			if (!mixPluginsLoaded) {
				var baseUrl:String = vidiunMixPlugin.mixPluginsBaseUrl;
				vapp.applicationConfig.pluginsFolder = URLProccessing.completeUrl(baseUrl, URLProccessing.BINDING_CDN_SERVER_URL);

				var url:String = vapp.applicationConfig.pluginsFolder + "/" + (flashvars.mixPluginsListFile ? flashvars.mixPluginsListFile : "plugins.xml");
				var urlRequest:URLRequest = new URLRequest(url);
				pluginListLoader = new URLLoader();
				pluginListLoader.addEventListener(Event.COMPLETE, loadedPluginsList);
				pluginListLoader.load(urlRequest);
			}
			else {
				getReadyEntries();
			}
		}


		/**
		 * video width 
		 */		
		public function get videoWidth():Number {
			return this.width;
		}


		/**
		 * video height 
		 */
		public function get videoHeight():Number {
			return this.height;
		}


		private function loadedPluginsList(e:Event):void {
			pluginListLoader.removeEventListener(Event.COMPLETE, loadedPluginsList);
			mixPluginsLoaded = true;
			loadPlugingList(new XML(e.target.data));
			getReadyEntries();
		}
	}
}
