package com.vidiun.vdpfl.util
{
	import com.vidiun.vdpfl.view.controls.VTrace;
	
	import flash.utils.ByteArray;

	public class VdpEmbeddedData 
	{
		private static var singleton:VdpEmbeddedData = null;
		[Embed(source="VdpEmbeddedDataBin.bin", mimeType="application/octet-stream")]
		private const embeddedData:Class;
		public var embeddedModules:Object  = new Object();
		
		public function VdpEmbeddedData()
		{
			var embeddedDataBA: ByteArray = new embeddedData() as ByteArray;
			
			while(embeddedDataBA.position < embeddedDataBA.length)
			{
				var nameLen:int = embeddedDataBA.readInt();
				if (nameLen == 0)
					break;
				
				var name:String = embeddedDataBA.readUTFBytes(nameLen);
				var dataLen:int = embeddedDataBA.readInt();
				//trace("embedded module: " + name + " length: " + dataLen);
				var dataBA:ByteArray = new ByteArray();
				embeddedDataBA.readBytes(dataBA, 0, dataLen);
				embeddedModules[name] = dataBA;
			}
		}
		
		public static function getData(url:String):ByteArray
		{
			var embeddedModules:Object = getSingleton().embeddedModules;
			
			if(embeddedModules)
			{
				var i:int;
				for ( var key:String in embeddedModules)
				{
					var n:int = url.indexOf(key); 
					if (url.indexOf(key) >= 0)
					{
						var ba:ByteArray = embeddedModules[key];
						if (ba)
						{
							//trace("loaded embedded module: " + key);
							VTrace.getInstance().log("loaded embedded module: " + key);
							return ba;
						}
						break;
					}
				}
			}
			
			return null;
		} 
		
		/**
		 *  @private
		 *  Typed as Object, for now. Ideally this should be IModuleManager.
		 */
		public static function getSingleton():VdpEmbeddedData
		{
			if (!singleton)
				singleton = new VdpEmbeddedData();
			
			return singleton;
		}
	}
}
