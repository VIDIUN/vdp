package com.vidiun.osmf.vidiunMix
{
	import com.vidiun.components.players.eplayer.Eplayer;
	
	import org.osmf.media.LoadableElementBase;
	import org.osmf.media.MediaResourceBase;
	import org.osmf.traits.DisplayObjectTrait;
	import org.osmf.traits.LoadTrait;
	import org.osmf.traits.LoaderBase;
	import org.osmf.traits.MediaTraitBase;
	import org.osmf.traits.MediaTraitType;
	import org.osmf.traits.TimeTrait;
	/**
	 * Class VidiunMixElement extends the OSMF with a unique element which is constructed from snippets of different videos. 
	 * It has all the traits as a regular MediaElement
	 * @author Hila
	 * 
	 */	
	public class VidiunMixElement extends LoadableElementBase
	{
		public var disableUrlHashing:Boolean = false;
		/**
		 * Constructor 
		 * @param loader
		 * @param resource
		 * 
		 */		
		public function VidiunMixElement(loader:LoaderBase, resource:MediaResourceBase=null)
		{
			super(resource, loader);
		}
		
		/**
		 * @inheritDoc
		 */
		override protected function createLoadTrait(resource:MediaResourceBase, loader:LoaderBase):LoadTrait
		{
			return new VidiunMixLoadTrait(loader, resource);
		}
       	
		/**
		 * @inheritDoc
		 */
		override protected function processReadyState():void
		{
			
			//Remove all exsiting traits before loading; required for restoring media after sequence plugins have played.
			//Has no backward-compatibility issues
			while (traitTypes.length != 1)
			{
				if ( traitTypes[1] != MediaTraitType.LOAD )
				{
					removeTrait( traitTypes[1]);
				}
			}
			//var loadTrait:LoadTrait = getTrait(MediaTraitType.LOAD) as LoadTrait;
			var vidiunMixsprite:VidiunMixSprite = new VidiunMixSprite(this, 640, 480,disableUrlHashing);
			var eplayer:Eplayer = vidiunMixsprite.eplayer;
	    	addTrait(MediaTraitType.AUDIO, new VidiunMixAudioTrait(eplayer));
	    	addTrait(MediaTraitType.BUFFER, new VidiunMixBufferTrait(eplayer));
			var timeTrait:TimeTrait = new VidiunMixTimeTrait(eplayer);
			addTrait(MediaTraitType.TIME, timeTrait);
			var displayObjectTrait:DisplayObjectTrait = new VidiunMixViewTrait(vidiunMixsprite, 640, 480);
    		addTrait(MediaTraitType.SEEK, new VidiunMixSeekTrait(timeTrait, eplayer));
			addTrait(MediaTraitType.DISPLAY_OBJECT, displayObjectTrait);
			addTrait(MediaTraitType.PLAY, new VidiunMixPlayTrait(eplayer));
			
		}
		
		public function cleanMedia () : void
		{
			
		}
		
	}
}