package framework.objs{
	import flash.display.BitmapData;
	import flash.geom.Matrix;
	import framework.events.FrameworkEvent;
	import framework.game.Game;
	import framework.system.ObjectPool;
	import framework.game.UpdateType;
	import framework.utils.LibUtil;
	import framework.namespaces.frameworkInternal;
	import flash.geom.Transform;
	import flash.display.Bitmap;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.events.Event;
	use namespace frameworkInternal;
	
	public class Clip extends Sprite{
		private var _renderedIndex:int;
		private var _curIndex:int;
		private var _maxIndex:int = -1;
		private var _infoList:Vector.<FrameInfo>;
		private var _isPlaying:Boolean;
		private var _addToPool:Boolean;
		private var _game:Game = Game.getInstance();
		/**表示是否在切换父容器，防止切换容器触发REMOVE_FROM_STATE事件执行销毁*/
		private var _isSwapParenting:Boolean;
		/**决定这个影片的播放暂停是否受到控制，true:暂停恢复游戏时执行stop()/play(), addToStage时不播放,------在添加到舞台前进行设置*/
		public var controlled:Boolean;
		/**决定播放至最后一帧是否发出完成事件*/
		public var isDispatchComplete:Boolean; 
		/**从舞台移除时是否执行destroy方法*/
		public var removeIsDestroy:Boolean;
		/**从舞台移除时是否执行stop方法*/
		public var removeIsStop:Boolean=true;
		public var customName:String;
		private var _bitmap:Bitmap;
		
		public static function fromTranstormDisplayObject(disObj:flash.display.DisplayObject,poolKey:String = null,removeIsDestroy:Boolean=true, parent:DisplayObjectContainer = null, controlled:Boolean=false,isApplyFilters:Boolean=true):Clip{
			var matrix_old:Matrix=disObj.transform.matrix.clone();
			disObj.transform.matrix=new Matrix();
			var clip:Clip=Clip.fromDisplayObject(disObj,poolKey,removeIsDestroy,parent,controlled,isApplyFilters);
			clip.transform.matrix=disObj.transform.matrix=matrix_old;
			return clip;
		}
		
		/**返回一个clip，名称、坐标、位置、滤镜与disObj相同*/
		public static function fromDisplayObject(disObj:flash.display.DisplayObject,poolKey:String = null,removeIsDestroy:Boolean=true, parent:DisplayObjectContainer = null, controlled:Boolean=false,isApplyFilters:Boolean=true):Clip{
			var pool:ObjectPool=Game.getInstance().global.objectPool;
			var infoList:Vector.<FrameInfo>;
			if (poolKey&&pool.has(poolKey)){
				infoList = pool.get(poolKey) as Vector.<FrameInfo>;
				if (infoList == null) throw new Error("对象池中存在: "+poolKey+" 但不是 Vector.<FrameInfo> 类型");
			}else{
				infoList = Cacher.cacheDisObj(disObj, poolKey);
			}
			var clip:Clip=new Clip(infoList, Boolean(poolKey), removeIsDestroy, parent, disObj.x, disObj.y, disObj.name,controlled);
			if(isApplyFilters){
				clip.filters=disObj.filters;
			}
			return clip;
		}
		
		/**以defName从库中获取定义生成实例转化为clip,再返回clip对象*/
		public static function fromDefName(defName:String, addToPool:Boolean = false, removeIsDestroy:Boolean=true, parent:DisplayObjectContainer=null, x:Number=0, y:Number=0,controlled:Boolean=false):Clip{
			var key:String = defName + "_frameInfoList";
			var pool:ObjectPool=Game.getInstance().global.objectPool;
			var infoList:Vector.<FrameInfo>;
			if (addToPool && pool.has(key)){
				infoList = pool.get(key) as Vector.<FrameInfo>;
				if (infoList == null) throw new Error("对象池中存在: "+key+" 但不是 Vector.<FrameInfo> 类型");
			}else{
				infoList = Cacher.cacheDefName(defName, addToPool);
				if (addToPool) pool.add(infoList, key);
			}
			return new Clip(infoList,addToPool,removeIsDestroy, parent, x, y, null,controlled);
		}
		
		public static function fromBitmapData(bitmapData:BitmapData,poolKey:String = null,removeIsDestroy:Boolean=true, parent:DisplayObjectContainer = null, x:Number=0, y:Number=0, customName:String=null, controlled:Boolean=false):Clip{
			var pool:ObjectPool=Game.getInstance().global.objectPool;
			var infoList:Vector.<FrameInfo>;
			if (poolKey&&pool.has(poolKey)){
				infoList=pool.get(poolKey) as Vector.<FrameInfo>;
				if (infoList==null) throw new Error("对象池中存在: "+poolKey+" 但不是 Vector.<FrameInfo> 类型");
			}else{
				infoList=new Vector.<FrameInfo>();
				infoList[0]=new FrameInfo(bitmapData,0,0,1);
			}
			var clip:Clip=new Clip(infoList, Boolean(poolKey), removeIsDestroy, parent, x, y, customName,controlled);
			return clip;
		}
		
		
		public function Clip(infoList:Vector.<FrameInfo>, addToPool:Boolean=false, removeIsDestroy:Boolean=true, parent:DisplayObjectContainer=null, x:Number=0, y:Number=0, customName:String=null,controlled:Boolean=false){
			super();
			this.x = x;
			this.y = y;
			this.customName = customName?customName:this.customName;
			_addToPool = addToPool;
			this.removeIsDestroy = removeIsDestroy;
			alpha = 1;
			rotation = 0;
			visible = true;
			scaleX = scaleY = 1;
			this.controlled=controlled;
			_bitmap = new Bitmap(null,"auto",true);
			addChild(_bitmap);
			
			_curIndex = 0;
			_maxIndex = -1;
			
			_isPlaying = true;
			setInfoList(infoList);
			addEventListener(Event.ADDED_TO_STAGE, addOrRemoveStage);
			addEventListener(Event.REMOVED_FROM_STAGE, addOrRemoveStage);
			_game.addEventListener(FrameworkEvent.PAUSE, pauseResumeHandler);
			_game.addEventListener(FrameworkEvent.RESUME, pauseResumeHandler);
			
			parent && parent.addChild(this);
		}
		
		private function pauseResumeHandler(e:FrameworkEvent):void{
			controlled || (_game.pause ? stop() : play());
		}
		
		private function addOrRemoveStage(e:Event):void{
			if (e.type == Event.ADDED_TO_STAGE){
				if(_isSwapParenting){
					_isSwapParenting=false;
				}else{
					_isPlaying = !controlled;
					if(_maxIndex == 0) gotoFrame(_curIndex);//只有一帧时
					else (_maxIndex > -1) && (_isPlaying ? updatePlayStatus() : gotoFrame(_curIndex));
				}
			}else{
				if(!_isSwapParenting){
					removeIsStop && stop();
					removeIsDestroy && destroy();
				}
			}
		}
		
		/**切换父容器，请一定使用这个方法切换父容器，否则会触发REMOVE_FROM_STATE事件销毁自身*/
		public function swapParent(parent:DisplayObjectContainer):void{
			_isSwapParenting=true;
			parent.addChild(this);
		}
		
		public function play():void{
			_isPlaying = true;
			updatePlayStatus();
		}
		
		public function stop():void{
			_isPlaying = false;
			updatePlayStatus();
		}
		
		private function updatePlayStatus():void{
			if (_isPlaying && _maxIndex > -1 && stage){
				_game.addUpdate(UpdateType.FOREVER,enterFrame);
			} else{
				_game.removeUpdate(UpdateType.FOREVER,enterFrame);
			}
		}
		
		public function nextFrame():void{
			var frame:int=currentFrame+1>totalFrames?1:currentFrame+1;
			gotoAndStop(frame);
		}
		
		/**跳至下一帧并停止，如果到达总帧数回到第一帧*/
		private function nextFrame_internal():void{
			gotoFrame(_curIndex);
			var funcName:String = "frame" + _curIndex + "Func";
			if (_funObj && _funObj[funcName]){
				_funObj[funcName]();
			}
			//发送播放完成事件
			_curIndex == _maxIndex && isDispatchComplete && dispatchEvent(new Event(Event.COMPLETE));
			(++_curIndex > _maxIndex) && (_curIndex = 0);
		}
		
		/**跳转到指定帧并播放*/
		public function gotoAndPlay(frameIndex:int):void{
			gotoFrame(frameIndex - 1);
			play();
		}
		
		/**跳转到指定帧并停止*/
		public function gotoAndStop(frameIndex:int):void{
			gotoFrame(frameIndex - 1);
			stop();
		}
		
		private function enterFrame():void{
			nextFrame_internal();
		}
		
		/** 跳转到指定索引的帧*/
		private function gotoFrame(frameIndex:int):void{
			_curIndex = frameIndex > _maxIndex ? _maxIndex : (frameIndex < 0 ? 0 : frameIndex);
			var f_info:FrameInfo = _infoList[_curIndex];
			var isChange:Boolean=_bitmap.bitmapData!=f_info.bitmapData;
			if(isChange){
				_bitmap.bitmapData = f_info.bitmapData;
				_bitmap.x = f_info.x;
				_bitmap.y = f_info.y;
				_bitmap.alpha = f_info.alpha;
			}
			_renderedIndex=_curIndex;//记录渲染完成的id，function get currentFrame();方法返回
		}
		
		private var _funObj:*;
		public function addFrameScript(frameNo:uint, func:Function):void{
			if (func == null) return;
			_funObj ||={ };
			_funObj["frame" + frameNo + "Func"] = func;
		}
		
		public function destroy():void{
			//
			if (!_addToPool && _infoList){
				var frameInfo:FrameInfo;
				var i:int=_infoList.length;
				while(--i>=0){
					frameInfo=_infoList[i];
					if (frameInfo.bitmapData)frameInfo.bitmapData.dispose();
				}
			}
			//
			_game.removeEventListener(FrameworkEvent.PAUSE, pauseResumeHandler);
			_game.removeEventListener(FrameworkEvent.RESUME, pauseResumeHandler);
			removeEventListener(Event.ADDED_TO_STAGE, addOrRemoveStage);
			removeEventListener(Event.REMOVED_FROM_STAGE, addOrRemoveStage);
			if (_bitmap){
				_bitmap.parent && _bitmap.parent.removeChild(_bitmap);
				_bitmap = null;
			}
			_funObj = null;
			_infoList = null;
			_game = null;
		}
		
		//======================================================
		//---------------- seter geter -------------------------
		private function setInfoList(value:Vector.<FrameInfo>):void{
			if(!value)return;
			_infoList = value;
			_maxIndex = _infoList.length - 1;
			if (_maxIndex > -1) gotoFrame(0);
		}
		public function get smoothing():Boolean{ return _bitmap.smoothing; }
		public function set smoothing(value:Boolean):void{ _bitmap.smoothing=value; }
		public function get isPlaying():Boolean{ return _isPlaying; }
		public function get currentFrame():int{ return _renderedIndex+1; }
		public function get totalFrames():int{ return _infoList ? _infoList.length : 0; }
		
		

	};

}
import flash.display.BitmapData;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.geom.Rectangle;
import framework.game.Game;
import framework.system.ObjectPool;
import framework.utils.LibUtil;
import flash.display.MovieClip;

class Cacher{
	static private const _pt:Point = new Point(0, 0);
	static private function cacheSingle(source:flash.display.DisplayObject, poolKey:String = null, transparent:Boolean = true, fillColor:uint = 0x00000000, scale:Number = 1):FrameInfo{
		var pool:ObjectPool=Game.getInstance().global.objectPool;
		var frameInfo:FrameInfo;
		if (poolKey && pool.has(poolKey)){
			frameInfo = pool.get(poolKey) as FrameInfo;
			if (frameInfo == null) throw new Error("对象池中存在: "+poolKey+" 但不是 FrameInfo 类型");
		}else{
			var matrix:Matrix = source.transform.matrix.clone();
			var w:uint, h:uint, x:int, y:int, rect:Rectangle;
			if (source.parent){
				rect = source.getBounds(source.parent);
				matrix.a *= scale;
				matrix.d *= scale;
				matrix.tx = int((matrix.tx - rect.x) * scale + 0.5);
				matrix.ty = int((matrix.ty - rect.y) * scale + 0.5);
			}else{
				rect = source.getBounds(null);
				matrix.a = scale;
				matrix.d = scale;
				matrix.tx = -int(rect.x * scale + 0.5);
				matrix.ty = -int(rect.y * scale + 0.5);
			} 
			//w, h 取上限
			w = uint(rect.width * scale + 0.9);
			h = uint(rect.height * scale + 0.9);
			//x,y 取source的局部坐标
			x = -matrix.tx;
			y = -matrix.ty;
			
			var bitData:BitmapData = new BitmapData(w < 1 ? 1 : w, h < 1 ? 1 : h , transparent, fillColor);
			bitData.draw(source, matrix, null, null, null, true);
			/*
			//剔除边缘空白像素
			var realRect:Rectangle = bitData.getColorBoundsRect(0xFF000000, 0x00000000, false);
			if (!realRect.isEmpty() && (bitData.width != realRect.width || bitData.height != realRect.height)){
				var realBitData:BitmapData = new BitmapData(realRect.width, realRect.height, transparent, fillColor);
				realBitData.copyPixels(bitData, realRect, _pt);
				bitData.dispose();
				bitData = realBitData;
				x += realRect.x;
				y += realRect.y;
			}
			*/
			
			frameInfo = new FrameInfo(bitData, x, y, source.alpha);
			if (poolKey) pool.add(frameInfo, poolKey);
		}
		return frameInfo;
	}
	
	static public function cacheDisObj(source:flash.display.DisplayObject, poolKey:String=null, transparent:Boolean = true, fillColor:uint = 0x00000000, scale:Number = 1):Vector.<FrameInfo>{
		var v_bitInfo:Vector.<FrameInfo>;
		if(source is flash.display.MovieClip){
			var mc:flash.display.MovieClip=MovieClip(source);
			var i:int = 0;
			var c:int = mc.totalFrames;
			mc.gotoAndStop(1);
			v_bitInfo = new Vector.<FrameInfo>(c, true);
			var frameNoKey:String;
			while (i < c){
				frameNoKey = poolKey ? poolKey + "_frameNo_" + i : null;
				v_bitInfo[i] = cacheSingle(mc, frameNoKey, transparent, fillColor, scale);
				mc.nextFrame();
				i++;
			}
		}else{
			v_bitInfo = new Vector.<FrameInfo>(1, true);
			v_bitInfo[0] = cacheSingle(source, poolKey, transparent, fillColor, scale);
		}
		return v_bitInfo;
	}
	
	static public function cacheDefName(defName:String, addToPool:Boolean = false, transparent:Boolean = true, fillColor:uint = 0x00000000, scale:Number = 1):Vector.<FrameInfo>{
		var disObj:flash.display.DisplayObject = LibUtil.getDefDisObj(defName);
		var infoList:Vector.<FrameInfo>;
		if(disObj) infoList= cacheDisObj(disObj);
		return infoList;
	}
};



class FrameInfo{
	public var x:Number;
	public var y:Number;
	public var alpha:Number;
	public var bitmapData:BitmapData;

	public function FrameInfo(bitmapData:BitmapData, x:Number = 0, y:Number = 0, alpha:Number = 0){
		this.bitmapData = bitmapData;
		this.x = x;
		this.y = y;
		this.alpha = alpha;
	}
};