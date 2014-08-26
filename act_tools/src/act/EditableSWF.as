package act
{
	import com.hurlant.eval.Evaluator;

	import flash.display.BitmapData;
	import flash.geom.Rectangle;
	import flash.utils.ByteArray;
	import flash.utils.Endian;

	import org.libspark.swfassist.io.ByteArrayOutputStream;
	import org.libspark.swfassist.swf.io.SWFWriter;
	import org.libspark.swfassist.swf.io.WritingContext;
	import org.libspark.swfassist.swf.structures.Asset;
	import org.libspark.swfassist.swf.structures.FillStyle;
	import org.libspark.swfassist.swf.structures.FillStyleTypeConstants;
	import org.libspark.swfassist.swf.structures.Matrix;
	import org.libspark.swfassist.swf.structures.RGB;
	import org.libspark.swfassist.swf.structures.Rect;
	import org.libspark.swfassist.swf.structures.SWF;
	import org.libspark.swfassist.swf.structures.SceneData;
	import org.libspark.swfassist.swf.structures.StraightEdgeRecord;
	import org.libspark.swfassist.swf.structures.StyleChangeRecord;
	import org.libspark.swfassist.swf.tags.DefineBitsLossless2;
	import org.libspark.swfassist.swf.tags.DefineSceneAndFrameLabelData;
	import org.libspark.swfassist.swf.tags.DefineShape;
	import org.libspark.swfassist.swf.tags.DefineSprite;
	import org.libspark.swfassist.swf.tags.DoABC;
	import org.libspark.swfassist.swf.tags.PlaceObject2;
	import org.libspark.swfassist.swf.tags.PlaceObject3;
	import org.libspark.swfassist.swf.tags.SetBackgroundColor;
	import org.libspark.swfassist.swf.tags.ShowFrame;
	import org.libspark.swfassist.swf.tags.SymbolClass;
	import org.libspark.swfassist.swf.tags.Tag;

	/**
	 * @author moyubing
	 * 用于NPC的图标导出
	 * 格式:
	 * act/npc_icons/npc_icons_[城镇ID]/[npcID].png
	 * 使用软件后选择act目录
	 * 自动以npc_icon_[npcID]为as类名放入 act/程序导出文件/bin/npc_icons 目录下
	 */
	public class EditableSWF extends SWF
	{
		private var _bytes:ByteArray=new ByteArray();
		private var _doABC:DoABC=new DoABC();
		private var _TagIDCount:uint=0;
		private var _pngLists:Vector.<Vector.<DefineBitsLossless2>>=new Vector.<Vector.<DefineBitsLossless2>>();
		private var _shapeLists:Vector.<Vector.<DefineShape>>=new Vector.<Vector.<DefineShape>>();
		private var _spriteList:Vector.<DefineSprite>=new Vector.<DefineSprite>();
		private var _symbolClass:SymbolClass=new SymbolClass();
		private var _strClass:String=new String();
		private var _rectFix:Vector.<Rectangle>=new Vector.<Rectangle>();
		private var _pngsCountInBitmapData:uint=0;
		private var _spriteCount:uint=0;
		private var background:SetBackgroundColor=new SetBackgroundColor();

		public function EditableSWF()
		{
			var black:RGB=new RGB();
			var frameSizeRect:Rect=new Rect();

			black.red=0x00;
			black.green=0x00;
			black.blue=0x00;
			background.backgroundColor=black;
			header.frameRate=30;
			frameSizeRect.xMax=550;
			frameSizeRect.yMax=400;
			header.frameSize=frameSizeRect;
			header.version=10;
			header.isCompressed=true;
			header.numFrames=1;
			fileAttributes.isActionScript3=true;
		}

		// 添加sprite到数组中
		private function addSprite2Array(mcName:String, spriteList:Vector.<DefineSprite>, tagID:uint, tags:Vector.<Tag>, nFrame:uint=0):uint
		{
			var sprite:DefineSprite=new DefineSprite();
			++_spriteCount;
			sprite.spriteId=tagID;
			for each (var tempTag:Tag in tags)
			{
				sprite.tags.tags.push(tempTag);
			}
			sprite.numFrames=nFrame;
			spriteList.push(sprite);
			if (mcName.length > 0)
			{
				var symbolClassData:Asset=new Asset();
				symbolClassData.name=mcName;
				symbolClassData.characterId=tagID;
				_symbolClass.symbols.push(symbolClassData);
				_strClass+=" public class " + mcName + " extends flash.display.MovieClip {public function " + mcName + "() {}}";
			}
			return 0;
		}

		private function addPlaceObject2AndShowFrame2Array(placeObjectList:Vector.<Tag>, characterID:uint, pngPositions:Rectangle, isFisrt:Boolean, rect:Rectangle):void
		{
			var tempMatrix:Matrix=new Matrix();
			var po:PlaceObject2=new PlaceObject2();
			tempMatrix.translateX=pngPositions.x - rect.x;
			tempMatrix.translateY=pngPositions.y - rect.y;
			if (isFisrt)
			{
				po.hasClipActions=false;
				po.hasClipDepth=false;
				po.hasName=false;
				po.hasRatio=false;
				po.hasColorTransform=false;
				po.hasMatrix=true;
				po.hasCharacter=true;
				po.isMove=false;
				po.characterId=characterID;
				po.matrix=tempMatrix;
				po.depth=1;
				placeObjectList.push(po);
				placeObjectList.push(new ShowFrame());
			}
			else
			{
				po=new PlaceObject2();
				po.hasClipActions=false;
				po.hasClipDepth=false;
				po.hasRatio=false;
				po.hasColorTransform=false;
				po.hasMatrix=true;
				po.hasCharacter=true;
				po.isMove=true;
				po.characterId=characterID;
				po.matrix=tempMatrix;
				po.depth=1;
				placeObjectList.push(po);
				placeObjectList.push(new ShowFrame());
			}
		}

		public function savePngList2Swf(pngs:Vector.<BitmapData>, pngPositions:Vector.<Rectangle>, mcName:String, rectFixValue:Vector.<Rectangle>=null):void
		{
			var pngList:Vector.<DefineBitsLossless2>=new Vector.<DefineBitsLossless2>();
			var shapeList:Vector.<DefineShape>=new Vector.<DefineShape>();
			var placeObjecAndShowFrametList:Vector.<Tag>=new Vector.<Tag>();
			if (rectFixValue != null)
				_rectFix=rectFixValue;

			_pngsCountInBitmapData=0;
			for each (var png:BitmapData in pngs)
			{
				var pngBounds:Rectangle=new Rectangle(0, 0, png.width, png.height);
				var pngByteArray:ByteArray=new ByteArray();

				var temRect:Rectangle=new Rectangle();
				if (_pngsCountInBitmapData < pngPositions.length)
				{
					temRect.x=pngPositions[_pngsCountInBitmapData].x;
					temRect.y=pngPositions[_pngsCountInBitmapData].y;
				}
				else
				{
					temRect.x=0;
					temRect.y=0;
					trace("Positions length is wrong!Used position (0,0)");
				}
				var bd2:BitmapData=new BitmapData(png.width, png.height);
				// 颜色通道处理
				for (var i:uint=0; i < png.width; i++)
				{
					for (var j:uint=0; j < png.height; j++)
					{
						var c:uint=png.getPixel32(i, j);
						var r:uint=c >> 16 & 0xff;
						var g:uint=c >> 8 & 0xff;
						var b:uint=c & 0xff;
						var alpha:uint=c >> 24 & 0xff;
						var cc:uint=(r * alpha / 255) << 16 | (g * alpha / 255) << 8 | (b * alpha / 255) | alpha << 24;
						png.setPixel32(i, j, cc);
					}
				}
				pngByteArray=png.getPixels(pngBounds);
				pngByteArray.position=0;
				bd2.setPixels(pngBounds, pngByteArray);
				addPNG2Array(pngList, png, shapeList, temRect, placeObjecAndShowFrametList, (++_pngsCountInBitmapData) == 1);
			}

			addSprite2Array(mcName, _spriteList, IDFixed, placeObjecAndShowFrametList, placeObjecAndShowFrametList.length / 2);
			_pngLists.push(pngList);
			_shapeLists.push(shapeList);
		}

		private function addPNG2Array(pngArray:Vector.<DefineBitsLossless2>, png:BitmapData, shapeArray:Vector.<DefineShape>, pngPositions:Rectangle, placeObjecAndShowFrametList:Vector.<Tag>, isFisrt:Boolean):void
		{
			var pngInSWF:DefineBitsLossless2=new DefineBitsLossless2();
			if (pngArray == null)
			{
				pngArray=new Vector.<DefineBitsLossless2>();
			}
			pngInSWF.bitmapFormat=05;
			pngInSWF.bitmapHeight=png.height;
			pngInSWF.bitmapWidth=png.width;
			pngInSWF.characterId=IDFixed;
			pngInSWF.data=png.getPixels(new Rectangle(0, 0, png.width, png.height));
			pngArray.push(pngInSWF);
			addDefineShape2Array(pngInSWF.characterId, png, shapeArray, IDFixed, pngPositions, placeObjecAndShowFrametList, isFisrt);
		}

		private function addDefineShape2Array(pngID:uint, pngInSWF:BitmapData, shapeArray:Vector.<DefineShape>, pngShapeID:uint, pngPositions:Rectangle, placeObjecAndShowFrametList:Vector.<Tag>, isFirst:Boolean):void
		{
			shapeArray.push(createDefineShape(pngID, pngShapeID, pngInSWF));
			addPlaceObject2AndShowFrame2Array(placeObjecAndShowFrametList, pngShapeID, pngPositions, isFirst, _rectFix.length <= _spriteCount ? (new Rectangle()) : _rectFix[_spriteCount]);
		}

		public function collectTags():void
		{
			tags.addTag(background);
			// Scene
			tags.addTag(createDefineSceneAndFrameLabelData("Scene 1"));
			for (var i:uint=0; i < _pngLists.length; ++i)
			{
				for (var j:uint=0; j < _pngLists[i].length; ++j)
				{
					tags.addTag(_pngLists[i][j]);
					tags.addTag(_shapeLists[i][j]);
				}
				tags.addTag(_spriteList[i]);
			}

			// doABC
			if (_strClass.length > 0)
			{
				var evaluator:Evaluator=new Evaluator();
				_bytes=evaluator.eval(_strClass);
				_doABC.abcData=_bytes;
				_doABC.isLazyInitialize=true;
				tags.addTag(_doABC);
				tags.addTag(_symbolClass);
			}
			tags.addTag(new ShowFrame());
		}

		// 写swf文件
		public function writeToFile(url:String):void
		{
			var swfWriter:SWFWriter=new SWFWriter();
			var byteArrayOutputStream:ByteArrayOutputStream=new ByteArrayOutputStream();
			var writingcontent:WritingContext=new WritingContext();
			swfWriter.writeSWF(byteArrayOutputStream, writingcontent, this);
			FileUtil.writeBytesTofile(url, byteArrayOutputStream.byteArray);
		}

		public function addPNGOnly(bitmapdata:BitmapData, asName:String):void
		{
			var png:DefineBitsLossless2=new DefineBitsLossless2();
			png.bitmapFormat=05;
			png.bitmapHeight=bitmapdata.height;
			png.bitmapWidth=bitmapdata.width;
			png.characterId=IDFixed;
			png.data=bitmapdata.getPixels(new Rectangle(0, 0, bitmapdata.width, bitmapdata.height));
			tags.addTag(png);

			// 脚本的 avm 二进制中箭码
			var doABC:DoABC=new DoABC();
			// 末位为asName长度
			var bitmapDataScript1_part1:Array=[0x10, 0x00, 0x2e, 0x00, 0x03];
			var bitmapDataScript1_part2:Array=[0x00, 0x00, 0x07, 0x00, 0x03, 0x69, 0x6e, 0x74];
			// name [0x69,0x31,0x31,0x32,0x30,0x33,0x30,0x33,0x30,0x31];
			var bitmapDataScript2:Array=[0x0d, 0x66, 0x6c, 0x61, 0x73, 0x68, 0x2e, 0x64, 0x69, 0x73, 0x70, 0x6c, 0x61, 0x79, 0x0a, 0x42, 0x69, 0x74, 0x6d, 0x61, 0x70, 0x44, 0x61, 0x74, 0x61, 0x06, 0x4f, 0x62, 0x6a, 0x65, 0x63, 0x74, 0x04, 0x16, 0x01, 0x16, 0x04, 0x18, 0x03, 0x00, 0x05, 0x07, 0x01, 0x02, 0x07, 0x01, 0x03, 0x07, 0x02, 0x05, 0x07, 0x01, 0x06, 0x03, 0x00, 0x00, 0x00, 0x00, 0x02, 0x00, 0x01, 0x01, 0x00, 0x08, 0x02, 0x01, 0x03, 0x02, 0x03, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x02, 0x03, 0x08, 0x03, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01, 0x02, 0x01, 0x02, 0x04, 0x01, 0x00, 0x03, 0x00, 0x01, 0x01, 0x04, 0x05, 0x03, 0xd0, 0x30, 0x47, 0x00, 0x00, 0x01, 0x03, 0x03, 0x05, 0x06, 0x08, 0xd0, 0x30, 0xd0, 0xd1, 0xd2, 0x49, 0x02, 0x47, 0x00, 0x00, 0x02, 0x02, 0x01, 0x01, 0x04, 0x13, 0xd0, 0x30, 0x65, 0x00, 0x60, 0x04, 0x30, 0x60, 0x03, 0x30, 0x60, 0x03, 0x58, 0x00, 0x1d, 0x1d, 0x68, 0x02, 0x47, 0x00, 0x00];
			var bitmapDataScriptByteArray:ByteArray=new ByteArray();
			for each (var intValue1:int in bitmapDataScript1_part1)
				bitmapDataScriptByteArray.writeByte(intValue1);
			if (bitmapdata.width < 0x80)
			{
				bitmapDataScriptByteArray.writeByte(bitmapdata.width);
			}
			else
			{
				var tempBa1:ByteArray=new ByteArray();
				tempBa1.endian=Endian.LITTLE_ENDIAN;
				tempBa1.writeShort(bitmapdata.width + 0x100);
				bitmapDataScriptByteArray.writeBytes(tempBa1);
			}
			// 大于0x80的长宽需要移位
			if (bitmapdata.height < 0x80)
			{
				bitmapDataScriptByteArray.writeByte(bitmapdata.height);
			}
			else
			{
				var tempBa2:ByteArray=new ByteArray();
				tempBa2.endian=Endian.LITTLE_ENDIAN;
				tempBa2.writeShort(bitmapdata.height + 0x100);
				bitmapDataScriptByteArray.writeBytes(tempBa2);
			}
			for each (var intValue2:int in bitmapDataScript1_part2)
			{
				bitmapDataScriptByteArray.writeByte(intValue2);
			}
			bitmapDataScriptByteArray.writeByte(asName.length);
			bitmapDataScriptByteArray.writeUTFBytes(asName);
			for each (var intValue3:int in bitmapDataScript2)
			{
				bitmapDataScriptByteArray.writeByte(intValue3);
			}
			doABC.abcData=bitmapDataScriptByteArray;
			doABC.isLazyInitialize=true;
			tags.addTag(doABC);
			tags.addTag(createSymbolClass(asName, png.characterId));
			tags.addTag(new ShowFrame());
		}

		public function createDefineSceneAndFrameLabelData(sceneName:String):DefineSceneAndFrameLabelData
		{
			var defineSceneAndFrameLabelData:DefineSceneAndFrameLabelData=new DefineSceneAndFrameLabelData();
			var defineSceneData:SceneData=new SceneData();
			defineSceneData.name=sceneName;
			defineSceneAndFrameLabelData.scenes.push(defineSceneData);
			return defineSceneAndFrameLabelData;
		}

		private function createDefineShape(pngID:uint, pngShapeID:uint, bitmapdata:BitmapData):DefineShape
		{
			// shape平移
			// var translateRectX : int = _rectFix.length <= _pngsCountInBitmapData ? 0 : _rectFix[_pngsCountInBitmapData].x;
			// var translateRectY : int = _rectFix.length <= _pngsCountInBitmapData ? 0 : _rectFix[_pngsCountInBitmapData].y;

			var pngShape:DefineShape=new DefineShape();
			pngShape.shapeId=pngShapeID;
			var pngShapeRect:Rect=new Rect();
			pngShapeRect.xMax=bitmapdata.width;
			pngShapeRect.yMax=bitmapdata.height;
			pngShape.shapeBounds=pngShapeRect;
			var pngShapeFillStyle:FillStyle=new FillStyle();
			var pngShapeFillStyleMatrix:Matrix=new Matrix();
			pngShapeFillStyleMatrix.hasScale=true;
			pngShapeFillStyleMatrix.scaleX=20;
			pngShapeFillStyleMatrix.scaleY=20;

			// 贴图平移
			// trace("#####",pngShapeFillStyleMatrix.translateX);
			// pngShapeFillStyleMatrix.translateX = translateRectX;
			// pngShapeFillStyleMatrix.translateY = translateRectY;

			pngShapeFillStyle.bitmapId=pngID;
			// 0x41
			pngShapeFillStyle.fillStyleType=FillStyleTypeConstants.CLIPPED_BITMAP_FILL;
			pngShapeFillStyle.bitmapMatrix=pngShapeFillStyleMatrix;
			pngShape.shapes.fillStyles.fillStyles.push(pngShapeFillStyle);
			pngShape.shapes.lineStyles.lineStyles.push();
			var pngShapeStyleChangeRecord:StyleChangeRecord=new StyleChangeRecord();
			/*
			if (pngPositions != null) {
			pngShapeStyleChangeRecord.stateMoveTo = true;
			pngShapeStyleChangeRecord.moveDeltaX = pngPositions.x;
			pngShapeStyleChangeRecord.moveDeltaY = pngPositions.y;
			}
			 *
			 */
			// 形状平移
			// pngShapeStyleChangeRecord.stateMoveTo = true;
			// pngShapeStyleChangeRecord.moveDeltaX = translateRectX;
			// pngShapeStyleChangeRecord.moveDeltaY = translateRectY;

			pngShapeStyleChangeRecord.stateNewStyles=false;
			pngShapeStyleChangeRecord.fillStyle0=1;
			pngShapeStyleChangeRecord.stateFillStyle0=true;
			pngShapeStyleChangeRecord.stateMoveTo=true;

			pngShape.shapes.shapeRecords.push(pngShapeStyleChangeRecord);
			var pngShapeStraightEdgeRecord1:StraightEdgeRecord=new StraightEdgeRecord();
			pngShapeStraightEdgeRecord1.deltaX=bitmapdata.width;
			pngShape.shapes.shapeRecords.push(pngShapeStraightEdgeRecord1);
			var pngShapeStraightEdgeRecord2:StraightEdgeRecord=new StraightEdgeRecord();
			pngShapeStraightEdgeRecord2.verticalLine=true;
			pngShapeStraightEdgeRecord2.deltaY=bitmapdata.height;
			pngShape.shapes.shapeRecords.push(pngShapeStraightEdgeRecord2);
			var pngShapeStraightEdgeRecord3:StraightEdgeRecord=new StraightEdgeRecord();
			pngShapeStraightEdgeRecord3.deltaX=-bitmapdata.width;
			pngShape.shapes.shapeRecords.push(pngShapeStraightEdgeRecord3);
			var pngShapeStraightEdgeRecord4:StraightEdgeRecord=new StraightEdgeRecord();
			pngShapeStraightEdgeRecord4.verticalLine=true;
			pngShapeStraightEdgeRecord4.deltaY=-bitmapdata.height;
			pngShape.shapes.shapeRecords.push(pngShapeStraightEdgeRecord4);
			return pngShape;
		}

		// 放入舞台的placeObject3
		private function createPlaceObject3(shapeID:uint):PlaceObject3
		{
			var po3:PlaceObject3=new PlaceObject3();
			po3.hasClipActions=false;
			po3.hasClipDepth=false;
			po3.hasName=false;
			po3.hasRatio=false;
			po3.hasColorTransform=false;
			po3.hasMatrix=false;
			po3.hasCharacter=true;
			po3.isMove=false;
			// reserved == 0
			po3.hasImage=false;
			po3.hasClassName=false;
			po3.hasCacheAsBitmap=false;
			po3.hasBlendMode=false;
			po3.hasFilterList=false;
			po3.depth=1;
			po3.characterId=shapeID;
			// po3.matrix = new Matrix();
			po3.className="";
			return po3;
		}

		// 创建abc脚本二进制代码
		// private function createDoABC(name : String) : DoABC {
		// var doABC : DoABC = new DoABC();
		// var eval : Evaluator = new Evaluator();
		// doABC.abcData = eval.eval("public class " + name + " extends flash.display.MovieClip {public function " + name + "() {}}");
		// doABC.isLazyInitialize = true;
		// return doABC;
		// }
		// 创建symbolClass标签
		private function createSymbolClass(asName:String, characterID:uint):SymbolClass
		{
			var sc:SymbolClass=new SymbolClass();
			var scData:Asset=new Asset();
			scData.name=asName;
			scData.characterId=characterID;
			sc.symbols.push(scData);
			return sc;
		}

		// id递增
		public function get IDFixed():uint
		{
			return ++_TagIDCount;
		}
	}
}
