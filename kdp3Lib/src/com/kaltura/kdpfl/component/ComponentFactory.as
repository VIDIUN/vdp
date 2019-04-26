package com.vidiun.vdpfl.component
{
	import com.vidiun.vdpfl.view.controls.VButton;
	
	import fl.controls.Button;
	import fl.core.UIComponent;
	
	import flash.utils.getDefinitionByName;VButton;
	import com.vidiun.vdpfl.view.containers.VVBox;VVBox;
	import com.vidiun.vdpfl.view.containers.VHBox;VHBox;
	import com.vidiun.vdpfl.view.containers.VCanvas;VCanvas;
	import com.vidiun.vdpfl.view.containers.VTile;VTile;
	import com.vidiun.vdpfl.view.media.VMediaPlayer;VMediaPlayer;
	import com.vidiun.vdpfl.view.controls.VScrubber;VScrubber;
	import com.vidiun.vdpfl.view.controls.VVolumeBar;VVolumeBar;
	import com.vidiun.vdpfl.view.controls.VTimer;VTimer;
	import com.vidiun.vdpfl.view.controls.VLabel;VLabel;
	import com.vidiun.vdpfl.view.controls.Screens;Screens;
	import com.vidiun.vdpfl.view.controls.Watermark;Watermark;
	import com.vidiun.vdpfl.view.media.VThumbnail;VThumbnail;
	import com.vidiun.vdpfl.view.controls.VFlavorComboBox;VFlavorComboBox;
	import fl.core.UIComponent;
	import com.vidiun.vdpfl.view.controls.VTextField;VTextField;
	import com.vidiun.vdpfl.view.controls.VList;VList;
	import com.vidiun.vdpfl.view.controls.VTrace;


	////////////////////////////////////////////////////////
	/**
	 * The ComponentFactory class contains the mapping between the xml tag names used in the config.xml file
	 * and the classes constructed for them in the layout building process. 
	 * @author Hila
	 * 
	 */	
	public class ComponentFactory
	{
		/**
		 * Map object between the config.xml tag names and the VDP associated classes. 
		 */		
		public static var _componentMap : Object = 
		{
			Button:"com.vidiun.vdpfl.view.controls.VButton",
			VBox:"com.vidiun.vdpfl.view.containers.VVBox",
			HBox:"com.vidiun.vdpfl.view.containers.VHBox",
			Canvas:"com.vidiun.vdpfl.view.containers.VCanvas",
			Tile:"com.vidiun.vdpfl.view.containers.VTile",
			Video:"com.vidiun.vdpfl.view.media.VMediaPlayer",
			Scrubber:"com.vidiun.vdpfl.view.controls.VScrubber",
			VolumeBar:"com.vidiun.vdpfl.view.controls.VVolumeBar",
			Label:"com.vidiun.vdpfl.view.controls.VLabel",
			Timer:"com.vidiun.vdpfl.view.controls.VTimer",
			Screens:"com.vidiun.vdpfl.view.controls.Screens",
			Watermark:"com.vidiun.vdpfl.view.controls.Watermark",
			Image:"com.vidiun.vdpfl.view.media.VThumbnail",
			Spacer:"fl.core.UIComponent",
			FlavorCombo:"com.vidiun.vdpfl.view.controls.VFlavorComboBox",
			Text:"com.vidiun.vdpfl.view.controls.VTextField",
			ComboBox:"com.vidiun.vdpfl.view.controls.VComboBox",
			List:"com.vidiun.vdpfl.view.controls.VList"
		}
		
		/**
		 * Constructor 
		 * 
		 */		
		public function ComponentFactory(){}
		
		
		/**
		 * Creates the components supported by the VDP 
		 * @param UIComponent type
		 * @return VDP UIComponent 
		 * 
		 */		
		public function getComponent(type:String):UIComponent
		{
			var uiComponent:UIComponent;
			
			if( _componentMap[type] != null )
			{
				try{
					//creating the class from the type sent in the signature
					var ClassReference:Class = getDefinitionByName( _componentMap[type] ) as Class;
				}
				catch(e:Error){
					VTrace.getInstance().log("ComponentFactory >> getComponent >> Error: class not found, " + _componentMap[type]);
				//	trace ("ComponentFactory >> getComponent >> Error: class not found");
					return null;
				}
				
				uiComponent = new ClassReference();	
			
				return uiComponent;
			}
			else
			{
				VTrace.getInstance().log("ComponentFactory >> getComponent >> Error: no class is mapped for this component name.");
			//	trace ("ComponentFactory >> getComponent >> Error: no class is mapped for this component name.");
			}
			
			return null;	
		}
	}
}