package g.objs{
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	import framework.events.FrameworkEvent;
	import framework.game.Game;
	import g.events.MyEvent;
	import g.objs.MyObj;
	/**秒计时器,倒计时指定秒数完成后自动停止和重置,需要手动调用start()开始计时*/
	public class SecondTimer extends MyObj{
		private var _totalSecond:int;
		private var _currentDownCount:int;
		private var _onTimer:Function;
		private var _onComplete:Function;
		private var _timer:Timer;
		private var _isStop:Boolean;
		
		/**
		 * 创建一个秒计时器
		 * @param	totalSecond 总秒数
		 * @param	deltaTime 一秒的增量
		 * @param	onTimer function(second:int):void; 如果delaySecond=5，则从4~0都执行onTimer函数
		 * @param	onComplete function():void;
		 * @return
		 */
		public static function create(totalSecond:int,deltaTime:Number=1,onTimer:Function=null,onComplete:Function=null):SecondTimer{
			var game:Game=Game.getInstance();
			var info:*={};
			info.totalSecond=totalSecond;
			info.deltaTime=deltaTime;
			info.onTimer=onTimer;
			info.onComplete=onComplete;
			return game.createGameObj(new SecondTimer(),info) as SecondTimer;
		}
		
		public function SecondTimer(){
			super();
		}
		
		override protected function init(info:* = null):void{
			super.init(info);
			_totalSecond=info.totalSecond;
			_currentDownCount=_totalSecond;
			_onTimer=info.onTimer;
			_onComplete=info.onComplete;
			_timer=new Timer(info.deltaTime*1000,int.MAX_VALUE);
			_timer.addEventListener(TimerEvent.TIMER,timerHandler);
			_game.addEventListener(FrameworkEvent.PAUSE,pauseOrResumeHandler);
			_game.addEventListener(FrameworkEvent.RESUME,pauseOrResumeHandler);
		}
		
		private function timerHandler(e:TimerEvent):void{
			_currentDownCount--;
			if(_onTimer!=null){
				_onTimer(_currentDownCount);
			}
			if(_currentDownCount<=0){
				if(_onComplete!=null)_onComplete();
				pause();
			}
		}
		
		/**开始计时*/
		public function start():void{
			if(_isStop)return;
			_timer.start();
		}
		
		/**重置*/
		public function reset():void{
			_currentDownCount=_totalSecond;
			_timer.reset();
		}
		
		/**暂停计时*/
		public function pause():void{
			if(_timer)_timer.stop();
		}
		
		/**永远停止*/
		public function stop():void{
			_isStop=true;
			pause();
		}
		
		private function pauseOrResumeHandler(e:FrameworkEvent):void{
			if(e.type==FrameworkEvent.PAUSE){
				pause();
			}else{
				if(currentCount<_totalSecond){
					//只有计时器在运行时才恢复
					start();
				}
			}
		}
		
		override protected function onDestroy():void{
			_game.removeEventListener(FrameworkEvent.PAUSE,pauseOrResumeHandler);
			_game.removeEventListener(FrameworkEvent.RESUME,pauseOrResumeHandler);
			pause();
			_timer.removeEventListener(TimerEvent.TIMER,timerHandler);
			_onTimer=null;
			_onComplete=null;
			_timer=null;
			super.onDestroy();
		}
		
		/**倒计时秒数*/
		public function get currentDownCount():int{ return _currentDownCount; }
		/**经过的时间秒数*/
		public function get currentCount():int{return _timer.currentCount;}
		
	};

}