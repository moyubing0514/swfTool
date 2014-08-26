package act {
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.system.LoaderContext;
	import flash.utils.ByteArray;

	/**
	 * @author moyubing
	 */
	public class MapPNGLoader extends EventDispatcher {
		private var _bitmapData : Vector.<BitmapData> = new Vector.<BitmapData>();
		private var _fileList : Array = new Array();
		private var _folder : File ;
		public var nameList : Array = new Array();

		public function startLoader() : void {
			if (_fileList.length > 0) getAllPNGs(_fileList.shift());
		}

		private function getAllPNGs(file : File) : void {
			var fileStream : FileStream = new FileStream();
			var loader : Loader = new Loader();
			var bytes : ByteArray = new ByteArray();
			var loaderContext : LoaderContext = new LoaderContext();

			fileStream.open(file, FileMode.READ);
			fileStream.readBytes(bytes, 0, fileStream.bytesAvailable);
			fileStream.close();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, pngLoaded);
			loaderContext.allowLoadBytesCodeExecution = true;
			loader.loadBytes(bytes, loaderContext);
			trace(file.name + "读取到字节数为：  " + bytes.length);
		}

		// load完成
		private  function pngLoaded(event : Event) : void {
			var source : BitmapData = event.target.content.bitmapData;
			_bitmapData.push(source);
			if (_fileList.length > 0)
				getAllPNGs(_fileList.shift());
			else
				dispatchEvent(new Event(Event.COMPLETE));
			// 转换结束
		}

		public  function get bitmapDataList() : Vector.<BitmapData> {
			return _bitmapData;
		}

		public  function get pngFilesList() : Array {
			return _fileList;
		}

		public function set folder(folderValue : File) : void {
			this._folder = folderValue;
			// 取png文件
			for each (var f:File in _folder.isDirectory ? _folder.getDirectoryListing() : null) {
				if (	f.extension == "png") _fileList.push(f);
			}
			for (var i : uint = 0;i < _fileList.length;++i) {
				var  fileName : String = _fileList[i].name.split(".")[0];
				nameList.push(fileName.split("_")[0] + "_" + fileName.split("_")[1] + "_" + _folder.name);
			}
		}

		public function get folder() : File {
			return _folder;
		}
	}
}
