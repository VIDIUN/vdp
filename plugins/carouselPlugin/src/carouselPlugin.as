package {
	import com.vidiun.vdpfl.plugin.IPlugin;
	import com.vidiun.vdpfl.plugin.IPluginFactory;
	
	import flash.display.Sprite;
	import flash.system.Security;
	import com.vidiun.vdpfl.plugin.CarouselPluginCode;

	public class carouselPlugin extends Sprite implements IPluginFactory
	{
		public function carouselPlugin()
		{
			Security.allowDomain("*");	
		}
		
		public function create(pluginName : String = null) : IPlugin	
		{
			return new CarouselPluginCode();
		}
	}
}
