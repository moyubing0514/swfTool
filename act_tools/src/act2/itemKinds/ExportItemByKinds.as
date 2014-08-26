package act2.itemKinds {
	import act.EditableSWF;
	import act.SourceType;
	import act.ToolsData;
	import act.avatar.PartType;

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
	[SWF(width=500,height=400,backgroundColor=0x000000,frameRate="30")]
	public class ExportItemByKinds extends Game {
		private var _selectFolder_btn2 : GButton;
		private var _file : File;
		// Items
		private var _SWFList : Array = new Array();
		private var _nameList : Array = new Array();
		private	var _handleItems : ItemHandler = new ItemHandler();
		private var _itemList : Array = [];
		private var _itemRoleTypeList : Array = [];

		public function ExportItemByKinds() {
		}

		override protected function startup() : void {
			_res.add(new SWFLoader(new LibData("ui/ui.swf", "uiLib")));
			_res.add(new SWFLoader(new LibData("ui/view.swf", "viewLib")));
			_res.addEventListener(Event.COMPLETE, completeHandler);
			_res.load();
		}

		private function completeHandler(event : Event) : void {
			addButtons();
			_selectFolder_btn2.addEventListener(MouseEvent.CLICK, selectFolderClickHandler);
			_handleItems.addEventListener(Event.COMPLETE, itemsExportComplete);
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
			var folder : File = new File(_file.nativePath + "\\item");
			_itemRoleTypeList = folder.isDirectory ? folder.getDirectoryListing() : [];
			if (_itemRoleTypeList.length > 0) getItemFromRoleTypeList(_itemRoleTypeList.shift());
		}

		private function getItemFromRoleTypeList(itemFolder : File) : void {
			for each (var itemFile:File in (itemFolder.isDirectory ? itemFolder.getDirectoryListing() : null)) {
				if (itemFile.extension == "swf")
					_itemList.push(itemFile);
				trace(itemFile.parent.name, itemFile.name);
			}
			if (_itemList.length > 0) {
				_handleItems.file = _itemList.shift();
				_handleItems.start();
			} else if (_itemRoleTypeList.length > 0) {
				getItemFromRoleTypeList(_itemRoleTypeList.shift());
			} else {
				for each (var indexIDStr:String in _handleItems.needList) {
					var dataList : Array = _handleItems.list[PartType.getIDBy(indexIDStr)] as Array;
					if (dataList == null) continue;
					for each (var writeData:ToolsData in dataList) {
						var indexStr : String = getLibNameByType(indexIDStr);
						if (_SWFList[indexStr] == null)
							_SWFList[indexStr] = new EditableSWF();
						_SWFList[indexStr].savePngList2Swf(writeData.bitmapDatas, writeData.positions, writeData.mcClassName);
						if (_nameList[indexStr] == null)
							_nameList[indexStr] = new String();
						_nameList[indexStr] = indexStr;
					}
				}
				writeSWFFile();
			}
		}

		private function itemsExportComplete(event : Event) : void {
			if (_itemList.length > 0) {
				_handleItems.file = _itemList.shift();
				_handleItems.start();
			} else if (_itemRoleTypeList.length > 0) {
				getItemFromRoleTypeList(_itemRoleTypeList.shift());
			} else {
				for each (var indexIDStr:String in _handleItems.needList) {
					var dataList : Array = _handleItems.list[PartType.getIDBy(indexIDStr)] as Array;
					if (dataList == null) continue;
					for each (var writeData:ToolsData in dataList) {
						var indexStr : String = getLibNameByType(indexIDStr);
						if (_SWFList[indexStr] == null)
							_SWFList[indexStr] = new EditableSWF();
						_SWFList[indexStr].savePngList2Swf(writeData.bitmapDatas, writeData.positions, writeData.mcClassName);
						if (_nameList[indexStr] == null)
							_nameList[indexStr] = new String();
						_nameList[indexStr] = indexStr;
					}
				}
				writeSWFFile();
			}
		}

		private function writeSWFFile() : void {
			for each (var swfName:String in _nameList) {
				var writeSWF : EditableSWF = _SWFList[swfName];
				if (writeSWF == null) continue;
				writeSWF.collectTags();
				writeSWF.writeToFile(_file.nativePath + "/程序导出文件/bin/items/1/" + swfName + ".swf");
			}
		}

		// 某些部件打包在一起
		public static function getLibNameByType(value : String) : String {
			var libName : String = "";
			switch(value) {
				case "wepHand":
				case "wepBody":
					libName = "weapon";
					break;
				case "glovesL":
				case "glovesR":
					libName = "gloves";
					break;
				case "shoesL":
				case "shoesR":
					libName = "shoes";
					break;
				case "sleeveL":
				case "sleeveR":
					libName = "coat";
					break;
				case "armL":
				case "armR":
					libName = "arm";
					break;
				case "fistL":
				case "fistR":
					libName = "fist";
					break;
				case "legL":
				case "legR":
					libName = "leg";
					break;
				case "footL":
				case "footR":
					libName = "foot";
					break;
				default:
					libName = value;
					break;
			}
			return libName;
		}
	}
}
