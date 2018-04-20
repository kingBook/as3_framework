package framework.game{
	import Box2D.Dynamics.b2Body;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.EventDispatcher;
	import flash.system.System;
	import flash.utils.getQualifiedClassName;
	import framework.events.FrameworkEvent;
	import framework.namespaces.frameworkInternal;
	import framework.objs.GameObject;
	import framework.system.Global;
	import framework.utils.ButtonEffect;
	import g.GameRoot;
	import g.Main;
	use namespace frameworkInternal;
	
	public class Game extends EventDispatcher{
		protected static var _instance:Game;
		public static function getInstance():Game{return _instance||=new Game();}
		public static function destroy():void{
			if(_instance) _instance.onDestroy();
			_instance=null;
			System.gc();
		}
		protected var _global:Global;
		protected var _fixedTimestep:Number=0.02;
		private var _gameObjectListProxy:GameObjectListProxy;
		private var _updateProxy:UpdateProxy;
		private var _intervalProxy:IntervalProxy;
		private var _pause:Boolean;
		private var _main:Main;
		
		public function Game() {
			if(_instance) throw new Error("该类只能实例化一次!!!");
			_instance = this;
			init();
		}
		
		protected function init():void{
			_gameObjectListProxy=new GameObjectListProxy();
			_updateProxy=new UpdateProxy(this);
			_intervalProxy=new IntervalProxy(this);
		}
		
		/**创建游戏对象*/
		public function createGameObj(obj:GameObject, info:*=null):GameObject{
			obj.init_internal(this,_gameObjectListProxy,info);
			return obj;
		}
		
		/**根据游戏对象类返回游戏对象列表Vector.<GameObject>,当destroy一个这个类型的GameObject会影响列表的长度
		 * 转换类型如: var players:Vector.< Player > = Vector.< Player >(getGameObjList(Player));
		 */
		public function getGameObjList(gameObjClass:Class):Vector.<GameObject>{ 
			var qualifiedClassName:String=getQualifiedClassName(gameObjClass);
			return _gameObjectListProxy.getGameObjectList(qualifiedClassName); 
		}
		
		/**根据游戏对象类返回游戏对象列表Array,当destroy()一个这个类型的GameObject会影响列表的长度*/
		public function getGameObjListToArray(gameObjClass:Class):Array{
			var qualifiedClassName:String=getQualifiedClassName(gameObjClass);
			return _gameObjectListProxy.getGameObjectListToArray(qualifiedClassName);
		}
		
		frameworkInternal function addUpdate(updateType:int,func:Function):void{
			_updateProxy.add(updateType,func);
		}
		frameworkInternal function removeUpdate(updateType:int,func:Function):void{
			_updateProxy.remove(updateType,func);
		}
		
		/**指定的间隔(interval 秒)，重复调度(repeat+1)次函数*/
		frameworkInternal function schedule(func:Function,interval:Number,repeat:int,params:Array=null):void{
			_intervalProxy.schedule(func,interval,repeat,params);
		}
		/**指定的间隔(delay 秒)，调度一次函数*/
		frameworkInternal function scheduleOnce(func:Function,delay:Number=0,params:Array=null):void{
			_intervalProxy.scheduleOnce(func,delay,params);
		}
		/**移除函数调度*/
		frameworkInternal function unschedule(func:Function):void{
			_intervalProxy.unschedule(func);
		}
		/**判断指定函数是否正在调度中*/
		frameworkInternal function isScheduleing(func:Function):Boolean{
			return _intervalProxy.isHasSchdule(func);
		}
		
		/**暂停*/
		public function get pause():Boolean{return _pause;}
		public function set pause(value:Boolean):void{
			if(value==_pause)return;
			_pause=value;
			var evt:FrameworkEvent = _pause?FrameworkEvent.getPauseEvent():FrameworkEvent.getResumeEvent();
			dispatchEvent(evt);
		}
		
		public function destroyAll():void{
			dispatchEvent(FrameworkEvent.getDestroyAllEvent());
		}
		
		/**启动*/
		public function startup(main:Main,gameRoot:GameRoot,stage:Stage,info:*=null):void{
			_main=main;
			_main.addEventListener("enterFrame",update);
		}
		
		private function update(e:*):void{
			_updateProxy.update();
		}
		
		protected function onDestroy():void{
			ButtonEffect.killAll();
			destroyAll();
			if(_main)_main.removeEventListener("enterFrame",update);
			if(_global){
				GameObject.destroy(_global);
				_global=null;
			}
			if(_gameObjectListProxy)_gameObjectListProxy.destroy();
			if(_intervalProxy)_intervalProxy.destroy();
			if(_updateProxy)_updateProxy.destroy();
			
			_gameObjectListProxy=null;
			_updateProxy=null;
			_intervalProxy=null;
			_main=null;
		}
		
		public function get global():Global{return _global;}
		public function get fixedTimestep():Number{return _fixedTimestep;}
		
	};
	
}