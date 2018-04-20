package g.objs{
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.b2Body;

	import framework.game.Game;
	import framework.objs.Clip;

	import g.map.Map;
	import g.objs.MovableObject;
	import g.components.TwoPtMotionBehavior;

	public class MotionPlatform extends MovableObject{
		private static const speed:Number=3;
		private var _twoPointBehavior:TwoPtMotionBehavior;
		public function MotionPlatform(){
			super();
		}

		public static function create(body:b2Body,dt:Number,viewDefName:String=null):void{
			var game:Game=Game.getInstance();
			var info:*={};
			info.body=body;
			if(viewDefName){
				info.view=Clip.fromDefName(viewDefName,true);
				info.viewParent=game.global.layerMan.items2Layer;
			}
			info.dt=dt;
			game.createGameObj(new MotionPlatform(),info);
		}

		override protected function init(info:*=null):void{
			super.init(info);
			var pos0:b2Vec2=_body.GetPosition().Copy();
			var pos1:b2Vec2=_body.GetUserData().target;
			var target:b2Vec2=pos1;
			_twoPointBehavior=TwoPtMotionBehavior.create(this,_body,pos0,pos1,target,speed,info.dt);
		}

		override protected function fixedUpdate():void{
			super.fixedUpdate();
			if(_twoPointBehavior.gotoTarget()){
				_twoPointBehavior.swapTarget();
			}
		}

		override protected function onDestroy():void{
			removeComponent(_twoPointBehavior);
			_twoPointBehavior=null;
			super.onDestroy();
		}
	}
}