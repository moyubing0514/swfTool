package act2.icon
{
	import flash.display.Bitmap;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.filesystem.File;
	import flash.geom.Rectangle;
	import flash.net.URLRequest;

	import act.EditableSWF;
	import act.ToolsData;

	/**
	 * @author moyubing
	 */
	[SWF(width=1200, height=600, backgroundColor=0x000000, frameRate="30")]
	public class PriteStageOfIcon extends Sprite

	{

		private var _file:File;
		private var _fileList:Array;
		private var swf:EditableSWF;
		private var _list:Array;
		// icon url
		private var rect:Rectangle;

		public function PriteStageOfIcon()
		{
			swf=new EditableSWF();
			_list=new Array();
			_fileList=new Array();
			_file=new File("E:\workspace\agetool\2013917\资源文档\mnq\images\skill");
			trace(_file.exists);
			var fileList:Array=_file.getDirectoryListing();
			for (var i:int=0; i < fileList.length; i++)
			{
				var f:File=fileList[i];
				if (f.extension == "png")
					_fileList.push(f);
			}

			if (_fileList.length > 0)
				load(_fileList.shift());

		}

		private var _currentFileName:String;

		private function load(f:File):void
		{
			var loader:Loader=new Loader();
			loader.load(new URLRequest(f.nativePath));
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onComepleted);
			_currentFileName=f.name.split(".")[0];

		}

		protected function onComepleted(event:Event):void
		{
			var td:ToolsData=new ToolsData(_currentFileName);
			td.bitmapDatas.push((event.target.content as Bitmap).bitmapData)
			_list.push(td);
			if (_fileList.length > 0)
				load(_fileList.shift());
			else
				writeMc();
		}

		private function writeMc():void
		{
			var swf:EditableSWF=new EditableSWF();
			for each (var td:ToolsData in _list)
			{
				swf.addPNGOnly(td.bitmapDatas[0], td.mcClassName);
			}
			swf.writeToFile(_file.nativePath + "/assets.swf");
		}
	}
}
