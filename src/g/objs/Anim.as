package g.objs{
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.utils.Dictionary;
	import framework.utils.FuncUtil;
	import framework.utils.LibUtil;
	import g.objs.MyObj;
	
	public class Anim extends MyObj{
		
		private var _isPlayed:Boolean;
		private var _runtimeDict:Dictionary;
		private var _lastFrame:int;
		protected var _mc:MovieClip;
		protected var _isStop:Boolean;
		protected var _isMouseDown:Boolean;
		
		public function Anim(){
			super();
		}
		
		override protected function init(info:*=null):void{
			super.init(info);
			
			var parent:Sprite=_game.global.layerMan.items3Layer;
			_mc=LibUtil.getDefMovie(info.defName);
			parent.addChild(_mc);
			
			onStageResize();
			_game.global.stage.addEventListener(Event.RESIZE,onStageResize);
			
			_runtimeDict=new Dictionary();
			_mc.addEventListener(MouseEvent.CLICK,clickHandler);
			_game.global.stage.addEventListener(MouseEvent.MOUSE_DOWN,mouseHandler);
			_game.global.stage.addEventListener(MouseEvent.MOUSE_UP,mouseHandler);
		}
		
		private function onStageResize(e:Event=null):void{
			_myGame.myGlobal.resizeMan.resizeBg_topLeft(_mc);
		}
		
		override protected function update():void{
			super.update();
			if(_mc.currentFrame>=_mc.totalFrames){
				onPlayComplete_private();
			}else{
				var isStopAtFrame:Boolean;
				for(var k:* in _runtimeDict){
					if(_mc.currentFrame==k){
						isStopAtFrame=true;
						break;
					}
				}
				//
				if(!isStopAtFrame&&!_isStop){
					_mc.nextFrame();
				}
				if(_mc.currentFrame!=_lastFrame){
					for(k in _runtimeDict){
						if(_mc.currentFrame==k){
							if(_runtimeDict[k].onFrameFunc)_runtimeDict[k].onFrameFunc();
							//没有设置targetName时，只停止就删除key
							if(!_runtimeDict[k].targetName)delete _runtimeDict[k];
							else delete _runtimeDict[k].onFrameFunc;
							break;
						}
					}
				}
				_lastFrame=_mc.currentFrame;
			}
		}
		
		/**
		 * 添加在指定的停止帧上的处理函数
		 * @param	atFrame 停止的帧
		 * @param	targetName 点击的目标名称
		 * @param	onFrameFunc 停止在指定帧时的处理函数
		 * @param	onClickFunc 点击目标时的处理函数
		 */
		final protected function addFrameClickFunc(atFrame:int,targetName:String=null,skipToFrame:int=0,onFrameFunc:Function=null,onClickFunc:Function=null):void{
			var o:*={};
			o.targetName=targetName;
			o.skipToFrame=skipToFrame;
			o.onFrameFunc=onFrameFunc;
			o.onClickFunc=onClickFunc;
			_runtimeDict[atFrame]=o;
		}
		
		private function clickHandler(e:MouseEvent):void{
			var targetName:String=e.target.name;
			var key:int=_mc.currentFrame;
			var data:*=_runtimeDict[key];
			if(data&&data.targetName){
				if(targetName==data.targetName){
					if(data.onClickFunc)data.onClickFunc();
					if(data.skipToFrame>0)_mc.gotoAndStop(data.skipToFrame);
					delete _runtimeDict[key];
				}
			}
		}
		
		private function onPlayComplete_private():void{
			if(_isPlayed)return;
			_isPlayed=true;
			onPlayComplete();
		}
		protected function onPlayComplete():void{
			
		}		
		
		protected function mouseHandler(e:MouseEvent):void{
			_isMouseDown=e.type==MouseEvent.MOUSE_DOWN;
		}
		
		protected function cancelStop():void{
			_isStop=false;
		}
		
		override protected function onDestroy():void{
			unschedule(cancelStop);
			_game.global.stage.removeEventListener(MouseEvent.MOUSE_DOWN,mouseHandler);
			_game.global.stage.removeEventListener(MouseEvent.MOUSE_UP,mouseHandler);
			_myGame.myGlobal.resizeMan.removeByNativePos(_mc);
			_game.global.stage.removeEventListener(Event.RESIZE,onStageResize);
			if(_mc){
				_mc.removeEventListener(MouseEvent.CLICK,clickHandler);
				FuncUtil.removeChild(_mc);
				_mc=null;
			}
			_runtimeDict=null;
			super.onDestroy();
		}
		
	};

}