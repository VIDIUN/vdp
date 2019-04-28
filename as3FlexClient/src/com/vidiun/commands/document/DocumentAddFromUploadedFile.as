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
package com.vidiun.commands.document
{
		import com.vidiun.vo.VidiunDocumentEntry;
	import com.vidiun.delegates.document.DocumentAddFromUploadedFileDelegate;
	import com.vidiun.net.VidiunCall;

	/**
	* Add new document entry after the specific document file was uploaded and the upload token id exists
	* 
	**/
	public class DocumentAddFromUploadedFile extends VidiunCall
	{
		public var filterFields : String;
		
		/**
		* @param documentEntry VidiunDocumentEntry
		* @param uploadTokenId String
		**/
		public function DocumentAddFromUploadedFile( documentEntry : VidiunDocumentEntry,uploadTokenId : String )
		{
			service= 'document';
			action= 'addFromUploadedFile';

			var keyArr : Array = new Array();
			var valueArr : Array = new Array();
			var keyValArr : Array = new Array();
				keyValArr = vidiunObject2Arrays(documentEntry, 'documentEntry');
				keyArr = keyArr.concat(keyValArr[0]);
				valueArr = valueArr.concat(keyValArr[1]);
			keyArr.push('uploadTokenId');
			valueArr.push(uploadTokenId);
			applySchema(keyArr, valueArr);
		}

		override public function execute() : void
		{
			setRequestArgument('filterFields', filterFields);
			delegate = new DocumentAddFromUploadedFileDelegate( this , config );
		}
	}
}
