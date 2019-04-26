package com.vidiun.vdpfl.plugin.view {
	import com.vidiun.vdpfl.view.containers.VHBox;
	import com.vidiun.vdpfl.view.containers.VVBox;
	import com.vidiun.vdpfl.view.controls.VButton;
	import com.vidiun.vdpfl.view.controls.VComboBox;
	import com.vidiun.vdpfl.view.controls.VLabel;
	import com.vidiun.vdpfl.view.controls.VTextField;
	
	import fl.data.DataProvider;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.utils.setTimeout;

	public class ModerationScreen extends VVBox {

		
		private var _headerText:String = 	'Report this content as inappropriate';
		private var _windowText:String = 	"Please describe your concern about " +
											"the video, so that we can review it and determine whether it " +
											"isn't appropriate for all viewers.";

		private var _reasonsDataProvider:Array = [];
		private var btnSubmit:VButton;
		private var _combo:VComboBox;
		private var _showCombo:Boolean;
		private var _comboSelectedIndex:Number = 0 ;


		public function ModerationScreen() {
			super();
			drawScreen();
		}


		/**
		 * create the screen ui
		 */
		private function drawScreen():void {
			this.paddingLeft = 5;
			this.paddingRight = 5;
//			this.paddingTop = 5;
//			this.paddingBottom = 5;
			this.verticalGap = 3;
			var availableWidth:Number = 290; 

			var lbl:VLabel = new VLabel();
			lbl.width = availableWidth;
			lbl.name = "windowTitle";
			lbl.text = _headerText;
			addChild(lbl);

			var txt:VTextField = new VTextField();
			txt.name = "windowText";
			txt.truncateToFit = false;
			txt.width = availableWidth;
			txt.height = 50;
			txt.text = _windowText;
			addChild(txt);

			_combo = new VComboBox();
			_combo.width = 150;
			_combo.dataProvider = new DataProvider(_reasonsDataProvider);
			addChild(_combo);


			var ti:VTextField = new VTextField();
			ti.name = "tiDescription";
			ti.editable = true;
			ti.truncateToFit = false;
			ti.borderColor = 0x4D4D4D;
			ti.border = true;
//			ti.background = true;
//			ti.backgroundColor = 0xff00ff;//TODO bring from outside.
			ti.width = availableWidth;
			ti.height = 100;
			addChild(ti);

			var hbox:VHBox = new VHBox();
			hbox.name = "controlBar";
			hbox.width = availableWidth;
			hbox.horizontalGap = 3;
			hbox.paddingLeft = 1;
			hbox.paddingRight = 1;
			hbox.paddingTop = 3;
			hbox.paddingBottom = 3;
//			hbox.horizontalAlign = "right"; 
			addChild(hbox);

			btnSubmit = new VButton();
			btnSubmit.name = "btnSubmit";
			btnSubmit.label = "submit";
			btnSubmit.addEventListener(MouseEvent.CLICK, notifyClick);
			btnSubmit.maxHeight = 20;
			hbox.addChild(btnSubmit);

			var btn:VButton = new VButton();
			btn.name = "btnCancel";
			btn.label = "cancel";
			btn.addEventListener(MouseEvent.CLICK, notifyClick);
			btn.maxHeight = 20;
			hbox.addChild(btn);
			
			setSkin("some name");
		}

		
		
		/**
		 * dispatch a relevant event
		 * @param e
		 */
		private function notifyClick(e:MouseEvent):void {
			if (e.target.name == "btnSubmit") {
				delayMultiPosting();
				dispatchEvent(new Event(ModerationPlugin.SUBMIT));
			}
			else if (e.target.name == "btnCancel") {
				dispatchEvent(new Event(ModerationPlugin.CANCEL));
			}
		}
		
		/**
		 * Delayed submit button for 5 sec to prevent multiple sending 
		 */		
		private function delayMultiPosting():void
		{
			btnSubmit.enabled = false;
			setTimeout(reEnableSubmitButton,5000);
		}
		/**
		 * Re Enable the button
		 */
		private function reEnableSubmitButton():void
		{
			btnSubmit.enabled = true;
		}
		
		
		/**
		 * we don't actually allow changing the skin. it's hardcoded.
		 * @param styleName		alleged style name, ignored.
		 * @param setSkinSize	something to do with button skin size, ignored.
		 */		
		override public function setSkin(styleName:String, setSkinSize:Boolean=false):void {
			super.setSkin( "Mod_darkBg");
			(this.getChildByName("windowTitle") as VLabel).setSkin("Mod_title", setSkinSize);
			(this.getChildByName("windowText") as VTextField).setSkin( "Mod_text", setSkinSize);
			_combo.setSkin("_mod", setSkinSize);
			(this.getChildByName("tiDescription") as VTextField).setSkin("Mod_text", setSkinSize);
			var hbox:VHBox = this.getChildByName("controlBar") as VHBox;
			(hbox.getChildByName("btnSubmit") as VButton).setSkin("mod", setSkinSize);
			(hbox.getChildByName("btnCancel") as VButton).setSkin("mod", setSkinSize);
		}


		/**
		 * clears the data entered in the form
		 * */
		public function clearData():void {
			_combo.selectedIndex = -1;
			if(_comboSelectedIndex)
				_combo.selectedIndex = _comboSelectedIndex;
				
			(this.getChildByName("tiDescription") as VTextField).text = "";
		}


		/**
		 * data entered in the form,
		 * {reason, description}
		 */
		public function get data():Object {
			var reason:Object = _combo.selectedItem.type;
			var description:String = (this.getChildByName("tiDescription") as VTextField).text;
			return {reason: reason, comments: description};
		}


		/**
		 * the title of the flagging window
		 */
		public function get headerText():String {
			return _headerText;
		}
		/**
		 * Show/hide the combobox
		 */
		public function set showCombo(value:Boolean):void {
			_showCombo = value;
			if(_combo)
			{
				_combo.visible = value;
				//hack. If we remove the combo from the displaylist we get errors
				if(!value)
					_combo.height = 1;
			}
		}
		public function set comboSelectedIndex(value:Number):void {
			_comboSelectedIndex = value;
			if(_combo)
			{
				_combo.selectedIndex = value;
			}
		}

		/**
		 * @private
		 */
		public function set buttonsPosition(value:String):void {
			(this.getChildByName("controlBar") as VHBox).horizontalAlign = value;
		}


		/**
		 * alignment of submit and cancel buttons
		 */
		public function get buttonsPosition():String {
			return (this.getChildByName("controlBar") as VHBox).horizontalAlign;
		}

		/**
		 * @private
		 */
		public function set headerText(value:String):void {
			(this.getChildByName("windowTitle") as VLabel).text = value;
			_headerText = value;
		}


		/**
		 * the text explaining what to do
		 */
		public function get windowText():String {
			return _windowText;
		}


		/**
		 * @private
		 */
		public function set windowText(value:String):void {
			(this.getChildByName("windowText") as VTextField).text = value;
			_windowText = value;
		}


		public function get reasonsDataProvider():Array {
			return _reasonsDataProvider;
		}


		public function set reasonsDataProvider(value:Array):void {
			_combo.dataProvider = new DataProvider(value);
			_reasonsDataProvider = value;
		}

	}
}