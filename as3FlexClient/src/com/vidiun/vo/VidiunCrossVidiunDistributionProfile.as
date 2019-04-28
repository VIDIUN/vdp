// ===================================================================================================
//                           _  __     _ _
//                          | |/ /__ _| | |_ _  _ _ _ __ _
//                          | ' </ _` | |  _| || | '_/ _` |
//                          |_|\_\__,_|_|\__|\_,_|_| \__,_|
//
// This file is part of the Vidiun Collaborative Media Suite which allows users
// to do with audio, video, and animation what Wiki platfroms allow them to do with
// text.
//
// Copyright (C) 2006-2011  Vidiun Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//
// @ignore
// ===================================================================================================
package com.vidiun.vo
{
	import com.vidiun.vo.VidiunConfigurableDistributionProfile;

	[Bindable]
	public dynamic class VidiunCrossVidiunDistributionProfile extends VidiunConfigurableDistributionProfile
	{
		/**
		**/
		public var targetServiceUrl : String = null;

		/**
		**/
		public var targetAccountId : int = int.MIN_VALUE;

		/**
		**/
		public var targetLoginId : String = null;

		/**
		**/
		public var targetLoginPassword : String = null;

		/**
		**/
		public var metadataXslt : String = null;

		/**
		**/
		public var metadataXpathsTriggerUpdate : Array = null;

		/**
		* @see com.vidiun.types.vidiunBoolean
		**/
		public var distributeCaptions : Boolean;

		/**
		* @see com.vidiun.types.vidiunBoolean
		**/
		public var distributeCuePoints : Boolean;

		/**
		* @see com.vidiun.types.vidiunBoolean
		**/
		public var distributeRemoteFlavorAssetContent : Boolean;

		/**
		* @see com.vidiun.types.vidiunBoolean
		**/
		public var distributeRemoteThumbAssetContent : Boolean;

		/**
		* @see com.vidiun.types.vidiunBoolean
		**/
		public var distributeRemoteCaptionAssetContent : Boolean;

		/**
		**/
		public var mapAccessControlProfileIds : Array = null;

		/**
		**/
		public var mapConversionProfileIds : Array = null;

		/**
		**/
		public var mapMetadataProfileIds : Array = null;

		/**
		**/
		public var mapStorageProfileIds : Array = null;

		/**
		**/
		public var mapFlavorParamsIds : Array = null;

		/**
		**/
		public var mapThumbParamsIds : Array = null;

		/**
		**/
		public var mapCaptionParamsIds : Array = null;

		override public function getUpdateableParamKeys():Array
		{
			var arr : Array;
			arr = super.getUpdateableParamKeys();
			arr.push('targetServiceUrl');
			arr.push('targetAccountId');
			arr.push('targetLoginId');
			arr.push('targetLoginPassword');
			arr.push('metadataXslt');
			arr.push('metadataXpathsTriggerUpdate');
			arr.push('distributeCaptions');
			arr.push('distributeCuePoints');
			arr.push('distributeRemoteFlavorAssetContent');
			arr.push('distributeRemoteThumbAssetContent');
			arr.push('distributeRemoteCaptionAssetContent');
			arr.push('mapAccessControlProfileIds');
			arr.push('mapConversionProfileIds');
			arr.push('mapMetadataProfileIds');
			arr.push('mapStorageProfileIds');
			arr.push('mapFlavorParamsIds');
			arr.push('mapThumbParamsIds');
			arr.push('mapCaptionParamsIds');
			return arr;
		}

		override public function getInsertableParamKeys():Array
		{
			var arr : Array;
			arr = super.getInsertableParamKeys();
			return arr;
		}

		override public function getElementType(arrayName:String):String
		{
			var result:String = '';
			switch (arrayName) {
				case 'metadataXpathsTriggerUpdate':
					result = 'VidiunStringValue';
					break;
				case 'mapAccessControlProfileIds':
					result = 'VidiunKeyValue';
					break;
				case 'mapConversionProfileIds':
					result = 'VidiunKeyValue';
					break;
				case 'mapMetadataProfileIds':
					result = 'VidiunKeyValue';
					break;
				case 'mapStorageProfileIds':
					result = 'VidiunKeyValue';
					break;
				case 'mapFlavorParamsIds':
					result = 'VidiunKeyValue';
					break;
				case 'mapThumbParamsIds':
					result = 'VidiunKeyValue';
					break;
				case 'mapCaptionParamsIds':
					result = 'VidiunKeyValue';
					break;
				default:
					result = super.getElementType(arrayName);
					break;
			}
			return result;
		}
	}
}
