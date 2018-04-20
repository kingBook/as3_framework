package g.objs{
	import flash.display.MovieClip;
	import framework.game.Game;
	import framework.objs.GameObject;
	import framework.utils.LibUtil;
	
	public class GameHint extends GameObject{
		public static function create():void{
			var game:Game=Game.getInstance();
			var info:*={};
			game.createGameObj(new GameHint(),info);
		}
		
		public function GameHint(){
			super();
		}
		
		private var _mc:MovieClip;
		private var _id:int;
		override protected function init(info:* = null):void{
			_mc=LibUtil.getDefMovie("GameHint_view");
			_mc.stop();
			_game.global.layerMan.uiLayer.addChild(_mc);
			hide();
			
		}

		
		public function hide():void{
			_mc.visible=false;
		}
		public function show(frame:int):void{
			_mc.gotoAndStop(frame);
			_mc.visible=true;
		}
		
		override protected function onDestroy():void{
			_mc.parent.removeChild(_mc);
			_mc=null;
			super.onDestroy();
		}
		
	};

}