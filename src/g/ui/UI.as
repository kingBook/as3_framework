package g.ui{
	import g.MyData;
	import g.MyGame;
	import g.map.MapData;
	import g.objs.MyObj;
	import g.ui.UIScaler;
	import flash.display.DisplayObject;
	import flash.display.InteractiveObject;
	import flash.display.MovieClip;
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import framework.game.Game;
	import framework.game.UpdateType;
	import framework.events.FrameworkEvent;
	import framework.objs.GameObject;
	import framework.utils.LibUtil;
	import framework.system.KeyboardManager;
	import framework.utils.ButtonEffect;
	import g.objs.MoveTo;
	public class UI extends MyObj{
		
		public static const TITLE:String="title";
		public static const SELECT_LEVEL:String="selectLevel";
		public static const FAILURE:String="failure";
		public static const VICTORY:String="victory";
		public static const MISSION_COMPLETE:String="missionComplete";
		public static const CONTROL_BAR:String="controlBar";
		public static const HELP:String="help";
		
		public static function create(type:String,endUIDelay:Number=0):void{
			var game:Game=Game.getInstance();
			var defName:String;
			switch(type){
				case UI.TITLE: defName="TitleUI_mc"; break;
				case UI.SELECT_LEVEL: defName="SelectLevelUI_mc"; break;
				case UI.FAILURE: defName="Failure_mc"; break;
				case UI.VICTORY: defName="VictoryUI_mc"; break;
				case UI.MISSION_COMPLETE: defName="MissionCompleteUI_mc"; break;
				case UI.CONTROL_BAR: defName="ControlUI_mc"; break;
				case UI.HELP: defName="HelpUI_mc"; break;
				default:
			}
			game.createGameObj(new UI(),{
				view:LibUtil.getDefSprite(defName),
				type:type,
				endUIDelay:endUIDelay
			});
		}
		
		protected var _view:Sprite;
		private var _scaler:UIScaler;
		private var _type:String;
		private var _moveTo:MoveTo;
		
		private var _moreGame:InteractiveObject;
		private var _toSelectLevel:InteractiveObject;
		private var _help:InteractiveObject;
		private var _toTitle:InteractiveObject;
		private var _resetLevel:InteractiveObject;
		private var _nextLevel:InteractiveObject;
		private var _mute:InteractiveObject;
		private var _muteOnce:InteractiveObject;
		private var _muteLoop:InteractiveObject;
		private var _pause:InteractiveObject;
		private var _toStory:InteractiveObject;
		private var _numMcList:Array;
		private var _keyboardMan:KeyboardManager;
		private var _endUIDelay:Number=0;
		private function get _muteMc():MovieClip{return _mute as MovieClip;}
		private function get _muteOnceMc():MovieClip{return _muteOnce as MovieClip;}
		private function get _muteLoopMc():MovieClip{return _muteLoop as MovieClip;}
		private function get _pauseMc():MovieClip{return _pause as MovieClip;}
		public function UI(){
			super();
		}
		
		override protected function init(info:*=null):void{
			_type=info.type;
			_view=info.view;
			MovieClip(_view).gotoAndStop(MyData.language=="en"?1:2);
			onPreCreateScaler();
			_scaler=UIScaler.create(MovieClip(_view),_type);
			_view.addEventListener(MouseEvent.CLICK, clickHandler);
			
			_moreGame=_view.getChildByName("moreGame") as InteractiveObject;
			_toSelectLevel=_view.getChildByName("toSelectLevel") as InteractiveObject;
			_help=_view.getChildByName("help") as InteractiveObject;
			_toTitle=_view.getChildByName("toTitle") as InteractiveObject;
			_resetLevel=_view.getChildByName("resetLevel") as InteractiveObject;
			_nextLevel=_view.getChildByName("nextLevel") as InteractiveObject;
			_mute=_view.getChildByName("mute") as InteractiveObject;
			_muteOnce=_view.getChildByName("muteOnce") as InteractiveObject;
			_muteLoop=_view.getChildByName("muteLoop") as InteractiveObject;
			_pause=_view.getChildByName("pause") as InteractiveObject;
			_toStory=_view.getChildByName("toStory") as InteractiveObject;
			
			if(_type==UI.SELECT_LEVEL){
				var unlockLevel:int=int(_game.global.localManager.get("unlockLevel")) || 1; 
				/*{//矩阵按钮形式
					var numMc:MovieClip;
					var i:int;
					while (++i <= MapData.maxLevel){
						numMc=_view.getChildByName("numMc" + i) as MovieClip;
						if(numMc){
							numMc.mouseChildren=false;
							//文本框
							numMc.gotoAndStop((MyData.unlock || i <= unlockLevel) ? 1 : 2);
							if (numMc.currentFrame == 1){
								numMc.buttonMode=true;
								ButtonEffect.to(numMc,{scale:{}});
							} else{
								numMc.buttonMode=false;
							}
							if (numMc.txt) numMc.txt.text=(i<10?"0":"")+i;
							
							//数字帧
							//numMc.gotoAndStop((MyData.unlock || i <= unlockLevel) ? i : numMc.totalFrames);
							//if(numMc.currentFrame!=numMc.totalFrames){
							//	numMc.buttonMode=true;
							//	ButtonEffect.to(numMc,{scale:{}});
							//}else{
							//	numMc.buttonMode=false;
							//}
							
							//var starNumMc:MovieClip=numMc.getChildByName("starNumMc") as MovieClip;
							//var starNum:int=_myGame.getLocalStarNum(i);
							//starNumMc.gotoAndStop(starNum+1);
							
							_numMcList ||= [];
							_numMcList[i - 1]=numMc;
						}else{

							trace("警告：没找到numMc"+i+"按钮，关卡总数:"+MapData.maxLevel);
						}
					}
				};*/
				{//照片墙滑页形式
					var photoSelectPageMc:MovieClip=_view.getChildByName("photoSelectPageMc") as MovieClip;
					if(photoSelectPageMc){
						PhotoSelectPage.create(this,photoSelectPageMc,MyData.unlock?MapData.maxLevel:unlockLevel,MapData.maxLevel);
					}
				};
			}
			
			if (_muteMc){
				_muteMc.buttonMode=true;
				_muteMc.gotoAndStop(_game.global.soundMan.mute ? 2 : 1);
			}
			_game.global.soundMan.addEventListener(FrameworkEvent.MUTE,muteHandler);
			if (_muteOnceMc){
				_muteOnceMc.buttonMode=true;
				_muteOnceMc.gotoAndStop(_game.global.soundMan.muteOnce ? 2 : 1);
			}
			_game.global.soundMan.addEventListener(FrameworkEvent.MUTE_ONCE,muteOnceHandler);
			if (_muteLoopMc){
				_muteLoopMc.buttonMode=true;
				_muteLoopMc.gotoAndStop(_game.global.soundMan.muteLoop ? 2 : 1);
			}
			_game.global.soundMan.addEventListener(FrameworkEvent.MUTE_LOOP,muteLoopHandler);
			
			if (_pauseMc){
				_pauseMc.buttonMode=true;
				_pauseMc.gotoAndStop(_game.pause ? 2 : 1);
			}
			_keyboardMan=KeyboardManager.create();
			
			if (isEndUI()){
				_view.visible=false;
				_endUIDelay=info.endUIDelay;
				scheduleOnce(addAnimtion,_endUIDelay); 
			}
			if (_type != CONTROL_BAR){
				ButtonEffect.to(_moreGame as DisplayObject,{scale:{}});
				ButtonEffect.to(_toSelectLevel as DisplayObject,{scale:{}});
				ButtonEffect.to(_help as DisplayObject,{scale:{}});
				ButtonEffect.to(_toTitle as DisplayObject,{scale:{}});
				ButtonEffect.to(_resetLevel as DisplayObject,{scale:{}});
				ButtonEffect.to(_nextLevel as DisplayObject,{ scale:{ }} );
				ButtonEffect.to(_toStory as DisplayObject,{ scale:{ }} );
			}
			/*if(_type==UI.MISSION_COMPLETE||_type==UI.VICTORY){
				starNumMc=_view.getChildByName("starNumMc") as MovieClip;
				starNumMc.gotoAndStop(_myGame.myGlobal.starNum+1);
			}*/
			_game.global.layerMan.uiLayer.addChild(_view);
			//
			//
			_game.addEventListener(FrameworkEvent.PAUSE, pauseResumeHandler);
			_game.addEventListener(FrameworkEvent.RESUME, pauseResumeHandler);
			_game.global.main.addEventListener(MouseEvent.MOUSE_OVER, mouseOverHandler);
		}
		
		protected function onPreCreateScaler():void{
			
		}
		
		private function mouseOverHandler(e:MouseEvent):void{
			var check:Boolean=true;
			check&&=e&&e.target;
			check&&=e.target is SimpleButton;
			check||=e.target is MovieClip&&MovieClip(e.target).buttonMode;
			//if(check) _game.global.soundMan.play("按钮",0.3);
		}
		
		private function pauseResumeHandler(e:FrameworkEvent):void{
			if (_pauseMc) _pauseMc.gotoAndStop(_game.pause ? 2 : 1);
		}
		
		private function muteHandler(e:FrameworkEvent):void{
			if (_muteMc) _muteMc.gotoAndStop(e.info.mute ? 2 : 1);
			if (_muteOnceMc) _muteOnceMc.gotoAndStop(e.info.mute ? 2 : 1);
			if (_muteLoopMc) _muteLoopMc.gotoAndStop(e.info.mute ? 2 : 1);
		}
		private function muteOnceHandler(e:FrameworkEvent):void{
			if (_muteOnceMc) _muteOnceMc.gotoAndStop(e.info.mute ? 2 : 1);
		}
		private function muteLoopHandler(e:FrameworkEvent):void{
			if (_muteLoopMc) _muteLoopMc.gotoAndStop(e.info.mute ? 2 : 1);
		}
		
		/**添加动画*/
		private function addAnimtion():void{
			_view.visible=true;
			_view.y-=200;
			_moveTo=MoveTo.create1(_view,0,0,0.7);
		}
		
		private function isEndUI():Boolean{
			return _type == FAILURE 
			|| _type == MISSION_COMPLETE 
			|| _type == VICTORY;
		}
		
		public function isGameingUI():Boolean{
			return _type == VICTORY 
			|| _type == MISSION_COMPLETE 
			|| _type == FAILURE 
			||_type == CONTROL_BAR;
		}
		
		private function linkHomePage():void{
			if (MyData.linkHomePageFunc != null) MyData.linkHomePageFunc();
			else trace("MyData.linkHomePageFunc == null");
		}
		private var _pauseIsMute:Boolean;
		protected function clickHandler(e:MouseEvent):void{
			var stageW:Number=_game.global.stage.stageWidth;
			var stageH:Number=_game.global.stage.stageHeight;
			var doDestroy:Boolean=isGameingUI();
			var newFunc:Function;
			var game:MyGame=_game as MyGame;
			switch (e.target){
				case _moreGame: 
					playDownSound();
					linkHomePage();
					break;
				case _toSelectLevel: 
					playDownSound();
					newFunc=function():void{game.gotoSelectLevel(doDestroy);}
					UITween.create(_game.global.main,GameObject.destroy,[this],newFunc,null,stageW,stageH);
					break;
				case _help: 
					playDownSound();
					newFunc=function():void{game.gotoHelp();}
					UITween.create(_game.global.main,GameObject.destroy,[this],newFunc,null,stageW,stageH);
					break;
				case _toTitle: 
					playDownSound();
					newFunc=function():void{game.gotoTitle(doDestroy)}
					UITween.create(_game.global.main,GameObject.destroy,[this],newFunc,null,stageW,stageH);
					break;
				case _resetLevel: 
					playDownSound();
					resetLevel();
					break;
				case _nextLevel: 
					playDownSound();
					nextLevel();
					break;
				case _pause: 
					playDownSound();
					pressPauseHandler();
					break;
				case _mute: 
					playDownSound();
					if (!_game.pause)_game.global.soundMan.mute=!_game.global.soundMan.mute;
					break;
				case _muteOnce: 
					playDownSound();
					if (!_game.pause)_game.global.soundMan.muteOnce=!_game.global.soundMan.muteOnce;
					break;
				case _muteLoop: 
					playDownSound();
					if (!_game.pause)_game.global.soundMan.muteLoop=!_game.global.soundMan.muteLoop;
					break;
				case _toStory:
					playDownSound();
					newFunc=function():void{StoryUI.create();}
					UITween.create(_game.global.main,GameObject.destroy,[this],newFunc,null,stageW,stageH);
					break;
				default: 
					if(_type==SELECT_LEVEL){
						if(_numMcList!=null){
							var id:int=_numMcList.indexOf(e.target);
							if(id>-1){
								var unlockLevel:int=int(_game.global.localManager.get("unlockLevel")) || 1; 
								newFunc=function():void{game.gotoLevel(id+1);}
								if (_numMcList){
									var isUnlockLevelNumBtn:Boolean=(id+1)<=unlockLevel;
									if (isUnlockLevelNumBtn||MyData.unlock){
										playDownSound();
										skipToLevel(id+1);
									}
								}
							}
						}
					}
			}
		}
		
		public function skipToLevel(level:int):void{
			var stageW:Number=_game.global.stage.stageWidth;
			var stageH:Number=_game.global.stage.stageHeight;
			var game:MyGame=_myGame;
			var newFunc:Function=function():void{game.gotoLevel(level);}
			UITween.create(_game.global.main,GameObject.destroy,[this],newFunc,null,stageW,stageH);
		}
		
		private function playDownSound():void{
			
		}
		
		override protected function foreverUpdate():void{
			if (MyData.language == "cn"){
				if (_keyboardMan.jp("SPACE")){
					if (_type == SELECT_LEVEL){
						runCurUnlockLevel();
					}else if (_type == MISSION_COMPLETE){
						nextLevel();
					}
				}
			}
			if (_type == CONTROL_BAR){
				if(_keyboardMan&&_keyboardMan.jp("P")) pressPauseHandler();
				if (_keyboardMan.jp("R")) resetLevel();
				
			}
		}
		
		private function pressPauseHandler():void{
			_game.pause=!_game.pause;
			if (_game.pause){
				_pauseIsMute=_game.global.soundMan.mute;
				_game.global.soundMan.mute=true;
			}else{
				_game.global.soundMan.mute=_pauseIsMute;
			}
		}
		
		/**跳到当前解锁关*/
		private function runCurUnlockLevel():void{
			var myGame:MyGame=_myGame;
			GameObject.destroy(this);
			var unlockLevel:int=Math.max(1, int(myGame.global.localManager.get("unlockLevel")) );
			myGame.gotoLevel(unlockLevel);
		}
		
		/**下一关*/
		private function nextLevel():void{
			var stageW:Number=_game.global.stage.stageWidth;
			var stageH:Number=_game.global.stage.stageHeight;
			var myGame:MyGame=_game as MyGame;
			var newFunc:Function=function():void{ myGame.nextLevel();}
			UITween.create(_game.global.main,GameObject.destroy,[this],newFunc,null,stageW,stageH);
		}
		
		/**重置当前关卡*/
		private function resetLevel():void{
			_myGame.resetLevel();
		}

		
		override protected function onDestroy():void{
			unschedule(addAnimtion);
			destroy(_scaler);
			if (_view.parent) _view.parent.removeChild(_view);
			_game.pause=false;
			_game.global.soundMan.removeEventListener(FrameworkEvent.MUTE,muteHandler);
			_game.global.soundMan.removeEventListener(FrameworkEvent.MUTE_ONCE,muteOnceHandler);
			_game.global.soundMan.removeEventListener(FrameworkEvent.MUTE_LOOP,muteLoopHandler);
			_game.removeEventListener(FrameworkEvent.PAUSE, pauseResumeHandler);
			_game.removeEventListener(FrameworkEvent.RESUME, pauseResumeHandler);
			_game.global.main.removeEventListener(MouseEvent.MOUSE_OVER, mouseOverHandler);
			_view.removeEventListener(MouseEvent.CLICK,clickHandler);
			if (_numMcList){
				var i:int=_numMcList.length;
				while (--i >= 0) 
					ButtonEffect.killOf(_numMcList[i]);
			}
			if(_moveTo){
				GameObject.destroy(_moveTo);
			}
			ButtonEffect.killOf(_moreGame);
			ButtonEffect.killOf(_toSelectLevel);
			ButtonEffect.killOf(_help);
			ButtonEffect.killOf(_toTitle);
			ButtonEffect.killOf(_resetLevel);
			ButtonEffect.killOf(_nextLevel);
			ButtonEffect.killOf(_toStory);
			if (_keyboardMan){
				GameObject.destroy(_keyboardMan);
				_keyboardMan=null;
			}
			_moreGame=null;
			_toSelectLevel=null;
			_help=null;
			_toTitle=null;
			_numMcList=null;
			_resetLevel=null;
			_nextLevel=null;
			_mute=null;
			_muteOnce=null;
			_muteLoop=null;
			_pause=null;
			_toStory=null;
			_view=null;
			_scaler=null;
			super.onDestroy();
		}
		
	}

}