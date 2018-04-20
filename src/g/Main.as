package g{
	import flash.display.MovieClip;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.ui.Mouse;
	public dynamic class Main extends MovieClip{
		private var _gameRoot:GameRoot;
		private var _recordFrameRate:Number;
		private static var _printStr:String;
		private static var _printTxt:TextField;
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
			//
			_printStr="";
			_printTxt=new TextField();
			_printTxt.autoSize=TextFieldAutoSize.LEFT;
			_printTxt.background=true;
			_printTxt.x=70;
			_printTxt.y=5;
			addChild(_printTxt);
			//
			createGame();
		}
		private function createGame():void{
			_gameRoot=new GameRoot(this);
			addChild(_gameRoot);
		}
		public function destroyGame():void{
			if(_printTxt){
				if(_printTxt.parent)_printTxt.parent.removeChild(_printTxt);
				_printTxt=null;
			}
			_printStr=null;
			
			if(mask&&mask.parent)mask.parent.removeChild(mask);
			if(_gameRoot&&_gameRoot.parent)_gameRoot.parent.removeChild(_gameRoot);
			_gameRoot=null;
			Mouse.show();
			if(_recordFrameRate)stage.frameRate=_recordFrameRate;//还原帧频
		}
		
		public static function print(...rest):void{
			if(_printStr)_printStr+="\n";
			for(var i:int=0;i<rest.length;i++){
				_printStr+=rest[i]+(i<rest.length-1?" ":"");
			}
			_printTxt.text=_printStr;
			trace(_printStr);
		}
		
	};
	
}
