package {
	import com.vidiun.vdpfl.plugin.IPlugin;
	import com.vidiun.vdpfl.plugin.IPluginFactory;
	
	import flash.display.Sprite;
	import flash.system.Security;
	
	/**
	 * plugin to VDP3 which enables displaying commercial via Eyewonder. </br>
	 * the VDP assumes an instance of this class is the main application of this plugin.
	 */
	public class eyewonderPlugin extends Sprite implements IPluginFactory
	{
		
		/**
		 * Constructor. 
		 */		
		public function eyewonderPlugin()
		{
			Security.allowDomain("*");
		}
		
		
		/**
		 * VDP calls this method on the created swf to initialize the plugin creation process. 
		 * @param pluginName
		 * @return an instance of the relevant IPlugin.
		 */		
		public function create(pluginName : String = null) : IPlugin	
		{
			return new EyewonderPluginCode();
		}
	}
}
