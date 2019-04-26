package
{
	import com.vidiun.vdpfl.plugin.IPlugin;
	import com.vidiun.vdpfl.plugin.IPluginFactory;
	import com.vidiun.vdpfl.plugin.PPTWidgetScrubber;
	
	import flash.display.Sprite;
	import flash.system.Security;
	
	public class pptWidgetScrubberPlugin extends Sprite implements IPluginFactory
	{
		public function pptWidgetScrubberPlugin()
		{
			Security.allowDomain("*");			
		}
		
		public function create(pluginName : String = null) : IPlugin	
		{
			return new PPTWidgetScrubber();
		}
	}
}