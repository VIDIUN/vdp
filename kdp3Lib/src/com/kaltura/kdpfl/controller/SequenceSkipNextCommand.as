package com.vidiun.vdpfl.controller
{
	import com.vidiun.vdpfl.model.MediaProxy;
	import com.vidiun.vdpfl.model.SequenceProxy;
	import com.vidiun.vdpfl.model.type.NotificationType;
	
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.command.SimpleCommand;

	/**
	 * Command responsible for skipping a sequence plugin (is the option exists)
	 */	
	public class SequenceSkipNextCommand extends SimpleCommand
	{
		public function SequenceSkipNextCommand()
		{
			super();
		}
		
		/**
		 * If the active plugin has items in its own subsequence, the player shows the next one; Otherwise it moves on to the next plugin
		 * @param notification
		 */		
		override public function execute(notification:INotification):void
		{
			//don't pause when media is live, it messes the player state machine
			if (!(( facade.retrieveProxy( MediaProxy.NAME ) as MediaProxy).vo.isLive))
				sendNotification (NotificationType.DO_PAUSE);
			
			var sequenceProxy : SequenceProxy = facade.retrieveProxy( SequenceProxy.NAME ) as SequenceProxy;
			var sequenceContext : String = sequenceProxy.sequenceContext;
			var currentIndex : int = (sequenceProxy.vo.preCurrentIndex != -1) ? sequenceProxy.vo.preCurrentIndex : sequenceProxy.vo.postCurrentIndex;
			if (!sequenceProxy.activePlugin().hasSubSequence())
			{
				sendNotification (NotificationType.SEQUENCE_ITEM_PLAY_END, {sequenceContext : sequenceContext, currentIndex : currentIndex});
			}
			else
			{
				sequenceProxy.activePlugin().start();
			}
		}
	}
}