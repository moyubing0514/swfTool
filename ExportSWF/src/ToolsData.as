package
{
	import flash.display.BitmapData;
	import flash.geom.Rectangle;

	public class ToolsData
	{
		public var mcClassName:String;
		public var bitmapDatas:Vector.<BitmapData>;
		public var positions:Vector.<Rectangle>;
		public var list:Vector.<ToolsData>;

		public function ToolsData(mcClassName:String=""):void
		{
			this.mcClassName=mcClassName;
			bitmapDatas=new Vector.<BitmapData>();
			positions=new Vector.<Rectangle>();
			list=new Vector.<ToolsData>();
		}
	}
}
