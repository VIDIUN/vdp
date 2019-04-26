package {
	import com.vidiun.vdpfl.model.type.NotificationType;
	
	import fl.events.ComponentEvent;
	
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.events.TimerEvent;
	import flash.net.URLRequest;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	import flash.system.Security;
	import flash.system.SecurityDomain;
	import flash.utils.Timer;
	import flash.utils.getDefinitionByName;
	
	/**
	 * @class ApplicationLoader
	 * This class is the preloader of the vdp3 application and its document class (root). </br>
	 * It delegates all calls to IVDP3 methods to the actual vdp3 instance, to enable
	 * communication with loading applications, etc.
	 * @author Atar
	 *
	 */
	public class ApplicationLoader extends MovieClip implements IVDP3 {
		
		/**
		 * an instance of the created application (vdp3)
		 */
		protected var _app:IVDP3;
		
		/**
		 * the loader instance that loads the external swf preloader.
		 */
		protected var _ldr:*;
		
		protected var _path:String;
		
		
		/**
		 * is the real app started yet
		 */
		protected var _isGoing:Boolean = false;
		
		
		/**
		 * temporarily save flashvars until _app is ready
		 */
		protected var _flashvars:Object;
		
		
		/**
		 * someone already asked to init the VDP
		 */
		protected var _shouldInit:Boolean;
		
		
		/**
		 * if someone asked to init with VML, save data here
		 */
		
		protected var _vml:XML;
		
		/**
		 * 
		 */		
		[Embed(source="assets/preloader.swf")]
		private var AssetClass:Class;

		
		private var _height:Number;
		private var _width:Number;
		
		/**
		 * will be used in case we loaded the preloader before flashvars were set 
		 */		
		private var _preloaderContent:Object;
		
		private var _vdp3Timer:Timer;
		
		/**
		 * in case vdp3 class wasn't found will start a timer with this delay 
		 */		
		public static const VDP3_LOAD_TIMER_DELAY:int = 100;
		/**
		 * in case vdp3 class wasn't found will start a timer and run this amount of times
		 */
		public static const VDP3_LOAD_TIMER_TRIES:int = 30;
		
		
		
		/**
		 * Constructor.
		 */
		public function ApplicationLoader() {
			this.addEventListener(ComponentEvent.HIDE, stopImmediatePropagation);
			this.addEventListener(ComponentEvent.SHOW, stopImmediatePropagation);
			Security.allowDomain("*");
			super();
			stop();
			//fix issue with FF 3.6 & wmode!="window": we already loaded the application
			if (loaderInfo.bytesLoaded == loaderInfo.bytesTotal)
				go();
			else
				loaderInfo.addEventListener(Event.COMPLETE, go);

			if (stage) {
				loadPreloader(null);
			}
			else {
				addEventListener(Event.ADDED_TO_STAGE, loadPreloader);
			}
		}
		
		
		/**
		 * concatenate the host and most of the path up to the preloader's folder
		 * or return given path, if such exist.
		 * @return full url of preloader swf
		 */
		protected function getPath():String {
			if (parameters.preloaderPath) {
				return parameters.preloaderPath;
			}
			var s:String = this.loaderInfo.url;
			var i:int = s.indexOf("vdp3.swf");
			s = s.substring(0, i);
			s += _path;
			return s;
		}
		
		
		/**
		 * load the preloader only when we have root, and only if the app is not running yet.
		 * @param e
		 */
		protected function loadPreloader(e:Event):void {
			if ( parameters.disablePlayerSpinner == 'true' )
				return;
			// only load custom preloader if app is not yet running or it is required as buffer anim
			if (!_isGoing || parameters.usePreloaderBufferAnimation=='true') {
				if (hasEventListener(Event.ADDED_TO_STAGE)) {
					removeEventListener(Event.ADDED_TO_STAGE, loadPreloader);
				}
				if (!parameters.preloaderPath)
				{
					_ldr = new AssetClass();
					addChild(_ldr);
					centerLoader(null);
				}
				else
				{
					_ldr = new Loader();
					centerLoader(null);
					addChild(_ldr);
					
					var context:LoaderContext = new LoaderContext( true, ApplicationDomain.currentDomain );
					
					if(!parameters.fileSystemMode || parameters.fileSystemMode=='false')
						context.securityDomain = SecurityDomain.currentDomain;
					
					var rqst:URLRequest = new URLRequest(getPath());
					_ldr.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, clearListeners, false, 0, true);
					_ldr.contentLoaderInfo.addEventListener(SecurityErrorEvent.SECURITY_ERROR, clearListeners, false, 0, true);
					_ldr.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoadComplete);
					_ldr.load(rqst, context);
				}	
				
				stage.addEventListener(Event.RESIZE, centerLoader);
			}
		}
		
		private function onLoadComplete(event:Event) : void {
			_ldr.contentLoaderInfo.removeEventListener(Event.COMPLETE, onLoadComplete);
			clearListeners(null);
			
			//if the loader registration point is not in the middle, center it
			if (parameters.centerPreloader && parameters.centerPreloader=='true' && stage && _ldr.content)
			{
				_ldr.x = (stage.stageWidth - _ldr.content.width) / 2;
				_ldr.y = (stage.stageHeight - _ldr.content.height) / 2;
			}
			if (parameters.usePreloaderBufferAnimation && parameters.usePreloaderBufferAnimation=='true')
			{
				//fix race condition: if preloader loaded before flashvars were set
				if (flashvars)
					flashvars.preloader = _ldr.content;
				else
					_preloaderContent = _ldr.content;
				if (_isGoing)
				{
					//fix race condition: if app was loaded before preloader swf
					if (_app)
					{
						_app.sendNotification(NotificationType.PRELOADER_LOADED, {preloader: _ldr.content});
					}
					_ldr.unloadAndStop(false);
					if (_ldr.parent != null) {
						removeChild(_ldr);
					}
				}
			}
		}
		
		
		/**
		 * place the loader at the center of the stage
		 * @param e	stage resize event
		 */
		protected function centerLoader(e:Event):void {
			if (stage) {
				_ldr.x = stage.stageWidth / 2;
				_ldr.y = stage.stageHeight / 2;
			}
		}
		
		
		/**
		 * Catching the errors so they won't go uncaught.
		 * @param e error event
		 */
		protected function clearListeners(e:Event):void {
			if (e) {
				trace("external preloader load failed: " + e.type);
			}
			_ldr.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, clearListeners, false);
			_ldr.contentLoaderInfo.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, clearListeners, false);
		}

		/**
		 * Starts the real application by creating an instance of vdp3.
		 */
		protected function go(e:Event = null):void {
			_isGoing = true;
			loaderInfo.removeEventListener(Event.COMPLETE, go);
			nextFrame();
			
			var mainClass:Class;
			
			try 
			{
				mainClass = Class(getDefinitionByName("vdp3"));
			}
			catch (e:Error)
			{
				//fix bug on linux & FF, after load, vdp3 class wasn't ready yet
				trace ("vdp3 class wasn't found");
				if (!_vdp3Timer)
				{
					_vdp3Timer = new Timer(VDP3_LOAD_TIMER_DELAY, VDP3_LOAD_TIMER_TRIES);
					_vdp3Timer.addEventListener(TimerEvent.TIMER, go);
					_vdp3Timer.addEventListener(TimerEvent.TIMER_COMPLETE, onTimerComplete);
					_vdp3Timer.start();
				}
			}
			
			if (mainClass) {
				if (_vdp3Timer)
				{
					_vdp3Timer.stop();
					onTimerComplete();
					trace ("found vdp3 class");
				}
				_app = new mainClass();
				(_app as DisplayObject).addEventListener(Event.ADDED_TO_STAGE, onAppAddedToStage);
				addChild(_app as DisplayObject);
								
				if (_flashvars) {
					_app.flashvars = _flashvars;
				}
				if (_shouldInit) {
					_app.init(_vml);
				}
			}
		}
		
		private function onTimerComplete(event:TimerEvent = null) : void
		{
			_vdp3Timer.removeEventListener(TimerEvent.TIMER, go);
			_vdp3Timer.removeEventListener(TimerEvent.TIMER_COMPLETE, onTimerComplete);
			if (event)
			{
				trace ("vdp3 timer complete. Failed to load vdp3");
			}
		}
		
		private function onAppAddedToStage (e : Event) : void
		{
			if (_width) {
				_app.width = _width;
			}
			if (_height) {
				_app.height = _height;
			}
		}
		
		protected function stopImmediatePropagation(event:Event):void {
			event.stopImmediatePropagation();
		}
		
		/* -----------------------------------------------------------------
		* ------------------------------------------------------------------
		*		  interface methods; delegated to the vdp3 instance
		* ------------------------------------------------------------------
		* ------------------------------------------------------------------ */
		
		public function set flashvars(obj:Object):void {
			//if we already loaded preloader swf, merge it to flashvars
			if (_preloaderContent)
			{
				obj.preloader = _preloaderContent;
			}
			
			if (_app) {
				_app.flashvars = obj;
			}
			else {
				_flashvars = obj;
			}
		}
		
		
		public function get flashvars():Object {
			if (_app) {
				return _app.flashvars;
			}
			else {
				return _flashvars;
			}
		}
		
		
		public function get preloader():DisplayObject {
			return _ldr;
		}
		
		
		override public function get height():Number {
			return _height;
		}
		
		
		override public function set height(value:Number):void {
			if (value == _height) return;
			//super.height = value;
			_height = value;
			if (_app) {
				_app.height = value;
			}
		}
		
		
		override public function get width():Number {
			return _width;
		}
		
		
		override public function set width(value:Number):void {
			if (value == _width) return;
			//super.width = value;
			_width = value;
			if (_app) {
				_app.width = value;
			}
		}
		
		
		/**
		 * a reference to application parameters
		 * */
		public function get parameters():Object {
			if (stage && stage.loaderInfo)
				return stage.loaderInfo.parameters;
			else
				return loaderInfo.parameters;
		}
		
		
		public function init(vml:XML = null):void {
			if (_app) {
				_app.init(vml);
			}
			else {
				_vml = vml;
				_shouldInit = true;
			}
		}
		
		
		public function sendNotification(notificationName:String, body:Object = null, type:String = null):void {
			_app.sendNotification(notificationName, body, type);
		}
		
		
		public function evaluate(expression:String):Object {
			return _app.evaluate(expression);
		}
		
		
		public function setAttribute(componentName:String, prop:String, newValue:String):void {
			_app.setAttribute(componentName, prop, newValue);
		}
		
		
		public function dispose():void {
			_app.dispose();
		}
		
	}
}