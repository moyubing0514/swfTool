package act {
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.system.LoaderContext;
	import flash.utils.ByteArray;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.geom.Rectangle;
	import flash.geom.Point;

	/**
	 * @author moyubing
	 */
	public class Main extends Sprite {
		public function Main() {
			var file : File = new File("d:/1.png");
			trace(file.name);
			var fileStream : FileStream = new FileStream();
			fileStream.open(file, FileMode.READ);
			var loader : Loader = new Loader();
			var bytes : ByteArray = new ByteArray();
			fileStream.readBytes(bytes, 0, fileStream.bytesAvailable);
			fileStream.close();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, pngLoaded);
			var loaderContext : LoaderContext = new LoaderContext();
			loaderContext.allowLoadBytesCodeExecution = true;
			loader.loadBytes(bytes, loaderContext);
		}

		private function pngLoaded(event : Event) : void {
			var source : BitmapData = event.target.content.bitmapData;
		}
	}
}
