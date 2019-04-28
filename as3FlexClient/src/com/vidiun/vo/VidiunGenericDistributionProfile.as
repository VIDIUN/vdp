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
	import com.vidiun.vo.VidiunGenericDistributionProfileAction;

	import com.vidiun.vo.VidiunGenericDistributionProfileAction;

	import com.vidiun.vo.VidiunGenericDistributionProfileAction;

	import com.vidiun.vo.VidiunGenericDistributionProfileAction;

	import com.vidiun.vo.VidiunDistributionProfile;

	[Bindable]
	public dynamic class VidiunGenericDistributionProfile extends VidiunDistributionProfile
	{
		/**
		**/
		public var genericProviderId : int = int.MIN_VALUE;

		/**
		**/
		public var submitAction : VidiunGenericDistributionProfileAction;

		/**
		**/
		public var updateAction : VidiunGenericDistributionProfileAction;

		/**
		**/
		public var deleteAction : VidiunGenericDistributionProfileAction;

		/**
		**/
		public var fetchReportAction : VidiunGenericDistributionProfileAction;

		/**
		**/
		public var updateRequiredEntryFields : String = null;

		/**
		**/
		public var updateRequiredMetadataXPaths : String = null;

		override public function getUpdateableParamKeys():Array
		{
			var arr : Array;
			arr = super.getUpdateableParamKeys();
			arr.push('submitAction');
			arr.push('updateAction');
			arr.push('deleteAction');
			arr.push('fetchReportAction');
			arr.push('updateRequiredEntryFields');
			arr.push('updateRequiredMetadataXPaths');
			return arr;
		}

		override public function getInsertableParamKeys():Array
		{
			var arr : Array;
			arr = super.getInsertableParamKeys();
			arr.push('genericProviderId');
			return arr;
		}

		override public function getElementType(arrayName:String):String
		{
			var result:String = '';
			switch (arrayName) {
				case 'submitAction':
					result = '';
					break;
				case 'updateAction':
					result = '';
					break;
				case 'deleteAction':
					result = '';
					break;
				case 'fetchReportAction':
					result = '';
					break;
				default:
					result = super.getElementType(arrayName);
					break;
			}
			return result;
		}
	}
}
