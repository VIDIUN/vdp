package
{
	import com.vidiun.cuePointPluginCode;
	import com.vidiun.vdpfl.plugin.IPlugin;
	import com.vidiun.vdpfl.plugin.IPluginFactory;
	
	import flash.display.Sprite;
	
	public class cuePointPlugin extends Sprite implements IPluginFactory
	{
		public function cuePointPlugin()
		{
			
		}
		
		public function create (pluginName : String=null) : IPlugin
		{
			return new cuePointPluginCode();
		}
	}
}