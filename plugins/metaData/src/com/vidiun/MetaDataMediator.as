package com.vidiun
{
	import com.vidiun.commands.metadata.MetadataList;
	import com.vidiun.events.VidiunEvent;
	import com.vidiun.vdpfl.util.XMLUtils;
	import com.vidiun.puremvc.as3.patterns.mediator.SequenceMultiMediator;
	import com.vidiun.types.VidiunMetadataObjectType;
	import com.vidiun.vo.VidiunMetadata;
	import com.vidiun.vo.VidiunMetadataFilter;
	import com.vidiun.vo.VidiunMetadataListResponse;VidiunMetadata;

	
	public class MetaDataMediator extends SequenceMultiMediator
	{
		
		
		
		public function MetaDataMediator(viewComponent : Object=null)
		{
			super(viewComponent);
			facade["bindObject"]["metaData"] = viewComponent;
		}
		
		
		
		public function start () : void
		{
			var vc : VidiunClient = facade.retrieveProxy("servicesProxy")["vidiunClient"] as VidiunClient;
			var entryId : String = facade.retrieveProxy("mediaProxy")["vo"]["entry"]["id"];
			var metadataFilter : VidiunMetadataFilter = new VidiunMetadataFilter();
			metadataFilter.metadataObjectTypeEqual = VidiunMetadataObjectType.ENTRY;
			metadataFilter.objectIdEqual = entryId;
			var metaDataList : MetadataList = new MetadataList(metadataFilter);
			metaDataList.addEventListener(VidiunEvent.COMPLETE, onMetadataReceived);
			metaDataList.addEventListener( VidiunEvent.FAILED, onMetadataFailed );
			vc.post( metaDataList );
		}
		
		private function onMetadataReceived (e : VidiunEvent) : void
		{
			viewComponent["metaData"] = new Object();
			var listResponse : VidiunMetadataListResponse = e.data as VidiunMetadataListResponse;
			if ( listResponse.objects[0])
			{
				var metadataXml : XMLList = XML(listResponse.objects[0]["xml"]).children();
				var metaDataObj : Object = new Object();
				for each (var node : XML in metadataXml)
				{
					metaDataObj[node.name().toString()] = node.valueOf().toString();
				}
				viewComponent["metaData"] = metaDataObj;
			}
			sendNotification("sequenceItemPlayEnd");
		}
		
		private function onMetadataFailed ( e: VidiunEvent) : void
		{
			trace("metadata failed");
			sendNotification("sequenceItemPlayEnd");
		}
	}
}