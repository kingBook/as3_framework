package g.ui {
	import flash.display.MovieClip;
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import framework.game.Game;
	import framework.events.FrameworkEvent;
	import framework.objs.GameObject;
	import framework.utils.ButtonEffect;
	import framework.utils.FuncUtil;
	import framework.utils.LibUtil;
	import g.events.MyEvent;
	import g.MyGame;
	import g.objs.MyObj;
	
	/**
	 * 故事剧情画面
	 * @author kingBook
	 * 2015-02-25 10:13
	 */
	public class StoryUI extends MyObj {
		private var _view:Sprite;
		private var _animation:MovieClip;
		private var _skip:SimpleButton;
		
		public static function create():void{
			var game:Game=Game.getInstance();
			game.createGameObj(new StoryUI());
		}
		
		public function StoryUI() {
			super();
		}
		
		override protected function init(info:*=null):void{
			_view = LibUtil.getDefSprite("StoryUI_mc");
			_animation = _view.getChildByName("animation")as MovieClip;
			_skip = _view.getChildByName("skip") as SimpleButton;
			_game.global.layerMan.uiLayer.addChild(_view);
			ButtonEffect.to(_skip, { scale: { }} );
			_skip.addEventListener(MouseEvent.CLICK, clickHandler);
			//_game.global.soundMan.stopAll();
			//_game.global.soundMan.playLoop("漫画",0.7);
		}
		
		private function clickHandler(e:MouseEvent):void {
			e.target.removeEventListener(MouseEvent.CLICK,clickHandler);
			var myGame:MyGame=_myGame;
			GameObject.destroy(this);
			//myGame.gotoLevel(1);
			myGame.gotoSelectLevel(false);
		}
		
		private function playFinish(e:Event):void {
			//_animation.addFrameScript(_animation.totalFrames-1,null);
			var myGame:MyGame=_myGame;
			GameObject.destroy(this);
			myGame.gotoLevel(1);
			
		}
		
		override protected function onDestroy():void {
			if(_skip)_skip.removeEventListener(MouseEvent.CLICK,clickHandler);
			ButtonEffect.killOf(_skip);
			_animation&&_animation.removeEventListener(Event.COMPLETE,playFinish);
			FuncUtil.removeChild(_animation);
			FuncUtil.removeChild(_view);
			_skip = null;
			_view = null;
			_animation = null;
			super.onDestroy();
		}
		
	}

}