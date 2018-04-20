package g.events{
	import framework.events.FrameworkEvent;
	import flash.events.Event;
	public class MyEvent extends FrameworkEvent{
		
		public static const CREATE_MAP_COMPLETE:String = "createMapComplete";
		
		public function MyEvent(type:String, info:*=null, bubbles:Boolean=false, cancelable:Boolean=false){
			super(type,info,bubbles,cancelable);
		}

		override public function clone():Event{
			return new MyEvent(type,info,bubbles,cancelable);
		}

		override public function toString():String{ 
			return formatToString("MyEvent", "type", "info", "bubbles", "cancelable", "eventPhase"); 
		}
		
	};

}