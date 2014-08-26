package act2.npcIcon {
	import act.FileUtil;
	import act.EditableSWF;
	import act.ToolsData;

	import gear.core.Game;
	import gear.net.LibData;
	import gear.net.SWFLoader;
	import gear.ui.controls.GButton;
	import gear.ui.data.GButtonData;

	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filesystem.File;
	import flash.geom.Rectangle;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;

	/**
	 * @author moyubing
	 */
	[SWF(width=1200,height=600,backgroundColor=0x000000,frameRate="30")]
	public class npcIcon extends Game {
		private var _file : File;
		private var _loader : Loader;
		private var _context : LoaderContext;
		private var _list : Array = new Array();
		private var _selectFolder_btn2 : GButton;
		private var _fileList : Array = new  Array();
		private var _townList : Array = new  Array();
		private var _currentFile : File;

		override protected function startup() : void {
			_res.add(new SWFLoader(new LibData("ui/ui.swf", "uiLib")));
			_res.add(new SWFLoader(new LibData("ui/view.swf", "viewLib")));
			_res.addEventListener(Event.COMPLETE, completeHandler);
			_res.load();
		}

		private function completeHandler(event : Event) : void {
			addButtons();
			initEvents();
		}

		private function addButtons() : void {
			var data : GButtonData = new GButtonData();
			data.labelData.text = "选择swf文件夹";
			_selectFolder_btn2 = new GButton(data);
			addChild(_selectFolder_btn2);
		}

		private function initEvents() : void {
			_selectFolder_btn2.addEventListener(MouseEvent.CLICK, selectFolderClickHandler);
		}

		private function selectFolderClickHandler(event : MouseEvent) : void {
			_file = new File();
			try {
				_file.addEventListener(Event.SELECT, dirSelected);
				_file.browseForDirectory("Select a directory");
			} catch(error : Error) {
				trace(error);
			}
		}

		private function dirSelected(event : Event) : void {
			_file = new File((event.target as File).nativePath + "/npc_icons/");
			trace(_file.nativePath);
			_loader = new Loader();
			_context = new LoaderContext(false, ApplicationDomain.currentDomain);
			try {
				_context["allowLoadBytesCodeExecution"] = true;
			} catch(e : Error) {
			}
			for each (var f:File in  _file.isDirectory ? _file.getDirectoryListing() : null) {
				_townList.push(f);
			}
			if (_townList.length > 0)
				getNpcIconFiles(_townList.shift());
		}

		private function getNpcIconFiles(folder : File) : void {
			_list = new Array();
			for each (var f:File in folder.isDirectory ? folder.getDirectoryListing() : null) {
				if (f.extension == "png" )
					_fileList.push(f);
			}
			if (_fileList.length > 0) {
				startConvert(_fileList.shift());
			} else if (_townList.length > 0) {
				getNpcIconFiles(_townList.shift());
			}
		}

		private function startConvert(f : File) : void {
			_currentFile = f;
			_loader.contentLoaderInfo.addEventListener(Event.COMPLETE, loaderCompleteHandler);
			_loader.loadBytes(FileUtil.readBytes(f.nativePath), _context);
		}

		private function loaderCompleteHandler(event : Event) : void {
			var icon : BitmapData = event.target.content.bitmapData;
			var toolData : ToolsData = new ToolsData();
			toolData.bitmapDatas = new Vector.<BitmapData>();
			toolData.bitmapDatas.push(icon);
			toolData.mcClassName = "npc_icon_" + _currentFile.name.split(".")[0].replace("npc_icon_", "");
			trace(toolData.mcClassName);
			_list.push(toolData);
			if (_fileList.length > 0) {
				startConvert(_fileList.shift());
			} else if (_townList.length > 0) {
				writeSWF();
				getNpcIconFiles(_townList.shift());
			} else {
				writeSWF();
			}
		}

		private function writeSWF() : void {
			var swf : EditableSWF = new EditableSWF();
			for each (var td:ToolsData in _list) {
				swf.addPNGOnly(td.bitmapDatas[0], td.mcClassName);
			}
			swf.writeToFile(_file.parent.nativePath + "/程序导出文件/bin/npc_icons/" + _currentFile.parent.name + ".swf");
		}
	}
}

