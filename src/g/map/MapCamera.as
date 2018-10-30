package g.map{
	import Box2D.Dynamics.b2Body;
	import flash.display.DisplayObject;
	import flash.events.EventDispatcher;
	import flash.geom.Point;
	import flash.utils.setInterval;
	import flash.utils.clearInterval;
	import framework.game.Game;
	import framework.utils.FuncUtil;
	import g.MyData;
	import g.events.MyEvent;
	import g.objs.MyObj;
	
	/*地图的相机*/
	public class MapCamera extends MyObj{
		public static const MOVE:String="move";
		public static const MOVE_COMPLETE:String="moveComplete";//每次vx、vy都为0则派发
		public const NONE:uint=0;
		public const POSITION_MODE:uint=1;
		public const TARGET_MODE:uint=2;
		public const CUSTOM_MOVE_MODE:uint=3;
		
		private var _easing:Number=0.2;
		private var _min:Point;
		private var _max:Point;
		private var _bindMode:uint=NONE;
		private var _position:Point;
		private var _targetPos:Point;
		private var _cameraTarget:DisplayObject;
		private var _bindTargets:Array;
		private var _bindTargetsCenter:Point;
		private var _moveEvent:MyEvent;
		private var _moveCompleteEvent:MyEvent;
		
		private var _shakeCount:int;
		private var _shakeMaxDistance:Number;
		private var _isShakeing:Boolean;
		private var _curShakeId:uint;
		private var _shakeTargetInitPos:Point=new Point();
		private var _cameraTargetInitPos:Point;
		private var _isAllowScorll:Boolean=true;
		private var _isAllowBackward:Boolean=true;
		
		private var _focus:Point;
		private var _mapSize:Point;
		
		public function MapCamera(){ super(); }
		
		/**
		 * 创建一个MapCamera
		 * @param	mapWidth 
		 * @param	mapHeight 
		 * @param	cameraTarget 要滚动的显示对象
		 * @param	focusX 0.01~0.99
		 * @param	focusY 0.01~0.99
		 * @return
		 */
		public static function create(mapWidth:Number,mapHeight:Number,cameraTarget:DisplayObject,focusX:Number=0.5,focusY:Number=0.5):MapCamera{
			var game:Game=Game.getInstance();
			var info:*={};
			info.mapWidth=mapWidth;
			info.mapHeight=mapHeight;
			info.cameraTarget=cameraTarget;
			info.focusX=focusX;
			info.focusY=focusY;
			return game.createGameObj(new MapCamera(),info) as MapCamera;
		}
		
		override protected function init(info:* = null):void{
			super.init(info);
			_cameraTarget=info.cameraTarget;
			_cameraTargetInitPos=new Point(_cameraTarget.x,_cameraTarget.y);
			_mapSize=new Point(info.mapWidth,info.mapHeight);
			setFocus(info.focusX,info.focusY);
		}
		
		/**
		 * 设置聚焦点
		 * @param	x 0.01~0.99
		 * @param	y 0.01~0.99
		 */
		public function setFocus(x:Number=0.5,y:Number=0.5):void{
			x=Math.min(Math.max(x,0.01),0.99);
			y=Math.min(Math.max(y,0.01),0.99);
			_focus||=new Point();
			_focus.setTo(x,y);
			
			var stageW:int=_game.global.stage.stageWidth;
			var stageH:int=_game.global.stage.stageHeight;
			
			_min||=new Point();
			_min.setTo(stageW*_focus.x,stageH*_focus.y);
			_min=FuncUtil.localXY_2(_min,_cameraTarget);
			_min.setTo(int(_min.x+0.9),int(_min.y+0.9));
			
			var fpt:Point=new Point(stageW*(1-_focus.x),stageH*(1-_focus.y));
			fpt=FuncUtil.localXY_2(fpt,_cameraTarget);
			_max||=new Point();
			_max.setTo(_mapSize.x-fpt.x, _mapSize.y-fpt.y);
			_max.setTo(int(_max.x),int(_max.y));
			
			_position||=new Point();
			_position.setTo(_min.x,_min.y);
		}
		
		/**绑定相机到一个位置上，位置可以每一帧改变, isRightNow:表示立即到这个位置不执行缓动*/
		public function bindPos(x:Number,y:Number,easing:Number=0.02,isRightNow:Boolean=false):void{
			_easing=easing;
			x=x>=0?int(x+0.9):int(x-0.9);
			y=y>=0?int(y+0.9):int(y-0.9);
			_targetPos||=new Point();
			_targetPos.x=x;
			_targetPos.y=y;
			if(isRightNow)move(_targetPos.x-_position.x,
							   _targetPos.y-_position.y);
			_bindMode=POSITION_MODE;
		}
		
		/**移动接口*/
		public function move(vx:Number=0,vy:Number=0):void{
			_bindMode=CUSTOM_MOVE_MODE;
			updatePosition(vx,vy);
		}
		
		/**绑定相机到多个目标中心,isRightNow:表示立即到目标中心不执行缓动*/
		public function bindTargets(targets:Array,easing:Number=0.2,isRightNow:Boolean=false,isClearTargets:Boolean=true):void{
			_easing=easing;
			_bindTargets||=[];
			if(isClearTargets && _bindTargets.length>0)_bindTargets.splice(0);
			var i:int=targets.length;
			while(--i>=0)_bindTargets.push(targets[i]);
			_bindTargetsCenter||=new Point();
			getTargetsCenter(_bindTargets,_bindTargetsCenter);
			if(isRightNow)move(int(_bindTargetsCenter.x+0.9)-_position.x,
							   int(_bindTargetsCenter.y+0.9)-_position.y);
			_bindMode=TARGET_MODE;
		}
		
		override protected function lateUpdate():void{
			super.lateUpdate();
			if(_isAllowScorll){
				var vx:Number=0, vy:Number=0;
				if(_bindMode==TARGET_MODE){//目标模式
					_bindTargetsCenter||=new Point();
					getTargetsCenter(_bindTargets,_bindTargetsCenter);
					vx=(_bindTargetsCenter.x-_position.x)*_easing;
					vy=(_bindTargetsCenter.y-_position.y)*_easing;
					updatePosition(vx,vy);
				}else if(_bindMode==POSITION_MODE){//位置模式
					vx=(_targetPos.x-_position.x)*_easing;
					vy=(_targetPos.y-_position.y)*_easing;
					updatePosition(vx,vy);
				}
			}
		}
			
		private function updatePosition(vx:Number,vy:Number):void{
			if(!_isAllowBackward && vx<0)return;
			if(Math.abs(vx)<1)vx=0;//防止中心两侧抖动
			if(Math.abs(vy)<1)vy=0;//防止中心两侧抖动
			
			vx=vx>=0?int(vx+0.9):int(vx-0.9);
			vy=vy>=0?int(vy+0.9):int(vy-0.9);
			
			var x:int=int(_position.x)+vx;
			var y:int=int(_position.y)+vy;
			x=Math.min(Math.max(x,_min.x),_max.x);
			y=Math.min(Math.max(y,_min.y),_max.y);
			
			vx=x-_position.x;
			vy=y-_position.y;

			if(vx!=0||vy!=0){
				dispatchMoveEvent(int(vx),int(vy));
				setPosition(x,y);
			}else{
				dispatchMoveCompleteEvent();
			}
		}
		
		private function dispatchMoveEvent(vx:int,vy:int):void{
			_moveEvent||=new MyEvent(MOVE,{});
			_moveEvent.info.vx=vx;
			_moveEvent.info.vy=vy;
			dispatchEvent(_moveEvent);
		}
		
		private function dispatchMoveCompleteEvent():void{
			_moveCompleteEvent||=new MyEvent(MOVE_COMPLETE,{});
			dispatchEvent(_moveCompleteEvent);
		}
		
		private function setPosition(x:int,y:int):void{
			x=Math.min(Math.max(x,_min.x),_max.x);
			y=Math.min(Math.max(y,_min.y),_max.y);
			_position.x=x;
			_position.y=y;
			
			_cameraTarget.x=-(_position.x-_min.x/*int(_size.x*_focus.x)*/);
			_cameraTarget.y=-(_position.y-_min.y/*int(_size.y*_focus.y)*/);
		}
		
		/**返回多个目标的中心*/
		private function getTargetsCenter(targets:Array,outputPoint:Point):void{
			const count:int=targets.length;
			var i:int=count;
			var x:Number=0;
			var y:Number=0;
			while (--i>=0){
				if(targets[i] is b2Body){
					x+=targets[i].GetPosition().x*MyData.ptm_ratio;
					y+=targets[i].GetPosition().y*MyData.ptm_ratio;
				}else{
					x+=targets[i].x;
					y+=targets[i].y;
				}
			}
			outputPoint.x = x/count;
			outputPoint.y = y/count;
		}
		
		/**摇动*/
		public function shake(timeSecond:Number=0.5,maxDistance:Number=5):void{
			if(_isShakeing) stopCurShake();
			_isShakeing=true;
			_shakeMaxDistance=maxDistance;
			_shakeTargetInitPos.x=_cameraTarget.parent.x;
			_shakeTargetInitPos.y=_cameraTarget.parent.y;
			var delay:Number=1/MyData.frameRate;
			_shakeCount=int(timeSecond/delay+0.9);
			_curShakeId=flash.utils.setInterval(shakeHandler,delay);
		}
		private function shakeHandler():void{
			var tx:Number=Math.random() * _shakeMaxDistance *(Math.random()>0.5?1:-1);
			var ty:Number=Math.random() * _shakeMaxDistance *(Math.random()>0.5?1:-1);
			_cameraTarget.parent.x=_shakeTargetInitPos.x+tx;
			_cameraTarget.parent.y=_shakeTargetInitPos.y+ty;
			_shakeCount--;
			if(_shakeCount<=0)stopCurShake();
		}
		private function stopCurShake():void{
			clearInterval(_curShakeId);
			_isShakeing=false;
			_cameraTarget.parent.x=_shakeTargetInitPos.x;
			_cameraTarget.parent.y=_shakeTargetInitPos.y;
		}
		
		public function setAllowScorll(value:Boolean):void{
			_isAllowScorll=value;
		}
		
		public function setEasing(value:Number):void{
			_easing=value;
		}
		
		public function setAllowBackward(value:Boolean):void{
			_isAllowBackward=value;
		}
		
		override protected function onDestroy():void{
			stopCurShake();
			_cameraTarget.x=_cameraTargetInitPos.x;
			_cameraTarget.y=_cameraTargetInitPos.y;
			_cameraTarget=null;
			_position=null;
			_targetPos=null;
			_cameraTarget=null;
			_bindTargets=null;
			_bindTargetsCenter=null;
			_moveEvent=null;
			_moveCompleteEvent=null;
			_shakeTargetInitPos=null;
			_focus=null;
			_mapSize=null;
			_min=null;
			_max=null;
			super.onDestroy();
		}
		
	};

}