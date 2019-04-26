package
{
	import com.vidiun.vdpfl.plugin.IPlugin;
	import com.vidiun.vdpfl.plugin.IPluginFactory;
	
	import flash.display.Sprite;
	import flash.system.Security;
	
	public class Shortcuts508Plugin extends Sprite implements IPluginFactory
	{
		public function Shortcuts508Plugin():void
		{
			Security.allowDomain("*");			
		}
		
		public function create(pluginName : String = null) : IPlugin	
		{
			return new Shortcuts508PluginCode();
		}
	}
}