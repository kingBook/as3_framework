package g{
	import g.objs.MyObj;
	import framework.game.Game;
	import framework.objs.GameObject;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Stage;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.utils.Dictionary;
	public class ResizeManager extends MyObj{
		public var curWidth:Number;
		public var curHeight:Number;
		public var curRatio:Number;
		public var curScale:Number;
		public var curWScale:Number;
		public var curHScale:Number;
		public var curMaxScale:Number;
		public var curMinScale:Number;
		public var sWidth:Number;
		public var sHeight:Number;
		public var sRatio:Number;
		private var _stage:Stage;
		public var centerPt:Point;
		public var topLeft:Point;
		public var topCenter:Point;
		public var topRight:Point;
		public var leftMiddle:Point;
		public var rightMiddle:Point;
		public var bottomLeft:Point;
		public var bottomCenter:Point;
		public var bottomRight:Point;
		private var _listeneners:Array
		private var _nativePositions:Dictionary;
		private var _nativeScales:Dictionary;
		public function ResizeManager(){
			super();
		}
		public static function create(stage:Stage,sw:Number=800,sh:Number=600):ResizeManager{
			var game:Game=Game.getInstance();
			var info:*={};
			info.stage=stage;
			info.sw=sw;
			info.sh=sh;
			return game.createGameObj(new ResizeManager(),info) as ResizeManager;
		}
		override protected function init(info:* = null):void{
			super.init(info);
			//destroyAll时不销毁
			GameObject.dontDestroyOnDestroyAll(this);
			
			_listeneners = [];
			_nativePositions=new Dictionary();
			_nativeScales=new Dictionary();
			_stage = info.stage;
			_stage.scaleMode = StageScaleMode.NO_SCALE;
			_stage.align = StageAlign.TOP_LEFT;
			_stage.addEventListener(Event.RESIZE, resizeHandler);
			sWidth = info.sw;
			sHeight = info.sh;
			sRatio = sWidth / sHeight;
			curWidth = _stage.stageWidth;
			curHeight = _stage.stageHeight;
			curRatio = curWidth / curHeight;
			curWScale = curWidth / sWidth;
			curHScale = curHeight / sHeight;
			curScale = Math.min(curWScale, curHScale);
			curMaxScale = Math.max(curWScale, curHScale);
			curMinScale = curScale;
			centerPt = new Point(sWidth / 2, sHeight / 2);
			topLeft = new Point(0, 0);
			topCenter = new Point(sWidth / 2, 0);
			topRight = new Point(sWidth, 0);
			leftMiddle = new Point(0, sHeight / 2);
			rightMiddle = new Point(sWidth, sHeight / 2);
			bottomLeft = new Point(0, sHeight);
			bottomCenter = new Point(sWidth / 2, sHeight);
			bottomRight = new Point(sWidth, sHeight);
		}
		public function addListener(func:Function, scope:* = null):void {
			for each(var o:Object in _listeneners)
			{
				if (o.func == func && o.scope == scope)
				{
					return;
				}
			}
			_listeneners.push( { func:func, scope:scope } );
		}
		public function removeListener(func:Function, scope:*= null):void
		{
			var len:int = _listeneners.length;
			for (var i:int = 0; i < len; i ++)
			{
				var o:Object = _listeneners[i];
				if (o.func == func && o.scope == scope)
				{
					_listeneners.splice(i, 1);
					return;
				}
			}
		}
		private function resizeHandler(e:Event = null):void {
			curWidth = _stage.stageWidth;
			curHeight = _stage.stageHeight;
			curRatio = curWidth / curHeight;
			curWScale = curWidth / sWidth;
			curHScale = curHeight / sHeight;
			curScale = Math.min(curWScale, curHScale);
			curMaxScale = Math.max(curWScale, curHScale);
			curMinScale = curScale;
			for each(var o:Object in _listeneners)
			{
				o.func.apply(o.scope, []);
			}
		}
		public function resizeByPt(obj:DisplayObject, pt:Point, factor:Number = 1):void
		{
			var ix:Number = obj.x;
			var sObj:DisplayObject = obj;
			var xo:Number = 0;
			var yo:Number = 0;
			while (sObj.parent != sObj.root)
			{
				sObj = sObj.parent;
				xo += sObj.x;
				yo += sObj.y;
			}
			
			obj.scaleX = curScale * factor;
			obj.scaleY = curScale * factor;
			
			
			obj.x = pt.x * curWScale - (pt.x - obj.x - xo) * curScale - xo;
			obj.y = pt.y * curHScale - (pt.y - obj.y - yo) * curScale - yo;
		}
		public function resizeSelf(factor:Number, ...objs):void
		{
			for each(var obj:DisplayObject in objs)
			{
				if(!obj)continue;
				var pt:Point = new Point(obj.x, obj.y);
				var sObj:DisplayObject = obj;
				while (sObj.parent != sObj.root)
				{
					sObj = sObj.parent;
					pt.x += sObj.x;
					pt.y += sObj.y;
				}
				resizeByPt(obj, pt, factor);
			}
		}
		public function addByNativePos(...objs):void{
			for each(var obj:DisplayObject in objs){
				if(!obj)continue;
				var scale:Point=_nativeScales[obj];
				if(!scale){
					scale=new Point(obj.scaleX,obj.scaleY);
					_nativeScales[obj]=scale;
				}
				obj.scaleX=scale.x*curScale;
				obj.scaleY=scale.y*curScale;
				
				var pt:Point=_nativePositions[obj];
				if(!pt){
					pt=new Point(obj.x,obj.y);
					_nativePositions[obj]=pt;
				}
				obj.x = pt.x * curWScale;
				obj.y = pt.y * curHScale;
			}
		}
		public function removeByNativePos(...objs):void{
			for each(var obj:DisplayObject in objs){
				delete _nativePositions[obj];
				delete _nativeScales[obj];
			}
		}
		
		public function addContainerByNativePos(c:DisplayObjectContainer,...filterObjs):void{
			for(var i:int=0;i<c.numChildren;i++){
				var child:DisplayObject=c.getChildAt(i);
				if(filterObjs.indexOf(child)>-1)continue;
				addByNativePos(child);
			}
		}
		public function removeContainerByNativePos(c:DisplayObjectContainer):void{
			for(var i:int=0;i<c.numChildren;i++){
				var child:DisplayObject=c.getChildAt(i);
				removeByNativePos(child);
			}
		}

		public function resizeBg_middle(obj:DisplayObject):void{
			obj.scaleX = obj.scaleY = curMaxScale;
			obj.x = curWidth / 2;
			obj.y = curHeight / 2;
		}
		
		public function resizeBg_topLeft(obj:DisplayObject):void{
			obj.scaleX = obj.scaleY = curMaxScale;
			var targetCenterX:Number=curWidth/2;
			var targetCenterY:Number=curHeight/2;
			var curCenterX:Number=sWidth/2*curMaxScale;
			var curCenterY:Number=sHeight/2*curMaxScale;
			var ox:Number=targetCenterX-curCenterX;
			var oy:Number=targetCenterY-curCenterY;
			
			var nativePos:Point=_nativePositions[obj];
			if(!nativePos){
				nativePos=new Point(obj.x,obj.y);
				_nativePositions[obj]=nativePos;
			}
			obj.x=nativePos.x+ox;
			obj.y=nativePos.y+oy;
			
		}
		
		public function getPosition(cors:DisplayObjectContainer, pt:Point, relativePt:Point = null):Point
		{
			var rtn:Point = new Point;
			var xo:Number = 0;
			var yo:Number = 0;
			while (cors != cors.root)
			{
				xo += cors.x;
				yo += cors.y;
				cors = cors.parent;
			}
			if (relativePt == null)
			{
				rtn.x = (pt.x + xo) * curWScale - xo;
				rtn.y = (pt.y + yo) * curHScale - yo;
			}
			else
			{
				rtn.x = relativePt.x * curWScale - (relativePt.x - pt.x - xo) * curScale - xo;
				rtn.y = relativePt.y * curHScale - (relativePt.y - pt.y - yo) * curScale - yo;
			}
			return rtn;
		}
		public function lockAt(obj:DisplayObject, pt:Point, factor:Number):void
		{
			
		}
		override protected function onDestroyAll():void{
			_listeneners.splice(0);
			clearDict(_nativePositions);
			clearDict(_nativeScales);
			super.onDestroyAll();
		}
		private function clearDict(dict:Dictionary):void{
			for(var k:* in dict) delete dict[k];
		}
		override protected function onDestroy():void{
			_stage.removeEventListener(Event.RESIZE, resizeHandler);
			_stage=null;
			centerPt=null;
			topLeft=null;
			topCenter=null;
			topRight=null;
			leftMiddle=null;
			rightMiddle=null;
			bottomLeft=null;
			bottomCenter=null;
			bottomRight=null;
			_listeneners=null
			_nativePositions=null;
			_nativeScales=null;
			super.onDestroy();
		}
	};

}