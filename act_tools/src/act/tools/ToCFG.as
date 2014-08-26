package act.tools {
	import flash.system.Capabilities;

	import act.career.CareerType;
	import act.combat.enemy.MonsterType;

	import gear.core.Game;

	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.utils.ByteArray;

	/**
	 * 生成配置
	 * 
	 * @author bright
	 * @version 20111201
	 */
	public class ToCFG extends Game {
		private static var _base : String = "C://work/client/act/bin/conf/";

		override protected  function startup() : void {
			if (Capabilities.os.indexOf("Windows") == -1) {
				_base = "/Users/flashpf/Documents/workspace/client/act/bin/conf/";
			}
			createServers();
			createCareers();
			createSkills();
			createNPCS();
			createTasks();
			createTowns();
			createMonsters();
		}

		private function createServers() : void {
			var servers : Object = new Object();
			var dianxin : Object = new Object();
			dianxin.name = "电信";
			var shanghai : Object = new Object();
			shanghai.name = "上海区";
			shanghai.list = [{name:"谁主沉浮", host:"127.0.0.1", port:1863, flag:1}, {name:"纵横天下", host:"127.0.0.1", port:1863, flag:1}];
			var guandong : Object = new Object();
			guandong.name = "广东区";
			guandong.list = [{name:"指点江山", host:"127.0.0.1", port:1863, flag:1}, {name:"乱世英雄", host:"127.0.0.1", port:1863, flag:1}];
			dianxin.list = [shanghai, guandong];
			var wangtong : Object = new Object();
			wangtong.name = "网通";
			var beijin : Object = new Object();
			beijin.name = "北京区";
			beijin.list = [{name:"号令四方", host:"127.0.0.1", port:1863, flag:1}, {name:"谁与争峰", host:"127.0.0.1", port:1863, flag:1}];
			var dongbei : Object = new Object();
			dongbei.name = "东北区";
			dongbei.list = [{name:"傲视群雄", host:"127.0.0.1", port:1863, flag:1}, {name:"君临天下", host:"127.0.0.1", port:1863, flag:1}];
			wangtong.list = [beijin, dongbei];
			servers.dianxin = dianxin;
			servers.wangtong = wangtong;
			saveFile(_base + "servers.cfg", servers);
		}

		private function createCareers() : void {
			var careers : Array = new Array();
			var career : Object = new Object();
			career.id = 0;
			career.type = CareerType.SWORD_MAN;
			career.maxHP = 185;
			career.strength = 12;
			career.constitution = 7;
			career.physicAttack = 13;
			career.physicDefense = 30;
			career.moveSpeed = -3;
			career.hitRate = 1;
			career.maxMP = 142;
			career.mens = 5;
			career.magicAttack = 12;
			career.magicDefense = 20;
			career.ankylosis = 600;
			careers.push(career);
			saveFile(_base + "careers.cfg", careers);
		}

		private function createSkills() : void {
			var skills : Array = new Array();
			var skill_0 : Object = {id:0, name:"鬼斩", mp:16, time:6000, force:false};
			var skill_1 : Object = {id:1, name:"上挑", mp:6, time:2000};
			var skill_2 : Object = {id:2, name:"后跳", mp:6, time:0};
			skills.push(skill_0);
			skills.push(skill_1);
			skills.push(skill_2);
			saveFile(_base + "skills.cfg", skills);
		}

		private function createNPCS() : void {
			var npcs : Array = new Array();
			npcs.push({id:0, name:"小妹妹"});
			npcs.push({id:1, name:"打铁匠"});
			npcs.push({id:2, name:"剑圣"});
			saveFile(_base + "npcs.cfg", npcs);
		}

		private function createTasks() : void {
		}

		private function createTowns() : void {
			var towns : Array = new Array();
			var town_0 : Object = {id:0, name:"伊弗利村庄"};
			town_0.npcs = new Array();
			town_0.npcs.push({id:0, x:200, y:400});
			town_0.npcs.push({id:1, x:400, y:400});
			town_0.npcs.push({id:2, x:600, y:400});
			var town_1 : Object = {id:1, name:"泽维尔小镇"};
			towns.push(town_0);
			towns.push(town_1);
			saveFile(_base + "towns.cfg", towns);
		}

		private function createMonsters() : void {
			var monsters : Array = new Array();
			var monster : Object = new Object();
			monster.type = MonsterType.GollumPig;
			monster.id = 0;
			monster.maxHP = 150;
			monster.physicAttack = 102;
			monster.physicDefense = 150;
			monster.magicAttack = 140;
			monster.magicDefense = 92;
			monster.ankylosis = 600;
			monster.evasion = 3;
			monsters.push(monster);
			saveFile(_base + "monsters.cfg", monsters);
		}

		private function saveFile(name : String, content : *) : void {
			var ba : ByteArray = new ByteArray();
			ba.writeObject(content);
			ba.compress();
			var file : File = File.documentsDirectory.resolvePath(name);
			var stream : FileStream = new FileStream();
			stream.open(file, FileMode.WRITE);
			stream.writeBytes(ba);
			stream.close();
		}
	}
}
