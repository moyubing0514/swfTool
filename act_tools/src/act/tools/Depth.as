package act.tools {
	import gear.core.Game;

	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;

	/**
	 * @author bright
	 * @version 20111008
	 */
	public class Depth extends Game {
		public var depths : Array;

		override protected function startup() : void {
			depths = [{name:"face_b", depth:100}, {name:"face_h", depth:101}, {name:"spear_d", depth:200}, {name:"staff_d", depth:200}, {name:"pole_d", depth:200}, {name:"rod_d", depth:200}, {name:"broom_d", depth:200}, {name:"axe_d", depth:200}, {name:"cross_d", depth:200}, {name:"rosary_d", depth:200}, {name:"scythe_d", depth:200}, {name:"totem_d", depth:200}, {name:"cap_d", depth:300}, {name:"hair_d", depth:400}, {name:"coat_d", depth:500}, {name:"neck_h", depth:550}, {name:"neck_d", depth:600}, {name:"lgswd_b", depth:650}, {name:"gemswd_b", depth:650}, {name:"sswd_b", depth:650}, {name:"mswd_b", depth:650}, {name:"lswd_b", depth:650}, {name:"club_b", depth:650}, {name:"staff_b", depth:650}, {name:"spear_b", depth:650}, {name:"rod_b", depth:650}, {name:"tonfa_b", depth:650}, {name:"knuckle_b", depth:650}, {name:"gauntlet_b", depth:650}, {name:"claw_b", depth:650}, {name:"hcan_b", depth:650}, {name:"pole_b", depth:650}, {name:"bowgun_b", depth:650}, {name:"auto_b", depth:650}, {name:"musket_b", depth:650}, {name:"katana_b", depth:650}, {name:"lkatana_b", depth:650}, {name:"glove_b", depth:650}, {name:"rev_b", depth:650}, {name:"beamswd_b1", depth:651}, {name:"beamswd_b2", depth:652}, {name:"cap_b", depth:700}, {name:"cap_h", depth:750}, {name:"hair_b", depth:800}, {name:"belt_d", depth:850}, {name:"belt_h", depth:860}, {name:"coat_b", depth:900}, {name:"coat_h", depth:925}, {name:"neck_b", depth:1000}, {name:"belt_b", depth:1100}, {name:"pants_d", depth:1150}, {name:"pants_h", depth:1151}, {name:"shoes_b", depth:1200}, {name:"shoes_h", depth:1250}, {name:"pants_b", depth:1300}, {name:"shoes_a", depth:1400}, {name:"shoes_g", depth:1450}, {name:"pants_a", depth:1500}, {name:"pants_g", depth:1501}, {name:"shoes_c", depth:1600}, {name:"pants_c", depth:1601}, {name:"belt_a", depth:1700}, {name:"coat_a", depth:1800}, {name:"coat_g", depth:1850}, {name:"neck_a", depth:1900}, {name:"face_c", depth:1925}, {name:"belt_c", depth:1950}, {name:"belt_g", depth:1951}, {name:"neck_x", depth:1975}, {name:"hair_a", depth:2000}, {name:"cap_a", depth:2100}, {name:"cap_g", depth:2125}, {name:"pole_a", depth:2150}, {name:"staff_a", depth:2150}, {name:"spear_a", depth:2150}, {name:"rod_a", depth:2150}, {name:"neck_c", depth:2200}, {name:"neck_g", depth:2251}, {name:"coat_c", depth:2300}, {name:"neck_e", depth:2350}, {name:"hair_c", depth:2400}, {name:"cap_c", depth:2500}, {name:"spear_c", depth:2600}, {name:"lgswd_c", depth:2600}, {name:"gemswd_c", depth:2600}, {name:"sswd_c", depth:2600}, {name:"lkatana_c", depth:2600}, {name:"mswd_c", depth:2600}, {name:"lswd_c", depth:2600}, {name:"club_c", depth:2600}, {name:"staff_c", depth:2600}, {name:"pole_c", depth:2600}, {name:"broom_c", depth:2600}, {name:"rosary_c", depth:2600}, {name:"scythe_c", depth:2600}, {name:"cross_c", depth:2600}, {name:"axe_c", depth:2600}, {name:"tonfa_c", depth:2600}, {name:"knuckle_c", depth:2600}, {name:"arm_c", depth:2600}, {name:"gauntlet_c", depth:2600}, {name:"boneclaw_c", depth:2600}, {name:"hcan_c", depth:2600}, {name:"bowgun_c", depth:2600}, {name:"auto_c", depth:2600}, {name:"bswd_c", depth:2600}, {name:"rod_c", depth:2600}, {name:"katana_c", depth:2600}, {name:"totem_c", depth:2600}, {name:"glove_c", depth:2600}, {name:"rev_c", depth:2600}, {name:"musket_c", depth:2600}, {name:"claw_c", depth:2600}, {name:"beamswd_c1", depth:2601}, {name:"beamswd_c2", depth:2602}, {name:"face_a", depth:2700}, {name:"face_g", depth:2750}, {name:"cap_f", depth:2810}, {name:"face_f", depth:2830}, {name:"neck_f", depth:2840}, {name:"coat_f", depth:2850}, {name:"pants_f", depth:2860}, {name:"belt_f", depth:2870}, {name:"shoes_f", depth:2880}];
			var path : String = "d://work//act_tools//bin//flas/depths.txt";
			var file : File = File.documentsDirectory.resolvePath(path);
			var stream : FileStream = new FileStream();
			stream.open(file, FileMode.READ);
			stream.position = 0;
			var text : String = stream.readUTFBytes(stream.bytesAvailable);
			stream.close();
			var lines : Array = text.split("\r");
			var commands : Array;
			var config : String = "var depths:Array=[";
			var index : int = 0;
			var depth : int;
			for (var i : int = 0;i < lines.length;i++) {
				commands = lines[i].split(" ");
				if (commands[0].indexOf("echo") != -1) {
					depth = commands[2].split("[")[1].split("]")[0];
					if (index++ > 0) config += ",";
					config += "{name:\"" + commands[1] + "\",depth:" + depth + "}";
				}
			}
			config += "];";
			trace(config);
		}
	}
}
