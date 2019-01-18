package framework.debug{
	import flash.display.DisplayObjectContainer;
	import framework.game.Game;
	import framework.objs.GameObject;
	import framework.utils.FuncUtil;
	
	public class FPSDebug extends GameObject{
		
		private var _fpsSprite:FPSSprite;
		
		public static function create(parent:DisplayObjectContainer):*{
			var game:Game=Game.getInstance();
			var info:*={};
			info.parent=parent;
			return game.createGameObj(new FPSDebug(),info);
		}
		
		public function FPSDebug(){
			super();
		}
		
		override protected function init(info:* = null):void{
			super.init(info);
			_fpsSprite=new FPSSprite();
			info.parent.addChild(_fpsSprite);
		}
		
		override protected function onDestroy():void{
			FuncUtil.removeChild(_fpsSprite);
			_fpsSprite=null;
			super.onDestroy();
		}
		
	};

}