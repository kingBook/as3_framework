package g.objs{
	import framework.game.Game;
	import g.ResizeManager;
	import flash.events.Event;
	import flash.display.Sprite;
	import flash.geom.Point;
	
	public class FitGameLayer extends MyObj{
		
		private var _resizeMan:ResizeManager;
		private var _fitSprite:Sprite;
		private var _recordFitSpriteScale:Point;
		
		public static function create():FitGameLayer{
			var game:Game=Game.getInstance();
			var info:*={};
			return game.createGameObj(new FitGameLayer(),info) as FitGameLayer;
		}
		
		public function FitGameLayer(){
			super();
		}
		
		override protected function init(info:* = null):void{
			super.init(info);
			_resizeMan=_myGame.myGlobal.resizeMan;
			_fitSprite=_game.global.layerMan.gameLayer;
			_recordFitSpriteScale=new Point(_fitSprite.scaleX,_fitSprite.scaleY);
			_game.global.stage.addEventListener(Event.RESIZE,onResize);
			onResize();
		}
		
		private function onResize(e:Event=null):void{
			_fitSprite.scaleY=_resizeMan.curHScale;
			_fitSprite.scaleX=_fitSprite.scaleY;
		}
		
		override protected function onDestroy():void{
			_game.global.stage.removeEventListener(Event.RESIZE,onResize);
			_fitSprite.scaleX=_recordFitSpriteScale.x;
			_fitSprite.scaleY=_recordFitSpriteScale.y;
			_resizeMan=null;
			_fitSprite=null;
			super.onDestroy();
		}
		
		
	};
}