package act2.itemKinds {
	import act.FileUtil;
	import act.ToolsData;
	import act.avatar.PartType;

	import gear.ui.manager.UIManager;
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
	public class ItemHandler extends EventDispatcher {
		// private var _folder : File;
		private var _domain : ApplicationDomain;
		private var _context : LoaderContext;
		private var _mc : MovieClip = new MovieClip();
		private var _loader : Loader;
		private var _swfName : String;
		private var _typeNameofRole : String = "";
		private var _itemIDofRole : String;
		private  var _mtx : Matrix = new Matrix();
		public var file : File;
		public var rect : Rectangle;
		public var list : Array = new Array();
		public var bd : BitmapData;
		public var needList : Array = ["hat", "pants", "belt", "glovesL", "glovesR", "shoesL", "shoesR", "coat", "sleeveL", "sleeveR", "wepBody", "wepHand"];

		// public var needList : Array = ["wepBody"];
		public function ItemHandler() {
			_mtx.identity();
			_mtx.scale(0.363, 0.363);
			_mtx.translate(300, 300);
		}

		public function start() : void {
			_loader = new Loader();
			_loader.unload();
			_context = new LoaderContext();
			try {
				_context["allowLoadBytesCodeExecution"] = true;
			} catch(e : Error) {
			}
			_loader.contentLoaderInfo.addEventListener(Event.COMPLETE, completeHandler);
			if (file == null) return;
			_swfName = getFileName(file);
			_loader.loadBytes(FileUtil.readBytes(file.nativePath), _context);
		}

		private function completeHandler(event : Event) : void {
			_domain = LoaderInfo(event.currentTarget).applicationDomain;
			var mcclass : Class = getClass(_swfName);
			if (mcclass == null) {
				trace("无法反射到资源：" + file.name);
				dispatchEvent(new Event(Event.COMPLETE));
				return;
			}
			_mc = new mcclass();
			for (var i : int = 1;i < _mc.totalFrames + 1;i++) {
				_mc.gotoAndStop(i);
				for (var ii : int = 0; ii < _mc.numChildren; ii++) {
					exportDataItem(ii);
					var indexID : int = PartType.getIDBy(_typeNameofRole);
					if (indexID < 0) continue;
					var partTypeList : Array = list[indexID] as Array;
					if (partTypeList == null)
						list[indexID] = new Array();
					partTypeList = list[indexID] ;
					var indexStr : String = getName(file.parent) + "_" + getName(file);
					var folderList : ToolsData = partTypeList[indexStr] as ToolsData;
					if (folderList == null) {
						partTypeList[indexStr] = new ToolsData();
						folderList = partTypeList[indexStr];
						folderList.bitmapDatas = new Vector.<BitmapData>();
						folderList.mcClassName = _typeNameofRole + "_" + _swfName.split("_")[1] + "_" + _itemIDofRole;
						folderList.positions = new Vector.<Rectangle>();
					}
					if (bd != null) {
						folderList.bitmapDatas.push(catBD(bd));
						folderList.mcClassName = _typeNameofRole + "_" + _swfName.split("_")[1] + "_" + _itemIDofRole;
						folderList.positions.push(new Rectangle(rect.x - 300, rect.y - 300));
					}
				}
			}
			dispatchEvent(new Event(Event.COMPLETE));
		}

		private function getName(f : File) : String {
			return f.name.split('.')[0];
		}

		private function exportDataItem(index : int) : void {
			for (var i : int = 0; i < _mc.numChildren; i++)
				_mc.getChildAt(i).visible = false;
			bd = new BitmapData(900, 900, true, 0);
			var objRoles : DisplayObject = _mc.getChildAt(index);
			objRoles.visible = true;
			if (objRoles.name.indexOf("_") == -1 || !inNeedList(objRoles.name.split("_")[0], needList) || int(objRoles.name.split("_")[1]) <= 101) {
				// trace(_swfName + "中输出元件的时候检测到没有符合规格的元件：" + objRoles.name);
				bd = null;
			} else {
				_typeNameofRole = objRoles.name.split("_")[0] ;
				trace("脚本名字:", objRoles.name);
				_itemIDofRole = objRoles.name.split("_")[1];
				bd.draw(_mc, _mtx);
			}
		}

		private function inNeedList(strValue : String, ls : Array) : Boolean {
			for each (var str:String in ls)
				if (str == strValue) return true;
			return false;
		}

		private function catBD(source : BitmapData) : BitmapData {
			rect = source.getColorBoundsRect(0xFF000000, 0x00000000, false);
			if (rect.equals(source.rect) || rect.width == 0 || rect.height == 0) return source;
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

		private function getFileName(s : File) : String {
			return s.name.split(".")[0];
		}
	}
}

