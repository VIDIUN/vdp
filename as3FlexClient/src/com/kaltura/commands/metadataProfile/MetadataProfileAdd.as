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
package com.vidiun.commands.metadataProfile
{
		import com.vidiun.vo.VidiunMetadataProfile;
	import com.vidiun.delegates.metadataProfile.MetadataProfileAddDelegate;
	import com.vidiun.net.VidiunCall;

	/**
	* Allows you to add a metadata profile object and metadata profile content associated with Vidiun object type
	* 
	**/
	public class MetadataProfileAdd extends VidiunCall
	{
		public var filterFields : String;
		
		/**
		* @param metadataProfile VidiunMetadataProfile
		* @param xsdData String
		* @param viewsData String
		**/
		public function MetadataProfileAdd( metadataProfile : VidiunMetadataProfile,xsdData : String,viewsData : String = null )
		{
			service= 'metadata_metadataprofile';
			action= 'add';

			var keyArr : Array = new Array();
			var valueArr : Array = new Array();
			var keyValArr : Array = new Array();
				keyValArr = vidiunObject2Arrays(metadataProfile, 'metadataProfile');
				keyArr = keyArr.concat(keyValArr[0]);
				valueArr = valueArr.concat(keyValArr[1]);
			keyArr.push('xsdData');
			valueArr.push(xsdData);
			keyArr.push('viewsData');
			valueArr.push(viewsData);
			applySchema(keyArr, valueArr);
		}

		override public function execute() : void
		{
			setRequestArgument('filterFields', filterFields);
			delegate = new MetadataProfileAddDelegate( this , config );
		}
	}
}
