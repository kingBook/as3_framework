package g.objs{
	import g.objs.MovableObject;
	import g.components.TwoPtMotionBehavior;
	/**两点间反复自由运动的对象 */
	public class TwoPtMotionObj extends MovableObject{
		protected var _twoPtBehavior:TwoPtMotionBehavior;
		override protected function init(info:*=null):void{
			super.init(info);
			_twoPtBehavior=TwoPtMotionBehavior.create(this,_body,info.pos0,info.pos1,info.target,info.speed,info.dt);
		}
		override protected function fixedUpdate():void{
			super.fixedUpdate();
			if(_twoPtBehavior.gotoTarget()){
				_twoPtBehavior.swapTarget();
			}
		}
		override protected function onDestroy():void{
			removeComponent(_twoPtBehavior);
			_twoPtBehavior=null;
			super.onDestroy();
		}
	}
}