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

package com.vidiun.model
{

	import com.adobe.cairngorm.model.IModelLocator;
	import com.vidiun.VidiunClient;
	import com.vidiun.base.context.VidiunApplicationConfig;
	import com.vidiun.base.context.PartnerInfo;
	import com.vidiun.dataStructures.HashMap;
	
	import mx.collections.ArrayCollection;

	/**
	 *a singleton manager for managing the vidiun application model.
	 */
	//[Bindable]
	public class VidiunModelLocator implements IModelLocator
	{
		static private var modelLocator : VidiunModelLocator;

		//-----------------------------------------------------------
		/**
		*log the commands
		*/
		private var _logStatus:String = '-> Model instantiated, waiting for configuration load...';

		public function get logStatus ():String
		{
			return _logStatus;
		}
		public function set logStatus (msg:String):void
		{
			_logStatus += '\n-> ' + msg;
		}

		//-----------------------------------------------------------
		public static function getInstance():VidiunModelLocator
		{
			if ( modelLocator == null )
				modelLocator = new VidiunModelLocator();

			return modelLocator;
		}

		//-----------------------------------------------------------
		public function VidiunModelLocator():void
		{
			if ( modelLocator != null )
				throw new Error( 'Only one ModelLocator instance should be instantiated' );
		}

		// MODELS ===================================================
		/**
		 *the vidiun client reference, this client is responsible for the callbacks to the vidiun server.
		 */
		public var vidiunClient : VidiunClient;
		/**
		*the application config.xml data, this holds information specific to the server to access, partner etc.
		*/
		public var applicationConfig:VidiunApplicationConfig = new VidiunApplicationConfig ();
		/**
		*the partner information of this vidiun application.
		*/
		public var partnerInfo:PartnerInfo = null;
		/**
		*hashMap to manage entries (Roughcuts).
		*/
		public var roughcutsMap:HashMap = new HashMap ();
		/**
		*entries map to manage roughcut entries.
		*/
		public var entriesMap:HashMap = new HashMap ();
		/**
		 *assets map to manage assets between roughcuts and across the application.
		 */
		public var assetsMap:HashMap = new HashMap ();
		/**
		* list of available transitions and their thumbnail urls, this should be instantiated with data from the server.
		*/
		public var transitions:ArrayCollection = new ArrayCollection ();
		/**
		* list of available overlays and their thumbnail urls, this should be instantiated with data from the server.
		*/
		public var overlays:ArrayCollection = new ArrayCollection ();
		/**
		* list of available text overlays and their thumbnail urls, this should be instantiated with data from the server.
		*/
		public var textOverlays:ArrayCollection = new ArrayCollection ();
		/**
		* list of available effects and their thumbnail urls, this should be instantiated with data from the server.
		*/
		public var effects:ArrayCollection = new ArrayCollection ();
	}
}