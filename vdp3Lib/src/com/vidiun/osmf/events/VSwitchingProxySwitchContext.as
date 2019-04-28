package com.vidiun.osmf.events
{
	/**
	 * Class containing the context types for an element switch performed by the <code>VSwitchingProxySwitchContext</code>.
	 * @author Hila
	 * 
	 */	
	public class VSwitchingProxySwitchContext
	{
		/**
		 * Indicates the secondary media element, usually a midroll. 
		 */		
		public static const SECONDARY : String = "secondary";
		/**
		 * Indicates the main media element being played by the VDP. 
		 */		
		public static const MAIN : String = "main";
	}
}