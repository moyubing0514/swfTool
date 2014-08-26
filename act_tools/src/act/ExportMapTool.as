package act {
	import flash.geom.Rectangle;
	import flash.display.BitmapData;

	import gear.core.Game;
	import gear.net.LibData;
	import gear.net.SWFLoader;
	import gear.ui.controls.GButton;
	import gear.ui.data.GButtonData;

	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filesystem.File;

	/**
	 * @author MoYubing
	 */
	[SWF(width=100,height=80,backgroundColor=0xff0000,frameRate="30")]
	public class ExportMapTool extends Game {
		private var _selectFolder_btn2 : GButton;
		private var _file : File;
		// maps
		private var _townsID : String = "0";
		private var _townsList : Array = [];
		private var _mapPNG2SWF : MapPNGLoader = new MapPNGLoader();
		private var _mapList : Array = new Array();
		private var _pngInsertIntoSWFofMap : EditableSWF = new EditableSWF();
		private var _townMapList : Array;
		private var _townMapPNG2SWF : MapPNGLoader;
		private var _pngInsertIntoSWFofTownMap : EditableSWF = new EditableSWF();

		public function ExportMapTool() {
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
			for each (var folder:File in _file.getDirectoryListing()) {
				// handle folders
				switch(SourceType.getIDby(folder.name.toLocaleLowerCase())) {
					case SourceType.MAP: {
						_mapList = folder.isDirectory ? folder.getDirectoryListing() : [];
						if (_mapList.length > 0 ) mapHandler(_mapList.shift());
						break;
					}
					case SourceType.TOWNS: {
						_townMapList = folder.isDirectory ? folder.getDirectoryListing() : [];
						if (_townMapList.length > 0 ) townMapHandler(_townMapList.shift());
						break;
					}
				}
			}
		}

		private function mapHandler(f : File) : void {
			_mapPNG2SWF = new MapPNGLoader();
			_mapPNG2SWF.addEventListener(Event.COMPLETE, mapPNG2SWFComplete);
			_mapPNG2SWF.folder = f;
			_mapPNG2SWF.startLoader();
		}

		private function townMapHandler(mapFolder : File) : void {
			_townMapPNG2SWF = new MapPNGLoader();
			_townMapPNG2SWF.folder = mapFolder;
			_townMapPNG2SWF.addEventListener(Event.COMPLETE, townMapPNG2SWFComplete);
			_townMapPNG2SWF.startLoader();
		}

		private function townMapPNG2SWFComplete(event : Event) : void {
			// var mapPackageName : String = "map_" + _mapPNG2SWF.pngFilesList[0].parent.name + "_" + _mapPNG2SWF.pngFilesList[0].name.split("_")[0] + ".swf";
			var townMapPackageName : String = _townMapPNG2SWF.folder.name + ".swf";
			for (var i : uint = 0; i < _townMapPNG2SWF.bitmapDataList.length ;++i  ) {
				var tempVectorBitmapData : Vector.<BitmapData> = new Vector.<BitmapData>();
				tempVectorBitmapData.push(_townMapPNG2SWF.bitmapDataList[i]);
				var tempVectorPositionList : Vector.<Rectangle> = new Vector.<Rectangle>();
				tempVectorPositionList.push(new Rectangle());
				_pngInsertIntoSWFofTownMap.savePngList2Swf(tempVectorBitmapData, new Vector.<Rectangle>(), _townMapPNG2SWF.nameList[i]);
			}
			_pngInsertIntoSWFofTownMap.collectTags();
			_pngInsertIntoSWFofTownMap.header.isCompressed = true;
			_pngInsertIntoSWFofTownMap.writeToFile(_file.nativePath + "/程序导出文件/bin/towns/town_" + townMapPackageName);
			_pngInsertIntoSWFofTownMap = new EditableSWF();
			if (_townMapList.length > 0) townMapHandler(_townMapList.shift());
		}

		private function mapPNG2SWFComplete(event : Event) : void {
			// var mapPackageName : String = "map_" + _mapPNG2SWF.pngFilesList[0].parent.name + "_" + _mapPNG2SWF.pngFilesList[0].name.split("_")[0] + ".swf";
			var mapPackageName : String = _mapPNG2SWF.folder.name + ".swf";
			for (var i : uint = 0; i < _mapPNG2SWF.bitmapDataList.length ;++i  ) {
				var tempVectorBitmapData : Vector.<BitmapData> = new Vector.<BitmapData>();
				tempVectorBitmapData.push(_mapPNG2SWF.bitmapDataList[i]);
				var tempVectorPositionList : Vector.<Rectangle> = new Vector.<Rectangle>();
				tempVectorPositionList.push(new Rectangle());
				_pngInsertIntoSWFofMap.savePngList2Swf(tempVectorBitmapData, new Vector.<Rectangle>(), _mapPNG2SWF.nameList[i]);
			}
			_pngInsertIntoSWFofMap.collectTags();
			trace(_file.nativePath + "/程序导出文件/bin/maps/map_" + mapPackageName);
			_pngInsertIntoSWFofMap.header.isCompressed = true;
			_pngInsertIntoSWFofMap.writeToFile(_file.nativePath + "/程序导出文件/bin/maps/map_" + mapPackageName);
			_pngInsertIntoSWFofMap = new EditableSWF();
			if (_mapList.length > 0) mapHandler(_mapList.shift());
		}
	}
}
