package act2.icon {
	import flash.display.Bitmap;
	import flash.display.Sprite;

	import act.FileUtil;
	import act.EditableSWF;
	import act.ToolsData;

	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;

	/**
	 * @author moyubing
	 */
	[SWF(width=1200,height=600,backgroundColor=0xffffff,frameRate="30")]
	public class test  extends Sprite {
		private var _loader : Loader;
		private var _context : LoaderContext;
		private var _domain : ApplicationDomain;
		private var _mc : MovieClip = new MovieClip();
		private var _list : Array = new Array();
		// icon url
		private const ICON_URL : String = "d:\\icon3.swf";

		public function test() {
			_loader = new Loader();
			_context = new LoaderContext(false, ApplicationDomain.currentDomain);
			try {
				_context["allowLoadBytesCodeExecution"] = true;
			} catch(e : Error) {
			}
			_loader.contentLoaderInfo.addEventListener(Event.COMPLETE, completeHandler);
			_loader.loadBytes(FileUtil.readBytes(ICON_URL), _context);
		}

		private function completeHandler(event : Event) : void {
			_domain = LoaderInfo(event.currentTarget).applicationDomain;
			var mcclass : Class = getClass("i112030301");
			var obj:Object = new mcclass();
			trace(obj.height);
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
