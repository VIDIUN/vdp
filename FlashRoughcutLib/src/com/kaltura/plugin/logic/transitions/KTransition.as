/*
This file is part of the Vidiun Collaborative Media Suite which allows users 
to do with audio, video, and animation what Wiki platfroms allow them to do with 
text.

Copyright (C) 2006-2008  Vidiun Inc.

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU Affero General Public License as
published by the Free Software Foundation, either version 3 of the
License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.

@ignore
*/
package com.vidiun.plugin.logic.transitions
{
	import com.vidiun.plugin.layer.LayersContainer;
	import com.vidiun.plugin.logic.Plugin;
	
	import flash.display.DisplayObject;

	public class VTransition extends Plugin
	{
		protected var _layers:LayersContainer;
		
		public static const REFLECTION:String = "VTRANSITION";
		
		public function VTransition (url:String = ""):void
		{
			super (url);
		}
		
		override public function get reflection ():String 
		{
			return VTransition.REFLECTION;
		}
		
		/**
		 * Sets the _current and the _next Layer objects to the referenced current and next Layer objects
		 * @param current The display object currently displaying in the player
		 * @param next The display object to be displayed in the player
		 * 
		 */		
		public override function setTargets(layers:DisplayObject):void
		{
			_layers = layers as LayersContainer;
			super.setTargets(layers);
		}
		/**
		 * sets both next and current layers back to their start point and cleans any reference pointing to them 
		 * @param nScreenWidth the width of the rectangle which defines the player/editor video panel
		 * @param nScreenWidth the height of the rectangle which defines the player/editor video panel
		 */		
		public override function detach(nScreenWidth:Number, nScreenHeight:Number, nX:Number, nY:Number):void
		{
			if (_layers != null)
				_layers.resetProperties();			
		}

	}
}