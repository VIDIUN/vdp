package
{
	import com.vidiun.vdpfl.plugin.IPlugin;
	import com.vidiun.vdpfl.plugin.IPluginFactory;
	import com.vidiun.metaDataPluginCode;
	
	import flash.display.Sprite;
	
	public class metaDataPlugin extends Sprite implements IPluginFactory
	{
		public function metaDataPlugin()
		{
			
		}
		public function create (pluginName:String=null) : IPlugin
		{
			return new metaDataPluginCode();
		}
	}
}