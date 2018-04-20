package g{
	import flash.display.MovieClip;
	import flash.ui.Mouse;
	public dynamic class Main extends MovieClip{
		private var _gameRoot:GameRoot;
		private var _recordFrameRate:Number;
		public function Main(){
			if(stage)addedToStage(); else addEventListener("addedToStage",addedToStage);
		}
		private function addedToStage(e:*=null):void{
			if(e)removeEventListener("addedToStage",addedToStage);
			addEventListener("enterFrame",init);
		}
		private function init(e:*):void{
			removeEventListener("enterFrame", init);
			_recordFrameRate=stage.frameRate;
			stage.frameRate=MyData.frameRate;//锁定帧频
			createGame();
		}
		private function createGame():void{
			_gameRoot=new GameRoot(this);
			addChild(_gameRoot);
		}
		public function destroyGame():void{
			if(mask&&mask.parent)mask.parent.removeChild(mask);
			if(_gameRoot&&_gameRoot.parent)_gameRoot.parent.removeChild(_gameRoot);
			_gameRoot=null;
			Mouse.show();
			if(_recordFrameRate)stage.frameRate=_recordFrameRate;//还原帧频
		}
		
	};
	
}
