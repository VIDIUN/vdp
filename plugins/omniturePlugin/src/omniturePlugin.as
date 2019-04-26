package
{
	import com.vidiun.vdpfl.plugin.IPlugin;
	import com.vidiun.vdpfl.plugin.IPluginFactory;
	
	import flash.display.Sprite;
	import flash.system.Security;
	
	/**
	 * Omniture plugin keeps statistics for entry views. 
	 */	
	public class omniturePlugin extends Sprite implements IPluginFactory
	{
		/**
		 * Constructor 
		 */		
		public function omniturePlugin()
		{
			Security.allowDomain("*");
		}
		
		/**
		 * create "real" plugin 
		 */		
		public function create(pluginName : String = null) : IPlugin	
		{
			return new omniturePluginCode();
		}
		
	}
}