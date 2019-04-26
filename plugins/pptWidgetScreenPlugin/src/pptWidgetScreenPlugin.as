package
{
	import com.vidiun.vdpfl.plugin.IPlugin;
	import com.vidiun.vdpfl.plugin.IPluginFactory;
	import com.vidiun.vdpfl.plugin.PPTWidgetScreenPluginCode;
	
	import flash.display.Sprite;
	import flash.system.Security;
	
	public class pptWidgetScreenPlugin extends Sprite implements IPluginFactory
	{
		public function pptWidgetScreenPlugin()
		{
			Security.allowDomain("*");			
		}
		
		public function create(pluginName : String = null) : IPlugin	
		{
			return new PPTWidgetScreenPluginCode();
		}
	}
}