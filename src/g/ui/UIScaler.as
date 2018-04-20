package g.ui{
	import flash.display.MovieClip;
	import framework.game.Game;
	import g.objs.MyObj;
	import g.ui.UI;
	public class UIScaler extends MyObj{
		
		public static function create(mc:MovieClip,type:String):UIScaler{
			var game:Game=Game.getInstance();
			var info:*={};
			info.mc=mc;
			info.type=type;
			return game.createGameObj(new UIScaler(),info) as UIScaler;
		}
		
		public function UIScaler(){
			super();
		}
		
		private var _mc:MovieClip;
		private var _type:String;
		
		override protected function init(info:* = null):void{
			super.init(info);
			_mc=info.mc;
			_type=info.type;
			
			
			resize();
			_myGame.myGlobal.resizeMan.addListener(resize);
		}
		
		private function resize():void{
			if(_mc["bg"]) _myGame.myGlobal.resizeMan.resizeBg(_mc["bg"]);
			_myGame.myGlobal.resizeMan.addContainerByNativePos(_mc,_mc["bg"]);
		}
		
		override protected function onDestroy():void{
			_myGame.myGlobal.resizeMan.removeListener(resize);
			_myGame.myGlobal.resizeMan.removeContainerByNativePos(_mc);
			_mc=null;
			super.onDestroy();
		}
	};

}