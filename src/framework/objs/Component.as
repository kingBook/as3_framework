package framework.objs{
	import flash.events.EventDispatcher;
	import framework.game.Game;
	import framework.game.UpdateType;
	import framework.namespaces.frameworkInternal;
	use namespace frameworkInternal;
	
	/**所有绑定到GameObject的组件的基类*/
	public class Component extends EventDispatcher{
		
		public var enabled:Boolean=true;//启用则更新，否则停止所有更新
		protected var _gameObject:GameObject;
		protected var _game:Game;
		
		public function Component(){
			super();
		}
		
		frameworkInternal function init_internal(gameObj:GameObject,game:Game,info:*=null):void{
			_gameObject=gameObj;
			_game=game;
			init(info);
		}
		
		frameworkInternal function callUpdate(updateType:int):void{
			if(!enabled)return;
			switch (updateType){
				case UpdateType.FOREVER: foreverUpdate(); break;
				case UpdateType.FIXED:   fixedUpdate();   break;
				case UpdateType.UPDATE:  update();        break;
				case UpdateType.LATE:    lateUpdate();    break;
				default:
			}
		}
		
		virtual protected function init(info:*=null):void{ }
		
		protected function foreverUpdate():void{}
		protected function fixedUpdate():void{}
		protected function update():void{}
		protected function lateUpdate():void{}
		
		
		/**指定的间隔(interval 秒)，重复调度(repeat+1)次函数*/
		final protected function schedule(func:Function,interval:Number,repeat:int,params:Array=null):void{
			_game.schedule(func,interval,repeat,params);
		}
		/**指定的间隔(delay 秒)，调度一次函数*/
		final protected function scheduleOnce(func:Function,delay:Number,params:Array=null):void{
			_game.scheduleOnce(func,delay,params);
		}
		
		/**移除函数调度*/
		final protected function unschedule(func:Function):void{
			_game.unschedule(func);
		}
		/**判断指定函数是否正在调度中*/
		final protected function isScheduleing(func:Function):Boolean{
			return _game.isScheduleing(func);
		}
		
		/**返回组件*/
		final public function getComponent(type:Class):Component{
			return _gameObject.getComponent(type);
		}
		/**返回组件列表*/
		final public function getComponents(type:Class,result:Vector.<Component>=null):Vector.<Component>{
			return _gameObject.getComponents(type,result);
		}
		
		private var _isDestroyed:Boolean;
		frameworkInternal function destroy_internal():void{
			if(_isDestroyed)return;
			_isDestroyed=true;
			onDestroy();
		}
		/**不能手动调用onDestroy()消毁，只能通过GameObject.removeComponent()消毁*/
		protected function onDestroy():void{
			_gameObject=null;
			_game=null;
		}
		
		
	};

}