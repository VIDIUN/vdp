package com.vidiun.vdpfl.plugin
{
	import com.yahoo.astra.fl.controls.Carousel;
	
	import fl.data.DataProvider;

	public class VCarousel extends Carousel
	{
		public function VCarousel()
		{
			super();
			
		}
		
		
		
		/**
		 * Our source is a bitmap data and we are using the item itself to store it
		 */
		override public function itemToSource(item:Object):Object
		{
			return item;
		}
		
		override public function set width(value:Number):void
		{
			super.width = value;
		}
		
		override public function set dataProvider(value:DataProvider):void
		{
			var prevSelectedIndex : int = this.selectedIndex != -1 ? this.selectedIndex : 0;
			
			if (prevSelectedIndex > value.length)
			{
				prevSelectedIndex = 0;
			}
			super.dataProvider = value;
			this.selectedIndex = prevSelectedIndex;
		}
		
		/**
		 * children were not affected from carousel.enabled value, override this function to affect children state. 
		 * @param value
		 * 
		 */		
		override public function set enabled(value:Boolean):void
		{
			this.mouseChildren = value;
			super.enabled = value;
		}
	}
}