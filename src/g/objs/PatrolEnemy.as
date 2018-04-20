package g.objs{
	import Box2D.Collision.b2Manifold;
	import Box2D.Collision.b2WorldManifold;
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.Contacts.b2Contact;
	import Box2D.Dynamics.Contacts.b2ContactEdge;
	import Box2D.Dynamics.b2Body;
	import framework.game.UpdateType;
	import framework.events.FrameworkEvent;
	import framework.utils.RandomKb;
	import g.map.MapModel;
	import g.MyData;
	import g.objs.PatrolEnemy;
	import framework.game.Game;
	import g.objs.MovableObject;
	import g.map.Map;
	import framework.utils.Box2dUtil;
	import Box2D.Dynamics.b2World;
	import framework.objs.GameObject;

	/**左右巡逻的敌人*/
	public class PatrolEnemy extends MovableObject{
		
		public static function create(world:b2World):PatrolEnemy{
			var game:Game=Game.getInstance();
			var info:*={};
			info.body=Box2dUtil.createRoundBox(40,60,100,100,world,MyData.ptm_ratio,5,10);
			info.dirX=RandomKb.wave;
			info.min=0;
			info.max=1e6;
			info.speedX=3;
			return game.createGameObj(new PatrolEnemy(),info) as PatrolEnemy;
		}
		
		protected var _min:Number;
		protected var _max:Number;
		protected var _dirX:int;
		protected var _speedX:Number=3;
		protected var _hitEdgeX:int;
		
		public function PatrolEnemy(){
			super();
		}
		
		override protected function init(info:*=null):void{
			super.init(info);
			_dirX=info.dirX||RandomKb.wave;
			_min=info.min/MyData.ptm_ratio||0;
			_max=info.max/MyData.ptm_ratio||1e6;
			_speedX=info.speedX||_speedX;
			
			_body.SetPreSolveCallback(preSolve);
			_body.SetFixedRotation(true);
			_body.SetAllowBevelSlither(false);
			_body.SetIsIgnoreFrictionY(true);
		}
		
		private function preSolve(contact:b2Contact,oldManifold:b2Manifold):void{
			if(!contact.IsTouching())return;
			var b1:b2Body=contact.GetFixtureA().GetBody();
			var b2:b2Body=contact.GetFixtureB().GetBody();
			var ob:b2Body=b1==_body?b2:b1;
			var oUserData:*=ob.GetUserData();
			var othis:*=oUserData?oUserData.thisObj:null;
			var type:String=oUserData?oUserData.type:null;
			preContactHandler(contact,othis,type);
		}
		
		protected function preContactHandler(contact:b2Contact, othis:*, type:String):void{
			if(type=="Ground"||type=="EdgeGround"||type=="SwitcherMovie"){
				
			}else{
				contact.SetEnabled(false);
			}
		}
		
		override protected function update():void{
			super.update();
			if(_isDeath){
				syncView();
				var y:Number=_body.GetPosition().y*MyData.ptm_ratio;
				var map:Map=_game.getGameObjList(Map)[0] as Map;
				
				var isOutWorld:Boolean=(y-50)>map.height;
				if(isOutWorld)GameObject.destroy(this);
				return;
			}
			ai();
		}
		
		protected function ai():void{
			if(_view)_view.scaleX=Math.abs(_view.scaleX)*_dirX;
			checkHitEdgeX();
			checkChangeDirX();
			walk(_dirX);
		}
		
		protected function checkChangeDirX():void{
			var pos:b2Vec2=_body.GetPosition();
			var result:Boolean=false;
			result||=_dirX>0&&pos.x>=_max;
			result||=_dirX<0&&pos.x<=_min;
			result||=_dirX==_hitEdgeX;
			if(result)_dirX=-_dirX;
		}
		
		protected function walk(dirX:int,customSpeed:Number=0):void{
			var speed:Number=customSpeed>0?customSpeed:_speedX;
			var vx:Number=speed*dirX-_body.GetLinearVelocity().x;
			var ix:Number=_body.GetMass()*vx;
			_body.ApplyImpulse(b2Vec2.MakeOnce(ix,0),_body.GetWorldCenter());
		}
		
		private var _worldManifold:b2WorldManifold=new b2WorldManifold();
		protected function checkHitEdgeX():void{
			var hitEdgeX:int=0;
			var ce:b2ContactEdge=_body.GetContactList();
			var contact:b2Contact;
			var nx:Number;
			for(ce; ce; ce=ce.next){
				contact = ce.contact;
				if(!contact.IsTouching())continue;
				if(contact.IsSensor()||!contact.IsEnabled())continue;
				contact.GetWorldManifold(_worldManifold);
				nx=_worldManifold.m_normal.x; if(contact.GetFixtureA().GetBody()!=_body)nx=-nx;
				if(Math.abs(nx)>0.8){
					hitEdgeX=nx>0?1:-1;
					break;
				}
			}
			_hitEdgeX=hitEdgeX;
		}
		
		
		private var _isDeath:Boolean;
		public function get isDeath():Boolean{ return _isDeath; }
		
		public function deathHandler(fallDir:int):void{
			if(_isDeath)return;
			_isDeath=true;
			_body.SetSensor(true);
			_body.SetLinearVelocity(b2Vec2.MakeOnce(fallDir*_body.GetMass()*10,-_body.GetMass()*25));
			_body.SetAwake(true);
			_game.global.soundMan.play("Sound_enemyDeath");
		}
		
	};

}