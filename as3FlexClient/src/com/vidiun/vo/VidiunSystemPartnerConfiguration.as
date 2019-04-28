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
	import com.vidiun.vo.VidiunBaseEntryFilter;

	import com.vidiun.vo.BaseFlexVo;

	[Bindable]
	public dynamic class VidiunSystemPartnerConfiguration extends BaseFlexVo
	{
		/**
		**/
		public var id : int = int.MIN_VALUE;

		/**
		**/
		public var partnerName : String = null;

		/**
		**/
		public var description : String = null;

		/**
		**/
		public var adminName : String = null;

		/**
		**/
		public var adminEmail : String = null;

		/**
		**/
		public var host : String = null;

		/**
		**/
		public var cdnHost : String = null;

		/**
		**/
		public var thumbnailHost : String = null;

		/**
		**/
		public var partnerPackage : int = int.MIN_VALUE;

		/**
		**/
		public var monitorUsage : int = int.MIN_VALUE;

		/**
		* @see com.vidiun.types.vidiunBoolean
		**/
		public var moderateContent : Boolean;

		/**
		**/
		public var rtmpUrl : String = null;

		/**
		* @see com.vidiun.types.vidiunBoolean
		**/
		public var storageDeleteFromVidiun : Boolean;

		/**
		* @see com.vidiun.types.VidiunStorageServePriority
		**/
		public var storageServePriority : int = int.MIN_VALUE;

		/**
		**/
		public var vmcVersion : int = int.MIN_VALUE;

		/**
		**/
		public var restrictThumbnailByVs : int = int.MIN_VALUE;

		/**
		* @see com.vidiun.types.vidiunBoolean
		**/
		public var supportAnimatedThumbnails : Boolean;

		/**
		**/
		public var defThumbOffset : int = int.MIN_VALUE;

		/**
		**/
		public var defThumbDensity : int = int.MIN_VALUE;

		/**
		**/
		public var userSessionRoleId : int = int.MIN_VALUE;

		/**
		**/
		public var adminSessionRoleId : int = int.MIN_VALUE;

		/**
		**/
		public var alwaysAllowedPermissionNames : String = null;

		/**
		* @see com.vidiun.types.vidiunBoolean
		**/
		public var importRemoteSourceForConvert : Boolean;

		/**
		**/
		public var permissions : Array = null;

		/**
		**/
		public var notificationsConfig : String = null;

		/**
		* @see com.vidiun.types.vidiunBoolean
		**/
		public var allowMultiNotification : Boolean;

		/**
		**/
		public var loginBlockPeriod : int = int.MIN_VALUE;

		/**
		**/
		public var numPrevPassToKeep : int = int.MIN_VALUE;

		/**
		**/
		public var passReplaceFreq : int = int.MIN_VALUE;

		/**
		* @see com.vidiun.types.vidiunBoolean
		**/
		public var isFirstLogin : Boolean;

		/**
		* @see com.vidiun.types.VidiunPartnerGroupType
		**/
		public var partnerGroupType : int = int.MIN_VALUE;

		/**
		**/
		public var partnerParentId : int = int.MIN_VALUE;

		/**
		**/
		public var limits : Array = null;

		/**
		* http/rtmp/hdnetwork
		* 
		**/
		public var streamerType : String = null;

		/**
		* http/https, rtmp/rtmpe
		* 
		**/
		public var mediaProtocol : String = null;

		/**
		**/
		public var extendedFreeTrailExpiryReason : String = null;

		/**
		* Unix timestamp (In seconds)
		* 
		**/
		public var extendedFreeTrailExpiryDate : int = int.MIN_VALUE;

		/**
		**/
		public var extendedFreeTrail : int = int.MIN_VALUE;

		/**
		**/
		public var crmId : String = null;

		/**
		**/
		public var crmLink : String = null;

		/**
		**/
		public var verticalClasiffication : String = null;

		/**
		**/
		public var partnerPackageClassOfService : String = null;

		/**
		* @see com.vidiun.types.vidiunBoolean
		**/
		public var enableBulkUploadNotificationsEmails : Boolean;

		/**
		**/
		public var deliveryRestrictions : String = null;

		/**
		**/
		public var bulkUploadNotificationsEmail : String = null;

		/**
		* @see com.vidiun.types.vidiunBoolean
		**/
		public var internalUse : Boolean;

		/**
		* @see com.vidiun.types.VidiunSourceType
		**/
		public var defaultLiveStreamEntrySourceType : String = null;

		/**
		**/
		public var liveStreamProvisionParams : String = null;

		/**
		**/
		public var autoModerateEntryFilter : VidiunBaseEntryFilter;

		/**
		**/
		public var logoutUrl : String = null;

		/**
		* @see com.vidiun.types.vidiunBoolean
		**/
		public var defaultEntitlementEnforcement : Boolean;

		/**
		**/
		public var cacheFlavorVersion : int = int.MIN_VALUE;

		/**
		**/
		public var apiAccessControlId : int = int.MIN_VALUE;

		/**
		**/
		public var defaultDeliveryType : String = null;

		/**
		**/
		public var defaultEmbedCodeType : String = null;

		/**
		**/
		public var disabledDeliveryTypes : Array = null;

		/**
		* @see com.vidiun.types.vidiunBoolean
		**/
		public var restrictEntryByMetadata : Boolean;

		/**
		* @see com.vidiun.types.VidiunLanguageCode
		**/
		public var language : String = null;

		/** 
		* a list of attributes which may be updated on this object 
		**/ 
		public function getUpdateableParamKeys():Array
		{
			var arr : Array;
			arr = new Array();
			arr.push('partnerName');
			arr.push('description');
			arr.push('adminName');
			arr.push('adminEmail');
			arr.push('host');
			arr.push('cdnHost');
			arr.push('thumbnailHost');
			arr.push('partnerPackage');
			arr.push('monitorUsage');
			arr.push('moderateContent');
			arr.push('rtmpUrl');
			arr.push('storageDeleteFromVidiun');
			arr.push('storageServePriority');
			arr.push('vmcVersion');
			arr.push('restrictThumbnailByVs');
			arr.push('supportAnimatedThumbnails');
			arr.push('defThumbOffset');
			arr.push('defThumbDensity');
			arr.push('userSessionRoleId');
			arr.push('adminSessionRoleId');
			arr.push('alwaysAllowedPermissionNames');
			arr.push('importRemoteSourceForConvert');
			arr.push('permissions');
			arr.push('notificationsConfig');
			arr.push('allowMultiNotification');
			arr.push('loginBlockPeriod');
			arr.push('numPrevPassToKeep');
			arr.push('passReplaceFreq');
			arr.push('isFirstLogin');
			arr.push('partnerGroupType');
			arr.push('partnerParentId');
			arr.push('limits');
			arr.push('streamerType');
			arr.push('mediaProtocol');
			arr.push('extendedFreeTrailExpiryReason');
			arr.push('extendedFreeTrailExpiryDate');
			arr.push('extendedFreeTrail');
			arr.push('crmId');
			arr.push('crmLink');
			arr.push('verticalClasiffication');
			arr.push('partnerPackageClassOfService');
			arr.push('enableBulkUploadNotificationsEmails');
			arr.push('deliveryRestrictions');
			arr.push('bulkUploadNotificationsEmail');
			arr.push('internalUse');
			arr.push('defaultLiveStreamEntrySourceType');
			arr.push('liveStreamProvisionParams');
			arr.push('autoModerateEntryFilter');
			arr.push('logoutUrl');
			arr.push('defaultEntitlementEnforcement');
			arr.push('cacheFlavorVersion');
			arr.push('apiAccessControlId');
			arr.push('defaultDeliveryType');
			arr.push('defaultEmbedCodeType');
			arr.push('disabledDeliveryTypes');
			arr.push('restrictEntryByMetadata');
			arr.push('language');
			return arr;
		}

		/** 
		* a list of attributes which may only be inserted when initializing this object 
		**/ 
		public function getInsertableParamKeys():Array
		{
			var arr : Array;
			arr = new Array();
			return arr;
		}

		/** 
		* get the expected type of array elements 
		* @param arrayName 	 name of an attribute of type array of the current object 
		* @return 	 un-qualified class name 
		**/ 
		public function getElementType(arrayName:String):String
		{
			var result:String = '';
			switch (arrayName) {
				case 'permissions':
					result = 'VidiunPermission';
					break;
				case 'limits':
					result = 'VidiunSystemPartnerLimit';
					break;
				case 'autoModerateEntryFilter':
					result = '';
					break;
				case 'disabledDeliveryTypes':
					result = 'VidiunString';
					break;
			}
			return result;
		}
	}
}
