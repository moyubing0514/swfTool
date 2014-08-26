package {
	import act.FileUtil;

	import gear.utils.MathUtil;

	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Rectangle;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;

	/**
	 * @author moyubing
	 */
	[SWF(width=100,height=100,backgroundColor=0xffffff,frameRate="30")]
	public class CopyOftest extends Sprite {
		private var _loader : Loader;
		private const URL : String = "d:/a.swf";
		private var _context : LoaderContext;
		private var _domain : ApplicationDomain;
		private var _mc : MovieClip;
		public var rect : Rectangle;

		public function CopyOftest() {
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
			var mcclass : Class = getClass("mcName");
			if (mcclass == null) {
				trace("无法反射到资源：" + URL);
				dispatchEvent(new Event(Event.COMPLETE));
				return;
			}
			_mc = new mcclass();
			_mc.x = _mc.y = 0;
			addChild(_mc);
			_mc.play();
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
