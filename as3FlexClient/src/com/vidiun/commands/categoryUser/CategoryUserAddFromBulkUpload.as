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
package com.vidiun.commands.categoryUser
{
		import flash.net.FileReference;
		import com.vidiun.net.VidiunFileCall;
		import com.vidiun.vo.VidiunBulkUploadJobData;
		import com.vidiun.vo.VidiunBulkUploadCategoryUserData;
	import com.vidiun.delegates.categoryUser.CategoryUserAddFromBulkUploadDelegate;

	/**
	**/
	public class CategoryUserAddFromBulkUpload extends VidiunFileCall
	{
		public var fileData:Object;

		
		/**
		* @param fileData Object - FileReference or ByteArray
		* @param bulkUploadData VidiunBulkUploadJobData
		* @param bulkUploadCategoryUserData VidiunBulkUploadCategoryUserData
		**/
		public function CategoryUserAddFromBulkUpload( fileData : Object,bulkUploadData : VidiunBulkUploadJobData=null,bulkUploadCategoryUserData : VidiunBulkUploadCategoryUserData=null )
		{
			service= 'categoryuser';
			action= 'addFromBulkUpload';

			var keyArr : Array = new Array();
			var valueArr : Array = new Array();
			var keyValArr : Array = new Array();
			this.fileData = fileData;
			if (bulkUploadData) { 
				keyValArr = vidiunObject2Arrays(bulkUploadData, 'bulkUploadData');
				keyArr = keyArr.concat(keyValArr[0]);
				valueArr = valueArr.concat(keyValArr[1]);
			} 
			if (bulkUploadCategoryUserData) { 
				keyValArr = vidiunObject2Arrays(bulkUploadCategoryUserData, 'bulkUploadCategoryUserData');
				keyArr = keyArr.concat(keyValArr[0]);
				valueArr = valueArr.concat(keyValArr[1]);
			} 
			applySchema(keyArr, valueArr);
		}

		override public function execute() : void
		{
			setRequestArgument('filterFields', filterFields);
			delegate = new CategoryUserAddFromBulkUploadDelegate( this , config );
		}
	}
}
