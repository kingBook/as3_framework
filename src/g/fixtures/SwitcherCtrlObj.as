package g.fixtures {
	import g.events.MyEvent;
	import g.objs.MyObj;
	
	/**开关控制的对象*/
	public class SwitcherCtrlObj extends MyObj{
		protected var _initIsOpen:Boolean;
		protected var _isOpen:Boolean;
		protected var _isGotoEnd:Boolean;
		protected var _ctrlMySwitcherName:String;
		public function SwitcherCtrlObj(){ super(); }
		
		override protected function init(info:* = null):void{
			_game.addEventListener(MyEvent.CREATE_MAP_COMPLETE,createMapComplete);
		}
		
		private function createMapComplete(e:MyEvent):void{
			_game.removeEventListener(MyEvent.CREATE_MAP_COMPLETE,createMapComplete);
			_initIsOpen=_isOpen;
		}
		
		/**控制接口*/
		public function control(isAuto:Boolean=false,isDoOpen:Boolean=false):void{
			if(isAuto){
				if(_isOpen)close();else open();
			}else{
				if(isDoOpen)open();else close();
			}
		}
		
		protected function open():void{}
		
		protected function close():void{}
		
		override protected function onDestroy():void{
			_game.removeEventListener(MyEvent.CREATE_MAP_COMPLETE,createMapComplete);
			super.onDestroy();
		}
		
		public function get ctrlMySwitcherName():String { return _ctrlMySwitcherName; }
		public function get initIsOpen():Boolean{ return _initIsOpen; }
	};

}