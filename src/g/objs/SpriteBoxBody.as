package g.objs{
	import framework.objs.GameObject;
	import framework.game.Game;
	import Box2D.Dynamics.b2Body;
	import framework.utils.Box2dUtil;
	import flash.display.Sprite;
	import flash.utils.getQualifiedClassName;
	import g.MyData;
	import Box2D.Dynamics.b2World;

	public class SpriteBoxBody extends GameObject{
		public static function create(sprite:Sprite,world:b2World,userDataType:String=null,isSensor:Boolean=false,bodyType:uint=0):SpriteBoxBody{
			var game:Game=Game.getInstance();
			var info:*={};
			info.userDataType=userDataType;
			info.isSensor=isSensor;
			info.bodyType=bodyType;
			info.body=Box2dUtil.createBoxFromSprite(sprite,world,MyData.ptm_ratio);
			return game.createGameObj(new SpriteBoxBody(),info) as SpriteBoxBody;
		}
		private var _body:b2Body;
		public function SpriteBoxBody(){
			super();
		}
		override protected function init(info:*=null):void{
			_body=info.body;
			var userDataType:String=info.userDataType;
			if(!userDataType){
				var qclassName:String=getQualifiedClassName(this);
				userDataType=qclassName.substr(qclassName.lastIndexOf(":")+1);
			}
			_body.SetUserData({type:userDataType,thisObj:this});
			_body.SetType(info.bodyType);
			_body.SetSensor(info.isSensor);
		}
		override protected function onDestroy():void{
			_body.Destroy();
			_body=null;
			super.onDestroy();
		}
		
	};
}