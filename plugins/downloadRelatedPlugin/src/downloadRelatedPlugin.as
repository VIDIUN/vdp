package
{
	import com.vidiun.VidiunClient;
	import com.vidiun.commands.attachmentAsset.AttachmentAssetGetUrl;
	import com.vidiun.commands.attachmentAsset.AttachmentAssetList;
	import com.vidiun.events.VidiunEvent;
	import com.vidiun.vdpfl.model.type.EnableType;
	import com.vidiun.vdpfl.model.type.NotificationType;
	import com.vidiun.vdpfl.plugin.IPlugin;
	import com.vidiun.vdpfl.plugin.IPluginFactory;
	import com.vidiun.vdpfl.view.containers.VCanvas;
	import com.vidiun.vdpfl.view.containers.VHBox;
	import com.vidiun.vdpfl.view.containers.VVBox;
	import com.vidiun.vdpfl.view.controls.VButton;
	import com.vidiun.vdpfl.view.controls.VLabel;
	import com.vidiun.vdpfl.view.controls.VTextField;
	import com.vidiun.vdpfl.view.controls.ToolTipManager;
	import com.vidiun.vo.VidiunAssetFilter;
	import com.yahoo.astra.fl.containers.VBoxPane;
	import com.yahoo.astra.layout.modes.HorizontalAlignment;
	import com.yahoo.astra.layout.modes.VerticalAlignment;
	
	import fl.core.UIComponent;
	
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.net.FileReference;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	
	import org.puremvc.as3.interfaces.IFacade;
	
	public class downloadRelatedPlugin extends VVBox implements IPluginFactory, IPlugin 
	{
		public var ar:AssetsRefferencer;
		private var _mediator:DownloadRelatedMediator;
		private var _mainVBox:VVBox;
		public var files:Array;
		public var client:VidiunClient; 
		
		public var vboxVerticalGap:Number = 10;
		public var vboxLeftPadding:Number = 10;
		public var iconWidth:Number = 26;
		public var iconMargin:Number = 5;
		public var iconHeight:Number = 26;
		public var itemHeight:Number = 45;
		public var itemBg:String = "rel_darkBg2" ;
		public var itemBgColor:String = "0x000000";
		public var itemBgAlpha:String = "0.5";
		public var labelSkin:String = "Button_Label_rel2";
		
		
		
		[Bindable]
		public var isActive:Boolean;
		
		public function downloadRelatedPlugin()
		{
		}
		public function show():void
		{
			ToolTipManager.getInstance().tooltipWidth = 200;
			ToolTipManager.getInstance().offsetX = 100;
			
			_mediator.sendNotification(NotificationType.ENABLE_GUI, {guiEnabled: false, enableType: EnableType.FULL} );
			_mediator.sendNotification(NotificationType.CLOSE_FULL_SCREEN );
			visible = true;
		}
		public var headerText:String = 'Featured Resources:';
		private var headerHbox:VHBox;
		
		 private var _originalWidth:Number = ToolTipManager.getInstance().tooltipWidth;
		 private var _originalXoffset:Number = ToolTipManager.getInstance().offsetX ;
		
		 public static function formatFileSize(bytes:int):String
		 {
			 if(bytes < 1024)
				 return bytes + " bytes";
			 
			 bytes /= 1024;
			 if(bytes < 1024)
				 return bytes + " Kb";
			 
			 bytes /= 1024;
			 if(bytes < 1024)
				 return bytes + " Mb";
			 
			 bytes /= 1024;
			 if(bytes < 1024)
				 return bytes + " Gb";
			 
			 return String(bytes);
		 }
		
		public var headerTextWidth:Number = 200;
		/**
		 * @inheritDoc 
		 **/
		public function initializePlugin(facade:IFacade):void 
		{
			visible = false;
			_mediator = new DownloadRelatedMediator(this);
			facade.registerMediator(_mediator); 
			
			
		}
		public function onClose(event:MouseEvent):void {
			
			
			this.visible = false;
			_mediator.sendNotification(NotificationType.ENABLE_GUI, {guiEnabled: true, enableType: EnableType.FULL} );

			ToolTipManager.getInstance().tooltipWidth = _originalWidth;
			ToolTipManager.getInstance().offsetX = _originalXoffset;
		}
		
		/**
		 * @inheritDoc	
		 **/
		public function create(pluginName:String = null):IPlugin {
			return this;
		}
		
		/**
		 * set the given style to all visual parts
		 * */
		override public function setSkin(styleName:String, setSkinSize:Boolean = false):void {
			setStyle("skin", rel_darkBg);
			mouseEnabled = false;
		}
		
		public function fetchAttachments(entryId:String):void
		{
			var attachmentFilter:VidiunAssetFilter = new VidiunAssetFilter();
			attachmentFilter.entryIdIn = entryId;
			var attachments:AttachmentAssetList = new AttachmentAssetList(attachmentFilter);
			attachments.addEventListener(VidiunEvent.COMPLETE , onComplete);
			attachments.addEventListener(VidiunEvent.FAILED , onFailed);
			client.post(attachments);
		}
		public function onFailed(event:VidiunEvent):void
		{
			trace('onFailed');	
		}
		public function onComplete(event:VidiunEvent):void
		{
			if(event.data && event.data.hasOwnProperty('objects') && ((event.data.objects) is Array) && (event.data.objects as Array).length > 0 )
			{
				files = event.data.objects;
				destroyUI();
				createUi();
				isActive = true;
			}else
			{
				//empty
				destroyUI();
				isActive = false;
				
			}
			
		}

		public function destroyUI():void
		{
			//clear previous
			var items:Number = _mainVBox.numChildren;
			for (var j:uint;j<items;j++)
			{
				if(_mainVBox.getChildAt(0) is VHBox)
					_mainVBox.removeChild(_mainVBox.getChildAt(0));
			}
		}
		
		
		public function createUi():void
		{
			
				for (var i:uint = 0; i<files.length ; i++)
				{
					
					var hbox:VHBox = new VHBox(); 
					hbox.horizontalAlign = HorizontalAlignment.LEFT;
					hbox.verticalAlign = VerticalAlignment.MIDDLE;
					hbox.paddingLeft = 0;
					hbox.height = itemHeight;
					
					hbox.horizontalGap = 5;
					hbox.width = _mainVBox.width - 50;
					if(itemBg)
						hbox.setSkin(itemBg,true); 
					if(itemBgColor)
					{
						hbox.bgColor = Number(itemBgColor);
					}
					if(itemBgAlpha)
					{
						hbox.bgAlpha = itemBgAlpha;
					}
					
					_mainVBox.addChild(hbox);
					
					var icon:VVBox = new VVBox();
					icon.width = iconWidth;
					icon.height = iconHeight;
					var spacer:UIComponent = new UIComponent();
					spacer.height = 1;
					spacer.width = iconMargin;
					hbox.addChild(spacer);
					//icons 
					var extension:String =  (files[i]["fileExt"] as String);
					extension = extension.toLocaleLowerCase();
					var extensionIcon:String;
					extension = extension.toLocaleLowerCase();
					switch(extension)
					{ 
						case 'pdf':
							extensionIcon = 'pdf';
						break;
						case 'doc':
						case 'docx':
						case 'rtf':
							extensionIcon = 'word';
						break;
						case 'ppt':
						case 'pptx':
						case 'pps':
						case 'ppsx':
							extensionIcon = 'powerpoint';
						break;
						case 'jpeg':
						case 'gif':
						case 'jpg':
						case 'bmp':
						case 'png':
						case 'tif':
						case 'tiff':
							extensionIcon = 'image';
						break;
						case 'xls':
						case 'xlsx':
						case 'xlr':
							extensionIcon = 'excel';
						break;
						case 'vsd':
						case 'vss':
						case 'vst':
						case 'vtx':
						case 'vsx':
						case 'vdx':
							extensionIcon = 'visio';
						break;
						default:
							extensionIcon = 'doc';
					}
					icon.setStyle("skin",extensionIcon);
					hbox.addChild(icon);
					
					var nn:Number = Number(files[i]['createdAt'])*1000;
					var d:Date = new Date(nn);
					var dateString:String = DateFormat.formatDate("M. d, Y h:i A" , d);
					
					var output:String = "";
					
					var title:String = files[i]['title'];
					if(title)
						output+="Title: "+title+"\n";
					var description:String = files[i]['description']; 
					if(description)
						output+="Description: "+description+"\n";
					var fileName:String = files[i]['filename'];
					if(fileName)
						output+="FileName: "+fileName+"\n";
					var fileSize:String = files[i]['size']; 
					if(fileSize)
						output+="FileSize: "+formatFileSize(int(fileSize))+"\n";
					output+="Date: "+dateString;
			
					var vlabel:VLabel = new VLabel();
					vlabel.setSkin(labelSkin); 
					vlabel.height = 23;
					
					vlabel.width = hbox.width - 50;
					if(title)
						vlabel.text = title;
					else
						vlabel.text = fileName;
						
					vlabel.name = files[i]['id'];
					
					if(output)
						vlabel.tooltip = output;

					icon.name = files[i]['id'];
					icon.addEventListener(MouseEvent.CLICK, onClick);
					vlabel.addEventListener(MouseEvent.CLICK, onClick);
					hbox.name = files[i]['id'];
					hbox.addChild(vlabel);
					
					//enforce no tooltip
					if(files[i]["description"])
						vlabel.tooltip = '';
					
					vlabel.mouseChildren = false;
					vlabel.buttonMode = true;
					vlabel.useHandCursor = true;
					vlabel.mouseEnabled = true;
					
					
					icon.mouseChildren = false;
					icon.buttonMode = true;
					icon.useHandCursor = true;
					icon.mouseEnabled = true;

				}
		}

		protected function onClick(evt:MouseEvent):void
		{
			var item:UIComponent = evt.currentTarget as UIComponent;
			var fileId:String = item.name;
			var url:AttachmentAssetGetUrl = new AttachmentAssetGetUrl(fileId);
			url.addEventListener(VidiunEvent.COMPLETE , onRecievedUrl);
			url.addEventListener(VidiunEvent.FAILED , onFailedRecievingUrl);
			client.post(url);
		} 
		
		private function onRecievedUrl(event:VidiunEvent):void{
			var request:URLRequest = new URLRequest(event.data as String);

			try {
				navigateToURL(request,"_top"); // second argument is target
			} catch (e:Error) {
				trace("Error occurred!");
			}
		}
		private function onFailedRecievingUrl(event:VidiunEvent):void{
			
			trace(1);
		}
		
		override public function set width(value:Number):void
		{
			super.width = value;
			resize();
		}
		override public function set height(value:Number):void
		{
			super.height = value;
			resize();
		}
		private var resizeCounter:Number=0;
		private var ready:Boolean;
		
		public function initializeMe():void
		{
			if( !ready && resizeCounter>3 )
			{
				ready = true; //loaded flag
				
				headerHbox = new VHBox();
				headerHbox.horizontalAlign = HorizontalAlignment.LEFT;
				headerHbox.name = "headerHbox";
				headerHbox.paddingLeft = 5;
				headerHbox.verticalAlign = "middle";
				headerHbox.height = 40;
				headerHbox.width = width -5;
				//headerHbox.setSkin(itemBg,true); 
				
				addChild(headerHbox);
				
				var lbl:VLabel = new VLabel();
				lbl.name = "windowTitle";
				lbl.text = headerText;
				lbl.width = headerTextWidth;
				lbl.setSkin("rel_title");
				headerHbox.addChild(lbl);
				
				var spacer:VVBox = new VVBox(); 
				spacer.width = headerHbox.width - headerTextWidth - 40 ;  
				spacer.height = 1;
				headerHbox.addChild(spacer);
				
				/*			var lbl1:VLabel = new VLabel();
				lbl1.name = "closeText";
				lbl1.text = _closeText;
				lbl1.width = _closeTextWidth;
				headerHbox.addChild(lbl1);*/
				
				var btn:VButton;
				btn = new VButton();
				btn.name = "closeBtn";
				btn.height = 15;
				btn.minHeight = 15;
				btn.width = 15;
				btn.minWidth = 15;
				btn.addEventListener(MouseEvent.CLICK, onClose);
				headerHbox.addChild(btn);
				btn.setSkin('rel');	
				
				
				
				_mainVBox = new VVBox();
				
				_mainVBox.setSkin("List_background_default");
				
				_mainVBox.height = this.height = 50;
				_mainVBox.horizontalScrollPolicy = "off";
				_mainVBox.verticalGap = 5;
				_mainVBox.paddingLeft = 20;
				_mainVBox.paddingRight = 20;
				addChild(_mainVBox);
			}
		}
		
		public function resize():void
		{
			if(++ resizeCounter > 3)
				initializeMe();
			if(_mainVBox)
			{
				_mainVBox.width = this.width;
				_mainVBox.height = this.height -50;
			}
			
			
			
		}
	}
}