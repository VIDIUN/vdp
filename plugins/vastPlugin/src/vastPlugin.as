package {
	import com.vidiun.vdpfl.plugin.IPlugin;
	import com.vidiun.vdpfl.plugin.IPluginFactory;
	
	import flash.display.Sprite;
	import flash.system.ApplicationDomain;
	import flash.system.Security;

	public class vastPlugin extends Sprite implements IPluginFactory
	{
		public function vastPlugin()
		{
			Security.allowDomain("*");
		}
		
		public function create (pluginName : String = null) : IPlugin
		{
			return new vastPluginCode();
		}
	}
}
