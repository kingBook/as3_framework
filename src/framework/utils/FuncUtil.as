package framework.utils {
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.FrameLabel;
	import flash.display.MovieClip;
	import flash.display.Sprite;
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
		
		/**全局坐标*/
		public static function globalXY(disObj:DisplayObject, localPt:Point = null,out:Point=null):Point {
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
				out.x+=localX;
				out.y+=localY;
			}
			var parentObj:DisplayObjectContainer=disObj.parent;
			while(parentObj){
				out.x*=parentObj.scaleX;
				out.y*=parentObj.scaleY;
				out.x+=parentObj.x;
				out.y+=parentObj.y;
				parentObj=parentObj.parent;
			}
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
			for(var i:int;true;i++){
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
		
		public function FuncUtil() {}
		
	}

}

