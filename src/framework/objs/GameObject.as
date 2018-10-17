package framework.objs{
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.utils.Dictionary;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	import flash.utils.getQualifiedSuperclassName;
	import framework.game.Game;
	import framework.game.GameObjectListProxy;
	import framework.game.UpdateType;
	import framework.events.FrameworkEvent;
	import framework.namespaces.frameworkInternal;
	import flash.events.EventDispatcher;
	import framework.utils.LibUtil;
	use namespace frameworkInternal;

	public class GameObject extends EventDispatcher{
		
		/**设置一个gameObject在FrameworkEvent.DESTROY_ALL事件中不销毁，只有手动调用GameObject.destroy(gameObject)才能销毁*/
		public static function dontDestroyOnDestroyAll(gameObject:GameObject):void{
			gameObject.isIgnoreDestroyAll=true;
		}
		
		public static function destroy(gameObject:GameObject):void{
			if(gameObject==null)return;
			gameObject.destroy_private();
		}
		
		protected var _game:Game;
		frameworkInternal var isIgnoreDestroyAll:Boolean=false;
		private var _gameObjectListProxy:GameObjectListProxy;
		private var _components:Vector.<Component>=new Vector.<Component>();
		private var _alphaToList:Vector.<AlphaTo>;
		private var _moveToList:Vector.<MoveTo>;
		private var _scaleToList:Vector.<ScaleTo>;
		private var _nextFixedUpdateDict:Dictionary;
		
		public function GameObject(){
			super();
		}
		
		frameworkInternal function init_internal(game:Game,gameObjectListProxy:GameObjectListProxy,info:*):void{
			_game=game;
			_gameObjectListProxy=gameObjectListProxy;
			addToGameObjectList(_gameObjectListProxy);
			initPre_internal(info);
			init(info);
			if(_game)_game.addEventListener(FrameworkEvent.DESTROY_ALL,destroyAll_self);
			
			//
			scheduleUpdate(UpdateType.FOREVER);
			scheduleUpdate(UpdateType.FIXED);
			scheduleUpdate(UpdateType.UPDATE);
			scheduleUpdate(UpdateType.LATE);
		}
		
		virtual frameworkInternal function initPre_internal(info:*=null):void{}
		virtual protected function init(info:*=null):void{}
		
		/**
		 * 指定的时间内移动目标到指定的位置
		 * @param	target 目标对象(拥有"x"和"y"属性的对象)
		 * @param	targetX 目标x
		 * @param	targetY 目标y
		 * @param	duration 时间
		 * @param	onComplete 完成时回调
		 * @param	onCompleteParams 完成时回调参数
		 * @param	onUpdate 移动过程中回调
		 * @param	onUpdateParams 移动过程中回调参数
		 * @return 返回一个新的MoveTo对象
		 */
		final protected function moveTo(target:*,targetX:Number,targetY:Number,duration:Number,
		onComplete:Function=null,onCompleteParams:Array=null,
		onUpdate:Function=null,onUpdateParams:Array=null):MoveTo{
			var mto:MoveTo=MoveTo.create(target,targetX,targetY,duration,onComplete,onCompleteParams,onUpdate,onUpdateParams);
			_moveToList||=new Vector.<MoveTo>();
			_moveToList.push(mto);
			mto.setPoolList(_moveToList);
			return mto;
		}
		/**
		 * 指定的时间内缩放目标到指定的大小
		 * @param	target 目标对象(拥有"scaleX"和"scaleY"属性的对象)
		 * @param	scaleInit 初始值
		 * @param	scaleTarget 目标值
		 * @param	duration 时间
		 * @param	onComplete 完成时回调
		 * @param	onCompleteParams 完成时回调参数
		 * @param	onUpdate 移动过程中回调
		 * @param	onUpdateParams 移动过程中回调参数
		 * @return 返回一个新的ScaleTo对象
		 */
		final protected function scaleTo(target:*,scaleInit:Number=1,scaleTarget:Number=0,duration:Number=1,
		onComplete:Function=null,onCompleteParams:Array=null,
		onUpdate:Function=null,onUpdateParams:Array=null):ScaleTo{
			var sto:ScaleTo=ScaleTo.create(target,scaleInit,scaleTarget,duration,onComplete,onCompleteParams,onUpdate,onUpdateParams);
			_scaleToList||=new Vector.<ScaleTo>();
			_scaleToList.push(sto);
			sto.setPoolList(_scaleToList);
			return sto;
		}
		/**
		 * 指定的时间内改变目标的alpha到指定的大小
		 * @param	target 目标对象(拥有"alpha"属性的对象)
		 * @param	alphaInit 初始值
		 * @param	alphaTarget 目标值
		 * @param	duration 时间
		 * @param	onComplete 完成时回调
		 * @param	onCompleteParams 完成时回调参数
		 * @param	onUpdate 移动过程中回调
		 * @param	onUpdateParams 移动过程中回调参数
		 * @return 返回一个新的AlphaTo对象
		 */
		final protected function alphaTo(target:*,alphaInit:Number=1,alphaTarget:Number=0,duration:Number=1,
		onComplete:Function=null,onCompleteParams:Array=null,
		onUpdate:Function=null,onUpdateParams:Array=null):AlphaTo{
			var ato:AlphaTo=AlphaTo.create(target,alphaInit,alphaTarget,duration,onComplete,onCompleteParams,onUpdate,onUpdateParams);
			_alphaToList=new Vector.<AlphaTo>();
			_alphaToList.push(ato);
			ato.setPoolList(_alphaToList);
			return ato;
		}
		
		/**添加组件*/
		final public function addComponent(componentClass:Class,info:*=null):Component{
			var component:Component=new componentClass() as Component;
			if(component==null)throw new Error("参数componentClass不是Component类");
			
			component.init_internal(this,_game,info);
			var id:int=_components.indexOf(component);
			if(id<0)_components.unshift(component);
			return component;
		}
		
		/**移除组件*/
		final public function removeComponent(component:Component):void{
			if(_components==null)return;
			var id:int=_components.indexOf(component);
			if(id>-1&&_components[id]!=null){
				_components[id].destroy_internal();
				_components[id]=null;
			}
		}
		
		/**按照添加的顺序，移除第一个符合类型的组件*/
		final public function removeComponentWithType(type:Class):void{
			var i:int=_components.length;
			while (--i>=0){
				if(_components[i] is type){
					_components[i].destroy_internal();
					_components[i]=null;
					break;
				}
			}
		}
		
		
		/**返回组件*/
		final public function getComponent(type:Class):Component{
			for(var i:int=0;i<_components.length;i++){
				if(_components[i] is type)return _components[i];
			}
			return null;
		}
		/**返回组件列表*/
		final public function getComponents(type:Class,result:Vector.<Component>=null):Vector.<Component>{
			result||=new Vector.<Component>();
			for(var i:int=0;i<_components.length;i++){
				if(_components[i] is type){
					result.push(_components[i]);
				}
			}
			return result;
		}
		
		private function addToGameObjectList(gameObjectListProxy:GameObjectListProxy):void{
			//添加实例类
			gameObjectListProxy.addGameObject(getQualifiedClassName(this),this);
			//添加父类
			var parentClassName:String, o:*=this;
			var rootClassName:String=getQualifiedClassName(GameObject);//framework.objs::GameObject
			while (true) {
				parentClassName=getQualifiedSuperclassName(o);
				gameObjectListProxy.addGameObject(parentClassName,this);
				if(parentClassName==rootClassName)break;//只添加到GameObject类就中断
				o=getDefinitionByName(parentClassName);//下一个父类
			}
		}
		
		private function removeFromGameObjectList(gameObjectListProxy:GameObjectListProxy):void{
			//移除实例类
			gameObjectListProxy.removeGameObject(getQualifiedClassName(this),this);
			//移除父类
			var parentClassName:String, o:*=this;
			var rootClassName:String=getQualifiedClassName(GameObject);//framework.objs::GameObject
			while (true) {
				parentClassName=getQualifiedSuperclassName(o);
				gameObjectListProxy.removeGameObject(parentClassName,this);
				if(parentClassName==rootClassName)break;//只移除到GameObject类就中断
				o=getDefinitionByName(parentClassName);//下一个父类
			}
		}
		/**updateType=UpdateType.UPDATE*/
		private function scheduleUpdate(updateType:int=2):void{
			switch (updateType){
				case UpdateType.FOREVER: _game.addUpdate(updateType,foreverUpdate_private); break;
				case UpdateType.FIXED:   _game.addUpdate(updateType,fixedUpdate_private);   break;
				case UpdateType.UPDATE:  _game.addUpdate(updateType,update_private);        break;
				case UpdateType.LATE:    _game.addUpdate(updateType,lateUpdate_private);    break;
				default:
			}
		}
		/**updateType=UpdateType.UPDATE*/
		private function unscheduleUpdate(updateType:int=2):void{
			switch (updateType){
				case UpdateType.FOREVER: _game.removeUpdate(updateType,foreverUpdate_private); break;
				case UpdateType.FIXED:   _game.removeUpdate(updateType,fixedUpdate_private);   break;
				case UpdateType.UPDATE:  _game.removeUpdate(updateType,update_private);        break;
				case UpdateType.LATE:    _game.removeUpdate(updateType,lateUpdate_private);    break;
				default:
			}
		}
		
		/**指定的间隔(interval 秒)，重复调度(repeat+1)次函数*/
		final protected function schedule(func:Function,interval:Number,repeat:int,params:Array=null):void{
			_game.schedule(func,interval,repeat,params);
		}
		/**指定的间隔(delay 秒)，调度一次函数*/
		final protected function scheduleOnce(func:Function,delay:Number,params:Array=null):void{
			_game.scheduleOnce(func,delay,params);
		}
		
		/**在下次fixedUpdate时，调度一次函数*/
		final protected function scheduleOnceNextFixed(func:Function,funcParams:Array=null):void{
			_nextFixedUpdateDict||=new Dictionary();
			if(!_nextFixedUpdateDict[func]){
				_nextFixedUpdateDict[func]={func:func,funcParams:funcParams};
			}
		}
		
		/**移除函数调度*/
		final protected function unschedule(func:Function):void{
			_game.unschedule(func);
		}
		/**判断指定函数是否正在调度中*/
		final protected function isScheduleing(func:Function):Boolean{
			return _game.isScheduleing(func);
		}
		
		private function foreachComponetsCallUpdate(updateType:int):void{
			var i:int=_components.length;
			while(--i>=0){
				if(_components[i]==null) _components.splice(i,1);
				else _components[i].callUpdate(updateType);
			}
		}
		private function foreverUpdate_private():void{
			foreachComponetsCallUpdate(UpdateType.FOREVER);
			foreverUpdate();
		}
		private function fixedUpdate_private():void{
			foreachComponetsCallUpdate(UpdateType.FIXED);
			//
			for(var k:* in _nextFixedUpdateDict){
				var obj:*=_nextFixedUpdateDict[k];
				obj.func.apply(null,obj.funcParams);
			}
			_nextFixedUpdateDict=null;
			//
			if(!_isDestroyed){
				fixedUpdate();
			}
			
		}
		private function update_private():void{
			foreachComponetsCallUpdate(UpdateType.UPDATE);
			update();
		}
		private function lateUpdate_private():void{
			foreachComponetsCallUpdate(UpdateType.LATE);
			lateUpdate();
		}
		
		virtual protected function foreverUpdate():void{}
		virtual protected function fixedUpdate():void{}
		virtual protected function update():void{}
		virtual protected function lateUpdate():void{}
		
		/**
		 * 根据defName从库中新建一个MovieClip
		 * @param	defName 链接类名
		 * @param	x 位置x
		 * @param	y 位置y
		 * @param	parent 父级
		 * @param	isStop 是否停止
		 * @param	removeAtFrame 当前帧位于该帧将从显示列表中移除: -1不移除, 0/1首帧, >totalFrames/totalFrames尾帧
		 * @param	removeCallback 从显示列表中移除回调函数
		 * @param	removeCallbackParams 从显示列表中移除回调函数参数
		 * @return 返回MovieClip
		 */
		final protected function createMovieClip(defName:String,x:Number=0,y:Number=0,parent:DisplayObjectContainer=null,isStop:Boolean=true,removeAtFrame:int=-1,
												 removeCallback:Function=null,removeCallbackParams:Array=null):MovieClip{
			var clip:MovieClip=LibUtil.getDefMovie(defName,null,isStop);
			clip.x=x;
			clip.y=y;
			if(parent)parent.addChild(clip);
			if(removeAtFrame>-1){
				removeAtFrame=Math.max(1,Math.min(clip.totalFrames,removeAtFrame));
				removeAtFrame-=1;
				clip.addFrameScript(removeAtFrame,function():void{
					if(removeCallback!=null)removeCallback.apply(null,removeCallbackParams);
					if(clip.parent)clip.parent.removeChild(clip);
					clip.addFrameScript(removeAtFrame,null);
				});
			}
			return clip;
		}
		/**
		 * 根据defName从库中新建一个位图剪辑
		 * @param	defName defName 链接类名
		 * @param	addToPool 是否添加到对象池
		 * @param	removeIsDestroy 从显示列表移除时是否销毁
		 * @param	parent 显示列表父级
		 * @param	x 位置x
		 * @param	y 位置y
		 * @param	controlled true时决定: 1.暂停/恢复游戏时不调用stop()/play()。2.内部不切换帧必须手动切换帧
		 * @param	removeAtFrame 当前帧位于该帧将从显示列表中移除: -1不移除, 0/1首帧, >totalFrames/totalFrames尾帧
		 * @param	removeCallback 从显示列表中移除回调函数
		 * @param	removeCallbackParams 从显示列表中移除回调函数参数
		 * @return 返回Clip
		 */
		final protected function createClip(defName:String, addToPool:Boolean=false, removeIsDestroy:Boolean=true, parent:DisplayObjectContainer=null, x:Number=0, y:Number=0, controlled:Boolean=false,
											removeAtFrame:int=-1,removeCallback:Function=null,removeCallbackParams:Array=null):Clip{
			var clip:Clip=Clip.fromDefName(defName,addToPool,removeIsDestroy,parent,x,y,controlled);
			if(removeAtFrame>-1){
				removeAtFrame=Math.max(1,Math.min(clip.totalFrames,removeAtFrame));
				removeAtFrame-=1;
				clip.addFrameScript(removeAtFrame,function():void{
					if(removeCallback!=null)removeCallback.apply(null,removeCallbackParams);
					if(clip.parent)clip.parent.removeChild(clip);
					clip.addFrameScript(removeAtFrame,null);
				});
			}
			return clip;
		}

		/**返回当前实例类名 */
		final protected function getClassName():String{
			var qclassName:String=getQualifiedClassName(this);
			return qclassName.substr(qclassName.lastIndexOf(":")+1);
		}
		
		private function destroyAll_self(e:FrameworkEvent):void{
			onDestroyAll();
			if(!isIgnoreDestroyAll){
				destroy_private();
			}
		}
		
		private var _isDestroyed:Boolean;
		private function destroy_private():void{
			if(_isDestroyed)return;
			_isDestroyed=true;
			onDestroy();
			onDestroy_private();
		}
		
		/**每次FrameworkEvent.DESTROY_ALL都执行*/
		virtual protected function onDestroyAll():void{
			
		}
		/**在销毁这个GameObject时执行*/
		virtual protected function onDestroy():void{
			
		}
		
		private function onDestroy_private():void{
			unscheduleUpdate(UpdateType.FOREVER);
			unscheduleUpdate(UpdateType.FIXED);
			unscheduleUpdate(UpdateType.UPDATE);
			unscheduleUpdate(UpdateType.LATE);
			_game.removeEventListener(FrameworkEvent.DESTROY_ALL,destroyAll_self);
			
			_nextFixedUpdateDict=null;
			
			if(_gameObjectListProxy){
				removeFromGameObjectList(_gameObjectListProxy);
				_gameObjectListProxy = null;
			}
			
			var i:int;
			if(_moveToList){
				i=_moveToList.length;
				while(--i>=0) destroy(_moveToList[i]);
				_moveToList=null;
			}
			if(_scaleToList){
				i=_scaleToList.length;
				while(--i>=0) destroy(_scaleToList[i]);
				_scaleToList=null;
			}
			if(_alphaToList){
				i=_alphaToList.length;
				while(--i>=0) destroy(_alphaToList[i]);
				_alphaToList=null;
			}
			if(_components){
				i=_components.length;
				while (--i>=0){
					if(_components[i]!=null)_components[i].destroy_internal();
				}
				_components=null;
			}
			_game=null;
		}
		
		public function get isDestroyed():Boolean{ return _isDestroyed; }
	};
	
}