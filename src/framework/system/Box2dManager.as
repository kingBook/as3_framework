package framework.system{
	import Box2D.Box2DSeparator.b2Separator;
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.Joints.b2Joint;
	import Box2D.Dynamics.Joints.b2MouseJoint;
	import Box2D.Dynamics.Joints.b2MouseJointDef;
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.b2DebugDraw;
	import Box2D.Dynamics.b2Fixture;
	import Box2D.Dynamics.b2World;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import framework.game.Game;
	import framework.objs.GameObject;
	
	public class Box2dManager extends GameObject{
		private var _world:b2World;
		private var _ptm_ratio:Number;
		private var _worldSprite:Sprite;
		private var _joint:b2MouseJoint;
		private var _isDebugDraw:Boolean;
		private var _dt:Number;
		private var _velocityIterations:int;
		private var _positionIterations:int;
		private var _useMouseJoint:Boolean;
		private var _box2dDebug:Box2dDebug;
		public function Box2dManager(){
			super();
		}
		public static function create(worldSprite:Sprite,isDebugDraw:Boolean,useMouseJoint:Boolean,world:b2World,
									  ptm_ratio:Number,dt:Number,velocityIterations:int,positionIterations:int):Box2dManager{
			var game:Game=Game.getInstance();
			var info:*={};
			info.worldSprite=worldSprite;
			info.isDebugDraw=isDebugDraw;
			info.useMouseJoint=useMouseJoint;
			info.world=world;
			info.ptm_ratio=ptm_ratio;
			info.dt=dt;
			info.velocityIterations=velocityIterations;
			info.positionIterations=positionIterations;
			return game.createGameObj(new Box2dManager(),info) as Box2dManager;
		}
		override protected function init(info:* = null):void{
			super.init(info);
			_worldSprite = info.worldSprite;
			_isDebugDraw=info.isDebugDraw;
			_useMouseJoint=info.useMouseJoint;
			_world=info.world;
			_ptm_ratio = info.ptm_ratio;
			_dt=info.dt;
			_velocityIterations=info.velocityIterations;
			_positionIterations=info.positionIterations;
			//设置接触监听
			_world.SetContactListener(new Box2dContactListener());
			//
			if (_useMouseJoint){
				_game.global.stage.addEventListener(MouseEvent.MOUSE_DOWN, mouseHandler);
				//_game.global.stage.addEventListener(MouseEvent.MOUSE_MOVE, mouseHandler);
				_game.global.stage.addEventListener(MouseEvent.MOUSE_UP, mouseHandler);
			}
			if(_isDebugDraw){
				_box2dDebug=Box2dDebug.create(_world,_ptm_ratio);
				GameObject.dontDestroyOnDestroyAll(_box2dDebug);
			}
		}
		private function mouseHandler(e:MouseEvent):void{
			var x:Number = _worldSprite.mouseX;
			var y:Number = _worldSprite.mouseY;
			switch(e.type){
				case MouseEvent.MOUSE_DOWN:
					mouseDownHandler(x,y);
					break;
				case MouseEvent.MOUSE_MOVE:
					mouseMoveHandler(x,y);
					break;
				case MouseEvent.MOUSE_UP:
					mouseUpHandler();
					break;
				default:
			}
		}
		private function mouseUpHandler():void{
			stopDragBody();
		}
		override protected function fixedUpdate():void{
			super.fixedUpdate();
			_world.Step(_dt,_velocityIterations,_positionIterations);
			clearIsDestroyBodies();
			_world.ClearForces();
			if(_isDebugDraw){
				_world.DrawDebugData();
			}
		}
		override protected function update():void{
			super.update();
			var x:Number=_worldSprite.mouseX;
			var y:Number=_worldSprite.mouseY;
			mouseMoveHandler(x,y);
		}
		private function mouseMoveHandler(x:Number,y:Number):void{
			if(_joint)_joint.SetTarget(new b2Vec2(x/_ptm_ratio,y/_ptm_ratio));
		}
		private function mouseDownHandler(x:Number,y:Number):void{
			var b:b2Body=getPosBody(x,y,_world);
			startDragBody(b,x,y);
		}
		private function clearWorld(world:b2World):void{
			for(var j:b2Joint=world.GetJointList(); j; j=j.GetNext()) world.DestroyJoint(j);
			for(var b:b2Body=world.GetBodyList(); b; b=b.GetNext()) world.DestroyBody(b);
			if(_box2dDebug)_box2dDebug.clear();
		}
		private function clearIsDestroyBodies():void{
			var b:b2Body=_world.GetBodyList();
			var userData:*;
			for(b;b;b=b.GetNext()){
				userData=b.GetUserData();
				if(userData && userData.isDestroy) _world.DestroyBody(b);
			}
		}
		/**返回位置下的刚体*/
		private function getPosBody(x:Number,y:Number,world:b2World):b2Body{
			var b:b2Body;
			world.QueryPoint(function(fixture:b2Fixture):Boolean{
				b=fixture.GetBody();
				return false;
			},new b2Vec2(x/_ptm_ratio,y/_ptm_ratio));
			return b;
		}
		/** 开始拖动刚体*/
		private function startDragBody(b:b2Body, x:Number, y:Number):void{
			if (!b || b.GetType()!=b2Body.b2_dynamicBody) return;
			_joint && _world.DestroyJoint(_joint);
			var jointDef:b2MouseJointDef=new b2MouseJointDef();
				jointDef.bodyA = _world.GetGroundBody();
				jointDef.bodyB = b;
				jointDef.target.Set(x/_ptm_ratio,y/_ptm_ratio);
				jointDef.maxForce=1e6;
			_joint = _world.CreateJoint(jointDef) as b2MouseJoint;
		}
		private function stopDragBody():void{
			_joint && _world.DestroyJoint(_joint);
		}
		override protected function onDestroy():void{
			_game.global.stage.removeEventListener(MouseEvent.MOUSE_DOWN, mouseHandler);
			_game.global.stage.removeEventListener(MouseEvent.MOUSE_MOVE, mouseHandler);
			_game.global.stage.removeEventListener(MouseEvent.MOUSE_UP, mouseHandler);
			if (_joint){
				_world.DestroyJoint(_joint);
				_joint = null;
			}
			if(_world){
				clearWorld(_world);
				_world = null;
			}
			if(_box2dDebug){
				GameObject.destroy(_box2dDebug);
				_box2dDebug=null;
			}
			_worldSprite = null;
			super.onDestroy();
		}
		
		public function get world():b2World{ return _world; }
		public function get debugDraw():b2DebugDraw{return _box2dDebug.debugDraw;}
		public function get dt():Number{return _dt;}
		public function get velocityIterations():int{return _velocityIterations;}
		public function get positionIterations():int{return _positionIterations;}
		public function get ptm_ratio():Number{return _ptm_ratio;}
		
		
	};

}