package g.objs{
	import Box2D.Collision.b2Manifold;
	import Box2D.Dynamics.Contacts.b2Contact;
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.b2ContactImpulse;
	import flash.display.MovieClip;
	import framework.game.Game;
	import framework.objs.Clip;
	import framework.utils.Box2dUtil;
	import g.MyData;
	import g.components.BoxBehavior;
	import g.fixtures.Switcher;
	import g.objs.MovableObject;
	import Box2D.Dynamics.b2World;
	
	/**箱子*/
	public class Box extends MovableObject{
		public static function create(childMc:MovieClip,viewDefName:String,world:b2World):void{
			var game:Game=Game.getInstance();
			var body:b2Body=Box2dUtil.createRoundBoxWithDisObj(childMc,world,MyData.ptm_ratio,5,10);
			//var body:b2Body=Box2dUtil.createBoxWithDisObj(childMc,game.global.curWorld,MyData.ptm_ratio);
			var clip:Clip=Clip.fromDefName(viewDefName,true);
			clip.smoothing=true;
			clip.transform.matrix=childMc.transform.matrix;
			var info:*={};
			info.body=body;
			info.view=clip;
			info.viewParent=game.global.layerMan.items2Layer;
			game.createGameObj(new Box(),info);
		}
        
        public static function createWithBody(body:b2Body,viewDefName:String):void{
            Box2dUtil.replaceRoundBoxWithFixture(body.GetFixtureList(),MyData.ptm_ratio,5,10);
            var game:Game=Game.getInstance();
            var info:*={};
            info.body=body;
            info.view=Clip.fromDefName(viewDefName,true);
            info.viewParent=game.global.layerMan.items2Layer;
            game.createGameObj(new Box(),info);
        }
		
		public function Box(){
			super();
		}
		
		override protected function init(info:* = null):void{
			super.init(info);
			_body.SetPreSolveCallback(preSolve);
			_boxBehavior=addComponent(BoxBehavior) as BoxBehavior;
			_boxBehavior.initialize(_body,false,NaN);
			Switcher.AddActiveObj(this);
		}
        
        override protected function preSolve(contact:b2Contact, oldManifold:b2Manifold, other:b2Body):void{
            super.preSolve(contact,oldManifold,other);
            _boxBehavior.preSolve(contact,oldManifold);
        }
        
        override protected function postSolve(contact:b2Contact, impulse:b2ContactImpulse, other:b2Body):void{
            super.postSolve(contact,impulse,other);
            _boxBehavior.postSolve(contact,impulse);
        }
		
		override protected function onDestroy():void{
			removeComponent(_boxBehavior);
			Switcher.RemoveActiveObj(this);
			_boxBehavior=null;
			super.onDestroy();
		}
		
		private var _boxBehavior:BoxBehavior;
	};

}