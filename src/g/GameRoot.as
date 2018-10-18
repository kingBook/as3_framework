package g{
	import flash.display.Sprite;
	import flash.events.Event;
	
	/**游戏根容器*/
	public dynamic class GameRoot extends Sprite{
		private var _main:Main;
		public function GameRoot(main:Main){
			super();
			_main=main;
			addEventListener(Event.ADDED_TO_STAGE,addedToStage);
			addEventListener(Event.REMOVED_FROM_STAGE,removeFromStage);
		}
		private function addedToStage(e:Event):void{
			removeEventListener(Event.ADDED_TO_STAGE, addedToStage);
			Assets.getInstance().init();
			Assets.getInstance().addEventListener("complete",assetsLoaded);
		}
		/**资源加载完成*/
		private function assetsLoaded(e:*):void{
			e.target.removeEventListener("complete", assetsLoaded);
			MyGame.getInstance().startup(_main,this,stage);
			MyGame.getInstance().gotoTitle();
		}
		private function removeFromStage(e:Event):void{
			removeEventListener(Event.REMOVED_FROM_STAGE,removeFromStage);
			MyGame.destroy();
			Assets.destroy();
			_main=null;
		}
		
	};

}