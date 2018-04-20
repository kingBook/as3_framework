package framework.game{
	import flash.utils.Dictionary;
	import flash.utils.clearInterval;
	import framework.events.FrameworkEvent;
	import framework.game.Game;
	import framework.namespaces.frameworkInternal;
	use namespace frameworkInternal;
	/**延时调度代理*/
	public class IntervalProxy{
		
		private var _game:Game;
		private var _scheduleDict:Dictionary;
		
		public function IntervalProxy(game:Game){
			_game=game;
			_game.addEventListener(FrameworkEvent.PAUSE,pauseRoResumeHandler);
			_game.addEventListener(FrameworkEvent.RESUME,pauseRoResumeHandler);
			_scheduleDict=new Dictionary();
		}
		
		/**指定的间隔(interval 秒)，重复调度(repeat+1)次函数*/
		frameworkInternal function schedule(func:Function,interval:Number,repeat:int,params:Array=null):void{
			if(isHasSchdule(func))return;
			if(repeat<0)throw new Error("参数repeat不能小于0");
			var schduleObj:ScheduleObject=new ScheduleObject(removeScheduleObject,func,interval,repeat,params);
			schduleObj.schedule();
			_scheduleDict[func]=schduleObj;
		}
		private function removeScheduleObject(func:Function):void{
			delete _scheduleDict[func];
		}
		
		/**指定的间隔(delay 秒)，调度一次函数*/
		frameworkInternal function scheduleOnce(func:Function,delay:Number=0,params:Array=null):void{
			schedule(func,delay,0,params);
		}
		
		/**移除函数调度*/
		frameworkInternal function unschedule(func:Function):void{
			if(!isHasSchdule(func))return;
			var schduleObj:ScheduleObject=_scheduleDict[func] as ScheduleObject;
			schduleObj.unschedule();
		}
		
		/**判断指定函数是否正在调度中*/
		frameworkInternal function isHasSchdule(func:Function):Boolean{
			return Boolean(_scheduleDict[func]);
		}
		
		private function pauseRoResumeHandler(e:FrameworkEvent):void{
			var isPause:Boolean=e.type==FrameworkEvent.PAUSE;
			for each(var obj:ScheduleObject in _scheduleDict){
				if(isPause)obj.pauseSchedule();
				else obj.resumeSchedule();
			}
		}
		
		frameworkInternal function destroy():void{
			_game.removeEventListener(FrameworkEvent.PAUSE,pauseRoResumeHandler);
			_game.removeEventListener(FrameworkEvent.RESUME,pauseRoResumeHandler);
			if(_scheduleDict){
				for (var k:* in _scheduleDict){
					delete _scheduleDict[k];
				}
				_scheduleDict=null;
			}
			_game=null;
		}
		
	};

}
import flash.utils.clearInterval;
import flash.utils.setInterval;
import framework.namespaces.frameworkInternal;
use namespace frameworkInternal;
class ScheduleObject{
	private var _removeCallback:Function;
	private var _func:Function;
	private var _interval:Number;
	private var _repeat:int;
	private var _params:Array;
	
	private var _intervalID:uint=0;
	
	private var _repeatCount:int;
	
	public function ScheduleObject(removeCallback:Function,func:Function,interval:Number,repeat:int,params:Array=null){
		_removeCallback=removeCallback;
		_func=func;
		_interval=interval; if(_interval<0)_interval=0;
		_repeat=repeat;
		_params=params;
	}
	
	frameworkInternal function pauseSchedule():void{
		unschedule(false);
	}
	
	frameworkInternal function resumeSchedule():void{
		schedule();
	}
	
	frameworkInternal function unschedule(isRemove:Boolean=true):void{
		clearInterval(_intervalID);
		if(isRemove)_removeCallback.call(null,_func);
	}
	
	frameworkInternal function schedule():void{
		_intervalID=setInterval(scheduleCallback,_interval*1000);
	}
	
	private function scheduleCallback():void{
		_repeatCount++;
		if(_repeatCount>_repeat){
			clearInterval(_intervalID);
			_removeCallback.call(null,_func);
		}
		_func.apply(null,_params);
	}
	
	frameworkInternal function destroy():void{
		clearInterval(_intervalID);
		_removeCallback=null;
		_func=null;
		_params=null;
	}
}