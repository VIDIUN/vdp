package com.vidiun.osmf.vidiunMix
{
	import com.vidiun.vo.VidiunMixEntry;
	
	import org.osmf.media.IMediaResource;
	import org.osmf.metadata.Metadata;

	public class VidiunMixResource implements IMediaResource
	{
		public var entry:VidiunMixEntry;
		
		public function VidiunMixResource(_entry:VidiunMixEntry)
		{
			entry = _entry;
		}

		public function get metadata():Metadata
		{
			return null;
		}
		
	}
}