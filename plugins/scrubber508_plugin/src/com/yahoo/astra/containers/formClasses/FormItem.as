/*
Copyright (c) 2009 Yahoo! Inc.  All rights reserved.  
The copyrights embodied in the content of this file are licensed under the BSD (revised) open source license
*/
package com.yahoo.astra.containers.formClasses {
	import com.yahoo.astra.containers.formClasses.FormItemContainer;
	import com.yahoo.astra.containers.formClasses.FormItemLabel;
	import com.yahoo.astra.containers.formClasses.FormLayoutStyle;
	import com.yahoo.astra.containers.formClasses.IForm;
	import com.yahoo.astra.events.FormDataManagerEvent;
	import com.yahoo.astra.events.FormLayoutEvent;
	import com.yahoo.astra.layout.LayoutContainer;
	import com.yahoo.astra.layout.LayoutManager;
	import com.yahoo.astra.layout.events.LayoutEvent;
	import com.yahoo.astra.layout.modes.BoxLayout;

	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;	

	/**
	 * Defines a label and one or more children arranged horizontally or vertically. 
	 *	@see com.yahoo.astra.fl.containers.Form
	 * @author kayoh
	 */

	public class FormItem extends LayoutContainer implements IForm {

		//--------------------------------------

		public function FormItem( ...args ) {
			formItemLayout.horizontalGap = horizontalGap; 
			
			super(formItemLayout);
			
			_skin = new Sprite();
			formItemLayout.addClient(errorGrayBoxSpriteHolder, {includeInLayout:false});
			this.addChild(errorGrayBoxSpriteHolder);
				var argStr : String = args[0].toString();
				i = 1;
				horizontalGap = 0;

		//--------------------------------------
		/**
		 * @private
		 */
		private var errorGrayBoxSpriteHolder : Sprite;
		/**
		 * @private
		 */
		/**

		/**
		 * 
		public function get skin() : DisplayObject {

		/**

		/**

		/**

		/**

		/**

		/**

		/**
			if(isFormHeadingLabel) return;
			if(_showErrorMessageBox == value) return;

		/**

		/**

		/**
			if(isFormHeadingLabel) return;
			if(_showErrorMessageText == value) return;
			if(value) {
				if(!instructionText) instructionText = " ";
				addListeners();
				removeListeners();
			}
		}

		/**

		/**

		/**

		/**

		/**

		/**

		/**

		/**

		/**

		/**
		 * @private
		 */
		private var _instructionText : String;

		/**
		public function get instructionText() : String {
			return itemContainer.instructionText;

		/**
		 * @private
		 */
			if(!_instructionText) _instructionText = value;
			itemContainer.instructionText = value;
		}

		/**

		/**
		 * <p>Acceptable values for the <code>labelAlign</code>: 
		 * <dl>
		 *  <dt><strong><code>FormLayoutStyle.RIGHT</code></strong>(default) : right end of label field.</dt>
		 *  <dt><strong><code>FormLayoutStyle.LEFT</code></strong> :  far left of <code>Form</code>.</dt>
		 *  <dt><strong><code>FormLayoutStyle.TOP</code></strong> : will be stacked vertically</dt>
		 * </dl>
		 * </p>

		/**

		/**

		/**
		 * 
		 * @default NaN

		/**

		/**

		/**

		/**

		/**

		/**
		 * <dl>
		 *  <dt><strong><code>FormLayoutStyle.INDICATOR_LABEL_RIGHT</code></strong>(default) : between a label and items.</dt>
		 * </dl>

		/**

		/**
		private var _itemAlign : String = FormLayoutStyle.DEFAULT_ITEM_ALIGN;

		/**
		 * <p>Acceptable values for the <code>itemAlign</code>: 
		 * <dl>
		 *  <dt><strong><code>FormLayoutStyle.HORIZONTAL</code></strong>(default)</dt>
		 *  <dt><strong><code>FormLayoutStyle.VERTICAL</code></strong></dt>
		 * </dl>
			return _itemAlign;
		}

		/**
			if(_itemAlign == value) return;
			_itemAlign = value;
			if(this.itemContainer) itemContainer.itemAlign = value;
		}

		/**
		private var _itemVerticalGap : Number = FormLayoutStyle.DEFAULT_FORMITEM_VERTICAL_GAP;

		/**
			return _itemVerticalGap;
		}

		/**
			if(itemVerticalGap == value) return;
		}

		/**
		private var _itemHorizontalGap : Number = FormLayoutStyle.DEFAULT_FORMITEM_HORIZONTAL_GAP;

		/**
			return _itemHorizontalGap;
		}

		/**

		/**
		private var _horizontalGap : Number = FormLayoutStyle.DEFAULT_HORIZONTAL_GAP;

		/**
			return _horizontalGap;
		}

		/**
			if(_horizontalGap == value) return;
			_horizontalGap = value;
			formItemLayout.horizontalGap = value;
		}

		
		/**

		/**

		/**
		}

		/**

		/**
			return _isFormHeadingLabel;

		/**
		 * @private
		 */

		/**

		/**

		/**

		/**

		/**

		/**

		/**
		 * @return RequiredIndicator

		/**
		 * @private
		 */
		public function set requiredIndicator(value : DisplayObject) : void {
			FormLayoutStyle.defaultStyles["indicatorSkin"] = value;
		}

		/**

		/**
					this.horizontalGap = Number(value);
				case FormLayoutEvent.UPDATED_PADDING_RIGHT:
					this.sidePadding = Number(value);
					break;	
			}

		//--------------------------------------
		}

		/**

		/**

		/**

		/**
			var tf : TextField = FormLayoutStyle.defaultTextField;
			tf.defaultTextFormat = FormLayoutStyle.defaultStyles["textFormat"];
			tf.autoSize = TextFieldAutoSize.LEFT;
			tf.htmlText = value;
			return tf;
		}

		private function addLabel( txt : String = "") : FormItemLabel {
			var labelItem : FormItemLabel = new FormItemLabel();
			labelItem.addEventListener(FormLayoutEvent.LABEL_ADDED, label_change, false, 0, true);
			labelItem.attLabel(txt);
			return labelItem;
		}

		/**
			gotResultBool &&= true;
			if(!gotResultBool && hasMultipleItems) return;
		}

		/**
			if(showErrorMessageText) instructionText = e.errorMessage ? e.errorMessage.toString() : this.errorString;
			if(!errorGrayBoxSprite) {
				var w : Number = this.width;
				var form : Object = this.parent.parent;
				// If this FormItem is a part of Form, width of gray box will be set to width of Form.
				if(this.parent.parent is IForm && form.paddingRight is Number) {
					var formWidth : Number = form.width - form.paddingRight - form.paddingLeft;
					if(formWidth > w) w = formWidth;
				}
				errorGrayBoxSprite = drawErrorGrayBox(-2, -2, w + 4, this.height + 4, FormLayoutStyle.defaultStyles["errorBoxColor"], FormLayoutStyle.defaultStyles["errorBoxAlpha"]);
			}
			errorGrayBoxSprite.visible = true;
		}

		/**

		/**
			this.removeEventListener(FormDataManagerEvent.VALIDATION_PASSED, handler_validation_passed);

		/**
		 * @private
		 */
		private function drawErrorGrayBox(x : Number, y : Number,w : Number, h : Number, clr : uint = 0xffffff, alpha : Number = 0) : Sprite {
			var sprite : Sprite = new Sprite();
			sprite.graphics.beginFill(clr, alpha);
			sprite.graphics.drawRect(x, y, w, h);
			sprite.graphics.endFill();
			return sprite;
		}
	}
}
