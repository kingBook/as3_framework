package framework.utils {
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.FrameLabel;
	import flash.display.Graphics;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.filters.GlowFilter;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.ByteArray;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;

	/**
	 * ...
	 * @author kingBook
	 * 2014-10-09 16:58
	 */
	public class FuncUtil {
		private static var _standardMat:Matrix = new Matrix(1, 0, 0, 1, 0, 0);
		private static var _stageRect:Rectangle;
		
		/**创建一个Sprite按钮*/
		public static function createBtn(x:Number,y:Number,text:String, parent:Sprite,w:Number=60,h:Number=20):Sprite {
			var sp:Sprite = new Sprite();
			sp.x = x;
			sp.y = y;
			sp.graphics.beginFill(0xcccccc, 1);
			sp.graphics.drawRect(0, 0, w, h);
			sp.graphics.endFill();
			
			var tf:TextFormat=new TextFormat();
			tf.align=TextFormatAlign.CENTER;
			
			var txt:TextField = new TextField();
			txt.defaultTextFormat=tf;
			txt.textColor = 0x000000;
			txt.text = text;
			txt.width = sp.width;
			txt.height = sp.height;
			
			sp.addChild(txt);
			parent.addChild(sp);
			
			sp.mouseChildren = false;
			sp.buttonMode = true;
			return sp;
		}
		
		/**从显示列表中安全的移除一个对象*/
		public static function removeChild(obj:DisplayObject):void {
			obj && obj.parent && obj.parent.removeChild(obj);
		}
		
		/**
		 * 从显示列表中安全的移除一个对象
		 * @param	obj :DisplayObject 要从显示列表中移除的对象
		 * @param	isStopSelf Boolean=true 如果true,当obj的类型是MovieClip时则调用stop().
		 * @param	isRemoveSelf Boolean=true 如果true,从显示列表中移除自身.
		 * @param	isStopChildren Boolean=true 如果true,所有层级的所有对象,如果类型是MovieClip都调用stop().
		 * @param	isRemoveChildren 如果true,所有层级的所有对象都从父级移除
		 */
		public static function removeChildPlus(obj:DisplayObject,isStopSelf:Boolean=true,isRemoveSelf:Boolean=true,isStopChildren:Boolean=true,isRemoveChildren:Boolean=true):void{
			isStopSelf && obj && obj.parent && obj.parent.removeChild(obj);
			if( isStopSelf&&obj is MovieClip)MovieClip(obj).stop();
			
			if(isStopChildren||isRemoveChildren){
				if(obj is DisplayObjectContainer){
					var container:*=DisplayObjectContainer(obj);
					var i:int=container.numChildren;
					var child:DisplayObject;
					while(--i>=0){
						child=container.getChildAt(i);
						removeChildPlus(child,isStopChildren,isRemoveChildren,isStopChildren,isRemoveChildren);
					}
				}
			}
			
		}
		
		/**返回矩形对象变形后的宽*/
		public static function getTransformWidth(obj:DisplayObject):Number{
			var recordMat:Matrix = obj.transform.matrix;
			obj.transform.matrix = _standardMat;
			var w:Number = obj.width;
			obj.transform.matrix = recordMat;
			w = w*obj.scaleX;
			return Math.abs(w);
		}
		
		/**返回矩形对象变形后的高*/
		public static function getTransformHeight(obj:DisplayObject):Number{
			var recordMat:Matrix = obj.transform.matrix;
			obj.transform.matrix = _standardMat;
			var h:Number = obj.height;
			obj.transform.matrix = recordMat;
			h = h*obj.scaleY;
			return Math.abs(h);
		}
		
		/**返回一个对象未经过矩形变化前的宽高*/
		public static function getDisObjStandardWH (disObj:DisplayObject):Point {
			var mat:Matrix = disObj.transform.matrix;
			disObj.transform.matrix = _standardMat;//还原到没发生变形前
			var w:Number = disObj.width;
			var h:Number = disObj.height;
			disObj.transform.matrix = mat;//取宽高后还原现有矩形	
			return new Point(w,h);
		}
		
		public static function addToList(obj:*, list:*):void {
			if (!obj) return;
			if (!list) throw new Error("list不能为 null");
			if (list.indexOf(obj) < 0) list.push(obj);
		}
		
		public static function removeFromList(obj:*, list:*):void {
			if (!obj) return;
			if (!list) return;
			var index:int = list.indexOf(obj);
			if (index > -1) list.splice(index, 1);
		}
		
		/**
		 * 随机化一个数组
		 * example:
		 *  var ary:Array=[1,2,3,4,5];
		 *  ary = randomArr(ary);
		 *  trace(ary);
		 *  输出: 3,5,2,1,4
		 * @param	arr
		 * @return
		 */
		public static function randomArr(arr:Array):Array {
			if (!arr) throw new Error("参数arr不能为null~~!");
			var sourceArr:Array = arr.slice();
			var tmpArr:Array = [];
			var i:int = sourceArr.length
			while (--i >= 0) tmpArr = tmpArr.concat(sourceArr.splice(Math.random() * sourceArr.length >> 0, 1));
			return tmpArr;
		}
		
		/**停止影片*/
		public static function stopMovie(o:DisplayObjectContainer):void {
			if (!o) return;
			if (o is MovieClip) (o as MovieClip).stop();
			var i:int = o.numChildren;
			while (--i >= 0) stopMovie(o.getChildAt(i) as DisplayObjectContainer);
		}
		
		/**恢复停止的影片*/
		public static function restMovie(o:DisplayObjectContainer):void {
			if (!o) return;
			if (o is MovieClip) (o as MovieClip).play();
			var i:uint = o.numChildren;
			while (--i >= 0) restMovie(o.getChildAt(i) as DisplayObjectContainer);
		}
		
		/**将一个显示对象列表中的所有对象,从父级移除*/
  		public static function removeChildList(list:*):void {
			if (!list) return;
			for each (var o:DisplayObject in list){ removeChild(o);}
		}
		
		/**根据标签返回帧编号*/
		/*public static function getLabelToFrame(mc:MovieClip, labelName:String):int {
			var labels:Array = mc.currentLabels;
			var len:int = labels.length
			for (var i:int = 0; i < len; i++) {
				var curLabel:FrameLabel = labels[i];
				if (curLabel.name == labelName)
					return curLabel.frame;
			}
			throw new Error("在mc中没有找到贴标签： ", labelName);
			return 0;
		}*/
		
		/**深度复制*/
		public static function deepClone(obj:Object):Object {
			var byArr:ByteArray = new ByteArray();
			byArr.writeObject(obj);
			byArr.position = 0;
			return byArr.readObject();
		}
		
		/**
		 * 全局坐标
		 * @param	disObj
		 * @param	localPt 表示disObj内的坐标,如：new Point(disObj.mouseX,disObj.mouseY);
		 * @param	out
		 * @return
		 */
		/*public static function globalXY(disObj:DisplayObject, localPt:Point = null,out:Point=null):Point {
			if (!disObj) throw new Error("FuncUtil::globalXY() 参数disObj不能为null");
			if (!disObj.parent) throw new Error("FuncUtil::globalXY()传进的对象不在显示列表!");
			
			//记录localPt,避免localPt与out引用相同，导致错误
			var localX:Number;
			var localY:Number;
			if(localPt){
				localX=localPt.x;
				localY=localPt.y;
			}
			
			if(!out)out=new Point(disObj.x,disObj.y);
			else out.setTo(disObj.x,disObj.y);
			
			if(localPt){
				out.x=localX;
				out.y=localY;
			}
			var parentObj:DisplayObject=disObj;
			while(parentObj){
				out.x*=parentObj.scaleX;
				out.y*=parentObj.scaleY;
				out.x+=parentObj.x;
				out.y+=parentObj.y;
				parentObj=parentObj.parent;
			}
			return out;
		}*/
		
		/**全局坐标*/
		public static function globalXY(disObj:DisplayObject, localPt:Point = null,out:Point=null):Point {
			if (!disObj) throw new Error("FuncUtil::globalXY() 参数disObj不能为null");
			if (!disObj.parent) throw new Error("FuncUtil::globalXY()传进的对象不在显示列表!");
			
			localPt||=new Point();
			var matrix:Matrix=new Matrix(1,0,0,1,localPt.x,localPt.y);
			matrix.concat(disObj.transform.matrix.clone());
			var parentObj:DisplayObjectContainer=disObj.parent;
			while(parentObj){
				matrix.concat(parentObj.transform.matrix);
				parentObj=parentObj.parent;
			}
			
			if(!out)out=new Point();
			out.setTo(matrix.tx,matrix.ty);
			return out;
		}
		
		private static var _pt:Point = new Point(0, 0);
		
		public static function localXY(disObj:DisplayObject, targetCoordinateSpace:DisplayObject):Point {
			if (!disObj) throw new Error("FuncUtil->localXY() 参数disObj不能为null");
			if (!targetCoordinateSpace) throw new Error("FuncUtil->localXY() 参数container不能为null");
			var gpt:Point = globalXY(disObj, _pt);
			var lpt:Point = targetCoordinateSpace.globalToLocal(gpt);
			return lpt;
		}
		
		public static function localXY_2(gpt:Point, targetCoordinateSpace:DisplayObject):Point {
			var lpt:Point = targetCoordinateSpace.globalToLocal(gpt);
			return lpt;
		}
		
		/**旋转*/
		public static function rotate(obj:DisplayObject, angle:Number):void {
			if (!obj) {
				trace("warning: 参数obj为null!")
				return;
			}
			var x:Number = obj.x;
			var y:Number = obj.y;
			var mat:Matrix = obj.transform.matrix;
			mat.tx = 0;
			mat.ty = 0;
			mat.rotate(angle * Math.PI / 180);
			mat.translate(x, y);
			obj.transform.matrix = mat;
		
		}
		
		/**对象在舞台*/
		public static function objInStage(disObj:DisplayObject, stageW:Number=640, stageH:Number=480):Boolean {
			if (!disObj) return false;
			if (!disObj.stage) return false;
			var rect1:Rectangle = disObj.getBounds(disObj.stage);
			_stageRect ||= new Rectangle();
			_stageRect.width = stageW;
			_stageRect.height = stageH;
			if (rect1.intersects(_stageRect)) return true;
			return false;
		}
		
		/**舞台包含对象*/
		public static function stageContainsObj(disObj:DisplayObject, stageW:Number=640, stageH:Number=480):Boolean {
			if (!disObj) return false;
			if (!disObj.stage) return false;
			var rect1:Rectangle = disObj.getBounds(disObj.stage);
			_stageRect ||= new Rectangle();
			_stageRect.width = stageW;
			_stageRect.height = stageH;
			if (_stageRect.containsRect(rect1)) return true;
			return false;
		}
		
		/**舞台包含框*/
		public static function stageContainsRect(rect2:Rectangle, stageW:Number=640, stageH:Number=480):Boolean {
			_stageRect ||= new Rectangle();
			_stageRect.width = stageW;
			_stageRect.height = stageH;
			return _stageRect.containsRect(rect2)
		}
		
		/**舞台包含点*/
		public static function stageContainsPt(pt:Point, stageW:Number=640, stageH:Number=480):Boolean {
			_stageRect ||= new Rectangle();
			_stageRect.width = stageW;
			_stageRect.height = stageH;
			return _stageRect.containsPoint(pt);
		}
		
		/**返回播放一个影片的总<毫秒>数*/
		public static function getPlayMovieMsec(totalFrames:uint, fps:uint = 30):Number {
			return (1000 / fps) * totalFrames;
		}
		
		/**返回播放一个影片的总<秒>数*/
		public static function getPlayMovieSecond(totalFrames:uint, fps:uint = 30):Number {
			return 1 / fps * totalFrames
		}
		
		/**dispose一个bitmapData列表*/
		public static function disposeBmdList(list:*):void {
			if (!list || !list.length) return;
			if (!(list is Array) && !(list is Vector.<BitmapData>)) return;
			var i:uint = list.length;
			while (--i >= 0) list[i] && list[i].dispose();
		}
		
		/**将一个显示对象列表添加到一个容器*/
  		public static function addChildListToContainer(list:*, c:DisplayObjectContainer):void {
			if (!list || !c) return;
			for each (var o:DisplayObject in list){ c.addChild(o);}
		}
		
		public static function foreach(arr:Array, ... params):void {
			var i:int = arr.length;
			while (--i >= 0)
				(arr[i] == null) ? arr.splice(i, 1) : arr[i].apply(null, params);
		}
		
		/**再制定义对象*/
		public static function duplicateDefObj(defObj:*):* {
			var name:String = getQualifiedClassName(defObj);
			var _Class:Class = getDefinitionByName(name) as Class;
			var duplicateO:* = new _Class();
			if (duplicateO.transform && defObj.transform) {
				duplicateO.transform = defObj.transform;
			}
			return duplicateO;
		}
		
		/**
		 * 将显示对象转换为BitmapData
		 * example:
		 * ----------------------------------------------------------
		 * 1.转换为未缩放前的BitmapData,不管注册点处于任何位置/缩放
		 * var bmd:BitmapData=getBmdFromDisObj(mc);
		 * addChild(new Bitmap(bmd));
		 * ----------------------------------------------------------
		 * 
		 * 
		 * @param	disObj
		 * @param	w
		 * @param	h
		 * @param	tx
		 * @param	ty
		 * @return
		 */
		public static function getBmdFromDisObj(disObj:DisplayObject,w:int=0,h:int=0,tx:Number=NaN,ty:Number=NaN):BitmapData{
			if(w==0||h==0){
				var r:Rectangle = disObj.getBounds(disObj);
				w=int(r.width+0.9), h=int(r.height+0.9);
			}
			var bmd:BitmapData=new BitmapData(w,h,true,0);
			var matrix:Matrix = new Matrix();
			if(!isNaN(tx))matrix.tx=tx;else if(r)matrix.tx=-r.x;
			if(!isNaN(ty))matrix.ty=ty;else if(r)matrix.ty=-r.y;
			bmd.draw(disObj,matrix);
			return bmd;
		}
		
		/**
		 * 将显示对象转换为BitmapData
		 * example:
		 * ----------------------------------------------------------
		 * 显示对象可以缩放 
		 * var bmd:BitmapData=getBmdFromDisObj(mc);
		 * addChild(new Bitmap(bmd));
		 * ----------------------------------------------------------
		 * 
		 * 
		 * @param	obj
		 * @param	smoothing
		 * @param	transparent
		 * @param	fillColor
		 * @return
		 */
		public static function getBmdFromScaleDisObj(obj:DisplayObject,smoothing:Boolean=false,transparent:Boolean=true,fillColor:uint=0x00000000):BitmapData{
			var m:Matrix=obj.transform.matrix;
			var r:Rectangle=obj.getBounds(obj);
			var w:int=int(r.width*m.a+0.9), h:int=int(r.height*m.d+0.9);
			var bmd:BitmapData=new BitmapData(w,h,transparent,fillColor);
			m.tx=-r.x*m.a;
			m.ty=-r.y*m.d;
			bmd.draw(obj,m,null,null,null,smoothing);
			return bmd;
		}
		
		/**返回两32位颜色之间的“差”，参考BitmapData.compare()方法*/
		public static function getColor32Diff(aColor:uint,bColor:uint):uint{
			var diff:uint;
			var aColor24:uint=aColor&0x00FFFFFF;
			var bColor24:uint=bColor&0x00FFFFFF;
			if(aColor24==bColor24){
				var diffA:uint=( ((aColor>>24)&0xFF) - ((bColor>>24)&0xFF) )&0xFF;
				diff=0x00FFFFFF|(diffA<<24);
			}else{
				var diffB:uint=( (aColor24&0xFF) - (bColor24&0xFF) )&0xFF;//最后一个&0xFF小减大时出现负数补码
				var diffG:uint=( ((aColor24>>>8)&0xFF) - ((bColor24>>>8)&0xFF) )&0xFF;
				var diffR:uint=( ((aColor24>>>16)&0xFF) - ((bColor24>>>16)&0xFF) )&0xFF;
				diff=diffB;
				diff=diff|(diffG<<8);
				diff=diff|(diffR<<16);
			}
			return diff;
		}
		
		/**倾倒填充*/
		public static function floodFill(sourceBmd:BitmapData,x:int,y:int,color:uint,glowBlur:Number=2):void{
			const sourcePickColor:uint=sourceBmd.getPixel32(x,y);
			var oldSourceBmd:BitmapData=sourceBmd.clone();
			sourceBmd.floodFill(x,y,color);
			var diffBmd:BitmapData=sourceBmd.compare(oldSourceBmd) as BitmapData;//比较取出填充部分
			oldSourceBmd.dispose();
			if(diffBmd){
				var diffPickColor:uint=diffBmd.getPixel32(x,y);
				var diffRect:Rectangle=new Rectangle(0,0,diffBmd.width,diffBmd.height);
				var glowFilter:GlowFilter=new GlowFilter(diffPickColor&0x00FFFFFF,(diffPickColor>>>24)/0xFF,glowBlur,glowBlur,10);
				diffBmd.applyFilter(diffBmd,diffRect,new Point(),glowFilter);//描边填充部分
				//_mc.addChild(new Bitmap(diffBmd));
				
				var fillRect:Rectangle=diffBmd.getColorBoundsRect(0xFF000000,0xFF000000,true);
				var destPoint:Point=new Point(fillRect.x,fillRect.y);
				
				/*diffBmd.threshold(diffBmd,fillRect,destPoint,">",0,color,0xFFFFFFFF);
				var diffBmp:Bitmap=new Bitmap(diffBmd);
				diffBmp.x=_fillBmp.x;
				diffBmp.y=_fillBmp.y;
				_content.addChild(diffBmp);*/
				
				sourceBmd.threshold(diffBmd,fillRect,destPoint,"==",sourcePickColor&diffPickColor,color,0xFFFFFFFF);//与初次填充图像对比，更改未填充的边缘像素
				diffBmd.dispose();
			}
		}
		
		/**
		 * 查找bmd各个角点颜色,如果checkFunc(pixelColor32:uint):Boolean返回true,则进行倾倒填充newColor32
		 * @param	bmd
		 * @param	checkFunc function(pixelColor32:uint):Boolean
		 * @param	newColor32
		 * @param	edgeOffset 边缘距离
		 */
		public static function floodFillOutside(bmd:BitmapData,checkFunc:Function,newColor32:uint,edgeOffset:uint=0):void{
			var list:Array=[new Point(0,0),new Point(1,0),new Point(1,1),new Point(0,1)];
			for(var i:int=0;i<list.length;i++){
				var x:int=list[i].x*(bmd.width-1);
				var y:int=list[i].y*(bmd.height-1);
				x=Math.max(edgeOffset,Math.min(bmd.width-1-edgeOffset,x));
				y=Math.max(edgeOffset,Math.min(bmd.height-1-edgeOffset,y));
				var pixelColor32:uint=bmd.getPixel32(x,y);
				if(checkFunc(pixelColor32)){
					FuncUtil.floodFill(bmd,x,y,newColor32,2);
				}
			}
		}
		
		/**
		 * 查找bmd中与checkColor32匹配的颜色并替换成newColor32
		 * @param	bmd
		 * @param	checkColor32
		 * @param	newColor32
		 * @param	ignoreAlpha
		 */
		public static function replaceBmdColor(bmd:BitmapData,checkColor32:uint,newColor32:uint,ignoreAlpha:Boolean=false):void{
			var mask:uint=0xFFFFFFFF;
			if(ignoreAlpha)mask=0x00FFFFFF;
			bmd.threshold(bmd,bmd.rect,bmd.rect.topLeft,"==",checkColor32,newColor32,mask);
		}
		
		/**
		 * 返回bitmapData不透明的像素数量
		 * @param	bmd
		 * @param	isClone 是否新建bmd副本，为了计算过程不改变bmd本身
		 * @return
		 */
		public static function getBmdColorPixelsCount(bmd:BitmapData,isClone:Boolean=true):uint{
			if(isClone)bmd=bmd.clone();
			var threshold:uint=0x00000000;
			var color:uint=0xFF00FF00;
			var mask:uint=0xFF000000;
			var copySource:Boolean=false;
			var count:uint=bmd.threshold(bmd,bmd.rect,bmd.rect.topLeft,">",threshold,color,mask,copySource);
			if(isClone)bmd.dispose();
			return count;
		}
		
		/**
		 * 画虚线
		 * @param	sp 线容器
		 * @param	x0 起始点x
		 * @param	y0 起始点y
		 * @param	x1 结束点x
		 * @param	y1 结束点y
		 * @param	dash 一段线的长度
		 * @param	spacing 间隔
		 * @param	thickness 粗细
		 * @param	color 颜色
		 * @param	alpha 透明度
		 */
		public static function drawDashed(sp:Sprite,x0:Number,y0:Number,x1:Number,y1:Number,dash:Number=6,spacing:Number=6,thickness:Number=NaN,color:uint=0,alpha:Number=1):void{
			sp.graphics.lineStyle(thickness,color,alpha);
			var a:Number=y1-y0;
			var b:Number=x1-x0;
			var maxLength:Number=Math.sqrt(a*a+b*b);
			var angleRadian:Number=Math.atan2(a,b);
			var cos:Number=Math.cos(angleRadian);
			var sin:Number=Math.sin(angleRadian);
			
			var c0:Number,c1:Number;
			var dx0:Number,dy0:Number;
			var dx1:Number,dy1:Number;
			for(var i:int=0;true;i++){
				c0=i*(dash+spacing);
				dx0=cos*c0;
				dy0=sin*c0;
				sp.graphics.moveTo(x0+dx0,y0+dy0);
				c1=c0+dash;
				if(c1>=maxLength){
					c1=maxLength;
					break;
				}
				dx1=cos*c1;
				dy1=sin*c1;
				sp.graphics.lineTo(x0+dx1,y0+dy1);
			}
		}
		
		/**
		 * 指定点列表画虚线
		 * @param	sp 线容器
		 * @param	points {type: Array | Vector} 元素类型为拥有x,y属性的任意对象
		 * @param	dash 一段线的长度
		 * @param	spacing 间隔
		 * @param	thickness 粗细
		 * @param	color 颜色
		 * @param	alpha 透明度
		 * @param	isCap 闭合
		 */
		public static function drawDashedWithPoints(sp:Sprite,points:*,dash:Number=6,spacing:Number=6,thickness:Number=NaN,color:uint=0,alpha:Number=1,isCap:Boolean=false):void{
			sp.graphics.lineStyle(thickness,color,alpha);
			const len:int=points.length;
			for(var i:int=0;i<len;i++){
				var nexti:int=(i+1)%len;
				
				var curPt:*=points[i];
				var nextPt:*=points[nexti];
				
				var a:Number=nextPt.y-curPt.y;
				var b:Number=nextPt.x-curPt.x;
				var maxLength:Number=Math.sqrt(a*a+b*b);
				var angleRadian:Number=Math.atan2(a,b);
				var cos:Number=Math.cos(angleRadian);
				var sin:Number=Math.sin(angleRadian);
				
				var c0:Number,c1:Number;
				var dx0:Number,dy0:Number;
				var dx1:Number,dy1:Number;
				for(var j:int=0;true;j++){
					c0=j*(dash+spacing);
					dx0=cos*c0;
					dy0=sin*c0;
					sp.graphics.moveTo(curPt.x+dx0,curPt.y+dy0);
					c1=c0+dash;
					if(c1>=maxLength){
						c1=maxLength;
						break;
					}
					dx1=cos*c1;
					dy1=sin*c1;
					sp.graphics.lineTo(curPt.x+dx1,curPt.y+dy1);
				}
				//不闭合
				if(!isCap&&nexti>=len-1){
					break;
				}
			}
		}
		
		/**
		 * 指定点列表画线
		 * @param	points {type: Array | Vector} 元素类型为拥有x,y属性的任意对象
		 * @param	graphics graphics
		 * @param	thickness 粗细
		 * @param	color 颜色
		 * @param	alpha 透明度
		 * @param	isCap 闭合
		 */
		public static function drawPoints(points:*,graphics:Graphics,thickness:Number=1,color:uint=0,alpha:Number=1,isCap:Boolean=false):void{
			graphics.lineStyle(thickness,color,alpha);
			for(var i:int=0;i<points.length;i++){
				if(i==0){
					graphics.moveTo(points[i].x,points[i].y);
				}else{
					graphics.lineTo(points[i].x,points[i].y);
					if(i>=points.length-1&&isCap){
						graphics.lineTo(points[0].x,points[0].y);
					}
				}
			}
		}
		
		/**
		 * 获取反射角(单位:弧度)
		 * @param	reInAng 反向入射角
		 * @param	normalAng 法线角
		 * @return
		 */
		public static function getReflectionAngleRadian(reInAng:Number,normalAng:Number):Number{
			var initReInDeg:Number=reInAng*Mathk.Rad2Deg;
			var reInDeg:Number=initReInDeg;
			if(reInDeg<0)reInDeg+=360;
			
			normalAng=normalAng*Mathk.Rad2Deg;
			if(normalAng<0)normalAng+=360;
			
			var rotateAng:Number=(normalAng-reInDeg)*2;
			var refAng:Number=initReInDeg+rotateAng;
			if(refAng>180)refAng-=360;
			else if(refAng<180)refAng+=360;
			
			return refAng*Mathk.Deg2Rad;
		}
		
		/**
		 * 获取秒转换为xx:xx的时钟形式字符
		 * @param	second 秒数
		 * @param	isHour 如果true那么转换为xx:xx:xx形式否则xx:xx形式
		 * @return
		 */
		public static function getClockString(second:Number,isHour:Boolean=false):String{
			var result:String;
			if(isHour){
				var hour:int=(second/60/60)|0;
				var minute:int=(second/60-hour*60)|0;
				var tempSecond:int=(second-hour*60*60-minute*60)|0;
				result=(hour<10?"0"+hour:hour)+":"+(minute<10?"0"+minute:minute)+":"+(tempSecond<10?"0"+tempSecond:tempSecond);
			}else{
				minute=(second/60)|0;
				tempSecond=(second-minute*60)|0;
				result=(minute<10?"0"+minute:minute)+":"+(tempSecond<10?"0"+tempSecond:tempSecond);
			}
			return result; 
		}
		
		/**
		 * 返回在time秒内每帧叠加运算能达到total的值
		 * @param	total 每帧执行加法运算达到的量
		 * @param	time 时间<秒>
		 * @param	frameRate 帧频
		 */
		public static function getEveryFrameValue(total:Number,time:Number,frameRate:int):Number{
			return total/time/frameRate;
		}
		
		/**返回显示对象的转换成位图的Sprite*/
		public static function getObjBmpSprite(disObj:DisplayObject):Sprite{
			var rect:Rectangle=disObj.getBounds(disObj);
			var bmd:BitmapData=FuncUtil.getBmdFromDisObj(disObj);
			var bmp:Bitmap=new Bitmap(bmd);
			bmp.x=rect.x;
			bmp.y=rect.y;
			
			var sp:Sprite=new Sprite();
			sp.x=disObj.x;
			sp.y=disObj.y;
			sp.addChild(bmp);
			return sp;
		}
		
		public static function getGotoPointV(x:Number,y:Number,ptx:Number,pty:Number,speed:Number):*{
			var dx:Number=ptx-x;
			var dy:Number=pty-y;
			var d:Number=Math.sqrt(dx*dx+dy*dy);
			var radian:Number=Math.atan2(dy,dx);
			var vx:Number,vy:Number;
			var isGoto:Boolean;
			if(d>speed){
				vx=Math.cos(radian)*speed;
				vy=Math.sin(radian)*speed;
				isGoto=false;
			}else{
				vx=Math.cos(radian)*d;
				vy=Math.sin(radian)*d;
				isGoto=true;
			}
			return {vx:vx,vy:vy,isGoto:isGoto};
		}
		
		/**返回两个点之间的距离*/
		public static function get2PointDistance(x1:Number,y1:Number,x2:Number,y2:Number):Number{
			var dx:Number=x2-x1;
			var dy:Number=y2-y1;
			return Math.sqrt(dx*dx+dy*dy);
		}
		
		/**细分列表中的点*/
		public static function subdivisionPoints(points:Vector.<Point>,subdivDistance:Number=10):Vector.<Point>{
			var result:Vector.<Point>=new Vector.<Point>();
			for(var i:int=0;i<points.length;i++){
				var nexti:int=(i+1)%points.length;
				var cur:Point=points[i];
				var next:Point=points[nexti];
				var dNext:Number=Point.distance(cur,next);
				if(dNext/subdivDistance<1.5){
					result.push(cur);
				}else{
					var segCount:int=(dNext/subdivDistance+0.5)|0;//四舍五入
					var dSplice:Number=dNext/segCount;//分割距离
					var angle:Number=Math.atan2(next.y-cur.y,next.x-cur.x);
					var ox:Number=Math.cos(angle)*dSplice;
					var oy:Number=Math.sin(angle)*dSplice;
					for(var j:int=0;j<segCount;j++){
						result.push(cur);
						cur=new Point(cur.x+ox,cur.y+oy);
					}
				}
				
			}
			return result;
		}
		
		public static function swapToParentContainer(obj:DisplayObject,parentContainer:DisplayObjectContainer):void{
			var objMatrix:Matrix=obj.transform.matrix;
			var nextParent:DisplayObjectContainer=obj.parent;
			while(nextParent){
				if(nextParent==parentContainer)break;
				objMatrix.concat(nextParent.transform.matrix);
				nextParent=nextParent.parent;
			}
			
			obj.transform.matrix=objMatrix;
			parentContainer.addChild(obj);
		}
		
		public static function swapToChildContainer(obj:DisplayObject,childContainer:DisplayObjectContainer):void{
			var parentList:Array=[];
			var nextParent:DisplayObjectContainer=childContainer;
			while(nextParent){
				if(nextParent==obj.parent)break;
				parentList.push(nextParent);
				nextParent=nextParent.parent;
			}
			
			var objMatrix:Matrix=obj.transform.matrix;
			while(parentList.length>0){
				var parent:DisplayObjectContainer=parentList.pop();
				var parentMatrix:Matrix=parent.transform.matrix;
				parentMatrix.invert();
				objMatrix.concat(parentMatrix);
			}
			
			obj.transform.matrix=objMatrix;
			childContainer.addChild(obj);
		}
		
		public function FuncUtil() {}
		
	}

}

