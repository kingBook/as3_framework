package g.components{
	import Box2D.Collision.b2Manifold;
	import Box2D.Collision.b2WorldManifold;
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.Contacts.b2Contact;
	import Box2D.Dynamics.b2Body;
	import framework.objs.Component;
	/*
	 override protected function init(info:* = null):void{
		_patrol=addComponent(Patrol) as Patrol;
		_patrol.initialize(new <String>["Ground","EdgeGround","SwitcherMovie"],_body,info.dirX,info.minX,info.maxX,info.speedX);
	 }
	 private function preSolve(contact:b2Contact,oldManifold:b2Manifold):void{
		_patrol.preSolve(contact,oldManifold);
	 }
	 override protected function onDestroy():void{
		removeComponent(_patrol);
	 }
	*/
	/**巡逻组件*/
	public class Patrol extends CharacterBehavior{
		
		private const e_isDoRest:uint =0x000004;
		private const e_isResting:uint=0x000008;
		private var _dirX:int;
		private var _min:Number;
		private var _max:Number;
		private var _speedX:Number;
		private var _hitEdgeX:int=0;
		private var _worldManifold:b2WorldManifold=new b2WorldManifold();
		private var _groundTypes:Vector.<String>;
		
		public function Patrol(){
			super();
		}
		
		public function initialize(groundTypes:Vector.<String>,body:b2Body,dirX:int,minX:Number=0,maxX:Number=1e6,speedX:Number=3,isDoRest:Boolean=false):void{
			_groundTypes=groundTypes;
			_body=body;
			_dirX=dirX;
			_min=minX;
			_max=maxX;
			_speedX=speedX;
			if(isDoRest)_flags|=e_isDoRest;
			
			_body.SetFixedRotation(true);
			_body.SetAllowBevelSlither(false);
			_body.SetUphillZeroFriction(true);
			_body.SetIsIgnoreFrictionY(true);
		}
		
		public function preSolve(contact:b2Contact,oldManifold:b2Manifold):void{
			if(!contact.IsTouching())return;
			var b1:b2Body=contact.GetFixtureA().GetBody();
			var b2:b2Body=contact.GetFixtureB().GetBody();
			var ob:b2Body=b1==_body?b2:b1;
			var othis:*=ob.GetUserData().thisObj;
			var otype:String=ob.GetUserData().type;
			contact.GetWorldManifold(_worldManifold);
			var normal:b2Vec2=_worldManifold.m_normal; if(b1!=_body)normal.Multiply(-1);
			
			if(_groundTypes.indexOf(otype)>-1){
				if(_hitEdgeX==0){
					if(Math.abs(normal.x)>0.8) _hitEdgeX=normal.x>0?1:-1;
				}
			}else{
				contact.SetEnabled(false);
			}
		}
		
		override protected function update():void{
			super.update();
			if((_flags&e_isDeath)>0){
				
				return;
			}
			//
			if((_flags&e_isResting)>0){
				//休息
				var delay:Number=Math.random()*1+0.5;
				scheduleOnce(restComplete,delay);
			}else if(Math.random()<0.008&&(_flags&e_isDoRest)>0){
				_flags|=e_isResting;
			}else{
				var x:Number=_body.GetPosition().x;
				if(_dirX>0){
					if(_hitEdgeX>0||x>=_max)_dirX=-1;
				}else if(_dirX<0){
					if(_hitEdgeX<0||x<=_min)_dirX=1;
				}
				
				if(_dirX<0){
					walk(-_speedX);
				}else if(_dirX>0){
					walk(_speedX);
				}
			}
			//
			_hitEdgeX=0;
		}
		
		private function restComplete():void{
			_flags&=~e_isResting;
		}
		
		override protected function onDestroy():void{
			unschedule(restComplete);
			_worldManifold=null;
			_groundTypes=null;
			super.onDestroy();
		}
		
		public function get dirX():int{return _dirX;}
		public function get isResting():Boolean{return (_flags&e_isResting)>0;}
		public function get isWalking():Boolean{return (_flags&e_isResting)==0;}
		
	};

}