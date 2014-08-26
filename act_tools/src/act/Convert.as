package act {
	import gear.images.PNGEncoder;
	import gear.utils.MathUtil;

	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.geom.Rectangle;
	import flash.system.LoaderContext;
	import flash.utils.ByteArray;

	/**
	 * @author Cafe
	 */
	public class Convert extends EventDispatcher {
		public var rect : Rectangle;
		public var file : File;
		public var id : int;

		public function Convert(target : IEventDispatcher = null) {
			super(target);
		}

		public function loadPNG() : void {
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
			id = int(file.name.split(".")[0]);
			trace(file.name + "读取到字节数为：  " + bytes.length);
		}

		private function pngLoaded(event : Event) : void {
			var source : BitmapData = event.target.content.bitmapData;
			// trace(BDUtil.getDOSize(img).toString());
			// rect = BDUtil.getDOSize(img);

			rect = source.getColorBoundsRect(0xFF000000, 0x00000000, false);
			if (rect.equals(source.rect)) {
				return ;
			}
			var bd : BitmapData = new BitmapData(rect.width, rect.height, true, 0);
			bd.copyPixels(source, rect, MathUtil.ZERO_POINT);
			// point.x += rect.x;
			// point.y += rect.y;
			var bytes:ByteArray=PNGEncoder.encode(bd);
			FileUtil.writeBytesTofile(file.parent.nativePath+"/c_"+file.name, bytes);
			dispatchEvent(new Event(Event.COMPLETE));
		}
	}
}
