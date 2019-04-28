package com.vidiun.vdpfl.controller.media
{
	import com.vidiun.vdpfl.model.ConfigProxy;
	import com.vidiun.vdpfl.model.MediaProxy;
	import com.vidiun.vdpfl.model.SequenceProxy;
	import com.vidiun.vdpfl.model.type.NotificationType;
	import com.vidiun.vdpfl.view.media.VMediaPlayer;
	import com.vidiun.vdpfl.view.media.VMediaPlayerMediator;
	
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.command.SimpleCommand;

	/**
	 * PostSequenceEndCommand is called when the pre-sequence of the player is complete. 
	 * The "main-event" media is reloaded into the player and begins to play automatically.
	 * All variables which have to do with the pre-sequence are nullified and the sequence is registered as COMPLETE.
	 */
	public class PreSequenceEndCommand extends SimpleCommand
	{
		override public function execute(notification:INotification):void
		{
			var sequenceProxy : SequenceProxy = facade.retrieveProxy( SequenceProxy.NAME ) as SequenceProxy;
			sequenceProxy.vo.isInSequence = false;
			sequenceProxy.vo.preCurrentIndex = -1;
			sequenceProxy.vo.preSequenceComplete = true;
			var flashvars:Object = (facade.retrieveProxy( ConfigProxy.NAME ) as ConfigProxy).vo.flashvars;
			if (!flashvars.pauseAfterPreSequence || flashvars.pauseAfterPreSequence=="false")
			{
				sendNotification(NotificationType.DO_PLAY);				
			}
			else
			{
				sendNotification(NotificationType.DO_PAUSE);	
				var mediaMediator:VMediaPlayerMediator = facade.retrieveMediator(VMediaPlayerMediator.NAME) as VMediaPlayerMediator;
				mediaMediator.cleanMedia();
				mediaMediator.vMediaPlayer.showThumbnail();
			}
			
		}
	}
}