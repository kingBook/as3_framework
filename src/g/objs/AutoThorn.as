package g.objs{
    import Box2D.Dynamics.b2Body;
    import framework.game.Game;
    import framework.objs.Clip;
    import g.objs.SyncDelayTwoPtMotionObj;
    import Box2D.Common.Math.b2Vec2;
    import flash.display.Sprite;
    import framework.utils.Box2dUtil;
    import g.MyData;
    import Box2D.Collision.b2AABB;
	/*自动伸缩的刺*/
    public class AutoThorn extends SyncDelayTwoPtMotionObj{
		private static const speed:Number=8;
		
		public static function create(body:b2Body,isOut:Boolean,offWaitDelay:Number,onWaitDelay:Number,dt:Number,viewDefName:String=null):void{
			var game:Game=Game.getInstance();

			var angle:Number=body.GetAngle();
			body.SetAngle(0);
			var aabb:b2AABB=body.GetAABB();
			var motionDistance:Number=aabb.GetExtents().x*2;
			body.SetAngle(angle);

			var viewMask:Sprite=Box2dUtil.getBodyMaskSprite(body,MyData.ptm_ratio,3);

			var pos:b2Vec2=body.GetPosition().Copy();
			var pos0:b2Vec2=new b2Vec2(pos.x-Math.cos(angle)*motionDistance, pos.y-Math.sin(angle)*motionDistance);
			var pos1:b2Vec2=pos;
			var target:b2Vec2;
			if(isOut){
				target=pos1;
			}else{
				body.SetPosition(pos0);
				target=pos0;
			}

			var info:*={};
			info.body=body;
			if(viewDefName){
				info.view=Clip.fromDefName(viewDefName,true);
				info.viewParent=game.global.layerMan.items2Layer;
			}
			info.motionDistance=motionDistance;
			info.pos0=pos0;
			info.pos1=pos1;
			info.target=target;
			info.speed=speed;
			info.dt=dt;
			info.offWaitDelay=offWaitDelay;
			info.onWaitDelay=onWaitDelay;
			info.viewMask=viewMask;
			game.createGameObj(new AutoThorn(),info);
		}
		
	}
}