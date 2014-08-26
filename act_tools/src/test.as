package {
	import flash.utils.ByteArray;

	import org.libspark.swfassist.swf.structures.Rect;

	import gear.ui.bd.BDPlayer;
	import gear.utils.BDUtil;
	import gear.render.BDList;

	import flash.display.Shape;

	import act.FileUtil;

	import gear.utils.MathUtil;

	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.BlendMode;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;

	/**
	 * @author moyubing
	 */
	[SWF(width=100,height=100,backgroundColor=0xffffff,frameRate="30")]
	public class test extends Sprite {
		private var _loader : Loader;
		private const URL : String = "d:/a.swf";
		private var _context : LoaderContext;
		private var _domain : ApplicationDomain;
		private var _mc : BitmapData;
		// private var _strArr : Array = ["armL", "fistL", "body", "armR", "fistR",];
		public var rect : Rectangle;

		public function test() {
			_context = new LoaderContext(false, ApplicationDomain.currentDomain);
			try {
				_context["allowLoadBytesCodeExecution"] = true;
			} catch(e : Error) {
			}
			_loader = new Loader();
			_loader.contentLoaderInfo.addEventListener(Event.COMPLETE, completeHandler);
			_loader.loadBytes(FileUtil.readBytes(URL), _context);
		}

		private function completeHandler(event : Event) : void {
			_domain = LoaderInfo(event.currentTarget).applicationDomain;
			// for each (var str:String in _strArr) {
			var mcclass : Class = getClass("mcName");
			if (mcclass == null) {
				trace("无法反射到资源：" + URL);
				dispatchEvent(new Event(Event.COMPLETE));
				return;
			}

			_mc = new mcclass();
			// _mc.x = _mc.y = 0;
			// _mc.gotoAndStop(2);
			// var bd : BitmapData = new BitmapData(_mc.getChildAt(0).width, _mc.getChildAt(0).height, true, 0);
			// bd.draw(_mc.getChildAt(0), null, null, BlendMode.DIFFERENCE);
			// allBd.copyPixels(bd, bd.rect, new Point(_mc.getChildAt(0).x + 100, _mc.getChildAt(0).y + 150), allBd, p, true);
			// var bt : Bitmap = new Bitmap(bd);
			// bt.x = _mc.getChildAt(0).x + 300;
			// bt.y = _mc.getChildAt(0).y + 150;
			// _mc.getChildAt(0).x = _mc.getChildAt(0).x + 50;
			// _mc.getChildAt(0).y = _mc.getChildAt(0).y + 80;
			addChild(new Bitmap(_mc));
			trace(_mc.getPixel32(0, 0).toString(16));
			var ba : ByteArray = _mc.getPixels(new Rectangle(0,0,100, 100));
			for (ba.position=0;ba.position < ba.length;) {
				trace("0x"+ba.readUnsignedInt().toString(16));
			}
			// _mc.play();
			// }
		}

		private function catBD(source : BitmapData) : BitmapData {
			rect = source.getColorBoundsRect(0xFF000000, 0x00000000, false);
			if (rect.equals(source.rect) || rect.width == 0 || rect.height == 0) {
				return source;
			}
			var bd : BitmapData = new BitmapData(rect.width, rect.height, true, 0);
			bd.copyPixels(source, rect, MathUtil.ZERO_POINT);
			return bd;
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
