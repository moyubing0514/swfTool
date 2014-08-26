package act2.monster {
	import flash.utils.Timer;
	import flash.geom.Rectangle;

	import act.EditableSWF;
	import act.ToolsData;

	import gear.core.Game;
	import gear.net.LibData;
	import gear.net.SWFLoader;
	import gear.ui.controls.GButton;
	import gear.ui.data.GButtonData;
	import gear.ui.data.GColor;

	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filesystem.File;
	import flash.text.TextField;
	import flash.text.TextFieldType;

	/**
	 * @author MoYubing
	 */
	[SWF(width=400,height=300,backgroundColor=0xffffff,frameRate="30")]
	public class MonsterExport extends Game {
		private var _selectFolder_btn2 : GButton;
		private var _file : File;
		private var _filesList : Array = new Array();
		private var _swfData : EditableSWF = new EditableSWF();
		private var _formater : MonsterHandler = new MonsterHandler();
		private var _inputBox : TextField = new TextField();

		override protected function startup() : void {
			_res.add(new SWFLoader(new LibData("ui/ui.swf", "uiLib")));
			_res.add(new SWFLoader(new LibData("ui/view.swf", "viewLib")));
			_res.addEventListener(Event.COMPLETE, completeHandler);
			_res.load();
			addInputBox(_inputBox, 1);
		}

		private function addInputBox(txt : TextField, n : uint) : void {
			txt.x = 250 + 50 * n;
			txt.y = 60;
			txt.width = 50;
			txt.height = 25;
			txt.type = TextFieldType.INPUT;
			txt.background = true;
			txt.border = true;
			txt.backgroundColor = 0xffffff0f;
			// txt.autoSize = TextFieldAutoSize.CENTER;
			txt.restrict = "0-9|.";
			txt.text = "0.363";
			this.addChild(txt);
		}

		private function completeHandler(event : Event) : void {
			var data : GButtonData = new GButtonData();
			data.labelData.text = "选择swf文件夹";
			data.labelData.color = new GColor();
			_selectFolder_btn2 = new GButton(data);
			_selectFolder_btn2.moveTo(300, 0);
			addChild(_selectFolder_btn2);
			_formater.addEventListener(Event.COMPLETE, formatCompelete);
			_selectFolder_btn2.addEventListener(MouseEvent.CLICK, selectFolderClickHandler);
		}

		private function formatCompelete(event : Event) : void {
			writeMc(_formater.list);
			if (_filesList.length > 0)
				Fomater(_filesList.shift());
		}

		private function Fomater(f : File) : void {
			_formater.start(f, new Rectangle(Number(_inputBox.text), Number(_inputBox.text)));
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
			_file = event.target as File;
			for each (var f:File in _file.getDirectoryListing()) {
				if (f.extension == "swf") _filesList.push(f);
			}
			if (_filesList.length > 0)
				Fomater(_filesList.shift());
			trace("ffadaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa", _filesList.length);
		}

		private function writeMc(value : Array) : void {
			for each (var actToolData:ToolsData in value) {
				_swfData.savePngList2Swf(actToolData.bitmapDatas, actToolData.positions, actToolData.mcClassName);
			}
			_swfData.collectTags();
			_swfData.header.isCompressed = true;
			_swfData.writeToFile(_file.nativePath + "/out/" + _formater.file.name);
			_swfData = new EditableSWF();
			_formater.list = new Array();
		}
	}
}
