package com.vidiun.vdpfl.plugin.component {
	import com.vidiun.VidiunClient;
	import com.vidiun.commands.stats.StatsCollect;
	import com.vidiun.config.VidiunConfig;
	import com.vidiun.vdpfl.model.ConfigProxy;
	import com.vidiun.vdpfl.model.ExternalInterfaceProxy;
	import com.vidiun.vdpfl.model.MediaProxy;
	import com.vidiun.vdpfl.model.SequenceProxy;
	import com.vidiun.vdpfl.model.ServicesProxy;
	import com.vidiun.vdpfl.model.type.AdsNotificationTypes;
	import com.vidiun.vdpfl.model.type.NotificationType;
	import com.vidiun.vdpfl.view.media.VMediaPlayerMediator;
	import com.vidiun.types.VidiunStatsEventType;
	import com.vidiun.vo.VidiunStatsEvent;
	
	import flash.display.DisplayObject;
	import flash.external.ExternalInterface;
	import flash.net.URLRequestMethod;
	import flash.utils.ByteArray;
	import flash.utils.describeType;
	
	import org.osmf.media.MediaPlayerState;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.mediator.Mediator;

	/**
	 * Class StatisticsPluginMediator is responsible for "catching" the VDP notifications and translating them to the appropriate statistics events.
	 * @author Hila
	 * 
	 */	
	public class StatisticsMediator extends Mediator {
		
		
		/**
		 * Mediator name 
		 */		
		public static const NAME:String = "statisticsMediator";


		public var statsDomain : String;
		
		private var _flashvars : Object;
		
		/**
		 * Parameter signifying whether statistics should be disabled. 
		 */		
		public var statsDis:Boolean;
		
		/**
		 * A flag that makes sure that only one "widgetLoaded event is fired per session. 
		 */		
		private var _ready:Boolean = false;
		
		/**
		 * Flag indicating that is a seek operation is on-going.
		 */		
		private var _inSeek:Boolean = false;
		
		/**
		 * iFlag indicating that the scrubber is being dragged.
		 */		
		private var _inDrag:Boolean = false;
		
		/**
		 * Flag indicating that fast forward operation is on-going. 
		 */		
		private var _inFF:Boolean = false;
		
		/**
		 * Flag indicating that the 25% point of the video has been reached.
		 */		
		private var _p25Once:Boolean = false;
		
		/**
		 *Flag indicating that the midway point of the video has been reached.
		 */	
		private var _p50Once:Boolean = false;
		
		/**
		 * Flag indicating that the 75% point of the video has been reached.
		 */	
		private var _p75Once:Boolean = false;
		
		/**
		 * Flag indicating that the video has completed playback.
		 */	
		private var _p100Once:Boolean = false;
		
		/**
		 *Flag that makes sure that the event "play" is dispatched only once per entry.
		 */		
		private var _played:Boolean = false;
		
		/**
		 * Flag indicating that a seek operation has been performed. 
		 */		
		private var _hasSeeked:Boolean = false;
		
		/**
		 * Flag indicating that the Player is in Full-Screen mode.
		 */		
		private var _fullScreen:Boolean = false;
		
		/**
		 * Flag indicating that the Player is normal-sized (not in Ful-Screen mode).
		 */		
		private var _normalScreen:Boolean = false;
		
		/**
		 * Parameter indicating the last position that as seek operation has been performed to.
		 */		
		private var _lastSeek:Number = 0;
		
		/**
		 * Parameter holds the Id of the last entry played by the VDP.
		 */		
		private var _lastId:String = "";
		
		private var _vc : VidiunClient;
		
		private var _bufferStarted:Boolean = false;
		
		/**
		 * if set to true buffer_start and buffer_end events won't be sent 
		 */		
		public var bufferStatsDis:Boolean = false;
		
		private var _mediaProxy:MediaProxy;
		
		private var _configProxy:ConfigProxy;
		
		public var trackEventMonitor:String;
		/**
		 * will hold string represantations of VidiunStatsEventType keys
		 * */
		private var statsKeys:Object;
		

		/**
		 * Constructor 
		 * @param disStats - boolean signifying that the statistics should no be dispatched.
		 * @param viewComponent
		 * 
		 */		
		public function StatisticsMediator(disStats:Boolean, viewComponent:Object = null) {
			super(NAME, viewComponent);
			statsDis = disStats;
			// will save all keys from VidiunStatsEventType with their matching values
			statsKeys = {};
			var statsEventType:XML = describeType(VidiunStatsEventType);
			var consts:XMLList = statsEventType..constant;
			for each (var constant:XML in consts) {
				statsKeys[VidiunStatsEventType[constant.@name.toXMLString()]] = constant.@name.toXMLString();
			}
		}

		/**
		 * Function returns the array of VDP notifications that the Mediator listens for. 
		 * @return array of the notifications that interest the Mediator.
		 * 
		 */		
		override public function listNotificationInterests():Array {
			return [
				NotificationType.HAS_OPENED_FULL_SCREEN, 
				NotificationType.HAS_CLOSED_FULL_SCREEN, 
				NotificationType.PLAYER_UPDATE_PLAYHEAD,  
				NotificationType.PLAYER_PLAYED, 
				NotificationType.MEDIA_READY,  
				NotificationType.PLAYER_SEEK_END, 
				NotificationType.SCRUBBER_DRAG_START, 
				NotificationType.SCRUBBER_DRAG_END, 
				NotificationType.PLAYER_STATE_CHANGE, 
				NotificationType.VDP_READY,
				NotificationType.VDP_EMPTY,
				NotificationType.DO_SEEK, 
				"gotoEditorWindow", 
				"doDownload", 
				"doGigya",
				"showAdvancedShare",
				"gotoContributorWindow",
				"flagForReview",
				AdsNotificationTypes.AD_START, 
				AdsNotificationTypes.AD_CLICK, 
				AdsNotificationTypes.BUMPER_STARTED, 
				AdsNotificationTypes.BUMPER_CLICKED,
				AdsNotificationTypes.FIRST_QUARTILE_OF_AD,
				AdsNotificationTypes.MID_OF_AD,
				AdsNotificationTypes.THIRD_QUARTILE_OF_AD,
				NotificationType.DO_REPLAY
			];
		}
		
		override public function onRegister():void 
		{
			_mediaProxy = facade.retrieveProxy(MediaProxy.NAME) as MediaProxy;
			_configProxy = facade.retrieveProxy(ConfigProxy.NAME) as ConfigProxy;
			_flashvars = _configProxy.vo.flashvars;
			
			var config : VidiunConfig = new VidiunConfig();
			config.domain = statsDomain ? statsDomain : _flashvars.host;
			config.vs = (facade.retrieveProxy(ServicesProxy.NAME) as ServicesProxy).vidiunClient.vs;
			config.partnerId = _flashvars.partnerId;
			config.protocol = _flashvars.httpProtocol;
			config.clientTag = (facade.retrieveProxy(ServicesProxy.NAME) as ServicesProxy).vidiunClient.clientTag;	
			_vc = new VidiunClient(config);
		}


		/**
		 * Function creates a statistics callback and initiates it with the basic data from the VDP.
		 * @param vs	session id 
		 * @return statistics event with basic (common) data
		 */
		private function getBasicStatsData(vs:String):VidiunStatsEvent {
			var mediaPlayer:VMediaPlayerMediator = facade.retrieveMediator(VMediaPlayerMediator.NAME) as VMediaPlayerMediator;
			var vse:VidiunStatsEvent = new VidiunStatsEvent();
			vse.partnerId = _flashvars.partnerId;
			vse.widgetId = _flashvars.id;
			vse.uiconfId = _flashvars.uiConfId;
			// this is where we choose the entry to report on
			if ( _mediaProxy.vo.entry ) {
				if (_mediaProxy.vo.entry.id)
					vse.entryId = _mediaProxy.vo.entry.id;
				vse.partnerId = _mediaProxy.vo.entry.partnerId;
			}

			vse.clientVer = "3.0:" + facade["vdpVersion"];
			var dt:Date = new Date();
			vse.eventTimestamp = dt.time + dt.timezoneOffset - dt.timezoneOffset * 60; // milisec UTC + users timezone offset
			if (mediaPlayer) {
				vse.duration = mediaPlayer.player.duration;
				vse.currentPoint = Number(mediaPlayer.getCurrentTime()) * 1000;
			}
			vse.sessionId = _configProxy.vo.sessionId;
			vse.seek = _hasSeeked;
			vse.referrer = _flashvars.referer;
			if (!vse.referrer)
				vse.referrer = _flashvars.refferer;
			// verify the the referrer is escaped once
			vse.referrer = escape(unescape(vse.referrer));
			
			if (_flashvars.playbackContext)
				vse.contextId = _flashvars.playbackContext;
			if (_flashvars.originFeature)
				vse.featureType = _flashvars.originFeature;
			if (_flashvars.applicationName)
				vse.applicationId = _flashvars.applicationName;
			if (_flashvars.userId)
				vse.userId = _flashvars.userId;
			
			return vse;
		}

		/**
		 * Function checks whether a progress statistics event should be dispathced.
		 * @param currPosition	current playhead position
		 * @param duration		media duration
		 * @return 	event type code, or -1 if none matched
		 * 
		 */
		private function percentStatsChanged(currPosition:Number, duration:int):int {

			var percent:Number = 0;
			var seekPercent:Number = 0;

			if (_inDrag || _inFF || _mediaProxy.vo.isLive) {
				return int.MIN_VALUE;
			}

			if (duration > 0) {
				percent = currPosition / duration;
				seekPercent = _lastSeek / duration;
			}

			if (!_p25Once && Math.round(percent * 100) >= 25 && seekPercent < 0.25) {
				_p25Once = true;
				return VidiunStatsEventType.PLAY_REACHED_25;
			}
			else if (!_p50Once && Math.round(percent * 100) >= 50 && seekPercent < 0.50) {
				_p50Once = true;
				return VidiunStatsEventType.PLAY_REACHED_50;
			}
			else if (!_p75Once && Math.round(percent * 100) >= 75 && seekPercent < 0.75) {
				_p75Once = true;
				return VidiunStatsEventType.PLAY_REACHED_75;
			}
			else if (!_p100Once && Math.round(percent * 100) >= 98 && seekPercent < 1) {
				_p100Once = true;
				return VidiunStatsEventType.PLAY_REACHED_100;
			}

			return int.MIN_VALUE;
		}

		/**
		 *  Function responsible for dispatching the appropriate statistics event according to the notification fired by the VDP.
		 * @param note notification fired by the VDP and caught by the Mediator.
		 * 
		 */		
		override public function handleNotification(note:INotification):void {
			if (statsDis)
				return;
			var timeSlot:String;
			//var _vc:VidiunClient = facade.retrieveProxy("servicesProxy")["vidiunClient"];		
			var vse:VidiunStatsEvent = getBasicStatsData(_vc.vs);
			var data:Object = note.getBody();
			
			var sequenceProxy : SequenceProxy = facade.retrieveProxy( SequenceProxy.NAME ) as SequenceProxy;
			
			if (sequenceProxy.vo.isInSequence)
			{
				//bumper plugin case - send play & play through statistics
				if (sequenceProxy.activePlugin() && 
					sequenceProxy.activePlugin().sourceType=="entryId" && 
					(note.getName()==NotificationType.MEDIA_READY || note.getName()==NotificationType.PLAYER_PLAYED || note.getName()==NotificationType.PLAYER_UPDATE_PLAYHEAD))
				{
					handleMainContentNotifications();
					
				}
				else
				{
					handleAdsNotifications();
				}
			}
			else
			{
				handleMainContentNotifications();
			}
			
			// if we enter this function for any wrong reason and we don't have event to send, just return...
			if (vse.eventType < 0) {
				return;
			}
			
			var collect:StatsCollect = new StatsCollect(vse);
			collect.method = URLRequestMethod.GET;
			_vc.post(collect);
			//notify js
			if ((facade.retrieveProxy(ExternalInterfaceProxy.NAME) as ExternalInterfaceProxy).vo.enabled
				&&trackEventMonitor && 
				trackEventMonitor!="" ) 
			{
				try {
					ExternalInterface.call(trackEventMonitor, statsKeys[vse.eventType], vse);
				}
				catch (e:Error) {
					//
				}
			}
				
			
			
			
			function handleMainContentNotifications () : void
			{
				switch (note.getName()) 
				{
					case NotificationType.HAS_OPENED_FULL_SCREEN:
						if (_fullScreen == false) {
							vse.eventType = VidiunStatsEventType.OPEN_FULL_SCREEN;
						}
						_fullScreen = true;
						_normalScreen = false;
						break;
					case NotificationType.HAS_CLOSED_FULL_SCREEN:
						if (_normalScreen == false) {
							vse.eventType = VidiunStatsEventType.CLOSE_FULL_SCREEN;
						}
						_fullScreen = false;
						_normalScreen = true;
						break;
	
					case NotificationType.VDP_EMPTY:
						if (_ready)
							return;
						vse.eventType = VidiunStatsEventType.WIDGET_LOADED;
						_ready = true;
						break;
	
					case NotificationType.PLAYER_PLAYED:
						
						
						//In the case of a bumper entry, the bumper has already reported PLAYER_PLAYED for the 
						//statistics "session" of the real entry, which causes wrong input of analytics.
						if (_lastId != vse.entryId) {
							_played = false;
							_lastId = vse.entryId;
						}
						
						if (!_played) {
							vse.eventType = VidiunStatsEventType.PLAY;
							_p25Once = false;
							_p50Once = false;
							_p75Once = false;
							_p100Once = false;
							_played = true;
						}
	
						break;
	
	
					case NotificationType.MEDIA_READY:
						
						if (vse.entryId) {
							if (_lastId != vse.entryId) {
								_played = false;
								_lastId = vse.entryId;
								_hasSeeked = false;
								vse.eventType = VidiunStatsEventType.MEDIA_LOADED;
							}
							else {
								_lastSeek = 0;
							}
						}
						break;
					
					case NotificationType.PLAYER_SEEK_END:
						_inSeek = false;
						return;
						break;
	
					case NotificationType.SCRUBBER_DRAG_START:
						_inDrag = true;
						return;
						break;
	
					case NotificationType.SCRUBBER_DRAG_END:
						_inDrag = false;
						_inSeek = false;
						return;
						break;
	
					case NotificationType.PLAYER_UPDATE_PLAYHEAD:
						
							vse.eventType = percentStatsChanged(data as Number, vse.duration);
							if (vse.eventType < 0) {
								return; // negative number means no need to change update
							}
							break;
	
					case NotificationType.VDP_READY:
						// Ready should not occur more than once
						if (_ready)
							return;
						vse.eventType = VidiunStatsEventType.WIDGET_LOADED;
						_ready = true;
						break;
					case "gotoEditorWindow":
						vse.eventType = VidiunStatsEventType.OPEN_EDIT;
						break
					case "doDownload":
						vse.eventType = VidiunStatsEventType.OPEN_DOWNLOAD;
						break;
					case "doGigya":
					case "showAdvancedShare":
						vse.eventType = VidiunStatsEventType.OPEN_VIRAL;
						break;
					case "flagForReview":
						vse.eventType = VidiunStatsEventType.OPEN_REPORT;
						break;
					case NotificationType.DO_SEEK:
						if (_inDrag && !_inSeek) {
							vse.eventType = VidiunStatsEventType.SEEK;
						}
						_lastSeek = Number(note.getBody());
						_inSeek = true;
						_hasSeeked = true;
						break;
					
					case "gotoContributorWindow":
						vse.eventType = VidiunStatsEventType.OPEN_UPLOAD;
						break;
					
					case NotificationType.PLAYER_STATE_CHANGE:
						if (!bufferStatsDis)
						{
							if (note.getBody() == MediaPlayerState.BUFFERING)
							{
								if (!_bufferStarted)
								{
									vse.eventType = VidiunStatsEventType.BUFFER_START;
									_bufferStarted = true;
								}
							}
							else if (_bufferStarted)
							{
								vse.eventType = VidiunStatsEventType.BUFFER_END;
								_bufferStarted = false;
							}
						}	
						break;
					
					case NotificationType.DO_REPLAY:
						vse.eventType = VidiunStatsEventType.REPLAY;
						break;
				}
			}
					
			function handleAdsNotifications ()  : void
			{
				
				switch (note.getName())
				{
					case AdsNotificationTypes.BUMPER_CLICKED:
						vse.eventType = VidiunStatsEventType.BUMPER_CLICKED;
						break;
					case AdsNotificationTypes.BUMPER_STARTED:
						if (note.getBody().timeSlot == "preroll") {
							vse.eventType = VidiunStatsEventType.PRE_BUMPER_PLAYED;
						}
						else if (note.getBody().timeSlot == "postroll") {
							vse.eventType = VidiunStatsEventType.POST_BUMPER_PLAYED;
						}
						break;
					case AdsNotificationTypes.AD_CLICK:
						timeSlot = note.getBody().timeSlot;
						switch (timeSlot) {
							case "preroll":
								vse.eventType = VidiunStatsEventType.PREROLL_CLICKED;
								break;
							case "midroll":
								vse.eventType = VidiunStatsEventType.MIDROLL_CLICKED;
								break;
							case "postroll":
								vse.eventType = VidiunStatsEventType.POSTROLL_CLICKED;
								break;
							case "overlay":
								vse.eventType = VidiunStatsEventType.OVERLAY_CLICKED;
								break;
							
						}
						break;
					case AdsNotificationTypes.AD_START:
						timeSlot = note.getBody().timeSlot;
						switch (timeSlot) {
							case "preroll":
								vse.eventType = VidiunStatsEventType.PREROLL_STARTED;
								break;
							case "midroll":
								vse.eventType = VidiunStatsEventType.MIDROLL_STARTED;
								break;
							case "postroll":
								vse.eventType = VidiunStatsEventType.POSTROLL_STARTED;
								break;
							case "overlay":
								vse.eventType = VidiunStatsEventType.OVERLAY_STARTED;
								break;
						}
						break;
					case AdsNotificationTypes.FIRST_QUARTILE_OF_AD:
						timeSlot = note.getBody().timeSlot;
						switch (timeSlot) {
							case "preroll":
								vse.eventType = VidiunStatsEventType.PREROLL_25;
								break;
							case "midroll":
								vse.eventType = VidiunStatsEventType.MIDROLL_25;
								break;
							case "postroll":
								vse.eventType = VidiunStatsEventType.POSTROLL_25;
								break;
							case "overlay":
	//							vse.eventType = VidiunStatsEventType.OVERLAY_STARTED;
								break;
						}
						break;
					case AdsNotificationTypes.MID_OF_AD:
						timeSlot = note.getBody().timeSlot;
						switch (timeSlot) {
							case "preroll":
								vse.eventType = VidiunStatsEventType.PREROLL_50;
								break;
							case "midroll":
								vse.eventType = VidiunStatsEventType.MIDROLL_50;
								break;
							case "postroll":
								vse.eventType = VidiunStatsEventType.POSTROLL_50;
								break;
							case "overlay":
	//							vse.eventType = VidiunStatsEventType.OVERLAY_STARTED;
								break;
						}
						break;
					case AdsNotificationTypes.THIRD_QUARTILE_OF_AD:
						timeSlot = note.getBody().timeSlot;
						switch (timeSlot) {
							case "preroll":
								vse.eventType = VidiunStatsEventType.PREROLL_75;
								break;
							case "midroll":
								vse.eventType = VidiunStatsEventType.MIDROLL_75;
								break;
							case "postroll":
								vse.eventType = VidiunStatsEventType.POSTROLL_75;
								break;
							case "overlay":
	//							vse.eventType = VidiunStatsEventType.OVERLAY_STARTED;
								break;
						}
						break;
				}
			}
			
		}
		
		public function get view():DisplayObject {
			return viewComponent as DisplayObject;
		}

	}
}