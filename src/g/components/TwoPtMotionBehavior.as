package g.components{
	import framework.objs.Component;
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.b2Body;
	import framework.objs.GameObject;
	import framework.utils.Box2dUtil;
	import framework.utils.Mathk;
	import Box2D.Collision.b2AABB;

	public class TwoPtMotionBehavior extends Component{
		private var _speed:Number;
		private var _pos0:b2Vec2;
		private var _pos1:b2Vec2;
		private var _target:b2Vec2;//only set  _pos0/_pos1
		private var _dt:Number;
		private var _body:b2Body;
		private var _leftMiddle:b2Vec2;
		
		public function TwoPtMotionBehavior(){
			super();
		}

		public static function create(gameObj:GameObject,body:b2Body,pos0:b2Vec2,pos1:b2Vec2,target:b2Vec2,speed:Number,dt:Number):TwoPtMotionBehavior{
			var info:*={};
			info.body=body;
			info.pos0=pos0;
			info.pos1=pos1;
			info.target=target;
			info.speed=speed;
			info.dt=dt;
			return gameObj.addComponent(TwoPtMotionBehavior,info) as TwoPtMotionBehavior;
		}
		override protected function init(info:*=null):void{
			super.init(info);
			_pos0=info.pos0;
			_pos1=info.pos1;
			_target=info.target;
			_speed=info.speed;
			_dt=info.dt;
			_body=info.body;

			//set left middle point
			var recordPos:b2Vec2=_body.GetPosition().Copy();
			var recordAngle:Number=_body.GetAngle();
			_body.SetPositionAndAngle(_pos0,0);
			var aabb:b2AABB=_body.GetAABB();
			_leftMiddle=new b2Vec2(aabb.lowerBound.x,aabb.lowerBound.y+aabb.GetExtents().y);
			_body.SetPositionAndAngle(recordPos,recordAngle);
		}
		//gameObject class implement
		/*override protected function fixedUpdate():void{
			super.fixedUpdate();
			if(gotoTarget()){
				swapTarget();
			}
		}*/
		public function gotoTarget():Boolean{
			var pos:b2Vec2=_body.GetPosition();
			var dx:Number=_target.x-pos.x;
			var dy:Number=_target.y-pos.y;
			var d:Number=Math.sqrt(dx*dx+dy*dy);
			var angle:Number=Math.atan2(dy,dx);
			if(d>=_speed*_dt){
				_body.SetLinearVelocity(b2Vec2.MakeOnce(Math.cos(angle)*_speed,Math.sin(angle)*_speed));
			}else{
				_body.SetLinearVelocity(b2Vec2.MakeOnce(Math.cos(angle)*d,Math.sin(angle)*d));
				return true;
			}
			return false;
		}
		public function isTargetEqualPos0():Boolean{
			return _target==_pos0;
		}
		public function isTargetEqualPos1():Boolean{
			return _target==_pos1;
		}
		public function swapTarget():void{
			if(isTargetEqualPos0())_target=_pos1;
			else _target=_pos0;
		}
		public function swapTargetToPos0():void{
			_target=_pos0;
		}
		public function swapTargetToPos1():void{
			_target=_pos1;
		}
		public function inAcceptRange(checkPt:b2Vec2):Boolean{
			const N:Number=4;
			const angle:Number=_body.GetAngle()+Math.PI*0.5;
			var p1:b2Vec2=new b2Vec2(_leftMiddle.x-Math.cos(angle)*N,
			                         _leftMiddle.y-Math.sin(angle)*N);
			var p2:b2Vec2=new b2Vec2(_leftMiddle.x+Math.cos(angle)*N,
			                         _leftMiddle.y+Math.sin(angle)*N);
			return Mathk.getPointOnLine(checkPt.x,checkPt.y,p1.x,p1.y,p2.x,p2.y) < 0;
		}
		override protected function onDestroy():void{
			_pos0=null;
			_pos1=null;
			_target=null;
			_body=null;
			_leftMiddle=null;
			super.onDestroy();
		}

	}
}