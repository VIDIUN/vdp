package com.vidiun.osmf.vidiunMix
{
	import com.vidiun.components.players.eplayer.Eplayer;
	
	import org.osmf.traits.AudioTrait;

	public class VidiunMixAudioTrait extends AudioTrait
	{
		public var eplayer:Eplayer;

		public function VidiunMixAudioTrait(_eplayer:Eplayer)
		{
			eplayer = _eplayer;
			super();
		}
		
		/**
		 * @inheritDoc
		 */		
		override protected function volumeChangeStart(newVolume:Number):void
		{
			eplayer.setOverAllVolume(muted ? 0 : newVolume);
		}
		
		/**
		 * @inheritDoc
		 */
		override protected function mutedChangeStart(newMuted:Boolean):void
		{
			eplayer.setOverAllVolume(newMuted ? 0 : volume);
		}
	}
}