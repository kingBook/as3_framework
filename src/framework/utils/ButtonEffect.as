/**
 * ButtonEffect.to(mc,{glow:{color:0x00FFFF},isSwapChildId:true});
 * glow:Object
 * params:
 * 	color:uint;
 * --------------------------------------------
 * ButtonEffect.to(mc,{scale:{f:0.2},isSwapChildId:true});
 * scale:Object
 * params:
 *	f:Number;//0~1
 */

package framework.utils {
	import flash.display.DisplayObject;
	import flash.events.MouseEvent;
	public final class ButtonEffect {
		private static var _bfArr:Array = [];
		//private var _tweenMax:TweenMax;
		private var _target:DisplayObject;
		private var _vars:Object;
		private var _noteScaleX:Number, _noteScaleY:Number;
		
		public function ButtonEffect(target:DisplayObject, vars:Object) {
			if (target == null) return;
			_target = target;
			_noteScaleX = _target.scaleX;
			_noteScaleY = _target.scaleY;
			_vars = vars;
			addOrRemoveEventListener();
			_bfArr.push( { target: _target, bf: this } );
		}
		
		private function addOrRemoveEventListener(remove:Boolean = false):void {
			var methodName:String = remove ? "removeEventListener" : "addEventListener";
			_target[methodName](MouseEvent.ROLL_OVER, rollOverHandler);
			_target[methodName](MouseEvent.ROLL_OUT, rollOutHandler);
		}
		
		private function rollOverHandler(e:MouseEvent):void {
			if (e.target != _target) {
				return;
			}
			if (_vars["glow"]) {
				addOrRemoveFilter(true);
			}
			if (_vars["scale"]) {
				var f:Number = Number(_vars.scale.f) ? Number(_vars.scale.f) : 0.2;
				_target.scaleX = _noteScaleX + f;
				_target.scaleY = _noteScaleY + f;
				var isSwapChildId:Boolean = _vars["isSwapChildId"] != undefined?_vars["isSwapChildId"]:true;
				if (_target.parent && isSwapChildId) {
					_target.parent.setChildIndex(_target, _target.parent.numChildren - 1);
				}
			}
		}
		
		private function rollOutHandler(e:MouseEvent):void {
			if (e.target != _target) {
				return;
			}
			if (_vars["glow"]) {
				addOrRemoveFilter(false);
			}
			if (_vars["scale"]) {
				_target.scaleX = _noteScaleX;
				_target.scaleY = _noteScaleY;
			}
		}
		
		private function addOrRemoveFilter(add:Boolean):void {
			var color:uint = uint(_vars.glow.color) ? uint(_vars.glow.color) : 0x00FFFF;
			/*if (add)
				_tweenMax = TweenMax.to(_target, 0, {glowFilter: {alpha: 1, blurX: 10, blurY: 10, color: color, strength: 1}});
			else
				_tweenMax = TweenMax.to(_target, 0, {glowFilter: {alpha: 0, blurX: 0, blurY: 0, color: color, strength: 0}});*/
		}
		
		private function destroy():void {
			if(_target){
				_target.scaleX = _noteScaleX;
				_target.scaleY = _noteScaleY;
				addOrRemoveEventListener(true);
			}
			//TweenMax.killTweensOf(_tweenMax);
			//_tweenMax = null;
			_vars = null;
			_target = null;
		}
		
		/**
		 * ButtonEffect.to(mc,{glow:{color:0x00FFFF}});
		 * glow:Object
		 * params:
		 * 	color:uint;
		 * --------------------------------------------
		 * ButtonEffect.to(mc,{scale:{f:0.2},isSwapChildId:true});
		 * scale:Object
		 * params:
		 *	f:Number;//0~1
		 *
		 * @param	target
		 * @param	vars
		 * @return
		 */
		public static function to(target:DisplayObject, vars:Object):ButtonEffect {
			return new ButtonEffect(target, vars);
		}
		
		public static function killOf(disObj:DisplayObject):void {
			var i:int = _bfArr.length;
			while (--i >= 0) {
				var obj:Object = _bfArr[i];
				var target:DisplayObject = obj.target;
				var bf:ButtonEffect = ButtonEffect(obj.bf);
				if (target == disObj) {
					bf.destroy();
					break;
				}
			}
		}
		
		public static function killAll():void {
			var i:int = _bfArr.length;
			while (--i >= 0) {
				var obj:Object = _bfArr[i];
				var bf:ButtonEffect = ButtonEffect(obj.bf);
				bf.destroy();
				_bfArr.splice(i, 1);
			}
		}
	}

}