package com.kaltura.vo
{
	import com.kaltura.vo.KalturaBaseSyndicationFeedBaseFilter;

	[Bindable]
	public dynamic class KalturaBaseSyndicationFeedFilter extends KalturaBaseSyndicationFeedBaseFilter
	{
		override public function getUpdateableParamKeys():Array
		{
			var arr : Array;
			arr = super.getUpdateableParamKeys();
			return arr;
		}

		override public function getInsertableParamKeys():Array
		{
			var arr : Array;
			arr = super.getInsertableParamKeys();
			return arr;
		}

	}
}
