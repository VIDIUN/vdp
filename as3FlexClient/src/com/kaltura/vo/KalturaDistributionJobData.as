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
	import com.vidiun.vo.VidiunDistributionJobProviderData;

	import com.vidiun.vo.VidiunEntryDistribution;

	import com.vidiun.vo.VidiunDistributionProfile;

	import com.vidiun.vo.VidiunJobData;

	[Bindable]
	public dynamic class VidiunDistributionJobData extends VidiunJobData
	{
		/**
		**/
		public var distributionProfileId : int = int.MIN_VALUE;

		/**
		**/
		public var distributionProfile : VidiunDistributionProfile;

		/**
		**/
		public var entryDistributionId : int = int.MIN_VALUE;

		/**
		**/
		public var entryDistribution : VidiunEntryDistribution;

		/**
		* Id of the media in the remote system
		* 
		**/
		public var remoteId : String = null;

		/**
		* @see com.vidiun.types.VidiunDistributionProviderType
		**/
		public var providerType : String = null;

		/**
		* Additional data that relevant for the provider only
		* 
		**/
		public var providerData : VidiunDistributionJobProviderData;

		/**
		* The results as returned from the remote destination
		* 
		**/
		public var results : String = null;

		/**
		* The data as sent to the remote destination
		* 
		**/
		public var sentData : String = null;

		/**
		* Stores array of media files that submitted to the destination site
		* Could be used later for media update
		* 
		**/
		public var mediaFiles : Array = null;

		override public function getUpdateableParamKeys():Array
		{
			var arr : Array;
			arr = super.getUpdateableParamKeys();
			arr.push('distributionProfileId');
			arr.push('distributionProfile');
			arr.push('entryDistributionId');
			arr.push('entryDistribution');
			arr.push('remoteId');
			arr.push('providerType');
			arr.push('providerData');
			arr.push('results');
			arr.push('sentData');
			arr.push('mediaFiles');
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
				case 'distributionProfile':
					result = '';
					break;
				case 'entryDistribution':
					result = '';
					break;
				case 'providerData':
					result = '';
					break;
				case 'mediaFiles':
					result = 'VidiunDistributionRemoteMediaFile';
					break;
				default:
					result = super.getElementType(arrayName);
					break;
			}
			return result;
		}
	}
}
