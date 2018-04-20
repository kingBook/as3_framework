package g.components{
	import framework.objs.Component;
	import Box2D.Collision.b2Manifold;
	import Box2D.Collision.b2WorldManifold;
	import Box2D.Common.Math.b2Math;
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.Contacts.b2Contact;
	import framework.utils.Box2dUtil;
	import g.MyData;
	
	/*
	 //实现过程
	 private var _pile:PileBehavior;
	 private function createMapComplete(e:MyEvent):void{
		_pile=addComponent(PileBehavior) as PileBehavior;
		_pile.initialize(p1Body, p2Body);
	 	//_pile.setOnlyP1ToP2();
		//_pile.setOnlyP2ToP1();
	 }
     
	 private function preSolve(contact:b2Contact, oldManifold:b2Manifold):void{
	 	_pile.preSolve(contact,oldManifold);
	 }
     
	 override public function destroy():void{
	 	removeComponent(_pile);
	 }
	*/
	/**堆叠组件，实现两个玩家堆叠功能*/
	public class PileBehavior extends Component{
		private var _body1:b2Body;
		private var _body2:b2Body;
		private var _worldManifold:b2WorldManifold=new b2WorldManifold();
		private var _isSensor:Boolean;
		private var _isOnlyP1ToP2:Boolean;
		private var _isOnlyP2ToP1:Boolean;
		
		public function PileBehavior(){
			super();
		}
		
		public function initialize(b1:b2Body,b2:b2Body):void{
			_body1=b1;
			_body2=b2;
			_body1.SetBullet(true);
			_body2.SetBullet(true);
			//允许睡眠会导致从下向上跳，上面的刚体(进入睡眠)不下落
			_body1.SetSleepingAllowed(false);
			_body2.SetSleepingAllowed(false);
		}
		
		/**设置仅p1->p2*/
		public function setOnlyP1ToP2():void{
			_isOnlyP1ToP2=true;
		}
		
		/**设置仅p2->p1*/
		public function setOnlyP2ToP1():void{
			_isOnlyP2ToP1=true;
		}
		
		/**如果为true两个刚体间将不碰撞*/
		public function setSensor(value:Boolean):void{
			_isSensor=value;
		}
		
		/**外部调用*/
		public function preSolve(contact:b2Contact, oldManifold:b2Manifold):void{
			if(!contact.IsTouching())return;
			var b1:b2Body=contact.GetFixtureA().GetBody();
			var b2:b2Body=contact.GetFixtureB().GetBody();
			var ob:b2Body=b1==_body1?b2:b1;
			if(ob!=_body2)return;//只处理_body1,_body2间的碰撞
			if(_isSensor){
				contact.SetEnabled(false);
				return;
			}
			var topBody:b2Body,bottomBody:b2Body;
			if(b1.GetPosition().y<=b2.GetPosition().y){
				topBody=b1;
				bottomBody=b2;
			}else{
				topBody=b2;
				bottomBody=b1;
			}
			
			contact.GetWorldManifold(_worldManifold);
			var ny:Number=_worldManifold.m_normal.y;if(b1!=topBody)ny=-ny;
			if(ny<=0.9){
				contact.SetEnabled(false);
			}else if(int(bottomBody.GetLinearVelocity().y)<0){
				contact.SetEnabled(false);//从下向上跳碰另一个底部忽略
			}else{
				var topVY:int=int(topBody.GetLinearVelocity().y);
				var hh:Number=topBody.GetAABB().GetExtents().y+bottomBody.GetAABB().GetExtents().y;
				hh*=0.7;
				var dy:Number=bottomBody.GetPosition().y-topBody.GetPosition().y;
				var enabled:Boolean=Math.abs(int(bottomBody.GetLinearVelocity().x))<1;//底部刚体不左右移动才堆叠
				enabled&&=dy>=hh;//两刚体上下距离
				enabled&&=topVY>=0;
				if(_isOnlyP1ToP2){//设置只能p1叠p2
					enabled&&=bottomBody==_body2;
				}else if(_isOnlyP2ToP1){//设置只能p2叠p1
					enabled&&=bottomBody==_body1;
				}
				contact.SetEnabled(enabled);
			}
		}
		
		override protected function onDestroy():void{
			_body1=null;
			_body2=null;
			_worldManifold=null;
			super.onDestroy();
		}
		
		public function get isSensor():Boolean{ return _isSensor; }
		
	};

}