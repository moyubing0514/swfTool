package act.dnf {
	import gear.core.Game;

	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.geom.Point;

	/**
	 * @author bright
	 * @version 20111008
	 */
	public class XYReader extends Game {
		private var _prefixs : Array;

		override protected function startup() : void {
			_prefixs = new Array();
			_prefixs.push("swordman_body_0");
			_prefixs.push("swordman_shoes_0b");
			_prefixs.push("swordman_shoes_0a");
			_prefixs.push("swordman_pants_0b");
			_prefixs.push("swordman_pants_0a");
			_prefixs.push("swordman_coat_0");
			_prefixs.push("swordman_hair_0");
			_prefixs.push("swordman_weapon_0b");
			_prefixs.push("swordman_weapon_0c");
			_prefixs.push("swordman_weapon_1b");
			_prefixs.push("swordman_weapon_1c");
			_prefixs.push("swordman_weapon_2b");
			_prefixs.push("swordman_weapon_2c");
			_prefixs.push("swordman_skill_0b");
			_prefixs.push("swordman_skill_0a");
			_prefixs.push("swordman_skill_1");
			var prefix : String;
			var path : String;
			var file : File;
			var stream : FileStream;
			var text : String;
			var lines : Array;
			var commands : Array;
			var params : Array;
			var points : Array;
			var offset : Point = new Point(-230, -330);
			var rename : Array = [1, 2, 3, 4, 5, 6, 21, 22, 23, 24, 25, 26, 27, 51, 52, 53, 54, 55, 56, 57, 75, 76, 77, 78, 79, 80, 81, 82, 90, 91, 92, 93, 94, 95, 98, 99, 100, 101, 102, 105, 106, 107, 108, 109, 110, 111, 112, 113, 114, 115, 116, 123, 124, 125, 126, 127, 129, 130, 133, 134, 135, 136, 137, 142, 143, 158, 159, 160, 165, 166, 176, 177, 178, 179, 180, 181, 182, 183, 184, 185, 186, 187, 188, 189, 190, 191, 192, 193, 194, 195, 196, 197, 199, 200, 201, 202, 203, 204, 205, 206, 207, 208];
			var config : String;
			var item : Object;
			for (var j : int = 0;j < _prefixs.length;j++) {
				prefix = _prefixs[j];
				path = "d://work//act_tools//bin//dnf//flas/png_swordman//" + prefix + "_xy.txt";
				file = File.documentsDirectory.resolvePath(path);
				stream = new FileStream();
				stream.open(file, FileMode.READ);
				stream.position = 0;
				text = stream.readUTFBytes(stream.bytesAvailable);
				stream.close();
				lines = text.split("\r");
				points = new Array();
				for (var i : int = 0;i < lines.length;i++) {
					commands = lines[i].split("  ");
					if (commands[0].indexOf("COORD") != -1) {
						params = commands[1].split("|");
						if (prefix.indexOf("skill") == -1) {
							points.push({x:(int(params[2]) + offset.x), y:(int(params[3]) + offset.y)});
						} else if (prefix.indexOf("_0b") != -1 || prefix.indexOf("_0a") != -1) {
							points.push({x:(int(params[2]) - 130), y:(int(params[3]) - 230)});
						} else if (prefix.indexOf("_1") != -1) {
							points.push({x:(int(params[2]) - 154), y:(int(params[3]) - 227)});
						}
					}
				}
				config = prefix + ": var newXY=[";
				if (prefix.indexOf("skill") == -1) {
					for (i = 0;i < rename.length;i++) {
						item = points[rename[i]];
						if (i > 0) config += ",";
						config += "{x:" + item.x + ",y:" + item.y + "}";
					}
				} else {
					for (i = 0;i < points.length;i++) {
						item = points[i];
						if (i > 0) config += ",";
						config += "{x:" + item.x + ",y:" + item.y + "}";
					}
				}
				config += "];";
				trace(config);
			}
		}
	}
}
