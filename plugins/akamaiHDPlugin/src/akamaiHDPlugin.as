package
{
	import com.akamai.osmf.AkamaiAdvancedStreamingPluginInfo;
	import com.vidiun.vdpfl.model.MediaProxy;
	import com.vidiun.vdpfl.plugin.IPlugin;
	import com.vidiun.vdpfl.plugin.IPluginFactory;
	import com.vidiun.vdpfl.plugin.VPluginEvent;
	import com.vidiun.vdpfl.plugin.akamaiHDMediator;
	
	import flash.display.Sprite;
	import flash.system.Security;
	import flash.utils.getDefinitionByName;
	
	import org.osmf.events.MediaFactoryEvent;
	import org.osmf.media.MediaFactory;
	import org.osmf.media.MediaResourceBase;
	import org.osmf.media.PluginInfoResource;
	import org.puremvc.as3.interfaces.IFacade;
	
	public class akamaiHDPlugin extends Sprite implements IPluginFactory, IPlugin
	{
		
		private static const AKAMAI_PLUGIN_INFO:String = "com.akamai.osmf.AkamaiAdvancedStreamingPluginInfo";
		private static const dummyRef:AkamaiAdvancedStreamingPluginInfo = null;
		
		public function akamaiHDPlugin()
		{
			Security.allowDomain("*");
		}
		
		public function create (pluginName : String =null) : IPlugin
		{
			return this;
		}
		
		public function initializePlugin(facade:IFacade):void
		{
			var mediator:akamaiHDMediator = new akamaiHDMediator();
			facade.registerMediator(mediator);
			
			//Getting Static reference to Plugin.
			var pluginInfoRef:Class = getDefinitionByName(AKAMAI_PLUGIN_INFO) as Class;
			var pluginResource:MediaResourceBase = new PluginInfoResource(new pluginInfoRef);
			
			var mediaFactory:MediaFactory = (facade.retrieveProxy(MediaProxy.NAME) as MediaProxy).vo.mediaFactory;
			mediaFactory.addEventListener(MediaFactoryEvent.PLUGIN_LOAD, onOSMFPluginLoaded);
			mediaFactory.addEventListener(MediaFactoryEvent.PLUGIN_LOAD_ERROR, onOSMFPluginLoadError);
			mediaFactory.loadPlugin(pluginResource);		
		}
		
		/**
		 * Listener for the LOAD_COMPLETE event.
		 * @param e - MediaFactoryEvent
		 * 
		 */		
		protected function onOSMFPluginLoaded (e : MediaFactoryEvent) : void
		{
			e.target.removeEventListener(MediaFactoryEvent.PLUGIN_LOAD, onOSMFPluginLoaded);
			dispatchEvent( new VPluginEvent (VPluginEvent.VPLUGIN_INIT_COMPLETE) );
		}
		/**
		 * Listener for the LOAD_ERROR event.
		 * @param e - MediaFactoryEvent
		 * 
		 */		
		protected function onOSMFPluginLoadError (e : MediaFactoryEvent) : void
		{
			e.target.removeEventListener(MediaFactoryEvent.PLUGIN_LOAD_ERROR, onOSMFPluginLoadError);
			dispatchEvent( new VPluginEvent (VPluginEvent.VPLUGIN_INIT_FAILED) );
		}
		
		public function setSkin(styleName:String, setSkinSize:Boolean=false):void
		{
			// Do nothing here
		}
	}
}