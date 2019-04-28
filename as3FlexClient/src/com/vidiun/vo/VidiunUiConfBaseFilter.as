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
	import com.vidiun.vo.VidiunFilter;

	[Bindable]
	public dynamic class VidiunUiConfBaseFilter extends VidiunFilter
	{
		/**
		**/
		public var idEqual : int = int.MIN_VALUE;

		/**
		**/
		public var idIn : String = null;

		/**
		**/
		public var nameLike : String = null;

		/**
		**/
		public var partnerIdEqual : int = int.MIN_VALUE;

		/**
		**/
		public var partnerIdIn : String = null;

		/**
		* @see com.vidiun.types.VidiunUiConfObjType
		**/
		public var objTypeEqual : int = int.MIN_VALUE;

		/**
		**/
		public var objTypeIn : String = null;

		/**
		**/
		public var tagsMultiLikeOr : String = null;

		/**
		**/
		public var tagsMultiLikeAnd : String = null;

		/**
		**/
		public var createdAtGreaterThanOrEqual : int = int.MIN_VALUE;

		/**
		**/
		public var createdAtLessThanOrEqual : int = int.MIN_VALUE;

		/**
		**/
		public var updatedAtGreaterThanOrEqual : int = int.MIN_VALUE;

		/**
		**/
		public var updatedAtLessThanOrEqual : int = int.MIN_VALUE;

		/**
		* @see com.vidiun.types.VidiunUiConfCreationMode
		**/
		public var creationModeEqual : int = int.MIN_VALUE;

		/**
		**/
		public var creationModeIn : String = null;

		/**
		**/
		public var versionEqual : String = null;

		/**
		**/
		public var versionMultiLikeOr : String = null;

		/**
		**/
		public var versionMultiLikeAnd : String = null;

		/**
		**/
		public var partnerTagsMultiLikeOr : String = null;

		/**
		**/
		public var partnerTagsMultiLikeAnd : String = null;

		override public function getUpdateableParamKeys():Array
		{
			var arr : Array;
			arr = super.getUpdateableParamKeys();
			arr.push('idEqual');
			arr.push('idIn');
			arr.push('nameLike');
			arr.push('partnerIdEqual');
			arr.push('partnerIdIn');
			arr.push('objTypeEqual');
			arr.push('objTypeIn');
			arr.push('tagsMultiLikeOr');
			arr.push('tagsMultiLikeAnd');
			arr.push('createdAtGreaterThanOrEqual');
			arr.push('createdAtLessThanOrEqual');
			arr.push('updatedAtGreaterThanOrEqual');
			arr.push('updatedAtLessThanOrEqual');
			arr.push('creationModeEqual');
			arr.push('creationModeIn');
			arr.push('versionEqual');
			arr.push('versionMultiLikeOr');
			arr.push('versionMultiLikeAnd');
			arr.push('partnerTagsMultiLikeOr');
			arr.push('partnerTagsMultiLikeAnd');
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
				default:
					result = super.getElementType(arrayName);
					break;
			}
			return result;
		}
	}
}
