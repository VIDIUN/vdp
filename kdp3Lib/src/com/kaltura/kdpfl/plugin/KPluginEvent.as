package com.vidiun.vdpfl.plugin
{
	import flash.events.Event;
	/**
	 * New class for unique events fired by the VDP plug-ins 
	 * @author Hila
	 * 
	 */	
	public class VPluginEvent extends Event
	{
		/**
		 * Constant signifying plugin initialize complete.
		 */		
		public static const VPLUGIN_INIT_COMPLETE : String = "vPluginInitComplete";
		/**
		 * Constant signifying plugin initialize failed.
		 */		
		public static const VPLUGIN_INIT_FAILED : String = "vPluginInitFailed";
		/**
		 *  
		 * @param type
		 * @param bubbles
		 * @param cancelable
		 * 
		 */		
		public function VPluginEvent(type:String, bubbles:Boolean=true, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}