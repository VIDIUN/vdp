package
{
	import com.vidiun.vdpfl.plugin.IPlugin;
	import com.vidiun.vdpfl.plugin.IPluginFactory;
	
	import flash.display.Sprite;
	import flash.system.Security;
	
	public class restrictUserAgentPlugin extends Sprite implements IPluginFactory
	{
		public function restrictUserAgentPlugin()
		{
			Security.allowDomain("*");	
		}
		
		public function create ( pluginName : String = "" ) : IPlugin
		{
			return new RestrictUserAgentPluginCode ();
		}
	}
}