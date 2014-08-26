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
	public class SJBToCFG extends Game {
		private static var _base : String = "D:/test/act/bin/conf/";

		override protected  function startup() : void {
			if (Capabilities.os.indexOf("Windows") == -1) {
				_base = "/Users/flashpf/Documents/workspace/client/act/bin/conf/";
			}
			createServers();
			// createCareers();
			// createSkills();
			// createNPCS();
			// createTasks();
			// createTowns();
			// createMonsters();
			createChatConfig();
		}

		private function createChatConfig() : void {
			var arr:Array = new Array();
			var config : Object = new Object();
			config.list = [{id:1, name:"世界"}, {id:2, name:"附近"}, {id:7, name:"公会"}, {id:5, name:"密语"}, {id:0, name:"系统"}, {id:8, name:"队伍"}];
			config.channel = [{id:2, name:"附近"}, {id:7, name:"公会"}, {id:1, name:"世界"}, {id:5, name:"密语"}];
			arr.push(config);
			saveFile(_base + "chats.cfg", arr);
		}

		private function createServers() : void {
			var servers : Object = new Object();
			var dianxin : Object = new Object();
			dianxin.name = "电信";
			var shanghai : Object = new Object();
			shanghai.name = "上海区";
			shanghai.list = [{name:"谁主沉浮", host:"127.0.0.1", port:1863, flag:1}, {name:"外网1", host:"61.129.51.161", port:1863, flag:1}, {name:"cafe", host:"192.168.80.107", port:1863, flag:1}, {name:"cafe笔", host:"192.168.83.56", port:1863, flag:1}, {name:"小楷子笔", host:"192.168.80.11", port:1863, flag:1}, {name:"胡剑锋", host:"192.168.83.22", port:1863, flag:1}];
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
			career.id = 1;
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
			npcs.push({id:204100001, name:"菲利丝", text:"人家等在这儿才不是因为喜欢你呢！你这个笨蛋！"});
			npcs.push({id:204100002, name:"珍妮弗", text:"这个世界就是乱花迷人眼！你这种横冲直撞的人生，我仅抱观望态度。"});
			npcs.push({id:204100003, name:"巴里", text:"这个世界就是乱花迷人眼！你这种横冲直撞的人生，我仅抱观望态度。"});
			npcs.push({id:204100004, name:"皮特大叔", text:"这个世界就是乱花迷人眼！你这种横冲直撞的人生，我仅抱观望态度。"});
			npcs.push({id:204100005, name:"艾琳大妈", text:"这个世界就是乱花迷人眼！你这种横冲直撞的人生，我仅抱观望态度。"});
			npcs.push({id:204100006, name:"约克", text:"这个世界就是乱花迷人眼！你这种横冲直撞的人生，我仅抱观望态度。"});
			npcs.push({id:204100007, name:"塞西尔", text:"这个世界就是乱花迷人眼！你这种横冲直撞的人生，我仅抱观望态度。"});
			npcs.push({id:204100008, name:"提姆", text:"这个世界就是乱花迷人眼！你这种横冲直撞的人生，我仅抱观望态度。"});
			saveFile(_base + "npcs.cfg", npcs);
		}

		private function createTasks() : void {
			var tasks : Array = new Array();
		}

		private function createTowns() : void {
			var towns : Array = new Array();
			var town_0 : Object = {id:110, name:"伊弗利村庄"};
			town_0.npcs = new Array();
			town_0.npcs.push({id:204100001, x:730, y:400, fun:[1]});
			town_0.npcs.push({id:204100002, x:930, y:400, fun:[1]});
			town_0.npcs.push({id:204100003, x:1100, y:400, fun:[1, 4]});
			town_0.trans = new Array();
			town_0.trans.push({id:0, target:120, tarX:200, tarY:550, lv:0, centerX:2650, centerY:400, width:100, height:100});
			var town_1 : Object = {id:120, name:"泽维尔小镇"};
			town_1.npcs = new Array();
			town_1.npcs.push({id:204100004, x:730, y:400, fun:[1]});
			town_1.npcs.push({id:204100005, x:930, y:400, fun:[1]});
			town_1.npcs.push({id:204100006, x:1100, y:400, fun:[1, 4]});
			town_1.trans = new Array();
			town_1.trans.push({id:3, target:110, tarX:2550, tarY:400, lv:0, centerX:50, centerY:600, width:100, height:100});
			town_1.trans.push({id:5, target:130, tarX:200, tarY:550, lv:0, centerX:1400, centerY:600, width:100, height:100});
			var town_2 : Object = {id:130, name:"泰伦城"};
			town_2.npcs = new Array();
			town_2.npcs.push({id:204100007, x:730, y:400, fun:[1]});
			town_2.npcs.push({id:204100008, x:930, y:400, fun:[1]});
			town_2.trans = new Array();
			town_2.trans.push({id:6, target:120, tarX:1300, tarY:550, lv:0, centerX:50, centerY:600, width:100, height:100});
			towns.push(town_0);
			towns.push(town_1);
			towns.push(town_2);
			saveFile(_base + "towns.cfg", towns);
		}

		private function createMonsters() : void {
			var monsters : Array = new Array();
			var monster : Object = new Object();
			// monster.type = MonsterType.GOBLIN;
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
