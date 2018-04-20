package framework.system {
	import flash.display.Stage;
	import flash.events.Event;
	import flash.utils.getTimer;
	import framework.game.Game;
	import framework.objs.GameObject;
	import framework.system.SystemKeyboard;

	public class KeyboardManager extends GameObject{
		private var _stage:Stage;
		private var _keys:SystemKeyboard;
		private var _lastTime:int;
		private var _isRelease:Boolean;
		private var _longPressTimes:*={};
		private var _pTimes:*={};
		
		public static function create():KeyboardManager{
			var game:Game=Game.getInstance();
			return game.createGameObj(new KeyboardManager()) as KeyboardManager;
		}
		
		public function KeyboardManager(){
			super();
		}
		
		override protected function init(info:* = null):void{
			super.init(info);
			_stage=_game.global.stage;
			
			_keys=SystemKeyboard.create();
			GameObject.dontDestroyOnDestroyAll(_keys);
			_keys.bind(_stage);
			_stage.focus = _stage;
			_stage.addEventListener(Event.DEACTIVATE, deActivateHandler);
		}
		
		private function deActivateHandler(e:Event):void { _keys.reset(); }
		override protected function foreverUpdate():void{
			super.foreverUpdate();
			 _keys.updateKeyStates();
			 
			for(var k:String in _longPressTimes){
				if(_keys.justReleased(k)){
					delete _longPressTimes[k];
				}
			}
			for(k in _pTimes){
				if(_keys.justReleased(k)){
					delete _pTimes[k];
				}
			}
			 
		}
		public function p(key:String):Boolean { return _keys.pressed(key); }
		public function jp(key:String):Boolean { return _keys.justPressed(key); }
		public function jr(key:String):Boolean { return _keys.justReleased(key); }
		
		public function p_keys(keys:Vector.<String>):Boolean{
			var i:int=keys.length;
			while (--i>=0){
				if(_keys.pressed(keys[i]))return true;
			}
			return false;
		}
		public function jp_keys(keys:Vector.<String>):Boolean{
			var i:int=keys.length;
			while (--i>=0){
				if(_keys.justPressed(keys[i]))return true;
			}
			return false;
		}
		public function jr_keys(keys:Vector.<String>):Boolean{
			var i:int=keys.length;
			while (--i>=0){
				if(_keys.justReleased(keys[i]))return true;
			}
			return false;
		}
		
		public function double(key:String):Boolean {
			var doubleKey:Boolean;
			if (jr(key)) {
				_isRelease = true;
			} else if (jp(key)) {
				if (_lastTime - (_lastTime=getTimer()) + 300 > 0 && _isRelease) {
					doubleKey = true;
				}
				_isRelease = false;
			}
			return doubleKey;
		}
		
		
		/**
		 * 是否长按下某一个键
		 * @param	key 键名
		 * @param	maxTime 判断长按的时间<ms>
		 * @return
		 */
		public function longPress(key:String,maxTime:int=300):Boolean{
			if(!_longPressTimes[key]){
				if(p(key)) _longPressTimes[key]=getTimer();
			}else{
				if(p(key)){
					if(getTimer()-_longPressTimes[key]>=maxTime){
						delete _longPressTimes[key];
						return true;
					}
				}else{
					delete _longPressTimes[key];
				}
			}
			return false;
		}
		
		public function lp_keys(keys:Vector.<String>,maxTime:int=300):Boolean{
			var i:int=keys.length;
			while (--i>=0){
				if(longPress(keys[i],maxTime))return true;
			}
			return false;
		}
		
		/**返回按下某键的时间*/
		public function pTime(key:String):int{
			if(_keys.pressed(key)){
				_pTimes[key]||=getTimer();
				return getTimer()-_pTimes[key];
			}
			return 0;
		}
		/**返回keys里按下最久的一个时间*/
		public function pTime_keys(keys:Vector.<String>):int{
			var ret:int=0;
			var i:int=keys.length;
			while (--i>=0){
				ret=Math.max(pTime(keys[i]),ret);
			}
			return ret;
		}
		
		override protected function onDestroy():void{
			_stage.removeEventListener(Event.DEACTIVATE, deActivateHandler);
			if (_keys) {
				GameObject.destroy(_keys);
				_keys.unbind(_stage);
				_keys = null;
			}
			_longPressTimes = null;
			_pTimes=null;
			_stage = null;
			super.onDestroy();
		}
		
	};
}