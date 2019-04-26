package com.vidiun.vdpfl.model
{
	import com.vidiun.VidiunClient;
	import com.vidiun.config.VidiunConfig;
	import com.vidiun.vdpfl.model.vo.ServicesVO;
	
	import flash.net.URLLoader;
	
	import org.puremvc.as3.patterns.proxy.Proxy;

	/**
	 *  Class ServicesProxy manages the parameters related to Vidiun services, i.e, creating a VidiunClient, VidiunConfig, etc.
	 * 
	 */	
	public class ServicesProxy extends Proxy
	{
		public static const NAME:String = "servicesProxy";
		
		
		//DEPRECATED
		public var vidiunClient : VidiunClient;
		
		//public static const CONFIG_SERVICE:String = "configService";
		private var _configService:URLLoader;
		/**
		 * Constructor 
		 * 
		 */			
		public function ServicesProxy()
		{
			super(NAME, new ServicesVO());
		}
		/**
		 * constructs a new VidiunClient based on a VidiunConfig object.
		 * @param config object of type VidiunConfig used to construct the VidiunClient
		 * 
		 */		
		public function createClient( config : VidiunConfig ) : void
		{
			this.vo.vidiunClient = new VidiunClient( config );
			vidiunClient = this.vo.vidiunClient;
			
		}
		
		public function get vo () : ServicesVO
		{
			return this.data as ServicesVO;
		}
			
		
		
		
		
		
		
	}
}