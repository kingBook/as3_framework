package g.objs{
	import Box2D.Dynamics.b2Body;
	import framework.game.Game;
	import framework.objs.Clip;
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Collision.b2AABB;
	public class SwMovie extends SwitchCtrlTwoPtMotionObj{
		private static const speed:Number=3;
		public static function create(body:b2Body,dt:Number,ctrlMyNames:String,isOut:Boolean,viewDefName:String=null):void{
			var game:Game=Game.getInstance();
			var info:*={};
			info.body=body;
			if(viewDefName){
				info.view=Clip.fromDefName(viewDefName,true);
				info.viewParent=game.global.layerMan.items1Layer;
			}
			var pos:b2Vec2=body.GetPosition().Copy();
			var angle:Number=body.GetAngle();

			body.SetAngle(0);
			var aabb:b2AABB=body.GetAABB();
			body.SetAngle(angle);
			
			var pos0:b2Vec2=new b2Vec2(pos.x-Math.cos(angle)*aabb.GetExtents().x*2,pos.y-Math.sin(angle)*aabb.GetExtents().x*2);
			var pos1:b2Vec2=pos;

			var target:b2Vec2;
			if(isOut){
				target=pos1;
			}else{
				target=pos0;
				body.SetPosition(target);
			}

			info.pos0=pos0;
			info.pos1=pos1;
			info.target=target;
			info.speed=speed;
			info.dt=dt;
			info.ctrlMyNames=ctrlMyNames;
			game.createGameObj(new SwMovie(),info);
		}
	}
}