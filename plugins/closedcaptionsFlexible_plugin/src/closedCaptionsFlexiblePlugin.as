package
{
	import com.vidiun.vdpfl.plugin.IPlugin;
	import com.vidiun.vdpfl.plugin.IPluginFactory;
	import com.vidiun.vdpfl.plugin.component.ClosedCaptions;
	
	import flash.display.Sprite;
	import flash.system.Security;
	
	public class closedCaptionsFlexiblePlugin extends Sprite implements IPluginFactory
	{
		public function closedCaptionsFlexiblePlugin():void
		{
			Security.allowDomain("*");			
		}
		
		public function create(pluginName : String = null) : IPlugin	
		{
			return new closedCaptionsFlexiblePluginCode();
		}
	}
}