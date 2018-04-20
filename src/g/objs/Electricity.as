package g.objs{
	import flash.display.MovieClip;
	import g.MyData;
	import g.objs.StandardObject;
	import framework.objs.GameObject;
	import framework.game.Game;
	import Box2D.Dynamics.b2Body;
	import framework.utils.Box2dUtil;
	import framework.objs.Clip;
	import flash.utils.getQualifiedClassName;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import Box2D.Dynamics.b2World;
	/**电流*/
	public class Electricity extends StandardObject{
		public static function create(childMc:MovieClip,viewDefName:String,world:b2World):Electricity{
			var game:Game=Game.getInstance();
			var info:*={};
			info.body=Box2dUtil.createBox(childMc.width,childMc.height,childMc.x,childMc.y,world,MyData.ptm_ratio);
			info.view=Clip.fromDefName(viewDefName,true);
			info.view.transform=childMc.transform;
			info.viewParent=game.global.layerMan.items2Layer;
			return game.createGameObj(new Electricity(),info) as Electricity;
		}
		public function Electricity(){ super(); }
		
		override protected function init(info:* = null):void{
			super.init(info);
			_body.SetType(b2Body.b2_staticBody);
			_body.SetSensor(true);
		}
	};

}