package com.vidiun.osmf.vidiunMix
{
	import flash.display.DisplayObject;
	
	import org.osmf.traits.DisplayObjectTrait;

	public class VidiunMixViewTrait extends DisplayObjectTrait
	{
		
		public var isSpriteLoaded : Boolean = false;
		public function VidiunMixViewTrait(view:DisplayObject, mediaWidth:Number=0, mediaHeight:Number=0)
		{
			super(view, mediaWidth, mediaHeight);
   			//view.width = info.width;
   			//view.height = info.height;
    				
			//setMediaDimensions(info.width, info.height);
			
		}
		
		public function loadAssets () : void
		{
			(displayObject as VidiunMixSprite).loadAssets();
		}
		
		public function get isReadyForLoad () : Boolean
		{
			return (displayObject as VidiunMixSprite).isReady;
		}
		
		
	}
}