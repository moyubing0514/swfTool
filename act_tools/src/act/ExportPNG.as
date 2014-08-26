package act {
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
	 * @author Cafe
	 * 
	 */
	public class ExportPNG extends EventDispatcher {
		public var file : File;
		private var _swfName : String;
		private var _loader : Loader;
		private var _domain : ApplicationDomain;
		private var _context : LoaderContext;
		private var _mc : MovieClip;
		public var rect : Rectangle;
		private var _positions : String = "";
		private var _typeNameofRole : String = "";
		private var _itemIDofRole : String;
		public var renderOrder : String = "";
		public var _data : ToolsData = new ToolsData();
		public var _list : Array = new Array();

		public function ExportPNG() {
			_loader = new Loader();
			_context = new LoaderContext(false, ApplicationDomain.currentDomain);
			try {
				_context["allowLoadBytesCodeExecution"] = true;
			} catch(e : Error) {
			}
			_loader.contentLoaderInfo.addEventListener(Event.COMPLETE, completeHandler);
		}

		private function completeHandler(event : Event) : void {
			_domain = LoaderInfo(event.currentTarget).applicationDomain;
			var mcclass : Class = getClass(_swfName);

			if (mcclass == null) {
				trace("无法反射到资源：" + _swfName);
				dispatchEvent(new Event(Event.COMPLETE));
				return;
			}
			_mc = new mcclass();
			export();
		}

		public function start() : void {
			if (file == null) return;
			_positions = "";
			renderOrder = "";
			_swfName = getFileName(file.name);
			// trace( _swfName);
			_loader.loadBytes(FileUtil.readBytes(file.nativePath), _context);
		}

		/**
		 * getClass 从SWF中获得类
		 * 
		 * @param className 类名称
		 * @return Class 类
		 */
		public function getClass(className : String) : Class {
			if (!_domain.hasDefinition(className)) {
				return null;
			}
			var assetClass : Class = _domain.getDefinition(className) as Class;
			return assetClass;
		}

		public function export() : void {
			var totalFrames : int = _mc.totalFrames;
			for (var i : int = 1;i < totalFrames + 1;i++) {
				_mc.gotoAndStop(i);
				for (var ii : int = 0; ii < _mc.numChildren; ii++) {
					exportDataRole(ii);
				}
				renderOrder += "\n";
			}

			FileUtil.writeStringToFile(file.parent.nativePath + "/" + _swfName.split("_")[1] + ".txt", renderOrder);
			renderOrder = "";
			dispatchEvent(new Event(Event.COMPLETE));
		}

		private function exportDataRole(index : int) : void {
			// 所有children不可见
			for (var i : int = 0; i < _mc.numChildren; i++) {
				_mc.getChildAt(i).visible = false;
			}
			var objRoles : DisplayObject = _mc.getChildAt(index);
			if (objRoles.name.indexOf("_") == -1) {
				// trace(_swfName + "中输出元件的时候检测到没有符合规格的元件：" + objRoles.name);
			} else {
				var temp : String = objRoles.name.split("_")[0];
				_typeNameofRole = getItemTypeName(objRoles.name.split("_")[0]) ;
				_itemIDofRole = objRoles.name.split("_")[1];
				renderOrder += PartType.getIDBy(temp) + ",";
				objRoles.visible = true;
				// draw时缩放平移矩阵
				var mtx : Matrix = new Matrix();
				var bd : BitmapData;
				mtx.identity();
				mtx.scale(0.363, 0.363);
				mtx.translate(300, 300);
				bd = new BitmapData(900, 900, true, 0);
				bd.draw(_mc, mtx);
				var data : ToolsData = _list[PartType.getIDBy(_typeNameofRole)] as ToolsData;
				if (data == null) {
					_list[PartType.getIDBy(_typeNameofRole)] = new ToolsData();
					data = _list[PartType.getIDBy(_typeNameofRole)] ;
					data.bitmapDatas = new Vector.<BitmapData>();
					data.mcClassName = _typeNameofRole + "_" + _swfName.split("_")[1] + "_" + _itemIDofRole;
					data.positions = new Vector.<Rectangle>();
				}
				data.bitmapDatas.push(catBD(bd));
				data.positions.push(new Rectangle(rect.x - 300, rect.y - 300));
			}
		}

		// 去除多余部分, 取有色矩形
		private function catBD(source : BitmapData) : BitmapData {
			rect = source.getColorBoundsRect(0xFF000000, 0x00000000, false);
			if (rect.equals(source.rect) || rect.width == 0 || rect.height == 0) {
				return source;
			}
			var bd : BitmapData = new BitmapData(rect.width, rect.height, true, 0);
			bd.copyPixels(source, rect, MathUtil.ZERO_POINT);
			return bd;
		}

		private function getItemTypeName(value : String) : String {
			return value;
			switch(value) {
				case "wepHand":
				case "wepBody":
					return "weapon";
				case "glovesL":
				case "glovesR":
					return "gloves";
				case "shoesL":
				case "shoesR":
					return "shoes";
				case "armL":
				case "armR":
					return "arm";
				case "fistL":
				case "fistR":
					return "fist";
				case "legL":
				case "legR":
					return "leg";
				case "footL":
				case "footR":
					return "foot";
				case "gloveL":
				case "gloveR":
					return "glove";
				default:
					return value;
			}
		}

		/**
		 * 去除文件名中的扩展名
		 */
		private function getFileName(s : String) : String {
			return s.split(".")[0];
		}
	}
}
