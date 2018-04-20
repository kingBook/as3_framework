package g.objs{
	import framework.game.Game;
	import g.components.TwoPtMotionBehavior;
	import g.components.SwitchCtrlObjBehavior;
	import g.objs.MovableObject;
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.Contacts.b2Contact;
	import Box2D.Collision.b2Manifold;
	import Box2D.Dynamics.b2Body;
	/**受到开关控制的 两点运动对象 */
	public class SwitchCtrlTwoPtMotionObj extends MovableObject{
		protected var _switchCtrlObjBehavior:SwitchCtrlObjBehavior;
		protected var _twoPtBehavior:TwoPtMotionBehavior;
		/*public static function create(body:b2Body,viewDefName:String=null):void{
			var game:Game=Game.getInstance();
			var info:*={};
			info.body=body;
			if(viewDefName){
				info.view=Clip.fromDefName(viewDefName,true);
				info.viewParent=game.global.layerMan.items1Layer;
			}
			info.pos0=pos0;
			info.pos1=pos1;
			info.target=pos1/pos0;
			info.speed=speed;
			info.dt=dt;
			info.ctrlMyNames=ctrlMyNames;
			game.createGameObj(new XXXX(),info);
		}*/
		override protected function init(info:*=null):void{
			super.init(info);
			_switchCtrlObjBehavior=SwitchCtrlObjBehavior.create(this,info.ctrlMyNames,on,off,(info.target==info.pos1));
			//off 时要求位置在pos0
			//on  时要求位置在pos1
			//target 刚体初始位置(pos0/pos1)的另一个位置(pos0/pos1)
			_twoPtBehavior=TwoPtMotionBehavior.create(this,_body,info.pos0,info.pos1,info.target,info.speed,info.dt);
		}
		override protected function fixedUpdate():void{
			super.fixedUpdate();
			if(_twoPtBehavior.gotoTarget()){
				onGotoTarget();
			}
		}
		virtual protected function onGotoTarget():void{}
		/**控制接口*/
		public function control(isAuto:Boolean=false,isDoOn:Boolean=false):void{
			_switchCtrlObjBehavior.control(isAuto,isDoOn);
		}
		protected function on():void{
			_twoPtBehavior.swapTargetToPos1();
		}
		protected function off():void{
			_twoPtBehavior.swapTargetToPos0();
		}
		public function inAcceptRange(checkPt:b2Vec2):Boolean{
			return _twoPtBehavior.inAcceptRange(checkPt);
		}
		override protected function preSolve(contact:b2Contact,oldManifold:b2Manifold,other:b2Body):void{
			super.preSolve(contact,oldManifold,other);
			if(!inAcceptRange(other.GetPosition())){
				contact.SetSensor(true);
			}
		}
		override protected function onDestroy():void{
			removeComponent(_twoPtBehavior);
			removeComponent(_switchCtrlObjBehavior);
			_switchCtrlObjBehavior=null;
			_twoPtBehavior=null;
			super.onDestroy();
		}
		public function get ctrlMyNames():String{
			return _switchCtrlObjBehavior.ctrlMyNames;
		}
		
	}
}