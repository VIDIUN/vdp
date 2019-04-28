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
package com.vidiun.commands.media
{
		import flash.net.FileReference;
		import com.vidiun.net.VidiunFileCall;
		import com.vidiun.vo.VidiunBulkUploadJobData;
		import com.vidiun.vo.VidiunBulkUploadEntryData;
	import com.vidiun.delegates.media.MediaBulkUploadAddDelegate;

	/**
	* Add new bulk upload batch job
	* Conversion profile id can be specified in the API or in the CSV file, the one in the CSV file will be stronger.
	* If no conversion profile was specified, partner's default will be used
	* 
	**/
	public class MediaBulkUploadAdd extends VidiunFileCall
	{
		public var fileData:Object;

		
		/**
		* @param fileData Object - FileReference or ByteArray
		* @param bulkUploadData VidiunBulkUploadJobData
		* @param bulkUploadEntryData VidiunBulkUploadEntryData
		**/
		public function MediaBulkUploadAdd( fileData : Object,bulkUploadData : VidiunBulkUploadJobData=null,bulkUploadEntryData : VidiunBulkUploadEntryData=null )
		{
			service= 'media';
			action= 'bulkUploadAdd';

			var keyArr : Array = new Array();
			var valueArr : Array = new Array();
			var keyValArr : Array = new Array();
			this.fileData = fileData;
			if (bulkUploadData) { 
				keyValArr = vidiunObject2Arrays(bulkUploadData, 'bulkUploadData');
				keyArr = keyArr.concat(keyValArr[0]);
				valueArr = valueArr.concat(keyValArr[1]);
			} 
			if (bulkUploadEntryData) { 
				keyValArr = vidiunObject2Arrays(bulkUploadEntryData, 'bulkUploadEntryData');
				keyArr = keyArr.concat(keyValArr[0]);
				valueArr = valueArr.concat(keyValArr[1]);
			} 
			applySchema(keyArr, valueArr);
		}

		override public function execute() : void
		{
			setRequestArgument('filterFields', filterFields);
			delegate = new MediaBulkUploadAddDelegate( this , config );
		}
	}
}
