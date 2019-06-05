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
		private var _clips:*;
		private var _parent:DisplayObjectContainer;
		private var _curClip:*;
		private var _curState:String;
		private var _transitionConditions:*;
		private var _childDeth:int=-1;
		
		private var _x:Number = 0;
		private var _y:Number = 0;
		private var _rotation:Number=0;
		private var _scaleX:Number = 1;
		private var _scaleY:Number = 1;
		private var _visible:Boolean=true;
		private var _alpha:Number=1;
		
		private const MultipleClipMode:uint=1;
		private const OneClipMode:uint=2;
		private var _mode:uint=0;
		/**false时将禁止update()*/
		public var enable:Boolean=true;
		
		private const ANY_STATE:String = "anyState";
		
		public static function create(parent:DisplayObjectContainer,childDeth:int=-1):Animator{
			var game:Game=Game.getInstance();
			var info:*={};
			info.parent=parent;
			info.childDeth=childDeth;
			return game.createGameObj(new Animator(),info) as Animator;
		}
		
		
		public function Animator() {
			super();
		}
		
		override protected function init(info:* = null):void{
			_clips={ };
			_transitionConditions={ };
			_parent=info.parent;
			_childDeth=info.childDeth;
		}
		
		/**
		 * 添加一个动作状态动画
		 * @param	name 动作状态名
		 * @param	clip 动画剪辑
		 */
		public function addStateClip(name:String, clip:DisplayObject = null):void {
			if(_mode==OneClipMode)return;
			_mode=MultipleClipMode;
			
			if (clip is Clip){
				Clip(clip).removeIsDestroy = false;
			}else if(clip is MovieClip){
				MovieClip(clip).stop();
			}
			_clips[name] = clip;
		}
		
		/**
		 * 添加一个动画，动画里每一小段帧区间是一个动作状态。
		 * 调用该方法后多次调用addStateFrames(name,startFrame,endFrame)为每个动作状态指定帧区间
		 * 注意：使用了该方法以下方法将不再起作用。 
		 * addStateClip(), 
		 * @param	clip 类型为MovieClip/g.Clip，包含所有动作状态的剪辑
		 */
		public function setAllStateClip(clip:*):void{
			if(_mode==MultipleClipMode)return;
			_mode=OneClipMode;
			
			if(_curClip&&_curClip.parent){
				_curClip.parent.removeChild(_curClip);
			}
			_curClip=clip;
			_parent.addChild(_curClip);
		}
		public function addStateFrames(name:String,startFrame:int,endFrame:int):void{
			if(_mode==MultipleClipMode)return;
			_clips[name]=[startFrame,endFrame];
		}
		
		/**
		 * 添加过渡条件
		 * @param	name1  !name1 时为任意动作状态
		 * @param	name2 满足条件将切换到的动作状态
		 * @param	condition 一个返回Boolean类型的Function
		 */
		public function addTransitionCondition(name1:String, name2:String, condition:Function):void {
			name1||=ANY_STATE;
			_transitionConditions[name1] ||= [];
			_transitionConditions[name1].push({ target:name2, condition:condition});
		}
		/**设置默认动画*/
		public function setDefaultState(name:String):void {
			changeCurState(name);
		}
		override protected function update():void {
			if(!enable)return;
			//指定状态过渡到目标状态
			var transitionCondition:Array = _transitionConditions[_curState];
			if (transitionCondition) {
				var i:int = transitionCondition.length, obj:*;
				while (--i >= 0) {
					obj = transitionCondition[i];
					//条件成立，则切换到目标动画
					if (obj.condition()) changeCurState(obj.target);
					
				}
			}
			//任意状态过渡到目标状态
			transitionCondition = _transitionConditions[ANY_STATE];
			if (transitionCondition) {
				i = transitionCondition.length;
				while (--i>=0) {
					obj = transitionCondition[i];
					//条件成立，则切换到目标动画
					if (obj.condition())changeCurState(obj.target);
				}
			}
			
			if(_mode==OneClipMode){
				if(_curClip.currentFrame<_clips[_curState][1]){
					_curClip.nextFrame();
				}else{
					_curClip.gotoAndStop(_clips[_curState][0]);
				}
			}
		}
		private var _changeBeginEvent:Event=new Event("changeBegin");
		private var _changeEndEvent:Event=new Event("changeEnd");
		public function changeCurState(name:String):void{
			if (_curState == name) return;
			if (_clips[name]) _curState = name;
			else trace("警告：发现动作 "+name+" , 为null/undefined，请检查是否正确使用addStateClip或setAllStateClip方法添加");
			
			this.dispatchEvent(_changeBeginEvent);//发出改变动作事件
			
			if(_mode==OneClipMode){
				_curClip.x = x;
				_curClip.y = y;
				_curClip.rotation = rotation;
				_curClip.scaleX = _scaleX;
				_curClip.scaleY = _scaleY;
				_curClip.visible= _visible;
				_curClip.alpha=_alpha;
				_curClip.gotoAndStop(_clips[_curState][0]);
			}else{
				//移除上一个动作
				if (_curClip) {
					FuncUtil.removeChild(_curClip);
					_curClip.alpha = 1;
					if(_curClip is MovieClip)MovieClip(_curClip).gotoAndStop(1);
				}
				//切换并添加到显示列表
				_curClip = _clips[_curState];
				if(_curClip){
					_curClip.x = x;
					_curClip.y = y;
					_curClip.rotation = rotation;
					_curClip.scaleX = _scaleX;
					_curClip.scaleY = _scaleY;
					_curClip.visible= _visible;
					_curClip.alpha=_alpha;
					addToParent(_curClip);
					if(_curClip is MovieClip)MovieClip(_curClip).gotoAndPlay(1);
				}
			}
			
			this.dispatchEvent(_changeEndEvent);
		}
		private var _isDestroy:Boolean;
		override protected function onDestroy():void{
			if (_isDestroy) return; _isDestroy = true;
			for (var key:String in _clips) {
				var disObj:DisplayObject = _clips[key] as DisplayObject;
				if (disObj) {
					FuncUtil.removeChild(disObj);
					if(disObj is Clip){
						(disObj as Clip).destroy();
					}else if(disObj is MovieClip){
						(disObj as MovieClip).stop();
					}
				}
			}
			_clips = null;
			_transitionConditions = null;
			_parent = null;
			_changeBeginEvent = null;
			_changeEndEvent = null;
			super.onDestroy();
		}
		
		public function get x():Number { return _x; }
		public function set x(value:Number):void { 
			_x = value; 
			if(_curClip)_curClip.x = _x;
		}
		
		public function get y():Number { return _y; }
		public function set y(value:Number):void {
			_y = value;
			if(_curClip)_curClip.y = _y;
		}
		
		public function get rotation():Number { return _rotation; }
		public function set rotation(value:Number):void { 
			_rotation = value; 
			if(_curClip)_curClip.rotation = _rotation;
		}
		
		public function get scaleX():Number { return _scaleX; }
		public function set scaleX(value:Number):void {
			_scaleX = value; 
			if(_curClip)_curClip.scaleX = _scaleX;
		}
		
		public function get scaleY():Number { return _scaleY; }
		public function set scaleY(value:Number):void {
			_scaleY = value; 
			if(_curClip)_curClip.scaleY = _scaleY;
		}
		
		public function get visible():Boolean{return _visible;}
		public function set visible(value:Boolean):void{
			_visible=value;
			if(_curClip)_curClip.visible=_visible;
		}
		
		public function get alpha():Number{return _alpha;}
		public function set alpha(value:Number):void{
			_alpha=value;
			if(_curClip)_curClip.alpha=_alpha;
		}
		
		/**设置父级*/
		public function setParent(parent:DisplayObjectContainer,childDeth:int=-1):void{
			_childDeth=childDeth;
			
			if(parent!=_parent){
				_parent=parent;
				
				if(_curClip.parent)_curClip.parent.removeChild(_curClip);
				addToParent(_curClip);
			}
		}
		
		private function addToParent(child:DisplayObject):void{
			if(_childDeth>-1){
				if(_childDeth>=_parent.numChildren){
					_childDeth=Math.max(_parent.numChildren-1,0);
				}
				_parent.addChildAt(child,_childDeth);
			}else{
				_parent.addChild(child);
			}
		}
		
		public function get curClip():DisplayObject { return _curClip; }
		public function get curState():String { return _curState; }
		public function getStateData(name:String):DisplayObject{ return _clips[name]; }
	}

}