package framework.system{
	import Box2D.Dynamics.b2World;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.EventDispatcher;
	import framework.game.Game;
	import framework.events.FrameworkEvent;
	import framework.objs.GameObject;
	import g.GameRoot;
	import g.Main;
	public class Global extends GameObject{
		protected var _main:Main;
		protected var _stage:Stage;
		protected var _gameRoot:GameRoot;
		protected var _layerMan:LayerManager;
		protected var _objectPool:ObjectPool;
		protected var _localMan:LocalManager;
		protected var _soundMan:SoundManager;
		public function Global(){
			super();
		}
		override protected function init(info:* = null):void{
			super.init(info);
			_main=info.main;
			_gameRoot=info.gameRoot;
			_stage=info.stage;
			//
			//创建层管理
			_layerMan=LayerManager.create(_gameRoot);
			GameObject.dontDestroyOnDestroyAll(_layerMan);
			//创建对象池
			_objectPool=ObjectPool.create();
			GameObject.dontDestroyOnDestroyAll(_objectPool);
			//创建本地存储管理
			_localMan=LocalManager.create();
			GameObject.dontDestroyOnDestroyAll(_localMan);
			//创建声音管理
			_soundMan=SoundManager.create();
			GameObject.dontDestroyOnDestroyAll(_soundMan);
		}
		override protected function onDestroy():void{
			if(_layerMan){
				GameObject.destroy(_layerMan);
				_layerMan=null;
			}
			if(_objectPool){
				GameObject.destroy(_objectPool);
				_objectPool=null;
			}
			if(_localMan){
				GameObject.destroy(_localMan);
				_localMan=null;
			}
			if(_soundMan){
				GameObject.destroy(_soundMan);
				_soundMan=null;
			}
			_stage=null;
			_main=null;
			_gameRoot=null;
			super.onDestroy();
		}
		
		public function get stage():Stage{return _stage;}
		public function get main():Main{return _main;}
		public function get gameRoot():GameRoot{return _gameRoot}
		public function get layerMan():LayerManager{return _layerMan;}
		public function get objectPool():ObjectPool{return _objectPool;}
		public function get localManager():LocalManager{return _localMan;}
		public function get soundMan():SoundManager{return _soundMan;}
		

	};
}