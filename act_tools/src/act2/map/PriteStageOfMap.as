package act2.map {
	import act.FileUtil;
	import act.MapPNGLoader;

	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFieldType;
	import flash.ui.Mouse;

	/**
	 * @author moyubing
	 */
	[SWF(width=1200,height=600,backgroundColor=0xffffff,frameRate="30")]
	public class PriteStageOfMap extends Sprite {
		private var _loader : Loader;
		private var _context : LoaderContext;
		private var _domain : ApplicationDomain;
		private var _textFieldWidth : TextField = new TextField();
		private var _textFieldHeight : TextField = new TextField();
		private var _button : TextField = new TextField();
		private var _mc : MovieClip = new MovieClip();
		private var _textChild : TextField = new TextField();
		private const MAP_URL : String = "d://111922.swf";

		public function PriteStageOfMap() {
			_loader = new Loader();
			_context = new LoaderContext(false, ApplicationDomain.currentDomain);
			try {
				_context["allowLoadBytesCodeExecution"] = true;
			} catch(e : Error) {
			}
			_loader.contentLoaderInfo.addEventListener(Event.COMPLETE, completeHandler);
			_loader.loadBytes(FileUtil.readBytes(MAP_URL), _context);
		}

		private function completeHandler(event : Event) : void {
			_domain = LoaderInfo(event.currentTarget).applicationDomain;
			_mc = event.target.content as MovieClip;
			_mc.gotoAndStop(1);
			textFieldFormat(_textFieldWidth);
			textFieldFormat(_textFieldHeight, _textFieldWidth.x);
			textFieldFormat(_textChild, _textFieldHeight.x, "1");
			buttonFormat();

			_button.addEventListener(MouseEvent.CLICK, ClickListener);
			_button.addEventListener(MouseEvent.MOUSE_OVER, mouseOverListener);
			_button.addEventListener(MouseEvent.MOUSE_OUT, mousOutListener);
			trace(_mc.numChildren);
			getBitmap(1);
		}

		private function mousOutListener(event : MouseEvent) : void {
			_button.backgroundColor = 0xff000000;
		}

		private function mouseOverListener(event : MouseEvent) : void {
			trace("over");
			_button.backgroundColor = 0xff333333;
		}

		private function ClickListener(event : MouseEvent) : void {
			_button.backgroundColor = 0xff777777;
			if (uint(_textChild.text) < _mc.numChildren) {
				for (var i : uint = 0;i < this.numChildren;++i) {
					if (this.getChildAt(i) is MovieClip) this.removeChildAt(i);
				}
				getBitmap(uint(_textChild.text));
			}
			trace(_textChild.text);
		}


		private function buttonFormat() : void {
			_button.selectable = false;
			_button.x = _textChild.x + _textFieldHeight.width;
			_button.htmlText = "确定";
			_button.textColor = 0xffffffff;
			_button.background = true;
			_button.autoSize = TextFieldAutoSize.CENTER;
			_button.border = true;
			_button.backgroundColor = 0xff000000;
			this.addChild(_button);
		}

		private function getBitmap(i : uint) : void {
			var bd : BitmapData = new BitmapData(_mc.width, _mc.height);
			bd.draw(_mc.getChildAt(i));
			var mc2 : MovieClip = new MovieClip();
			var bd2 : BitmapData = new BitmapData(uint(_textFieldWidth.text), uint(_textFieldHeight.text), true, 0x00000000);
			bd2.draw(bd);
			var bitmap : Bitmap = new Bitmap(bd2);
			bitmap.x = 50;
			bitmap.y = 50;
			mc2.addChild(bitmap);
			this.addChild(mc2);
		}

		public function textFieldFormat(txt : TextField, x : uint = 0, str : String = "500") : void {
			txt.x = x;
			txt.type = TextFieldType.INPUT;
			txt.background = true;
			txt.border = true;
			txt.backgroundColor = 0xffffffff;
			txt.autoSize = TextFieldAutoSize.CENTER;
			txt.restrict = "0-9";
			txt.text = str;
			this.addChild(txt);
		}

		public function getClass(className : String) : Class {
			if (!_domain.hasDefinition(className)) {
				return null;
			}
			var assetClass : Class = _domain.getDefinition(className) as Class;
			return assetClass;
		}
	}
}
