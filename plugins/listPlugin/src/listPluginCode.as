/**
 * VListPlugin
 *
 * @langversion 3.0
 * @playerversion Flash 9.0.28.0
 * @author Dan Bacon / www.baconoppenheim.com
 */ 
package
{
	import com.vidiun.vdpfl.plugin.IPlugin;
	import com.vidiun.vdpfl.plugin.component.IDataProvider;
	import com.vidiun.vdpfl.plugin.component.VList;
	import com.vidiun.vdpfl.plugin.component.VListItem;
	
	import fl.core.UIComponent;
	import fl.data.DataProvider;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import org.puremvc.as3.interfaces.IFacade;

	public class listPluginCode extends UIComponent implements IPlugin
	{
		private var _facade:IFacade;
		private var _vlist:VList;
		private var _dataProvider:IDataProvider;
		private var _itemRendererId:String;
		public var rowHeight:Number = 80;	
		public var listDisabledAlpha:Number = 0.3;
		public var excludeFromDisableGUI:Boolean = true;
		
		/**
		 * by fixing hard-coded styles we broke backward compatibility, so if we are using old templates we will 
		 * ignore the styleName 
		 */		
		public var supportNewStyle:Boolean = false;
		
		private var _styleName:String;
		/**
		 * should the scrollbar be on the left side 
		 */		
		public var useLeftScrollbar:Boolean = false;
		/**
		 * Constructor 
		 * 
		 */			
		public function listPluginCode()
		{
			_vlist = new VList();
			
			_vlist.addEventListener( MouseEvent.CLICK , onListItemClick, false, 0, true );
			this.addEventListener( MouseEvent.CLICK , onListPluginClick, false, 0, true );
			_vlist.addEventListener( Event.CHANGE, onListChange, false, 0, true );
			_vlist.addEventListener( Event.ADDED_TO_STAGE , resizeVdp );

			addChild( _vlist );		
		}

		public function setSkin( styleName:String, setSkinSize:Boolean=false ):void
		{
			_styleName = styleName;
			_vlist.setSkin( styleName, setSkinSize );
		}	
		
		/**
		 *  
		 * @param facade
		 * 
		 */		
		public function initializePlugin( facade:IFacade ):void
		{
			_facade = facade;	
			if (supportNewStyle && _styleName)
			 	VListItem.stylName = _styleName;
			_vlist.setStyle('cellRenderer', VListItem ); 
			_vlist.rowHeight = rowHeight;
			_vlist.setDisabledAlpha(listDisabledAlpha);
			
			// TODO error handling				
			var buildLayout:Function = facade.retrieveProxy("layoutProxy")["buildLayout"];
			var vml:XML = facade.retrieveProxy("layoutProxy")["vo"]["layoutXML"];
			var itemLayout:XML = vml.descendants().renderer.(@id == this.itemRenderer)[0];
			itemLayout = itemLayout.children()[0];

			_vlist.itemContentFactory = buildLayout; 
			_vlist.itemContentLayout = itemLayout;
			_vlist.leftScrollBar = useLeftScrollbar;
			
			resizeVdp();
		}	
		
		public function onListChange( evt:Event ):void
		{ 
			_dataProvider.selectedIndex = _vlist.selectedIndex;
			_facade.sendNotification("relatedItemClicked", {index: _vlist.selectedIndex});
			_vlist.scrollToSelected();
			
		}
	
		public function onListItemClick( evt:MouseEvent ):void
		{
			
			
		}
		
		private function onListPluginClick (evt : MouseEvent ) : void
		{
			
		}
	

			
		public function set itemRenderer( value:String ):void
		{
			_itemRendererId = value;
		}
		
		public function get itemRenderer():String
		{
			return( _itemRendererId )
		}
				
		[Bindable]		
		public function set dataProvider( data:DataProvider ):void
		{
			if( data )
			{
				_dataProvider = data as IDataProvider;
				_dataProvider.addEventListener( Event.CHANGE, onDataProviderItemChange, false, 0, true );
				_vlist.dataProvider = data;
			}
		}
		
		public function onDataProviderItemChange( evt:Event = null ):void
		{
			if(_dataProvider&&_dataProvider.selectedIndex<_vlist.length){
				_vlist.selectedIndex = _dataProvider.selectedIndex;
			    _vlist.scrollToIndex(_dataProvider.selectedIndex);
			}
		}
		
		public function get dataProvider():DataProvider
		{
			return _vlist.dataProvider;
		}				
		
 		override public function set width( value:Number ):void
		{
			 _vlist.width = super.width = value;	
		} 
	
		override public function set height( value:Number ):void
		{
			_vlist.height = super.height = value;
		} 
		
		override public function toString():String
		{
			return( "ListPlugin" );
		}
		
		/**
		 * Hack...fix the bug of sizing...
		 * @param event
		 * 
		 */		
		private function resizeVdp( event : Event = null ) : void
		{	
			if(_facade)
				_facade.retrieveMediator("stageMediator")["onResize"]();
		}
		
		override public function set enabled(value:Boolean):void
		{
			_vlist.enabled = value;
		}
		
	}
}
