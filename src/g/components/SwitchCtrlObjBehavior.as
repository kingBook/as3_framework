package g.components{
	import framework.objs.Component;
	import framework.objs.GameObject;

	public class SwitchCtrlObjBehavior extends Component{
		private const e_initIsOn:uint=0x000001;
		private const e_isOn:uint  =0x000002;
		private var _flags:uint;

		private var _ctrlMyNames:String;
		private var _onCallback:Function;
		private var _offCallback:Function;

		public static function create(gameObj:GameObject,ctrlMyNames:String,onCallback:Function,offCallback:Function,initStateIsOn:Boolean):SwitchCtrlObjBehavior{
			var info:*={};
			info.ctrlMyNames=ctrlMyNames;
			info.onCallback=onCallback;
			info.offCallback=offCallback;
			info.initStateIsOn=initStateIsOn;
			return gameObj.addComponent(SwitchCtrlObjBehavior,info)as SwitchCtrlObjBehavior;
		}

		override protected function init(info:* = null):void{
			super.init(info);
			_ctrlMyNames=info.ctrlMyNames;
			_onCallback=info.onCallback;
			_offCallback=info.offCallback;
			if(info.initStateIsOn){
				_flags|=e_isOn;
				_flags|=e_initIsOn;
			}
		}
		
		/**控制接口*/
		public function control(isAuto:Boolean=false,isDoOn:Boolean=false):void{
			if(isAuto){
				if((_flags&e_isOn)>0)off();else on();
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
		
		public function get ctrlMyNames():String { return _ctrlMyNames; }
		public function get initIsOn():Boolean{ return (_flags&e_initIsOn)>0; }
		
		
	}
}