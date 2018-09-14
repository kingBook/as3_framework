package g.components{
	import framework.objs.Component;
	import framework.objs.GameObject;
	import g.MyData;
	/**人物无敌闪烁行为*/
	public class FlashBehavior extends Component{
		
		public static function create(gameObject:GameObject):FlashBehavior{
			return gameObject.addComponent(FlashBehavior) as FlashBehavior;
		}
		
		private var _oldTargetAlpha:Number;
		
		/**target必须有alpha属性*/
		public function flashHandler(target:*,time:Number=1.5,complete:Function=null,completeParams:Array=null):void{
			_target=target;
			_time=time;
			_count=int(time*MyData.frameRate);
			_isFlashing=true;
			_complete=complete;
			_completeParams=completeParams;
			_oldTargetAlpha=_target.alpha;
		}
		
		override protected function update():void{
			if(_count>0){
				_count--;
				if(_target.alpha>0)_target.alpha=0;
				else _target.alpha=1;
			}else{
				if(_isFlashing){
					_isFlashing=false;
					 _target.alpha=_oldTargetAlpha;
					if(_complete!=null)_complete.apply(null,_completeParams);
				}
			}
		}
		
		override protected function onDestroy():void{
			if(_target){
				_target.alpha=_oldTargetAlpha;
				_target=null;
			}
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