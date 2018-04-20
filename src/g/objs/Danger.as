package g.objs{
	import g.objs.StandardObject;
	import Box2D.Dynamics.b2Body;
	import framework.game.Game;

	public class Danger extends StandardObject{
		public static function create(body:b2Body):void{
			var game:Game=Game.getInstance();
			var info:*={};
			info.body=body;
			game.createGameObj(new Danger(),info);
		}
	}
}