package act2.monster {
	import gear.render.BDList;

	import flash.display.Sprite;

	import act.FileUtil;
	import act.ToolsData;
	import act.avatar.PartType;

	import gear.utils.MathUtil;

	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.filesystem.File;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;

	/**
	 * @author moyubing
	 */
	[SWF(width=1200,height=600,backgroundColor=0xffffff,frameRate="30")]
	public class SWFFomater extends Sprite {
		public var file : File;
		private var _swfName : String;
		private var _loader : Loader;
		private var _context : LoaderContext;
		private var _mc : MovieClip;
		public var rect : Rectangle;
		public var _data : ToolsData = new ToolsData();
		public var _list : Array = new Array();
		public var _actList : Array = new Array();
		public var showMc : Vector.<MovieClip> = new Vector.<MovieClip>();
		public var list : Vector.<BDList> = new Vector.<BDList>()

		public function SWFFomater() {
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
				_list = new Array();
				showMc.push(MovieClip(_mc.getChildAt(i)));
				for (var ii : int = 1;ii < showMc[i].totalFrames + 1;ii++) {
					showMc[i].gotoAndStop(ii);
					export(i, showMc[i]);
				}
				_actList.push(_list);
			}
			dispatchEvent(new Event(Event.COMPLETE));
		}

		public function start(f : File = null) : void {
			file = f;
			if (file == null) return;
			_swfName = getFileName(file.name);
			_loader.loadBytes(FileUtil.readBytes(file.nativePath), _context);
		}

		private function export(index : uint, mc : MovieClip) : void {
			for (var i : int = 0; i < mc.numChildren; i++) {
				mc.getChildAt(i).visible = true;
			}
			// var obj : DisplayObject = mc.getChildAt(index);
			// obj.visible = true;
			var mtx : Matrix = new Matrix();
			var bd : BitmapData;
			mtx.identity();
			// mtx.scale(0.363, 0.363);
			mtx.translate(300, 300);
			bd = new BitmapData(900, 900, true, 0);
			bd.draw(mc, mtx);
			var data : ToolsData = _list[index] as ToolsData;
			if (data == null) {
				_list[index] = new ToolsData();
				data = _list[index] ;
				data.bitmapDatas = new Vector.<BitmapData>();
				data.mcClassName = new String();
				data.positions = new Vector.<Rectangle>();
			}
			data.bitmapDatas.push(catBD(bd));
			// x y 調整位置
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
