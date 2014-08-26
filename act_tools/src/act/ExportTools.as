package act {
	import gear.core.Game;
	import gear.net.LibData;
	import gear.net.SWFLoader;
	import gear.ui.controls.GButton;
	import gear.ui.data.GButtonData;

	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filesystem.File;


	/**
	 * @author tangjunhua
	 */
	[SWF(width=1000,height=570,backgroundColor=0xfffff0,frameRate="30")]
	public class ExportTools extends Game {
		private var _file : File;
		private var _swfList : Array = [];
		private var _exportPNG : ExportPNG;
		private var _selectFolder_btn2 : GButton;
		private var _swfData : EditableSWF = new EditableSWF();

		public function ExportTools() {
		}

		override protected function startup() : void {
			_res.add(new SWFLoader(new LibData("ui/ui.swf", "uiLib")));
			_res.add(new SWFLoader(new LibData("ui/view.swf", "viewLib")));
			_res.addEventListener(Event.COMPLETE, completeHandler);
			_res.load();
		}

		private function completeHandler(event : Event) : void {
			addButtons();
			initEvents();

			_exportPNG = new ExportPNG();
			_exportPNG.addEventListener(Event.COMPLETE, convertComplete);
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

		private function addButtons() : void {
			var data : GButtonData = new GButtonData();
			data.labelData.text = "选择swf文件夹";
			_selectFolder_btn2 = new GButton(data);
			addChild(_selectFolder_btn2);
		}

		private function dirSelected(event : Event) : void {
			_file = event.target as File;
			var files : Array = _file.getDirectoryListing();
			if (files.length > 0) getAllPNGFiles(_file);
		}

		private function getAllPNGFiles(directory : File) : void {
			var file : File;
			var files : Array = directory.getDirectoryListing();
			for (var i : uint = 0; i < files.length; i++) {
				file = files[i] as File;
				if (file.extension == "swf") {
					_swfList.push(file);
				}
			}
			if (_swfList.length > 0) startConvert(_swfList.shift());
		}

		private function startConvert(file : File) : void {
			_exportPNG.file = file;
			_exportPNG.start();
		}

		private function convertComplete(event : Event) : void {

			if (_swfList.length > 0) {
				writeMc(_exportPNG._list);
				startConvert(_swfList.shift());
				_exportPNG._list=new Array();
			} else {
				writeMc(_exportPNG._list);
				_exportPNG._list=new Array();
				_swfData.tags.clearTags();
				_swfData.collectTags();
				_swfData.header.isCompressed = true;
				_swfData.writeToFile(_file.nativePath + "/Export/" + "Package.swf");
			}
		}

		private function writeMc(value : Array) : void {
			for each (var actToolData:ToolsData in value) {
				_swfData.savePngList2Swf(actToolData.bitmapDatas, actToolData.positions, actToolData.mcClassName);
				//trace(actToolData.mcClassName+" "+actToolData.bitmapDatas.length+" "+actToolData.positions.length);
			}
		}
	}
}
