package com.vidiun.vdpfl.plugin.component
{
	import com.vidiun.vo.VidiunPlayableEntry;
	
	import mx.utils.ObjectProxy;
	
	[Bindable]
	/**
	 * This class represents playlist entry object 
	 * @author michalr
	 * 
	 */	
	public class PlaylistEntryVO extends ObjectProxy
	{
		/**
		 * Vidiun entry object 
		 */		
		public var entry:VidiunPlayableEntry;
		
		public var isOver:Boolean;
		
		public function PlaylistEntryVO(entry:VidiunPlayableEntry)
		{
			this.entry = entry;

		}
		
		//////////////////////////////////////////////////////////////////////
		// the following getters are required to keep backward compatibility
		//////////////////////////////////////////////////////////////////////
		
		public function get name():String
		{
			return entry.name;
		}
	
		public function get thumbnailUrl():String
		{
			return entry.thumbnailUrl;
		}

		public function get description():String
		{
			return entry.description;
		}
	
		public function get duration():int
		{
			return entry.duration;
		}
		
		public function get rank():Number
		{
			return entry.rank;
		}

		public function get plays():int
		{
			return entry.plays;
		}

		public function get votes():int
		{
			return entry.votes;
		}

		public function get entryId():String
		{
			return entry.entryId ? entry.entryId : entry.id;
		}

		public function get tags():String{
			return entry.tags;
		}

		public function get categories():String{
			return entry.categories;
		}

		public function get createdAt():int{
			return entry.createdAt;
		}
		
		public function get userScreenName():String
		{
			return entry.userScreenName;
		}
		
	}
}