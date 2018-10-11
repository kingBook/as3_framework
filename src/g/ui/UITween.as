package g.ui{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import framework.objs.AlphaTo;
	//import framework.utils.TweenMax;
	/**
	 * ...
	 * @author kingBook
	 * 2015/11/9 11:15
	 */
	public class UITween{
		/**
		 * 0 淡入淡出
		 * 1 马赛克
		 */
		private static var _id:int=-1;
		public function UITween(){ }
		
		public static function create(main:Sprite,destroyFunc:Function=null,destroyFuncParams:Array=null,newFunc:Function=null,newFuncParams:Array=null,w:Number=800,h:Number=600):void{
			switch (_id){
				case -1:
					destroyFunc.apply(null,destroyFuncParams);
					newFunc.apply(null,newFuncParams);
					break;
				case 0:
					createFade(main,destroyFunc,destroyFuncParams,newFunc,newFuncParams,w,h);
					break;
				case 1:
					createMosaic(main,destroyFunc,destroyFuncParams,newFunc,newFuncParams,w,h);
					break;
				
				default:
			}
		}
		
		/**淡入淡出*/
		public static function createFade(main:Sprite,destroyFunc:Function=null,destroyFuncParams:Array=null,newFunc:Function=null,newFuncParams:Array=null,w:Number=800,h:Number=600):void{
			var bmp1:Bitmap=new Bitmap(getDisObjBmd(main,w,h));
			destroyFunc.apply(null,destroyFuncParams);
			newFunc.apply(null,newFuncParams);
			var bmp2:Bitmap=new Bitmap(getDisObjBmd(main,w,h));
			bmp2.alpha=0;
			var sp1:Sprite=new Sprite();
			sp1.addChild(bmp1);
			var sp2:Sprite=new Sprite();
			sp2.addChild(bmp2);
			
			var blackShape:Shape=new Shape();
			blackShape.graphics.beginFill(0x000000,1);
			blackShape.graphics.drawRect(0,0,w,h);
			blackShape.graphics.endFill();
			main.addChild(blackShape);
			main.addChild(sp1);
			main.addChild(sp2);
			
			var time:Number=0.3;
			
			AlphaTo.create(bmp1,1,0.2,time,function ():void{
				bmp1.bitmapData.dispose();
				if(bmp1.parent)bmp1.parent.removeChild(bmp1);
				if(sp1.parent)sp1.parent.removeChild(sp1);
			});
			
			AlphaTo.create(bmp2,0.2,1,time,function ():void{
				bmp2.bitmapData.dispose();
				if(bmp2.parent)bmp2.parent.removeChild(bmp2);
				if(sp2.parent)sp2.parent.removeChild(sp2);
				if(blackShape.parent)blackShape.parent.removeChild(blackShape);
			});
		}
		
		/**马赛克*/
		public static function createMosaic(main:Sprite,destroyFunc:Function=null,destroyFuncParams:Array=null,newFunc:Function=null,newFuncParams:Array=null,w:Number=800,h:Number=600):void{
			new Mosaic(main,destroyFunc,destroyFuncParams,newFunc,newFuncParams,w,h);
		}
		
		private static function getDisObjBmd(disObj:DisplayObject, w:Number=NaN, h:Number=NaN, tx:Number=NaN, ty:Number=NaN):BitmapData{
			if(isNaN(w)||isNaN(h)){
				var r:Rectangle = disObj.getBounds(disObj);
				w=r.width, h=r.height;
			}
			var bmd:BitmapData = new BitmapData(w,h,true,0);
			var matrix:Matrix = new Matrix();
			if(!isNaN(tx))matrix.tx=tx;else if(r)matrix.tx = -r.x;
			if(!isNaN(ty))matrix.ty=ty;else if(r)matrix.ty = -r.y;
			bmd.draw(disObj,matrix);
			return bmd;
		}
	};

}
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.events.Event;
import flash.geom.Matrix;
import flash.geom.Rectangle;

class Mosaic{
	private var _bmd1:BitmapData,_bmd2:BitmapData;
	private var _bmp1:Bitmap,_bmp2:Bitmap;
	private var _main:Sprite;
	public function Mosaic(main:Sprite,destroyFunc:Function=null,destroyFuncParams:Array=null,newFunc:Function=null,newFuncParams:Array=null,w:Number=800,h:Number=600){
		_main=main;
		_bmd1=getDisObjBmd(main,w,h);
		destroyFunc.apply(null,destroyFuncParams);
		newFunc.apply(null,newFuncParams);
		_bmd2=getDisObjBmd(main,w,h);
		main.addEventListener(Event.ENTER_FRAME,enterFrame);
		
	}
	
	private var _max:int=10;
	private var _count:int=1;
	private var _sign:int=1;
	private var _speed:int=1;
	private var _count2:int=_max;
	private function enterFrame(e:Event):void{
		_count+=_sign*_speed;
		if(_sign>0){
			if(_bmp1){
				if(_bmp1.bitmapData)_bmp1.bitmapData.dispose();
				if(_bmp1.parent)_bmp1.parent.removeChild(_bmp1);
			}
			if(_count<_max){
				_bmp1=mosaic(_bmd1,_count*4,_count);
				//_bmp1.alpha=1-_count/_max;if(_bmp1.alpha<=0.2)_bmp1.alpha=0;
				_main.addChild(_bmp1);
			}else{
				_sign=-1;
			}
		}else{
			if(_bmp2){
				if(_bmp2.bitmapData)_bmp2.bitmapData.dispose();
				if(_bmp2.parent)_bmp2.parent.removeChild(_bmp2);
			}
			if(_count>1){
				_bmp2=mosaic(_bmd2,_count*4,_count);
				//_bmp2.alpha=_count/_max;if(_bmp2.alpha<=0.2)_bmp2.alpha=0;
				_main.addChild(_bmp2);
			}else{
				dispose();
			}
		}
	}
	
	private function mosaic(sourceBmd:BitmapData,sizeX:Number,sizeY:Number):Bitmap{
		var scaleBmd:BitmapData=new BitmapData(sourceBmd.width/sizeX,sourceBmd.height/sizeY,false);
		var scaleMatrix:Matrix=new Matrix();scaleMatrix.scale(1/sizeX,1/sizeY);
		scaleBmd.draw(sourceBmd,scaleMatrix);
		
		var bmp:Bitmap=new Bitmap(scaleBmd);
		bmp.width=sourceBmd.width;
		bmp.height=sourceBmd.height;
		return bmp;
	}
	
	private static function getDisObjBmd(disObj:DisplayObject, w:Number=NaN, h:Number=NaN, tx:Number=NaN, ty:Number=NaN):BitmapData{
		if(isNaN(w)||isNaN(h)){
			var r:Rectangle = disObj.getBounds(disObj);
			w=r.width, h=r.height;
		}
		var bmd:BitmapData = new BitmapData(w,h,true,0);
		var matrix:Matrix = new Matrix();
		if(!isNaN(tx))matrix.tx=tx;else if(r)matrix.tx = -r.x;
		if(!isNaN(ty))matrix.ty=ty;else if(r)matrix.ty = -r.y;
		bmd.draw(disObj,matrix);
		return bmd;
	}
	
	private function dispose():void{
		_main.removeEventListener(Event.ENTER_FRAME,enterFrame);
		
		_bmd1.dispose();
		_bmd2.dispose();
		if(_bmp1){
			if(_bmp1.bitmapData)_bmp1.bitmapData.dispose();
			if(_bmp1.parent)_bmp1.parent.removeChild(_bmp1);
			_bmp1=null;
		}
		if(_bmp2){
			if(_bmp2.bitmapData)_bmp2.bitmapData.dispose();
			if(_bmp2.parent)_bmp2.parent.removeChild(_bmp2);
			_bmp2=null;
		}
		_bmd1=null;
		_bmd2=null;
	}
	
}