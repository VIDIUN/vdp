package com.vidiun.vdpfl.model.type
{
	/**
	 * Class EnableType holds the constants representing the types of GUI-disabling that can occcur. 
	 * @author Hila
	 * 
	 */	
	public class EnableType
	{
		/**
		 * The enable-type FULL affects the entire VDP, including the playlist items.
		 */		
		public static const FULL : String = "full";
		/**
		 * The enable-type CONTROLS affects only the video and controller bar areas of the VDP. The Playlist area remains unaffected and can be
		 * interacted with. 
		 */		
		public static const CONTROLS : String = "controls";
	}
}