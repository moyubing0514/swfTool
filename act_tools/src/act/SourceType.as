package act {
	/**
	 * @author moyubing
	 */
	public class SourceType {
		public static const ITEM : int = 0;
		public static const MAP : int = 1;
		public static const MUSIC : int = 2;
		public static const NPCS : int = 3;
		public static const ROLE : int = 4;
		public static const TOWNS : int = 5;
		public static const TRANS : int = 6;

		public static function getArray() : Array {
			return [ITEM, MAP, MUSIC, NPCS, ROLE, TOWNS, TRANS];
		}

		public static function getIDby(name : String) : int {
			switch(name.toLocaleLowerCase()) {
				case "item":
					return ITEM;
				case "map":
					return MAP;
				case "music":
					return MUSIC;
				case "npcs":
					return NPCS;
				case "role":
					return ROLE;
				case "towns":
					return TOWNS;
				case "trans":
					return TRANS;
				default:
					return -1;
			}
		}

		public static function getNameby(id : int) : String {
			switch(id) {
				case ITEM:
					return "item";
				case MAP:
					return "map";
				case MUSIC:
					return "music";
				case NPCS:
					return "npcs";
				case ROLE:
					return "role";
				case TOWNS:
					return "towns";
				case TRANS:
					return "trans";
				default:
					return "";
			}
		}
	}
}
