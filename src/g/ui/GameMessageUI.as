package g.ui{
	import g.MyData;
	import g.objs.MyObj;
	import g.ui.UIScaler;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.text.TextField;
	import framework.events.FrameworkEvent;
	import framework.utils.FuncUtil;
	import framework.game.UpdateType;
	import framework.game.Game;
	import framework.utils.LibUtil;
	//import g.objs.Item;
	
	public class GameMessageUI extends MyObj{
		private var _view:Sprite;
		private var _scaler:UIScaler;
		
		public static function create():void{
			var game:Game=Game.getInstance();
			game.createGameObj(new GameMessageUI(),{view:LibUtil.getDefSprite("GameMessageUI_mc")});
		}
		
		public function GameMessageUI(){
			super();
		}
		
		override protected function init(info:*=null):void{
			_view=info.view;
			var mc:MovieClip=MovieClip(_view);
			mc.gotoAndStop(MyData.language=="en"?1:2);
			_scaler=UIScaler.create(mc,"gameMessageUI");
			//level text
			var lvTxt:TextField=_view.getChildByName("lvTxt") as TextField;
			lvTxt.text=(_myGame.myGlobal.gameLevel<10 ? "0" : "")+_myGame.myGlobal.gameLevel;
			//
			_game.global.layerMan.uiLayer.addChild(_view);
		}
		
		override protected function foreverUpdate():void{
			var hpTxt:TextField=_view.getChildByName("hpTxt") as TextField;
			if(hpTxt){
				hpTxt.text="2"//_myGame.myGlobal.playerHp.toString();
			}
			
			//
			var itemTxt:TextField=_view.getChildByName("itemTxt") as TextField;
			if(itemTxt){
				itemTxt.text="15"//Item.itemCount+"/"+Item.itemTotal;
			}
			//
			/*var starNumMc:MovieClip=_view.getChildByName("starNumMc") as MovieClip;
			var starNum:int=_myGame.computeStarNum();
			starNumMc.gotoAndStop(starNum+1);*/
		}
		
		override protected function onDestroy():void{
			destroy(_scaler);
			FuncUtil.removeChild(_view);
			_view=null;
			_scaler=null;
			super.onDestroy();
		}
		
	}

}