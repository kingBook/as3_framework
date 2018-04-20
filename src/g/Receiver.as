package g{
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.NetDataEvent;
	import framework.game.Game;
	import framework.objs.GameObject;
	import g.MyGame;
	import g.objs.MyObj;
	import g.ui.UITween;
	
	public class Receiver extends MyObj{
		private var _stage:Stage;
		
		public function Receiver(){
			super();
		}
		
		public static function create(stage:Stage):Receiver{
			return Game.getInstance().createGameObj(new Receiver(),{stage:stage}) as Receiver;
		}
		
		override protected function init(info:* = null):void{
			//destroyAll时不销毁
			GameObject.dontDestroyOnDestroyAll(this);
			_stage=info.stage;
			_stage.addEventListener("playSound",eventHandler);
			super.init(info);
		}
		
		private function eventHandler(e:NetDataEvent):void{
			switch (e.type){
				case "playSound":
					var name:String=e.info.name;
					var volume:Number=e.info.volume;
					_game.global.soundMan.play(name,volume);
					break;
				default:
			}
		}
		
		override protected function onDestroy():void{
			_stage.removeEventListener("playSound",eventHandler);
			_stage=null;
			super.onDestroy();
		}
		
		
		
	};

}