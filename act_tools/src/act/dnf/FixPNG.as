package act.dnf {
	import gear.core.Game;

	import flash.filesystem.File;

	/**
	 * @author bright
	 */
	public class FixPNG extends Game {
		private var _prefixs : Array;
		private var _deletes : Array;
		private var _renames : Array;

		private function init() : void {
			_deletes = [0, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 83, 84, 85, 86, 87, 88, 89, 96, 97, 103, 104, 117, 118, 119, 120, 121, 122, 128, 131, 132, 138, 139, 140, 141, 144, 145, 146, 147, 148, 149, 150, 151, 152, 153, 154, 155, 156, 157, 161, 162, 163, 164, 167, 168, 169, 170, 171, 172, 173, 174, 175, 198, 209];
			_renames = [1, 2, 3, 4, 5, 6, 21, 22, 23, 24, 25, 26, 27, 51, 52, 53, 54, 55, 56, 57, 75, 76, 77, 78, 79, 80, 81, 82, 90, 91, 92, 93, 94, 95, 98, 99, 100, 101, 102, 105, 106, 107, 108, 109, 110, 111, 112, 113, 114, 115, 116, 123, 124, 125, 126, 127, 129, 130, 133, 134, 135, 136, 137, 142, 143, 158, 159, 160, 165, 166, 176, 177, 178, 179, 180, 181, 182, 183, 184, 185, 186, 187, 188, 189, 190, 191, 192, 193, 194, 195, 196, 197, 199, 200, 201, 202, 203, 204, 205, 206, 207, 208];
		}

		private function deleteFiles(prefix : String) : void {
			var path : String = "d://work//act_tools//bin//dnf//flas/png_swordman//" + prefix + "//";
			var file : File;
			for (var i : int = 0;i < _deletes.length;i++) {
				try {
					file = File.documentsDirectory.resolvePath(path + _deletes[i] + ".png");
					trace("delete " + file.name);
					file.deleteFile();
				} catch(e : Error) {
					trace(e.getStackTrace());
				}
			}
		}

		private function renameFiles(prefix : String) : void {
			var path : String = "d://work//act_tools//bin//dnf//flas/png_swordman//" + prefix + "//";
			var file : File;
			var renameFile : File;
			for (var i : int = 0;i < _renames.length;i++) {
				file = File.documentsDirectory.resolvePath(path + _renames[i] + ".png");
				renameFile = File.documentsDirectory.resolvePath(path + prefix + "_" + i + ".png");
				try {
					trace("rename " + file.name + " to " + renameFile.name);
					file.moveTo(renameFile, true);
				} catch(e : Error) {
					trace(e.getStackTrace());
				}
			}
		}

		override protected function startup() : void {
			init();
			_prefixs = new Array();
			// _prefixs.push("swordman_body_0");
			// _prefixs.push("swordman_shoes_0b");
			// _prefixs.push("swordman_shoes_0a");
			// _prefixs.push("swordman_pants_0b");
			// _prefixs.push("swordman_pants_0a");
			// _prefixs.push("swordman_coat_0");
			// _prefixs.push("swordman_hair_0");
			// _prefixs.push("swordman_weapon_0b");
			// _prefixs.push("swordman_weapon_0c");
			_prefixs.push("swordman_weapon_2b");
			_prefixs.push("swordman_weapon_2c");
			var prefix : String;
			for (var i : int = 0;i < _prefixs.length;i++) {
				prefix = _prefixs[i];
				deleteFiles(prefix);
				renameFiles(prefix);
			}
		}
	}
}
