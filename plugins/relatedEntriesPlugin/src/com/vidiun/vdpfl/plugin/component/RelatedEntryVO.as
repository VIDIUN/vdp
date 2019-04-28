package com.vidiun.vdpfl.plugin.component
{
	import com.vidiun.vo.VidiunBaseEntry;
	
	import mx.utils.ObjectProxy;

	[Bindable]
	/**
	 * This class represents related entry object 
	 * @author michalr
	 * 
	 */	
	public class RelatedEntryVO extends ObjectProxy
	{
		/**
		 * Vidiun entry object 
		 */		
		public var entry:VidiunBaseEntry;
		/**
		 * is this the next selected entry 
		 */		
		public var isUpNext:Boolean;
		
		public var isOver:Boolean;
		
		public function RelatedEntryVO(entry:VidiunBaseEntry, isUpNext:Boolean = false)
		{
			this.entry = entry;
			this.isUpNext = isUpNext;
		}
	}
}