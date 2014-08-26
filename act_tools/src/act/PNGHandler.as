package act {
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.filesystem.File;

	/**
	 * @author tangjunhua
	 */
	public class PNGHandler extends Sprite {
		private var _file : File;
		private var _pngList : Array = [];
		private var _folders : Array = [];
		private var _positions : String = "";
		private var _conver : Convert = new Convert();

		public function PNGHandler() {
			_file = new File();
			try {
				_file.addEventListener(Event.SELECT, dirSelected);
				_file.browseForDirectory("Select a directory");
			} catch(error : Error) {
				trace(error);
			}
			_conver.addEventListener(Event.COMPLETE, convertComplete);
		}

		private function dirSelected(event : Event) : void {
			_file = event.target as File;
			var file : File;
			var files : Array = _file.getDirectoryListing();
			for (var i : uint = 0; i < files.length; i++) {
				file = files[i] as File;
				if (file.isDirectory) {
					_folders.push(file);
				}
			}
			if (_folders.length > 0) foldeHander(_folders.shift());
		}

		private function foldeHander(directory : File) : void {
			var file : File;
			var files : Array = directory.getDirectoryListing();
			for (var i : uint = 0; i < files.length; i++) {
				file = files[i] as File;
				if (file.extension == "png" && file.name.indexOf("c_") == -1) {
					_pngList.push(file);
				}
			}
			if (_pngList.length > 0) startConvert(_pngList.shift());
		}

		private function startConvert(file : File) : void {
			_conver.file = file;
			_conver.loadPNG();
		}

		private function convertComplete(event : Event) : void {
			_positions += (_conver.rect.x - 300) + "&" + (_conver.rect.y - 300) + "|";
			if (_pngList.length > 0) {
				startConvert(_pngList.shift());
			} else {
				FileUtil.writeStringToFile(_conver.file.parent.nativePath + "/positions.txt", _positions);
				_positions = "";
				if (_folders.length > 0) foldeHander(_folders.shift());
			}
		}
	}
}
