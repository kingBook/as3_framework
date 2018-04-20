package g.objs{
	import Box2D.Dynamics.b2Body;
	import flash.display.MovieClip;
	import framework.game.Game;
	import framework.objs.GameObject;
	import framework.utils.Box2dUtil;
	import framework.utils.LibUtil;
	import g.objs.MovableObject;
	import g.MyData;
	import g.events.MyEvent;
	import Box2D.Dynamics.b2World;
	/**打开传送门的钥匙*/
	public class TeleportKey extends MovableObject{
		
		public static function create(childMc:MovieClip,viewDefName:String,world:b2World):TeleportKey{
			var nameList:Array=childMc.name.split("_");
			//名称_颜色_开关名
			//key_yellow_s11
			var game:Game=Game.getInstance();
			var info:*={};
			info.body=Box2dUtil.createBox(childMc.width,childMc.height,childMc.x,childMc.y,world,MyData.ptm_ratio);
			info.view=LibUtil.getDefMovie(viewDefName);
			info.view.transform=childMc.transform;
			info.myName=nameList[2];
			game.global.layerMan.items3Layer.addChild(info.view);
			return game.createGameObj(new TeleportKey(),info) as TeleportKey;
		}
		
		public function TeleportKey(){ super(); }
		
		private var _myName:String;
		private var _teleport:Teleport;//要打开的传送门
		private var _isOpenTping:Boolean;//是否正在打开传送门
		override protected function init(info:* = null):void{
			super.init(info);
			_myName=info.myName;
			_body.SetSensor(true);
			_body.SetType(b2Body.b2_kinematicBody);
			
			_game.addEventListener(MyEvent.CREATE_MAP_COMPLETE,createMapComplete);
		}
		
		private function createMapComplete(e:MyEvent):void{
			e.target.removeEventListener(MyEvent.CREATE_MAP_COMPLETE,createMapComplete);
			
			var tps:Vector.<GameObject>=_game.getGameObjList(Teleport);
			var i:int=tps.length;
			while (--i>=0){
				var tp:Teleport=tps[i] as Teleport;
				if(tp.ctrlMySwitcherName==_myName && !tp.isOpen){
					_teleport=tp;
					break;
				}
			}
		}
		
		
		public function openTp():void{
			if(_isOpenTping)return;
			_isOpenTping=true;
			MoveTo.create2(_body,_teleport.x/MyData.ptm_ratio,_teleport.y/MyData.ptm_ratio,1,openComplete);
		}
		
		private function openComplete():void{
			_teleport.control();
			GameObject.destroy(this);
		}
		
		
		
		
	};

}