package g {
	import flash.display.Stage;
	import framework.game.Game;
	import framework.events.FrameworkEvent;
	import framework.objs.GameObject;
	import framework.system.Global;
	
	public class MyGlobal extends Global {
		private var _receiver:Receiver;
		private var _resizeMan:ResizeManager;
		private var _gameLevel:int;
		private var _isGameing:Boolean;
		private var _isDisableKeyboard:Boolean;
		private var _resetPointList:Array;
		public var starNum:int;
		
		public function MyGlobal() {
			super();
		}
		public static function create(main:Main,gameRoot:GameRoot,stage:Stage):MyGlobal{
			var game:Game=Game.getInstance();
			var info:*={};
			info.main=main;
			info.gameRoot=gameRoot;
			info.stage=stage;
			return game.createGameObj(new MyGlobal(),info) as MyGlobal;
		}
		override protected function init(info:* = null):void{
			super.init(info);
			_game.addEventListener(FrameworkEvent.PAUSE, pauseResumeHandler);
			_game.addEventListener(FrameworkEvent.RESUME, pauseResumeHandler);
			_receiver=Receiver.create(_stage);
			_resizeMan=ResizeManager.create(_stage,MyData.designW,MyData.designH);
		}
		public function gotoLevel(level:int):void {
			_gameLevel=level;
			_isGameing=true;
			_isDisableKeyboard=false;
			_main["gameLevel"] = _gameLevel;
			
			_resetPointList = [];
			starNum=0;
			
		}
		public function destroyCurLevel():void{
			_resetPointList.length = 0;
		}
		public function win():void {
			_isGameing=false;
			_isDisableKeyboard=true;
		}
		public function gameFailure():void {
			_isGameing=false;
			_isDisableKeyboard=true;
		}
		private function pauseResumeHandler(e:FrameworkEvent):void {
			_isDisableKeyboard=_game.pause;
		}
		override protected function onDestroy():void{
			GameObject.destroy(_receiver);
			GameObject.destroy(_resizeMan);
			_receiver=null;
			_resizeMan=null;
			super.onDestroy();
		}
		
		public function get resizeMan():ResizeManager{return _resizeMan;}
		public function get resetPointList():Array { return _resetPointList; }
		public function get gameLevel():int { return _gameLevel; }
		public function get isDisableKeyboard():Boolean { return _isDisableKeyboard; }
		public function get isGameing():Boolean{ return _isGameing; }
	}

}