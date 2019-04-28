package com.vidiun.vdpfl.model.vo
{
	import com.vidiun.vo.VidiunUiConf;
	import com.vidiun.vo.VidiunWidget;
	
	/**
	 * Class ConfigVO holds parameters related to the general configuration of the VDP. 
	 * 
	 */	
	public class ConfigVO
	{
		/**
		 * Parameter holds the flashvars passed to the VDP.
		 */		
		public var flashvars:Object;
		/**
		 * Parameter holds the information on the current VidiunWidget
		 */		
		public var vw : VidiunWidget; 
		/**
		 * Parameter to hold the Uiconf object of the player.
		 */		
		public var vuiConf : VidiunUiConf;
		/**
		 * A unique ID for the loaded instance of the VDP. 
		 */		
		public var sessionId : String;
	}
}