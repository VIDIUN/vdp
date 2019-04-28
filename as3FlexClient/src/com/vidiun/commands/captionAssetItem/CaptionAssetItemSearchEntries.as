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
package com.vidiun.commands.captionAssetItem
{
		import com.vidiun.vo.VidiunBaseEntryFilter;
		import com.vidiun.vo.VidiunCaptionAssetItemFilter;
		import com.vidiun.vo.VidiunFilterPager;
	import com.vidiun.delegates.captionAssetItem.CaptionAssetItemSearchEntriesDelegate;
	import com.vidiun.net.VidiunCall;

	/**
	* Search caption asset items by filter, pager and free text
	* 
	**/
	public class CaptionAssetItemSearchEntries extends VidiunCall
	{
		public var filterFields : String;
		
		/**
		* @param entryFilter VidiunBaseEntryFilter
		* @param captionAssetItemFilter VidiunCaptionAssetItemFilter
		* @param captionAssetItemPager VidiunFilterPager
		**/
		public function CaptionAssetItemSearchEntries( entryFilter : VidiunBaseEntryFilter=null,captionAssetItemFilter : VidiunCaptionAssetItemFilter=null,captionAssetItemPager : VidiunFilterPager=null )
		{
			service= 'captionsearch_captionassetitem';
			action= 'searchEntries';

			var keyArr : Array = new Array();
			var valueArr : Array = new Array();
			var keyValArr : Array = new Array();
			if (entryFilter) { 
				keyValArr = vidiunObject2Arrays(entryFilter, 'entryFilter');
				keyArr = keyArr.concat(keyValArr[0]);
				valueArr = valueArr.concat(keyValArr[1]);
			} 
			if (captionAssetItemFilter) { 
				keyValArr = vidiunObject2Arrays(captionAssetItemFilter, 'captionAssetItemFilter');
				keyArr = keyArr.concat(keyValArr[0]);
				valueArr = valueArr.concat(keyValArr[1]);
			} 
			if (captionAssetItemPager) { 
				keyValArr = vidiunObject2Arrays(captionAssetItemPager, 'captionAssetItemPager');
				keyArr = keyArr.concat(keyValArr[0]);
				valueArr = valueArr.concat(keyValArr[1]);
			} 
			applySchema(keyArr, valueArr);
		}

		override public function execute() : void
		{
			setRequestArgument('filterFields', filterFields);
			delegate = new CaptionAssetItemSearchEntriesDelegate( this , config );
		}
	}
}
