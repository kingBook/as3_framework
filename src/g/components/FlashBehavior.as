package g.components{
	import framework.objs.Component;
	import framework.objs.GameObject;
	import g.MyData;
	/**人物无敌闪烁行为*/
	public class FlashBehavior extends Component{
		
		public static function create(gameObject:GameObject):FlashBehavior{
			return gameObject.addComponent(FlashBehavior) as FlashBehavior;
		}
		
		/**target必须有visible属性*/
		public function flashHandler(target:*,time:Number=1.5,complete:Function=null,completeParams:Array=null):void{
			_target=target;
			_time=time;
			_count=int(time*MyData.frameRate);
			_isFlashing=true;
			_complete=complete;
			_completeParams=completeParams;
		}
		
		override protected function update():void{
			if(_count>0){
				_count--;
				_target.visible=!_target.visible;
			}else{
				if(_isFlashing){
					_isFlashing=false;
					_target.visible=true;
					if(_complete!=null)_complete.apply(null,_completeParams);
				}
			}
		}
		
		override protected function onDestroy():void{
			_target=null;
			_complete=null;
			_completeParams=null;
			super.onDestroy();
		}
		
		public function get isFlashing():Boolean{return _isFlashing;}
		
		private var _count:int;
		private var _target:*;
		private var _time:Number;
		private var _isFlashing:Boolean;
		private var _complete:Function;
		private var _completeParams:Array;
		
	};

}