package com.vidiun.vdpfl.style
{
	import com.vidiun.vdpfl.events.StyleEvent;
	import com.vidiun.vdpfl.util.VdpEmbeddedData;
	import com.vidiun.vdpfl.view.controls.VTrace;
	
	import flash.display.Loader;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLRequest;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	import flash.system.SecurityDomain;
	import flash.utils.ByteArray;
	
	public class VStyleLoader extends EventDispatcher
	{
		private static var _instance:VStyleLoader;

		private var _loader:Loader;
		private var _context:LoaderContext;
		
		//private var _dispatcher:IEventDispatcher;
		
		public function VStyleLoader(sing:Singleton)
		{
			if(null == sing)
			{
				throw new Error("Singleton Error");
			}
			init();
		}
		
		public static function getInstance():VStyleLoader
		{
			if(!_instance)
			{
				_instance = new VStyleLoader(new Singleton());
			}
			return _instance;
		} 
		
		private function init():void
		{
			_loader = new Loader();
			_loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onComplete);
			_loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onError );
			_loader.contentLoaderInfo.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onError );
			
			///////////////////////////////////////////////
			//TODO: ADD ALL OTHER LISTENERS IF NEEDED
			///////////////////////////////////////////////
			
			_context = new LoaderContext();
			_context.applicationDomain = ApplicationDomain.currentDomain;
	
		}
		
		public function loadSkin(url:String , byPass : Boolean = false):void
		{
			//if this isn't a debug Mode use the same securty domain to load style
			if(!byPass)
			{
				_context.securityDomain = SecurityDomain.currentDomain;
				_context.checkPolicyFile = true;
			}
			
			var ba:ByteArray = VdpEmbeddedData.getData(url);
			if (ba) // if bytes are supplied, then load the bytes instead of loading from the url.
			{
				_context.securityDomain = null;
				//trace("load from embedded data:" + _url);
				_context.checkPolicyFile = false;
				_loader.loadBytes(ba, _context );
			}
			else
			{
				var urlRequest:URLRequest = new URLRequest(url);
				_loader.load(urlRequest, _context);
			}
		}
		
		//private function loadSwf(url:
		/**
		 * When the skin complete the loading 
		 * @param e
		 * 
		 */		
		private function onComplete(  event : Event ):void
		{
			dispatchEvent( new StyleEvent(  StyleEvent.COMPLETE ) );
		}
		
		//We must implement IO Error to any case somwone is closing the browser in the middle of
		//Loading, if not it might crash the browser.
		private function onError( event : ErrorEvent ) : void
		{
			//TODO: Report, Log and Alert the user...
			VTrace.getInstance().log("skin loaded error");
			//trace("skin loaded error");
			dispatchEvent( new StyleEvent(  StyleEvent.ERROR ) );
		}
		

	}
}
internal class Singleton{}