package g.components{
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.b2Body;
	import flash.geom.Point;
	import framework.objs.Component;
	import framework.objs.GameObject;
	import framework.system.KeyboardManager;
	import framework.utils.Box2dUtil;
	import g.map.Map;
	import g.MyData;
	/**没有重力的玩家*/
	public class NoGravityPlayerBehavior extends Component{
		
		private var _body:b2Body;
		private var _upKeys:Vector.<String>;
		private var _downKeys:Vector.<String>;
		private var _leftKeys:Vector.<String>;
		private var _rightKeys:Vector.<String>;
		private var _dirV:Point;//与_faceV不同，它的各分量可能为0
		/**表示脸朝向,与_dirV不同，不能所有分量都为0: {0,-1}上、{0,1}下、{-1,0}左、{1,0}右，{-1,-1}左上、{1,-1}右上、{1,1}右下、{-1,1}左下*/
		private var _faceV:Point;
		private var _releaseResumeDirV:Point;
		private var _releaseResumeFaceV:Point;
		private var _km:KeyboardManager;
		private var _speedV:Point;
		private var _defaultSpeedV:Point;
		private var _disableLeft:Boolean;
		private var _disableRight:Boolean;
		private var _disableUp:Boolean;
		private var _disableDown:Boolean;
		private var _isPressLeft:Boolean;
		private var _isPressRight:Boolean;
		private var _isPressUp:Boolean;
		private var _isPressDown:Boolean;
		
		/**用于储存按下或释放方向键时的回调函数，0:释放所有键,1:左,2:右,3:上,4:下*/
		private var _callbackList:Array=[];
		
		/**
		 * 创建接口
		 * @param	gameObj
		 * @param	body
		 * @param	upKeys
		 * @param	downKeys
		 * @param	leftKeys
		 * @param	rightKeys
		 * @param	defaultSpeedV 默认移动速度Point
		 * @param	defaultDirV 默认移动方向Point
		 * @param	defaultFaceV 默认脸的朝向Point
		 * @param	releaseResumeDirV 不按任意方向键时，需要恢复移动方向，null时不恢复保留在最后一次移动方向
		 * @param	releaseResumeFaceV 不按任意方向键时，需要恢复的脸朝向，null时不恢复保留在最后一次脸朝向
		 * @return
		 */
		public static function create(gameObj:GameObject,body:b2Body,
		upKeys:Vector.<String>,downKeys:Vector.<String>,leftKeys:Vector.<String>,rightKeys:Vector.<String>,
		defaultSpeedV:Point=null,defaultDirV:Point=null,defaultFaceV:Point=null,releaseResumeDirV:Point=null,releaseResumeFaceV:Point=null):NoGravityPlayerBehavior{
			defaultSpeedV||=new Point(3,3);
			defaultDirV||=new Point(0,0);
			defaultFaceV||=new Point(0,1);
			
			var info:*={};
			info.body=body;
			info.upKeys=upKeys;
			info.downKeys=downKeys;
			info.leftKeys=leftKeys;
			info.rightKeys=rightKeys;
			info.speedV=defaultSpeedV;
			info.dirV=defaultDirV;
			info.faceV=defaultFaceV;
			info.releaseResumeDirV=releaseResumeDirV;
			info.releaseResumeFaceV=releaseResumeFaceV;
			return gameObj.addComponent(NoGravityPlayerBehavior,info) as NoGravityPlayerBehavior;
		}
		
		public function NoGravityPlayerBehavior(){
			super();
		}
		
		override protected function init(info:* = null):void{
			super.init(info);
			_body=info.body;
			_upKeys=info.upKeys;
			_downKeys=info.downKeys;
			_leftKeys=info.leftKeys;
			_rightKeys=info.rightKeys;
			_defaultSpeedV=new Point(info.speedV.x,info.speedV.y);
			_speedV=new Point(info.speedV.x,info.speedV.y);
			_dirV=new Point(info.dirV.x,info.dirV.y);
			_faceV=info.faceV;
			_releaseResumeFaceV=info.releaseResumeFaceV;
			_releaseResumeDirV=info.releaseResumeDirV;
			
			_km=KeyboardManager.create();
			
			_body.SetCustomGravity(new b2Vec2(0,0),true);
			_body.SetFixedRotation(true);
			Box2dUtil.setBodyFixture(_body,NaN,0);
		}
		
		override protected function update():void{
			super.update();
			var isReleaseX:Boolean=false,isReleaseY:Boolean=false;
			if(_km.p_keys(_leftKeys)){
				_isPressLeft=true;
				if(!_disableLeft) _dirV.x=_faceV.x=-1;
				if(_callbackList[1]!=null)_callbackList[1].call(null,true);
			}else if(_km.p_keys(_rightKeys)){
				_isPressRight=true;
				if(!_disableRight)_dirV.x=_faceV.x=1;
				if(_callbackList[2]!=null)_callbackList[2].call(null,true);
			}else{
				_isPressLeft=false;
				_isPressRight=false;
				if(!_disableLeft) {if(_km.jr_keys(_leftKeys)) _dirV.x=0;}
				if(!_disableRight){if(_km.jr_keys(_rightKeys))_dirV.x=0;}
				if(_callbackList[1]!=null)_callbackList[1].call(null,false);
				if(_callbackList[2]!=null)_callbackList[2].call(null,false);
				isReleaseX=true;
			}
			if(_km.p_keys(_upKeys)){
				_isPressUp=true;
				if(!_disableUp)_dirV.y=_faceV.y=-1;
				if(_callbackList[3]!=null)_callbackList[3].call(null,true);
			}else if(_km.p_keys(_downKeys)){
				_isPressDown=true;
				if(!_disableDown)_dirV.y=_faceV.y=1;
				if(_callbackList[4]!=null)_callbackList[4].call(null,true);
			}else{
				_isPressUp=false;
				_isPressDown=false;
				if(!_disableUp)  {if(_km.jr_keys(_upKeys))   _dirV.y=0;}
				if(!_disableDown){if(_km.jr_keys(_downKeys)) _dirV.y=0;}
				if(_callbackList[3]!=null)_callbackList[3].call(null,false);
				if(_callbackList[4]!=null)_callbackList[4].call(null,false);
				isReleaseY=true;
			}
			
			//释放所有方向键时，恢复脸朝向
			if(isReleaseX&&isReleaseY){
				if(_releaseResumeFaceV!=null) _faceV.setTo(_releaseResumeFaceV.x,_releaseResumeFaceV.y);
				if(_releaseResumeDirV!=null){
					if(!_disableLeft&&!_disableRight) _dirV.x=_releaseResumeDirV.x;
					if(!_disableUp&&!_disableDown)    _dirV.y=_releaseResumeDirV.y;
				}
				if(_callbackList[0]!=null)_callbackList[0].apply();
			}
			
			var tvx:Number=_speedV.x*_dirV.x;
			var tvy:Number=_speedV.y*_dirV.y;
			
			var map:Map=_game.getGameObjList(Map)[0] as Map;
			var lower:b2Vec2=_body.GetAABB().lowerBound;
			var upper:b2Vec2=_body.GetAABB().upperBound;
			
			if(_dirV.x>=0){
				if(upper.x*MyData.ptm_ratio>=map.width-5)tvx=0;
			}else{
				if(lower.x*MyData.ptm_ratio<=5)tvx=0;
			}
			if(_dirV.y>=0){
				if(upper.y*MyData.ptm_ratio>=map.height-5)tvy=0;
			}else{
				if(lower.y*MyData.ptm_ratio<=5)tvy=0;
			}
			
			var vx:Number=tvx-_body.GetLinearVelocity().x;
			var vy:Number=tvy-_body.GetLinearVelocity().y;
			
			var i:b2Vec2=b2Vec2.Make(_body.GetMass()*vx,_body.GetMass()*vy);
			_body.ApplyImpulse(i,_body.GetWorldCenter());
		}
		
		override protected function onDestroy():void{
			GameObject.destroy(_km);
			_km=null;
			_body=null;
			_upKeys=null;
			_downKeys=null;
			_leftKeys=null;
			_rightKeys=null;
			_dirV=null;
			_faceV=null;
			_releaseResumeDirV=null;
			_releaseResumeFaceV=null;
			_callbackList=null;
			super.onDestroy();
		}
		
		/**表示脸朝向,与dirV不同，不能所有分量都为0: {0,-1}上、{0,1}下、{-1,0}左、{1,0}右，{-1,-1}左上、{1,-1}右上、{1,1}右下、{-1,1}左下*/
		public function get faceV():Point{ return _faceV; }
		/**表示当前按键指定的方向，与faceV不同，它的各分量可能为0*/
		public function get dirV():Point { return _dirV; }
		public function setDirVX(x:int):void{ _dirV.x=x;}
		public function setDirVY(y:int):void{ _dirV.y=y;}
		
		public function get km():KeyboardManager{ return _km; }
		/**callback: function():void;*/
		public function setReleaseAllCallback(callback:Function):void{ _callbackList[0]=callback; }
		/**callback: function(isPress:Boolean):void;*/
		public function setLeftCallback      (callback:Function):void{ _callbackList[1]=callback; }
		/**callback: function(isPress:Boolean):void;*/
		public function setRightCallback     (callback:Function):void{ _callbackList[2]=callback; }
		/**callback: function(isPress:Boolean):void;*/
		public function setUpCallback        (callback:Function):void{ _callbackList[3]=callback; }
		/**callback: function(isPress:Boolean):void;*/
		public function setDownCallback      (callback:Function):void{ _callbackList[4]=callback; }
		
		/**禁用一个键，按下或释放该键时都不设置_dirV*/
		public function setDisableLeft (value:Boolean):void{ _disableLeft=value; }
		/**禁用一个键，按下或释放该键时都不设置_dirV*/
		public function setDisableRight(value:Boolean):void{ _disableRight=value; }
		/**禁用一个键，按下或释放该键时都不设置_dirV*/
		public function setDisableUp   (value:Boolean):void{ _disableUp=value; }
		/**禁用一个键，按下或释放该键时都不设置_dirV*/
		public function setDisableDown (value:Boolean):void{ _disableDown=value; }
		
		public function setSpeedV(x:Number=NaN,y:Number=NaN):void{ 
			var vx:Number=isNaN(x)?_defaultSpeedV.x:x;
			var vy:Number=isNaN(y)?_defaultSpeedV.y:y;
			_speedV.setTo(vx,vy);
		}
		
		public function setSpeedVToDefault():void{
			_speedV.setTo(_defaultSpeedV.x,_defaultSpeedV.y);
		}
		
		public function get defaultSpeedV():Point{ return _defaultSpeedV; }
		public function get speedV():Point{ return _speedV; }
		
		public function get isPressUp():Boolean   {return _isPressUp;}
		public function get isPressDown():Boolean {return _isPressDown;}
		public function get isPressLeft():Boolean {return _isPressLeft;}
		public function get isPressRight():Boolean{return _isPressRight;}
		public function get isPressLR():Boolean{return _isPressLeft||_isPressRight;}
		public function get isPressUD():Boolean{return _isPressUp||_isPressDown;}
		
	};

}