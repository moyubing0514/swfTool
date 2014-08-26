package act2.monster {
	import act.EditableSWF;
	import act.ToolsData;

	import gear.core.Game;
	import gear.net.LibData;
	import gear.net.SWFLoader;
	import gear.render.BDList;
	import gear.ui.bd.BDPlayer;
	import gear.ui.controls.GButton;
	import gear.ui.data.GButtonData;
	import gear.ui.data.GColor;
	import gear.utils.BDUtil;

	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.filesystem.File;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFieldType;

	/**
	 * @author MoYubing
	 */
	[SWF(width=860,height=600,backgroundColor=0xffffff,frameRate="30")]
	public class MonsterTool extends Game {
		private var _selectFolder_btn2 : GButton;
		private var _saveAndNext : GButton;
		private var _setXY : GButton;
		private var _preMc : GButton;
		private var _textLabel : TextField = new TextField();
		private var _inputBoxX : TextField = new TextField();
		private var _inputBoxY : TextField = new TextField();
		private var _mcContainer : Sprite = new Sprite();
		private var _markPointSprite : Sprite = new Sprite();
		private var _file : File;
		private var _filesList : Array = new Array();
		private var _swfData : EditableSWF = new EditableSWF();
		private var _formater : SWFFomater = new SWFFomater();
		private var _fixRectList : Vector.<Rectangle> = new Vector.<Rectangle>();
		private var _current : uint = 0;
		private var _flag : Boolean = true;
		private const OFFSET_POS : Number = 200;
		private var _shadow : Sprite;
		private var _shadow_bp : *;

		public function MonsterTool() {
		}

		override protected function startup() : void {
			_res.add(new SWFLoader(new LibData("ui/ui.swf", "uiLib")));
			_res.add(new SWFLoader(new LibData("ui/view.swf", "viewLib")));
			_res.addEventListener(Event.COMPLETE, completeHandler);
			_res.load();
		}

		private function completeHandler(event : Event) : void {
			addButtons();
			addTextLabel();
			// X Y 输入框
			addInputBox(_inputBoxX, 1);
			addInputBox(_inputBoxY, 2);
			initEvents();
		}

		private function initEvents() : void {
			drawBackground();
			this.addChild(_mcContainer);
			_markPointSprite.mouseEnabled = false;
			_markPointSprite.mouseChildren = false;
			this.addChild(_markPointSprite);
			_selectFolder_btn2.addEventListener(MouseEvent.CLICK, selectFolderClickHandler);
		}

		private function keyPressListener(event : KeyboardEvent) : void {
			var x : Number = Number(_inputBoxX.text)  ;
			var y : Number = Number(_inputBoxY.text);
			trace("鼠标设定", x, y);
			switch(event.keyCode) {
				case 37:
					updateXY(x - 1, y);
					break;
				case 38:
					updateXY(x, y - 1);
					break;
				case 39:
					updateXY(x + 1, y);
					break;
				case 40:
					updateXY(x, y + 1);
					break;
				default:
			}
		}

		private function setXYClick(event : MouseEvent) : void {
			if (_formater.showMc.length != 0) {
				var x : Number = Number(_inputBoxX.text)  ;
				var y : Number = Number(_inputBoxY.text);
				trace("输入框设定坐标:", x, y);
				updateXY(x, y);
			}
		}

		private function mcContainerClick(event : MouseEvent) : void {
			var x : Number = mouseX;
			var y : Number = mouseY;
			trace("鼠标设定", x, y);
			updateXY(x, y);
		}

		private function updateXY(x : Number, y : Number) : void {
			_fixRectList[_current] = new Rectangle(x - OFFSET_POS, y - OFFSET_POS);
			_inputBoxX.text = "" + x;
			_inputBoxY.text = "" + y;
			_markPointSprite.graphics.clear();
			_markPointSprite.graphics.beginFill(0x00ff00);
			_markPointSprite.graphics.drawCircle(x, y, 5);
			_markPointSprite.graphics.endFill();
		}

		private function saveAndNext(event : MouseEvent) : void {
			deleteMcInSprite();
			// _markPointSprite.graphics.clear();
			if (++_current < _formater.showMc.length ) {
				deleteMcInSprite();
				deleteMcInSprite();
				drawMc(_current);
			} else if (_filesList.length > 0) {
				writeMc(_formater._actList, _fixRectList);
				Fomater(_filesList.shift());
			} else {
				if (_flag) {
					writeMc(_formater._actList, _fixRectList);
					_flag = false;
				}
				allComplete();
			}
		}

		private function preMcListener(event : MouseEvent) : void {
			// _markPointSprite.graphics.clear();
			if (_current > 0) {
				deleteMcInSprite();
				drawMc(--_current);
			} else {
				trace("第一个");
			}
		}

		private function Fomater(f : File) : void {
			_formater.start(f);
			_textLabel.text = "文件名:" + f.name + " ";
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
			_formater.addEventListener(Event.COMPLETE, formatCompelete);

			if (_filesList.length == 0) {
				allComplete();
			} else {
				Fomater(_filesList.shift());
			}
		}

		private function formatCompelete(event : Event) : void {
			stage.addEventListener(KeyboardEvent.KEY_DOWN, keyPressListener);
			_mcContainer.addEventListener(MouseEvent.CLICK, mcContainerClick);
			_saveAndNext.addEventListener(MouseEvent.CLICK, saveAndNext);
			_setXY.addEventListener(MouseEvent.CLICK, setXYClick);
			_preMc.addEventListener(MouseEvent.CLICK, preMcListener);
			for (var i : uint = 0; i < _formater.showMc.length;++i)
				_fixRectList.push(new Rectangle(0, 0));
			if (_current < _formater.showMc.length ) {
				deleteMcInSprite();
				drawMc(_current);
			}
		}

		private function drawMc(i : uint) : void {
			// 影子容器
			_shadow = new Sprite();
			_shadow.mouseEnabled = _shadow.mouseChildren = false;
			_shadow_bp = new Bitmap();
			_shadow_bp.alpha = 0.5;
			_shadow.addChild(_shadow_bp);

			_textLabel.text = _textLabel.text.split(" ")[0] + (" \nMovieClip名:" + _formater.showMc[i].name);
			_formater.showMc[i].graphics.clear();
			_formater.showMc[i].graphics.beginFill(0xff0000);
			_formater.showMc[i].graphics.drawCircle(0, 0, 5);
			_formater.showMc[i].graphics.endFill();
			_formater.showMc[i].x = _formater.showMc[i].y = OFFSET_POS;
			var a : BDPlayer = new BDPlayer();
			a.list = BDUtil.toBDList(_formater.showMc[i]);

			a.list.create(true, true);
			a.x = a.y = OFFSET_POS;
			a.play(33, null, 100);
			a.mouseEnabled = false;
			a.mouseChildren = false;
			a.shadow = _shadow_bp;
			_shadow.x = a.x;
			_shadow.y = a.y;
			_mcContainer.addChild(_shadow);

			_formater.showMc[i].x = _formater.showMc[i].y = OFFSET_POS;
			_formater.showMc[i].play();
			_formater.showMc[i].mouseEnabled = false;
			_formater.showMc[i].mouseChildren = false;
			_mcContainer.addChild(_formater.showMc[i]);
		}

		private function deleteMcInSprite() : void {
			for (var i : uint = 0;i < _mcContainer.numChildren;++i)
				_mcContainer.removeChildAt(i);
			_mcContainer.graphics.clear();
			drawBackground();
		}

		private function writeMc(value : Array, rectList : Vector.<Rectangle>) : void {
			for each (var actList:Array in value) {
				for each (var actToolData:ToolsData in actList) {
					_swfData.savePngList2Swf(actToolData.bitmapDatas, actToolData.positions, actToolData.mcClassName, rectList);
				}
			}
			_formater._list = new Array();
			_formater._actList = new Array();
			_swfData.collectTags();
			_swfData.header.isCompressed = true;
			_swfData.writeToFile(_file.nativePath + "/out/" + _formater.file.name);
			_swfData = new EditableSWF();
			_current = 0;
		}

		private function drawBackground() : void {
			_mcContainer.graphics.beginFill(0xffffff);
			_mcContainer.graphics.drawRect(0, 0, 550, 400);
			_mcContainer.graphics.endFill();
		}

		private function addTextLabel() : void {
			_textLabel.background = true;
			_textLabel.backgroundColor = 0xffccee;
			_textLabel.multiline = true;
			_textLabel.x = 560;
			_textLabel.width = 180;
			_textLabel.height = 55;
			this.addChild(_textLabel);
		}

		private function allComplete() : void {
			_mcContainer.removeEventListener(MouseEvent.CLICK, mcContainerClick);
			_saveAndNext.removeEventListener(MouseEvent.CLICK, saveAndNext);
			_setXY.removeEventListener(MouseEvent.CLICK, setXYClick);
			_preMc.removeEventListener(MouseEvent.CLICK, preMcListener)
			_selectFolder_btn2.removeEventListener(MouseEvent.CLICK, selectFolderClickHandler);

			var _completeConvertText : TextField = new TextField();
			_completeConvertText.text = "已经处理完全部文件";
			_completeConvertText.background = true;
			_completeConvertText.backgroundColor = 0xfffff0;
			_completeConvertText.autoSize = "center";
			_completeConvertText.x = 300;
			_completeConvertText.y = 300;
			this.addChild(_completeConvertText);
		}

		private function addButtons() : void {
			var data : GButtonData = new GButtonData();
			data.labelData.text = "选择swf文件夹";
			data.labelData.color = new GColor();
			_selectFolder_btn2 = new GButton(data);
			_selectFolder_btn2.moveTo(750, 0);

			var data2 : GButtonData = new GButtonData();
			data2.labelData.text = "保存并进行下一个";
			data2.labelData.color = new GColor();
			_saveAndNext = new GButton(data2);
			_saveAndNext.moveTo(750, 30);

			var data4 : GButtonData = new GButtonData();
			data4.labelData.text = "上一个";
			data4.labelData.color = new GColor();
			_preMc = new GButton(data4);
			_preMc.moveTo(750, 60);

			var data3 : GButtonData = new GButtonData();
			data3.labelData.text = "确认坐标";
			data3.labelData.color = new GColor();
			_setXY = new GButton(data3);
			_setXY.moveTo(750, 90);

			addChild(_selectFolder_btn2);
			addChild(_saveAndNext);
			addChild(_preMc);
			addChild(_setXY);
		}

		private function addInputBox(txt : TextField, n : uint) : void {
			txt.x = 580 + 50 * n;
			txt.y = 90;
			txt.width = 50;
			txt.height = 25;
			txt.type = TextFieldType.INPUT;
			txt.background = true;
			txt.border = true;
			txt.backgroundColor = 0xffffff0f;
			// txt.autoSize = TextFieldAutoSize.CENTER;
			txt.restrict = "0-9|.";
			txt.text = "200";
			this.addChild(txt);
		}
	}
}
