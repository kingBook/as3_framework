package{
	import flash.display.Stage;
	import flash.events.NetDataEvent;
	public class Sender{
		
		private var _stage:Stage;
		
		public function Sender(){
			super();
		}
		
		private static var _instance:Sender;
		public static function getInstance(stage:Stage):Sender{
			if(!_instance){
				_instance=new Sender();
				_instance.init(stage);
			}
			return _instance;
		}
		
		private function init(stage:Stage):void{
			_stage=stage;
		}
		
		public function playSound(name:String, volume:Number=1):void{
			_stage.dispatchEvent(new NetDataEvent("playSound",false,false,0,{name:name,volume:volume}));
		}
		
	};

}