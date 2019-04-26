package
{
	import com.vidiun.vdpfl.plugin.IPlugin;
	import com.vidiun.vdpfl.plugin.IPluginFactory;
	import com.vidiun.vdpfl.plugin.WVMediaElement;
	
	import flash.display.Sprite;
	
	import org.puremvc.as3.interfaces.IFacade;
	
	public class widevinePlugin extends Sprite implements IPluginFactory
	{
		public function widevinePlugin()
		{
			var wv: WVMediaElement;
		}
		
		public function create(pluginName : String = null) : IPlugin
		{
			return new widevinePluginCode();
		}
		
		public function initializePlugin(facade:IFacade):void {
			
		}
		public function setSkin( styleName : String , setSkinSize : Boolean = false) : void {}
		
	}
}