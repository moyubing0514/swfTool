package act2.skill {
	import act.FileUtil;

	import gear.core.Game;
	import gear.images.PNGEncoder;
	import gear.net.LibData;
	import gear.net.SWFLoader;
	import gear.ui.controls.GButton;
	import gear.ui.data.GButtonData;

	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filesystem.File;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	import flash.utils.ByteArray;

	/**
	 * @author moyubing
	 */
	[SWF(width=880,height=680,backgroundColor=0x000000,frameRate="30")]
	public class Skill extends Game {
		private const SCALE : Number = 0.5;
		private  var _name : String = "";
		private var _loader : Loader;
		private var _context : LoaderContext;
		private var _mc : MovieClip;
		private var bd : BitmapData ;
		private var bitmapDatas : Vector.<BitmapData> = new Vector.<BitmapData>();
		private var pos : Vector.<Rectangle> = new Vector.<Rectangle>();
		private var _selectFolder_btn2 : GButton;
		private var _root : File = new File();
		private var _fileList : Array = new Array();
		public var rect : Rectangle;

		public function Skill() {
		}

		override protected function startup() : void {
			_res.add(new SWFLoader(new LibData("ui/ui.swf", "uiLib")));
			_res.add(new SWFLoader(new LibData("ui/view.swf", "viewLib")));
			_res.addEventListener(Event.COMPLETE, uiCompleteHandler);
			_res.load();
			_context = new LoaderContext(false, ApplicationDomain.currentDomain);
			try {
				_context["allowLoadBytesCodeExecution"] = true;
			} catch(e : Error) {
			}
			_loader = new Loader();
			_loader.contentLoaderInfo.addEventListener(Event.COMPLETE, completeHandler);
		}

		private function uiCompleteHandler(event : Event) : void {
			addButtons();
			_selectFolder_btn2.addEventListener(MouseEvent.CLICK, selectFolderClickHandler);
		}

		private function addButtons() : void {
			var data : GButtonData = new GButtonData();
			data.labelData.text = "选择swf文件夹";
			_selectFolder_btn2 = new GButton(data);
			addChild(_selectFolder_btn2);
		}

		private function selectFolderClickHandler(event : MouseEvent) : void {
			try {
				_root.addEventListener(Event.SELECT, dirSelected);
				_root.browseForDirectory("Select a directory");
			} catch(error : Error) {
				trace(error);
			}
		}

		private function dirSelected(event : Event) : void {
			_root = new File((event.target as File).nativePath + "/t/skill");
			getSkillList(_root);
		}

		private function getSkillList(folder : File) : void {
			for each (var f:File in folder.getDirectoryListing()) {
				if (f.extension == "swf") _fileList.push(f) ;
			}
			if (_fileList.length > 0)
				convert(_fileList.shift());
		}

		private function convert(f : File) : void {
			_name = f.name.split(".")[0];
			_loader.loadBytes(FileUtil.readBytes(f.nativePath), _context);
		}

		private function completeHandler(event : Event) : void {
			_mc = event.target.content as MovieClip;
			_mc.gotoAndStop(1);

			for (var j : uint = 0 ;j < _mc.numChildren ;++j) {
				if (!(_mc.getChildAt(j) is MovieClip))
					continue;
				var skillMc : MovieClip = MovieClip(_mc.getChildAt(j));
				for (var i : uint = 1 ;i < skillMc.totalFrames + 1;++i) {
					skillMc.gotoAndStop(i);
					if (skillMc.width == 0)
						bd = new BitmapData(1, 1, true, 0);
					else
						bd = new BitmapData(900, 900, true, 0);
					// trace(skillMc.width, skillMc.height);
					if (skillMc.numChildren != 0) {
						var translateX : Number = skillMc.getChildAt(0).x * SCALE;
						var translateY : Number = skillMc.getChildAt(0).y * SCALE;
						trace(skillMc.getChildAt(0).x, skillMc.getChildAt(0).y);
						trace(translateX, translateY);
					} else {
						var translateX : Number = 0;
						var translateY : Number = 0;
					}
					var mt : Matrix = new Matrix();
					mt.scale(SCALE, SCALE);
					mt.translate(300, 300);
					bd.draw(skillMc, mt);
					var posByteArray : ByteArray = new ByteArray();
					var a : BitmapData = catBD(bd);
					trace(a.width, a.height);
					FileUtil.writeBytesTofile(_root.nativePath + "/png/" + skillMc.name + "/" + skillMc.name + "_" + i + ".png", PNGEncoder.encode(a));
					posByteArray.writeUTFBytes((rect.x - 300) + "&" + (rect.y - 300));
					FileUtil.writeBytesTofile(_root.nativePath + "/png/" + skillMc.name + "/" + skillMc.name + "_" + i + ".txt", posByteArray);
					bitmapDatas.push(bd);
					pos.push(new Rectangle(rect.x, rect.y));
				}
			}
			bitmapDatas = new Vector.<BitmapData>();
			if (_fileList.length > 0) {
				convert(_fileList.shift());
			}
		}

		private function catBD(source : BitmapData) : BitmapData {
			rect = source.getColorBoundsRect(0xFF000000, 0x00000000, false);
			if (rect.equals(source.rect)) {
				return source;
			} else if ( rect.width == 0 || rect.height == 0) {
				rect.x = rect.y = 300;
				return new BitmapData(1, 1, true, 0);
			}
			var bd : BitmapData = new BitmapData(rect.width, rect.height, true, 0);
			bd.copyPixels(source, rect, new Point(0, 0));
			return bd;
		}
		//
		//		//  取范围更大的矩形
		// private function bigerRect(r : Rectangle, t : Rectangle) : Rectangle {
		// var a : Rectangle = new Rectangle();
		// a = (r.width * r.height < t.width * t.height) ? t : r;
		// return a;
		// }
	}
}
