package act2.monster {
	import act.FileUtil;
	import act.ToolsData;

	import gear.utils.MathUtil;

	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.filesystem.File;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;

	/**
	 * @author moyubing
	 */
	[SWF(width=1200,height=600,backgroundColor=0xffffff,frameRate="30")]
	public class MonsterHandler extends Sprite {
		public var file : File;
		private var _swfName : String;
		private var _loader : Loader;
		private var _context : LoaderContext;
		private var _mc : MovieClip;
		private var _scale : Rectangle;
		public var rect : Rectangle;
		public var list : Array = new Array();

		public function MonsterHandler() {
			_loader = new Loader();
			_context = new LoaderContext(false, ApplicationDomain.currentDomain);
			try {
				_context["allowLoadBytesCodeExecution"] = true;
			} catch(e : Error) {
			}
			_loader.contentLoaderInfo.addEventListener(Event.COMPLETE, completeHandler);
		}

		private function completeHandler(event : Event) : void {
			_mc = event.target.content as MovieClip;
			var totalFrames : int = _mc.totalFrames;
			trace("totalFrames: " + totalFrames);
			_mc.gotoAndStop(1);
			trace("numChildren: " + _mc.numChildren);
			for (var i : int = 0; i < _mc.numChildren; i++) {
				var temp : MovieClip = MovieClip(_mc.getChildByName("m" + (i + 1)));
				if(!temp) break;
				for (var ii : int = 1;ii < temp.totalFrames + 1;ii++) {
					temp.gotoAndStop(ii);
					export(i, temp);
				}
			}
			dispatchEvent(new Event(Event.COMPLETE));
		}

		public function start(f : File = null, scale : Rectangle = null) : void {
			_scale = scale;
			file = f;
			if (file == null) return;
			_swfName = getFileName(file.name);
			_loader.loadBytes(FileUtil.readBytes(file.nativePath), _context);
		}

		private function export(index : uint, mc : MovieClip) : void {
			var mtx : Matrix = new Matrix();
			var bd : BitmapData;
			mtx.identity();
			mtx.scale(_scale.x, _scale.y);
			mtx.translate(300, 300);
			bd = new BitmapData(900, 900, true, 0);
			bd.draw(mc, mtx);
			var data : ToolsData = list[0] as ToolsData;
			if (data == null) {
				list[0] = new ToolsData();
				data = list[0] ;
				data.bitmapDatas = new Vector.<BitmapData>();
				data.mcClassName = file.name.split(".")[0];
				data.positions = new Vector.<Rectangle>();
			}
			data.bitmapDatas.push(catBD(bd));
			data.positions.push(new Rectangle(rect.x - 300, rect.y - 300));
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

		/**
		 * 去除文件名中的扩展名
		 */
		private function getFileName(s : String) : String {
			return s.split(".")[0];
		}
	}
}
