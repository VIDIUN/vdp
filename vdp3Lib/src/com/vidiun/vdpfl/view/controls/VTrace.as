package com.vidiun.vdpfl.view.controls
{
	import flash.external.ExternalInterface;

	/**
	 * VTrace class enables to send the traces to javaScript. 
	 * @author Michal
	 * 
	 */	
	public class VTrace
	{
		private var _jsCallback:Boolean;
		
		private static var _instance:VTrace;
		
		
		public static function getInstance() : VTrace
		{
			if (_instance == null) _instance = new VTrace();
			return _instance as VTrace;
		}
		
		/**
		 * if true- traces will be added to the page 
		 * @param value
		 * 
		 */		
		public function set jsCallback(value:Boolean):void
		{
			if (!_jsCallback && value) {
				ExternalInterface.call("function() {var ta = document.createElement('textarea'); ta.setAttribute('id', 'vLog'); ta.setAttribute('style', 'width: 500px; height: 400px; position: absolute; top: 0; right: 1px;'); document.getElementsByTagName('body')[0].appendChild( ta );}");
			}
			_jsCallback = value;
		}
		
		public function get jsCallback():Boolean {
			return _jsCallback;
		}
		
		public function log(... args):void {
			trace(args);
			if (jsCallback) {
				args.push("\n");
				ExternalInterface.call("function( msg ) { document.getElementById('vLog').innerHTML += msg; }", args.join(' '));
			}
		}
	}
}