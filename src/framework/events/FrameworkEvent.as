package framework.events {
	import flash.events.Event;
	
	public class FrameworkEvent extends Event{
		public static const CHANGE_CURRENT_WORLD:String = "changeCurrentWorld";
		public static const MUTE:String="mute";
		public static const MUTE_ONCE:String="muteOnce";
		public static const MUTE_LOOP:String="muteLoop";
		
		/**消毁所有事件*/
		public static const DESTROY_ALL:String = "destroyAll";
		private static var _destroyAllEvt:FrameworkEvent;
		public static function getDestroyAllEvent(info:* = null):FrameworkEvent {
			_destroyAllEvt||=new FrameworkEvent(DESTROY_ALL);
			_destroyAllEvt.info = info;
			return  _destroyAllEvt;
		}
		
		/**暂停事件*/
		public static const PAUSE:String = "pause";
		private static var _pauseEvt:FrameworkEvent;
		public static function getPauseEvent(info:*= null):FrameworkEvent {
			_pauseEvt ||= new FrameworkEvent(PAUSE);
			_pauseEvt.info = info;
			return  _pauseEvt;
		}
		
		/**恢复事件*/
		public static const RESUME:String = "resume";
		private static var _resumeEvt:FrameworkEvent;
		public static function getResumeEvent(info:*= null):FrameworkEvent {
			_resumeEvt ||= new FrameworkEvent(RESUME);
			_resumeEvt.info = info;
			return _resumeEvt;
		}
		
		public var info:*;
		public function FrameworkEvent(type:String,info:*=null,bubbles:Boolean=false,cancelable:Boolean=false){
			this.info = info;
			super(type,bubbles,cancelable);	
		}
		
		override public function clone():Event {
			return new FrameworkEvent(type,info,bubbles,cancelable);
		}

		override public function toString():String { 
			return formatToString("FrameworkEvent", "type", "info", "bubbles", "cancelable", "eventPhase"); 
		}

	};
}