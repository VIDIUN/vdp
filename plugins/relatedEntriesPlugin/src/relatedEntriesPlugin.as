package
{
	import com.vidiun.vdpfl.plugin.IPlugin;
	import com.vidiun.vdpfl.plugin.IPluginFactory;
	
	import fl.core.UIComponent;
	
	import flash.display.Sprite;
	import flash.system.Security;
	
	public class relatedEntriesPlugin extends UIComponent implements IPluginFactory
	{
		public function relatedEntriesPlugin()
		{
			Security.allowDomain("*");
		}
		
		public function create(pluginName : String = null) : IPlugin
		{
			return new relatedEntriesPluginCode();
		}
	}
}