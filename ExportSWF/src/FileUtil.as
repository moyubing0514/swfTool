package
{
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.utils.ByteArray;

	/**
	 * @author Cafe
	 */
	public class FileUtil
	{
		public static function writeStringToFile(url:String, content:String):void
		{
			//trace("保存路径为："+url+"内容是："+content);
			var pFile:File=File.documentsDirectory.resolvePath(url);
			var filesStream:FileStream=new FileStream();
			filesStream.open(pFile, FileMode.WRITE);
			filesStream.writeUTFBytes(content);
			filesStream.close();
		}

		public static function writeBytesTofile(url:String, bytes:ByteArray):void
		{
			trace("保存路径为：" + url + "二进制文件大小为：" + bytes.length);
			var pFile:File=File.documentsDirectory.resolvePath(url);
			var filesStream:FileStream=new FileStream();
			filesStream.open(pFile, FileMode.WRITE);
			filesStream.writeBytes(bytes);
			filesStream.close();
		}

		public static function readBytes(url:String):ByteArray
		{
			var bytes:ByteArray=new ByteArray();
			var file:File=File.desktopDirectory.resolvePath(url);
			var fileStream:FileStream=new FileStream();
			fileStream.open(file, FileMode.READ);
			fileStream.readBytes(bytes);
			fileStream.close();
			trace("读取路径为：" + url + "二进制文件大小为：" + bytes.length);
			return bytes;
		}
	}
}
