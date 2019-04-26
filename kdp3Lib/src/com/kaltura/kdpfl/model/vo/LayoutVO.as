package com.vidiun.vdpfl.model.vo
{
	import com.vidiun.vdpfl.view.containers.VCanvas;
	
	import mx.utils.ObjectProxy;
	
	/**
	 * Class LayoutVO holds parameters related to the visual layout of the VDP. 
	 * @author Hila
	 * 
	 */	
	public class LayoutVO extends ObjectProxy
	{
		/**
		 * Holds the layout XML 
		 */		
		public var layoutXML:XML;
		/**
		 * Holds an object that has all screens UIcomponents.Their key is the screenId  
		 */		
		public var screens:Object;
		/**
		 * This is a foreground layer that components and plugins could use to place a 
		 * displayObject on a layer over the main layout
		 */		
		public var foreground:VCanvas 
		
		[Bindable]
		/**
		 * indicates if player is currently in full screen mode 
		 */		
		public var isInFullScreen:Boolean;
	}
}