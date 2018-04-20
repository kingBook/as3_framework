package g.components{
	import Box2D.Collision.b2Manifold;
	import Box2D.Collision.b2WorldManifold;
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.Contacts.b2Contact;
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.b2ContactImpulse;
	import framework.objs.Component;
	import framework.utils.Box2dUtil;
	/*
	private var _boxBehavior:BoxBehavior;
	
	_boxBehavior=addComponent(BoxBehavior) as BoxBehavior;
	_boxBehavior.initialize(_body,false,NaN);
	
	private function preSolve(contact:b2Contact,oldManifold:b2Manifold):void{
		_boxBehavior.preSolve(contact,oldManifold);
	}
	
	private function postSolve(contact:b2Contact,impulse:b2ContactImpulse):void{
		_boxBehavior.postSolve(contact,impulse);
	}
	*/
	
	/**箱子行為*/
	public class BoxBehavior extends Component{
		
		public function BoxBehavior(){
			super();
		}
		
		public function initialize(body:b2Body,fixedRotation:Boolean=false,fixtureFriction:Number=NaN):void{
			_body=body;
			_body.SetFixedRotation(fixedRotation);
			_body.SetUphillZeroFriction(true);
			Box2dUtil.setBodyFixture(_body,NaN,fixtureFriction);
		}
		
		
		public function preSolve(contact:b2Contact,oldManifold:b2Manifold):void{
			var b1:b2Body=contact.GetFixtureA().GetBody();
			var b2:b2Body=contact.GetFixtureB().GetBody();
			var ob:b2Body=b1==_body?b2:b1;
			var ob_type:String=ob.GetUserData().type;
			if(!contact.IsTouching())return;
			contact.GetWorldManifold(_worldManifold);
			var ny:Number=_worldManifold.m_normal.y; if(b1!=_body)ny=-ny;
			if(ob_type=="Player" || ob_type=="Enemy"){//从上落下
				if(ny>0.8){
					contact.SetEnabled(false);
				}
			}else if(ob_type=="Ladder"){
				if(ny>0.7){}else{
					contact.SetEnabled(false);
				}
			}
		}
		
		public function postSolve(contact:b2Contact,impulse:b2ContactImpulse):void{
			if(impulse.normalImpulses[0]>35){
			//	_game.global.soundMan.play("箱子掉落");
			}
		}
		
		override protected function update():void{
			velFriction();
		}
		
		private function velFriction():void{
			var v:b2Vec2=_body.GetLinearVelocity();
			v.x*=0.9;
			_body.SetLinearVelocity(v);
		}
		
		override protected function onDestroy():void{
			_body=null;
			_worldManifold=null;
			super.onDestroy();
		}
		
		
		
		private var _body:b2Body;
		private var _worldManifold:b2WorldManifold=new b2WorldManifold();
		
	};

}