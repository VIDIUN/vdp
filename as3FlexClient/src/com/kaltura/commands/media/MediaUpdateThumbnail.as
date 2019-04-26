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
	import com.vidiun.delegates.media.MediaUpdateThumbnailDelegate;
	import com.vidiun.net.VidiunCall;

	/**
	* Update media entry thumbnail by a specified time offset (In seconds)
	* If flavor params id not specified, source flavor will be used by default
	* 
	**/
	public class MediaUpdateThumbnail extends VidiunCall
	{
		public var filterFields : String;
		
		/**
		* @param entryId String
		* @param timeOffset int
		* @param flavorParamsId int
		**/
		public function MediaUpdateThumbnail( entryId : String,timeOffset : int,flavorParamsId : int=int.MIN_VALUE )
		{
			service= 'media';
			action= 'updateThumbnail';

			var keyArr : Array = new Array();
			var valueArr : Array = new Array();
			var keyValArr : Array = new Array();
			keyArr.push('entryId');
			valueArr.push(entryId);
			keyArr.push('timeOffset');
			valueArr.push(timeOffset);
			keyArr.push('flavorParamsId');
			valueArr.push(flavorParamsId);
			applySchema(keyArr, valueArr);
		}

		override public function execute() : void
		{
			setRequestArgument('filterFields', filterFields);
			delegate = new MediaUpdateThumbnailDelegate( this , config );
		}
	}
}
