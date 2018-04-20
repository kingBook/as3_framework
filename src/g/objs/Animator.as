package g.objs {
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import framework.game.Game;
	import framework.objs.Clip;
	import framework.game.UpdateType;
	import framework.objs.GameObject;
	import framework.utils.FuncUtil;
	/**
	 * ...
	 * @author kingBook
	 * 2015-02-25 11:38
	 */
	[Event(name="changeBegin", type="flash.events.Event")] 
	[Event(name="changeEnd", type="flash.events.Event")] 
	public dynamic class Animator extends GameObject{
		private var _animations:*;
		private var _container:DisplayObjectContainer;
		private var _curAnimation:DisplayObject;
		private var _curAniKey:String;
		private var _transitionConditions:*;
		private var _childDeth:int=-1;
		
		private var _x:Number = 0;
		private var _y:Number = 0;
		private var _rotation:Number=0;
		private var _scaleX:Number = 1;
		private var _scaleY:Number = 1;
		private var _visible:Boolean=true;
		private var _alpha:Number=1;
		private const ANY_STATE:String = "anyState";
		
		public static function create(container:DisplayObjectContainer,childDeth:int=-1):Animator{
			var game:Game=Game.getInstance();
			var info:*={};
			info.container=container;
			info.childDeth=childDeth;
			return game.createGameObj(new Animator(),info) as Animator;
		}
		
		
		public function Animator() {
			super();
		}
		
		override protected function init(info:* = null):void{
			_animations={ };
			_transitionConditions={ };
			_container=info.container;
			_childDeth=info.childDeth;
		}
		
		/**添加动画*/
		public function addAnimation(name:String, animation:DisplayObject = null):void {
			if (animation is Clip){
				Clip(animation).removeIsDestroy = false;
			}else if(animation is MovieClip){
				MovieClip(animation).stop();
			}
			_animations[name] = animation;
		}
		/**
		 * 添加过渡条件
		 * @param	name1  !name1 时为任意状态
		 * @param	name2
		 * @param	condition 一个返回Boolean类型的Function
		 */
		public function addTransitionCondition(name1:String, name2:String, condition:Function):void {
			name1||=ANY_STATE;
			_transitionConditions[name1] ||= [];
			_transitionConditions[name1].push({ target:name2, condition:condition});
		}
		/**设置默认动画*/
		public function setDefaultAnimation(name:String):void {
			changeCurAnimation(name);
		}
		override protected function update():void {
			//指定状态过渡到目标状态
			var transitionCondition:Array = _transitionConditions[_curAniKey];
			if (transitionCondition) {
				var i:int = transitionCondition.length, obj:*;
				while (--i >= 0) {
					obj = transitionCondition[i];
					//条件成立，则切换到目标动画
					if (obj.condition()) changeCurAnimation(obj.target);
					
				}
			}
			//任意状态过渡到目标状态
			transitionCondition = _transitionConditions[ANY_STATE];
			if (transitionCondition) {
				i = transitionCondition.length;
				while (--i>=0) {
					obj = transitionCondition[i];
					//条件成立，则切换到目标动画
					if (obj.condition())changeCurAnimation(obj.target);
				}
			}
		}
		private var _changeBeginEvent:Event=new Event("changeBegin");
		private var _changeEndEvent:Event=new Event("changeEnd");
		public function changeCurAnimation(name:String):void {
			if (_curAniKey == name) return;
			if (_animations[name]) _curAniKey = name;
			else trace("警告：发现动作 "+name+" , 为null/undefined，请检查是否正确使用addAnimation方法添加");
			
			this.dispatchEvent(_changeBeginEvent);//发出改变动作事件 
			
			//移除上一个动作
			if (_curAnimation) {
				FuncUtil.removeChild(_curAnimation);
				_curAnimation.alpha = 1;
				if(_curAnimation is MovieClip)MovieClip(_curAnimation).gotoAndStop(1);
			}
			
			_curAnimation = _animations[_curAniKey];
			if(_curAnimation){
				_curAnimation.x = x;
				_curAnimation.y = y;
				_curAnimation.rotation = rotation;
				_curAnimation.scaleX = _scaleX;
				_curAnimation.scaleY = _scaleY;
				_curAnimation.visible= _visible;
				_curAnimation.alpha=_alpha;
				addToContainer(_curAnimation);
				if(_curAnimation is MovieClip)MovieClip(_curAnimation).gotoAndPlay(1);
			}
			this.dispatchEvent(_changeEndEvent);
		}
		private var _isDestroy:Boolean;
		override protected function onDestroy():void{
			if (_isDestroy) return; _isDestroy = true;
			for (var key:String in _animations) {
				var disObj:DisplayObject = _animations[key] as DisplayObject;
				if (disObj) {
					FuncUtil.removeChild(disObj);
					if(disObj is Clip){
						(disObj as Clip).destroy();
					}else if(disObj is MovieClip){
						(disObj as MovieClip).stop();
					}
				}
			}
			_animations = null;
			_transitionConditions = null;
			_container = null;
			_changeBeginEvent = null;
			_changeEndEvent = null;
			super.onDestroy();
		}
		
		public function get x():Number { return _x; }
		public function set x(value:Number):void { 
			_x = value; 
			if(_curAnimation)_curAnimation.x = _x;
		}
		
		public function get y():Number { return _y; }
		public function set y(value:Number):void {
			_y = value;
			if(_curAnimation)_curAnimation.y = _y;
		}
		
		public function get rotation():Number { return _rotation; }
		public function set rotation(value:Number):void { 
			_rotation = value; 
			if(_curAnimation)_curAnimation.rotation = _rotation;
		}
		
		public function get scaleX():Number { return _scaleX; }
		public function set scaleX(value:Number):void {
			_scaleX = value; 
			if(_curAnimation)_curAnimation.scaleX = _scaleX;
		}
		
		public function get scaleY():Number { return _scaleY; }
		public function set scaleY(value:Number):void {
			_scaleY = value; 
			if(_curAnimation)_curAnimation.scaleY = _scaleY;
		}
		
		public function get visible():Boolean{return _visible;}
		public function set visible(value:Boolean):void{
			_visible=value;
			if(_curAnimation)_curAnimation.visible=_visible;
		}
		
		public function get alpha():Number{return _alpha;}
		public function set alpha(value:Number):void{
			_alpha=value;
			if(_curAnimation)_curAnimation.alpha=_alpha;
		}
		
		/**设置容器*/
		public function setContainer(container:DisplayObjectContainer,childDeth:int=-1):void{
			_childDeth=childDeth;
			
			if(container!=_container){
				_container=container;
				
				if(_curAnimation.parent)_curAnimation.parent.removeChild(_curAnimation);
				addToContainer(_curAnimation);
			}
		}
		
		private function addToContainer(disObj:DisplayObject):void{
			if(_childDeth>-1){
				if(_childDeth>=_container.numChildren){
					_childDeth=Math.max(_container.numChildren-1,0);
				}
				_container.addChildAt(disObj,_childDeth);
			}else{
				_container.addChild(disObj);
			}
		}
		
		public function get curAnimation():DisplayObject { return _curAnimation; }
		public function get curAniKey():String { return _curAniKey; }
		public function getAnimation(name:String):DisplayObject{ return _animations[name]; }
	}

}