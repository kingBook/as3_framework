package g.components{
	import framework.objs.Component;
	import framework.objs.GameObject;
	import g.components.SwitchBehavior;

	public class SwitchBehavior extends Component{
		private const e_isOnce:uint	    =0x000001;//是否只触发一次
		private const e_isTriggered:uint=0x000002;//已经触发过了
		private const e_isOn:uint       =0x000004;//
		private var _flags:uint;
		
		private var _myName:String;
		private var _onCallback:Function;
		private var _offCallback:Function;

		public static function create(gameObj:GameObject,name:String,onCallback:Function,offCallback:Function,isOnce:Boolean=false):SwitchBehavior{
			var info:*={};
			info.name=name;
			info.onCallback=onCallback;
			info.offCallback=offCallback;
			info.isOnce=isOnce;
			return gameObj.addComponent(SwitchBehavior,info) as SwitchBehavior;
		}

		override protected function init(info:*=null):void{
			super.init(info);
			_myName=info.name;
			_onCallback=info.onCallback;
			_offCallback=info.offCallback;
			if(info.isOnce){
				_flags|=e_isOnce;
			}
		}
		public function control(isAuto:Boolean=false,isDoOn:Boolean=false):void{
			if((_flags&e_isOnce)>0 && (_flags&e_isTriggered)>0)return;
			_flags|=e_isTriggered;//设置为已经触发过
			
			if(isAuto){
				if((_flags&e_isOn)>0)off(); else on();
			}else{
				if(isDoOn)on();else off();
			}
		}
		
		private function on():void{
			if((_flags&e_isOn)>0)return;
			_flags|=e_isOn;
			if(_onCallback!=null)_onCallback();
		}
		
		private function off():void{
			if((_flags&e_isOn)==0)return;
			_flags&=~e_isOn;
			if(_offCallback!=null)_offCallback();
		}
		
		override protected function onDestroy():void{
			_onCallback=null;
			_offCallback=null;
			super.onDestroy();
		}

		public function get name():String{
			return _myName;
		}
		
	}
}