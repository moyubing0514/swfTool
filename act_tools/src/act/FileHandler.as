package act
{
	import act.avatar.PartType;

	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.filesystem.File;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;

	import gear.ui.manager.UIManager;
	import gear.utils.MathUtil;

	/**
	 * @author moyubing
	 */
	public class FileHandler extends EventDispatcher
	{
		public var file:File;
		public var data:ToolsData=new ToolsData();
		public var rect:Rectangle;
		public var _data:ToolsData=new ToolsData();
		public var list:Array=new Array();
		public var bd:BitmapData;
		private var _domain:ApplicationDomain;
		private var _context:LoaderContext;
		private var _mc:MovieClip=new MovieClip();
		private var _loader:Loader;
		private var _swfName:String;
		private var type:int;
		private var _typeNameofRole:String="";
		private var _itemIDofRole:String;
		private var _mtx:Matrix=new Matrix();

		public function FileHandler()
		{
			_mtx.identity();
			_mtx.scale(0.363, 0.363);
			_mtx.translate(300, 300);
			_loader=new Loader();
			_context=new LoaderContext(false, ApplicationDomain.currentDomain);
			try
			{
				_context["allowLoadBytesCodeExecution"]=true;
			}
			catch (e:Error)
			{
			}
			_loader.contentLoaderInfo.addEventListener(Event.COMPLETE, completeHandler);
		}

		public function start(t:int):void
		{
			type=t;
			if (file == null)
				return;
			_swfName=getFileName(file);
			_loader.loadBytes(FileUtil.readBytes(file.nativePath), _context);
		}

		private function completeHandler(event:Event):void
		{
			_domain=LoaderInfo(event.currentTarget).applicationDomain;
			var mcclass:Class=getClass(_swfName);
			if (mcclass == null)
			{
				trace("无法反射到资源：" + file.name);
				dispatchEvent(new Event(Event.COMPLETE));
				return;
			}
			_mc=new mcclass();
			export();
		}

		public function export():void
		{
			var totalFrames:int=_mc.totalFrames;
			for (var i:int=1; i < totalFrames + 1; i++)
			{
				_mc.gotoAndStop(i);
				switch (type)
				{
					case SourceType.ITEM:
					{
						bd=new BitmapData(900, 900, true, 0);
						for (var ii:int=0; ii < _mc.numChildren; ii++)
						{
							exportDataItem(ii);
						}
						var data:ToolsData=list[0] as ToolsData;
						if (data == null)
						{
							list[0]=new ToolsData();
							data=list[0];
							data.bitmapDatas=new Vector.<BitmapData>();
							data.mcClassName=PartType.getLibNameByType(_typeNameofRole) + "_" + _swfName.split("_")[1] + "_" + _itemIDofRole;
							data.positions=new Vector.<Rectangle>();
						}
						data.bitmapDatas.push(catBD(bd));
						data.positions.push(new Rectangle(rect.x - 300, rect.y - 300));
						break;
					}
					case SourceType.NPCS:
					{
						exportDataNpcs();
						break;
					}
					case SourceType.ROLE:
					{
						for (var ii:int=0; ii < _mc.numChildren; ii++)
							exportDataRole(ii);
						break;
					}
				}
			}
			dispatchEvent(new Event(Event.COMPLETE));
		}

		// private function playMC(_mc : MovieClip) : void {
		// for (var i : int = 0; i < _mc.numChildren; i++) {
		// var obj : * = _mc.getChildAt(i);
		// if (obj is MovieClip)
		// MovieClip(obj).play();
		// }
		// }
		private function exportDataItem(index:int):void
		{
			for (var i:int=0; i < _mc.numChildren; i++)
			{
				_mc.getChildAt(i).visible=false;
			}
			var objRoles:DisplayObject=_mc.getChildAt(index);
			// file.parent.parent.name is type of items
			if (objRoles.name.indexOf("_") == -1 || getItemTypeName(objRoles.name.split("_")[0]) != file.parent.parent.name)
			{
				trace(_swfName + "中输出元件的时候检测到没有符合规格的元件：" + objRoles.name);
			}
			else if (getItemTypeName(objRoles.name.split("_")[0]) == file.parent.parent.name)
			{
				_typeNameofRole=objRoles.name.split("_")[0];
				_itemIDofRole=objRoles.name.split("_")[1];
				objRoles.visible=true;
				bd.draw(_mc, _mtx);
			}
		}

		private function exportDataRole(index:int):void
		{
			for (var i:int=0; i < _mc.numChildren; i++)
			{
				_mc.getChildAt(i).visible=false;
			}
			var objRoles:DisplayObject=_mc.getChildAt(index);
			if (objRoles.name.indexOf("_") == -1)
			{
				// trace(_swfName + "中输出元件的时候检测到没有符合规格的元件：" + objRoles.name);
			}
			else
			{
				_typeNameofRole=objRoles.name.split("_")[0];
				_itemIDofRole=objRoles.name.split("_")[1];
				objRoles.visible=true;
				bd=new BitmapData(900, 900, true, 0);
				bd.draw(_mc, _mtx, null, null, null, false);
				var data:ToolsData;
				if (objRoles.name == "role_000_shadow")
					data=list[PartType.SHADOW] as ToolsData;
				else
					data=list[PartType.getIDBy(_typeNameofRole)] as ToolsData;
				if (data == null)
				{
					list[PartType.getIDBy(_typeNameofRole)]=new ToolsData();
					data=list[PartType.getIDBy(_typeNameofRole)];
					data.bitmapDatas=new Vector.<BitmapData>();
					if (objRoles.name == "role_000_shadow")
						data.mcClassName="role_000_shadow";
					else
						data.mcClassName=_typeNameofRole + "_" + _swfName.split("_")[1] + "_" + _itemIDofRole;
					data.positions=new Vector.<Rectangle>();
				}
				var bd2:BitmapData=catBD(bd);
				// if (_typeNameofRole == "fistL" || _typeNameofRole == "fistR" || _typeNameofRole == "armL" || _typeNameofRole == "armR" || _typeNameofRole == "body")
				// data.bitmapDatas.push(removeAlache50(bd2, new Rectangle(0, 0, rect.width, rect.height)));
				// else
				data.bitmapDatas.push(bd2);
				trace(objRoles.x == rect.x);
				data.positions.push(new Rectangle(rect.x - 300, rect.y - 300));
			}
		}

		// 添加到UI窗口的舞台
		// private function addToStage(value : DisplayObject) : void {
		// if (value == null) return;
		// UIManager.root.stage.addChild(value);
		// }
		//
		// private function removeAlache50(value : BitmapData, rec : Rectangle) : BitmapData {
		// for (var i : int = rec.x; i < rec.width; i++) {
		// for (var j : int = rec.y; j < rec.height; j++) {
		// var pixel : uint = value.getPixel32(i, j);
		//					//  trace((pixel).toString(16));
		// if (isTranslucent(pixel)) {
		// trace("0x" + pixel.toString(16));
		// value.setPixel32(i, j, value.getPixel32(i, j) | 0xff000000);
		//						//  trace(pixel);1c000000
		// }
		// }
		// }
		// return value;
		// }
		// 判断是否是需要处理的像素
		// private function isTranslucent(i : uint) : Boolean {
		// if (((i >> 24) & 0xFF) < uint(0.01 * 0xff)) {
		// return false;
		// } else if (((i >> 24) & 0xFF) > int(0.9 * 0xff)) {
		// return false;
		// } else if ((i & 0xffffff) == 0x585858) {
		// return false;
		// } else if ((i & 0xffffff) == 0x000000) {
		// return false;
		// } else if ((i & 0xffffff) == 0x333333) {
		// return false;
		// } else if ((i & 0xffffff) == 0x313131) {
		// return false;
		// } else if ((i & 0xffffff) == 0x313131) {
		// return false;
		// }
		// return true;
		// }
		private function exportDataNpcs():void
		{
			for (var i:int=0; i < _mc.numChildren; i++)
			{
				_mc.visible=false;
			}
			var objNpcs:DisplayObject=_mc;
			objNpcs.visible=true;

			bd=new BitmapData(900, 900, true, 0);
			bd.draw(_mc, _mtx);
			var data:ToolsData=list[0] as ToolsData;

			if (data == null)
			{
				list[0]=new ToolsData();
				data=list[0];
				data.bitmapDatas=new Vector.<BitmapData>();
				if (_swfName.split("_").length == 3)
				{
					data.mcClassName="npc_" + _swfName.split("_")[2] + "_" + _swfName.split("_")[1];
				}
				else
				{
					data.mcClassName="npc_" + _swfName.split("_")[1];
				}
				trace(data.mcClassName);
				data.positions=new Vector.<Rectangle>();
			}
			data.bitmapDatas.push(catBD(bd));
			data.positions.push(new Rectangle(rect.x - 300, rect.y - 300));
		}

		private function catBD(source:BitmapData):BitmapData
		{
			rect=source.getColorBoundsRect(0xFF000000, 0x00000000, false);
			if (rect.equals(source.rect) || rect.width == 0 || rect.height == 0)
			{
				return source;
			}
			var bd:BitmapData=new BitmapData(rect.width, rect.height, true, 0);
			bd.copyPixels(source, rect, new Point(0, 0));
			return bd;
		}

		public function getClass(className:String):Class
		{
			if (!_domain.hasDefinition(className))
			{
				return null;
			}
			var assetClass:Class=_domain.getDefinition(className) as Class;
			return assetClass;
		}

		private function getFileName(s:File):String
		{
			return s.name.split(".")[0];
		}

		private function getItemTypeName(value:String):String
		{
			switch (value)
			{
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
	}
}

