package com.vidiun.osmf.vidiunMix
{
	import com.vidiun.osmf.vidiun.VidiunBaseEntryResource;
	import com.vidiun.vo.VidiunMixEntry;
	
	import org.osmf.media.MediaResourceBase;
	import org.osmf.traits.LoadState;
	import org.osmf.traits.LoadTrait;
	import org.osmf.traits.LoaderBase;

	public class VidiunMixLoader extends LoaderBase
	{
		public function VidiunMixLoader()
		{
			super();
		}
		
		/**
		 * @inheritDoc
		 */
		override protected function executeLoad(loadTrait:LoadTrait):void
		{	
			updateLoadTrait(loadTrait, LoadState.LOADING);
			updateLoadTrait(loadTrait, LoadState.READY);		
		}
		
		/**
		 * @inheritDoc
		 */
		override protected function executeUnload(loadTrait:LoadTrait):void
		{
			updateLoadTrait(loadTrait, LoadState.UNLOADING); 			
			updateLoadTrait(loadTrait, LoadState.UNINITIALIZED); 
							
		}
		
		/**
		 * @inheritDoc
		 */
		override public function canHandleResource(resource:MediaResourceBase):Boolean
		{
			//if (resource is VidiunEntryResource && (resource as VidiunEntryResource).entry is VidiunEntry)
			//	return true;
			if (resource is VidiunBaseEntryResource && (resource as VidiunBaseEntryResource).entry is VidiunMixEntry)
				return true;
				
			return false;
		}
		
	}
}