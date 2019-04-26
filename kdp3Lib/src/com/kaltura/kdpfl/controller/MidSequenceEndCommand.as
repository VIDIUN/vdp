package com.vidiun.vdpfl.controller
{
	import com.vidiun.vdpfl.model.MediaProxy;
	import com.vidiun.vdpfl.model.SequenceProxy;
	import com.vidiun.vdpfl.model.type.NotificationType;
	import com.vidiun.osmf.proxy.VSwitchingProxyElement;
	
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.command.SimpleCommand;
	
	public class MidSequenceEndCommand extends SimpleCommand
	{
		public function MidSequenceEndCommand()
		{
			super();
		}
		
		override public function execute(notification:INotification):void
		{
			var mediaProxy : MediaProxy = facade.retrieveProxy( MediaProxy.NAME ) as MediaProxy;
			var sequenceProxy : SequenceProxy = facade.retrieveProxy( SequenceProxy.NAME ) as SequenceProxy;
			if ((mediaProxy.vo.media as VSwitchingProxyElement).proxiedElement != (mediaProxy.vo.media as VSwitchingProxyElement).mainMediaElement)
			{
				(mediaProxy.vo.media as VSwitchingProxyElement).switchElements();
			}
			sequenceProxy.vo.midrollArr = new Array();
			sequenceProxy.vo.midCurrentIndex = -1;
			sequenceProxy.vo.isInSequence = false;
			sendNotification( NotificationType.DO_PLAY );
		}
	}
}