package act.tools {
	import gear.core.Game;
	import gear.images.PNGEncoder;
	import gear.net.AssetData;
	import gear.net.LibData;
	import gear.net.RESManager;
	import gear.net.SWFLoader;
	import gear.utils.BDUtil;
	import gear.utils.MathUtil;

	import flash.display.BitmapData;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.ByteArray;

	/**
	 * @author Administrator
	 */
	public class ToPNG extends Game {
		private var _file : File;

		override protected function startup() : void {
			_file = new File();
			try {
				_file.addEventListener(Event.SELECT, dirSelected);
				_file.browseForDirectory("请选择输出路径");
			} catch(error : Error) {
				trace(error);
			}
		}

		private function dirSelected(event : Event) : void {
			_file = event.target as File;
			_res.add(new SWFLoader(new LibData("monsters/test.swf")));
			_res.addEventListener(Event.COMPLETE, res_completeHandler);
			_res.load();
		}

		private function res_completeHandler(event : Event) : void {
			_res.removeEventListener(Event.COMPLETE, res_completeHandler);
			var mc : MovieClip = RESManager.getMC(new AssetData("下劈", "test"));
			mc.x = 200;
			mc.y = 200;
			addChild(mc);
			var frames : Array = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];
			var rect : Rectangle;
			var mtx : Matrix = new Matrix();
			var bd : BitmapData;
			var ba : ByteArray;
			var name : String;
			var file : File;
			var stream : FileStream;
			for (var i : int = 0;i < frames.length;i++) {
				mc.gotoAndStop(frames[i]);
				rect = MathUtil.toIntRect(mc.getBounds(mc));
				mtx.identity();
				mtx.translate(-rect.x, -rect.y);
				bd = new BitmapData(rect.width, rect.height, true, 0);
				bd.draw(mc, mtx);
				bd = BDUtil.getResizeBD(bd, rect.width, rect.height);
				bd = BDUtil.getCutBD(bd, new Point());
				ba = PNGEncoder.encode(bd);
				name = _file.nativePath + "/" + i + ".png";
				file = File.documentsDirectory.resolvePath(name);
				stream = new FileStream();
				stream.open(file, FileMode.WRITE);
				stream.writeBytes(ba);
				stream.close();
			}
		}
	}
}
