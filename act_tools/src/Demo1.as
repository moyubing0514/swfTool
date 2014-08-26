package {
	import act.core.Common;
	import act.core.InfoCode;
	import act.debug.ACTDebugger;
	import gear.core.Game;
	import gear.log4a.GLogger;
	import gear.log4a.UIAppender;
	import gear.ui.data.GStatsData;
	import gear.ui.manager.UIManager;
	import gear.ui.monitor.GStats;

	public class Demo1 extends Game {
		private var _kick : int;

		override protected function startup() : void {
			init();
		}

		private function init() : void {
			UIManager.appWidth = 1024;
			UIManager.appHeight = 640;
			Common.uiAppender = new UIAppender(this);
			Common.uiAppender.debuger = new ACTDebugger();
			var data : GStatsData = new GStatsData();
			data.parent = this;
			Common.stats = new GStats(data);
			GLogger.addAppender(Common.uiAppender);
			_kick = InfoCode.NONE;
		}

	}
}