package com.vidiun.osmf.vidiun
{
	import com.vidiun.vo.VidiunBaseEntry;
	
	import org.osmf.media.MediaResourceBase;

	public class VidiunBaseEntryResource extends MediaResourceBase
	{
		public var entry:VidiunBaseEntry;
		
		public function VidiunBaseEntryResource(_entry:VidiunBaseEntry)
		{
			entry = _entry;
		}

	}
}
