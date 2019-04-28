package com.vidiun.osmf.vidiunMix
{
	import com.vidiun.assets.assets.VoiceAsset;
	import com.vidiun.components.players.eplayer.Eplayer;
	
	import org.osmf.events.SeekEvent;
	import org.osmf.traits.SeekTrait;
	import org.osmf.traits.TimeTrait;

	public class VidiunMixSeekTrait extends SeekTrait
	{
		public var eplayer:Eplayer;

		public function VidiunMixSeekTrait(timeTrait:TimeTrait, _eplayer:Eplayer)
		{
			super(timeTrait);
			eplayer = _eplayer;
			//eplayer.addEventListener(SeekEvent.SEEK_BEGIN, onSeekBegin);
			
		}
		
		/**
		 * @inheritDoc
		 */
		override protected function seekingChangeStart(newSeeking:Boolean, time:Number):void
		{
			if (newSeeking)
			{
				eplayer.seekSequence(time);
			}
		}
		
		/**
		 * @inheritDoc
		 */
		override protected function seekingChangeEnd(time:Number):void
		//override protected function postProcessSeekingChange(time:Number):void
		{
			super.seekingChangeEnd(time);
			
			// If we just started seeking, finish since this operation is async.
			if (seeking == true)
			{
				setSeeking(false, time);
			}
		}

	}
}