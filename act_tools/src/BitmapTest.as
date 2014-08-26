package {
	import flash.geom.Rectangle;

	import act.EditableSWF;

	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.geom.Matrix;
	import flash.geom.Point;

	/**
	 * @author moyubing
	 */
	public class BitmapTest extends Sprite {
		public function BitmapTest() {
			var bitm : Bitmap;
			var bitmapd : BitmapData = new BitmapData(100, 100, true, 0x80ff0000);
			for (var i : uint = 0;i < bitmapd.width;i++) {
				for (var j = 0;j < bitmapd.height;j++) {
					var c : uint = bitmapd.getPixel32(i, j) & 0x00ffffff;
					var alpha : uint =bitmapd.getPixel32(i, j) >> 24 &0xff;
					trace(alpha.toString(16));
					var cc : uint = (c * alpha / 255) | alpha << 24;
					bitmapd.setPixel32(i, j, cc);
				}
			}
			bitm = new Bitmap(bitmapd);
			var swf : EditableSWF = new EditableSWF();
			var array : Vector.<BitmapData> = new Vector.<BitmapData>();
			array.push(bitmapd);
			var pos : Vector.<Rectangle>=new Vector.<Rectangle>();
			swf.addPNGOnly(bitmapd, "mcName");
			// swf.collectTags();
			swf.header.isCompressed = false;
			swf.writeToFile("d://a.swf");
		}
	}
}
