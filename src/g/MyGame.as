package g{
	import flash.display.MovieClip;
	import flash.display.Stage;
	import flash.system.Capabilities;
	import framework.debug.FPSDebug;
	import framework.game.Game;
	import framework.objs.GameObject;
	import framework.system.LocalManager;
	import framework.utils.FuncUtil;
	import framework.utils.LibUtil;
	import g.events.MyEvent;
	import g.map.Map;
	import demo.TestObj;
	import framework.system.SoundInstance;
	import g.map.MapData;
	import g.ui.GameMessageUI;
	import g.ui.UI;

	public class MyGame extends Game{
		public function MyGame(){
			super();
		}
		public static function getInstance():MyGame{
			return (_instance||=new MyGame()) as MyGame;
		}
		public static function destroy():void{
			Game.destroy();
		}
		
		override protected function init():void{
			_fixedTimestep=MyData.fixedTimestep;
			super.init();
		}
		override public function startup(main:Main,gameRoot:GameRoot,stage:Stage,info:*=null):void{
			trace("==== startup MyGame ====");
			//初始全局对象
			_global=MyGlobal.create(main,gameRoot,stage);
			GameObject.dontDestroyOnDestroyAll(_global);
			if (MyData.clearLocalData) _global.localManager.clear();
			if (MyData.mute) _global.soundMan.mute = true;
			//设置语言
			if(MyData.languageVersion=="auto"){
				var isCN:Boolean=flash.system.Capabilities.language=="zh-CN";
				MyData.language=isCN?"cn":"en";
			}else{
				MyData.language=MyData.languageVersion;
			}
			MyData.isAIR=Capabilities.playerType=="Desktop";
			//FPS
			if(MyData.isVisibleFPS)FPSDebug.create(gameRoot);
			super.startup(main,gameRoot,stage,info);
		}
		/**保存解锁关卡*/
		public function saveUnlockNextLevel():void{
			var localMan:LocalManager = _global.localManager;
			// 解锁关卡
			var unlockLevel:int = getUnlockLevel();
			if (myGlobal.gameLevel+1>unlockLevel)
				localMan.save("unlockLevel",Math.min(myGlobal.gameLevel + 1,MapData.maxLevel));
		}
		public function getUnlockLevel():int{
			return _global.localManager.getInt("unlockLevel",1);
		}
		private function destroyCurLevel():void{
			destoryAllEndLevelAnims();
			myGlobal.destroyCurLevel();
			destroyAll();
		}
		public function gotoTitle(isDestroyCurLevel:Boolean=false):void{
			if(isDestroyCurLevel)destroyCurLevel();
			UI.create(UI.TITLE);
			_global.soundMan.stopAll();
			_global.soundMan.playLoop("Sound_title");
		}
		public function gotoSelectLevel(isDestroyCurLevel:Boolean=false):void{
			if(isDestroyCurLevel)destroyCurLevel();
			UI.create(UI.SELECT_LEVEL);
			_global.soundMan.stopAll();
			_global.soundMan.playLoop("Sound_title");
		}
		public function gotoHelp():void{
			UI.create(UI.HELP);
            if(!MyData.isEndContinueBackgroupMusic){
			    
            }else{
                _global.soundMan.stop("Sound_bg");
            }
		}
		
		public function win(isCreateAnim:Boolean=false,endUIDelay:Number=0):void{
			if(!myGlobal.isGameing) return;
			trace("==== game win ====");
			myGlobal.win();
			//
			function cb():void{
				//computeSaveStarNum(myGlobal.gameLevel);
				// 弹过关，通关 界面
				if (myGlobal.gameLevel<MapData.maxLevel){
					UI.create(UI.MISSION_COMPLETE,endUIDelay);
				}else {
					UI.create(UI.VICTORY,endUIDelay);
				}
				
				saveUnlockNextLevel();
				//播放胜利音效
                if(!MyData.isEndContinueBackgroupMusic){
				    _global.soundMan.stopAll();
                }
				_global.soundMan.play("Sound_win");
			}
			if(isCreateAnim)createEndLevelAnim("WinAnim_mc",cb);
			else cb();
		}
		public function failure(isCreateAnim:Boolean=false,endUIDelay:Number=0):void{
			if (!myGlobal.isGameing) return;
			trace("==== game failure ====");
			myGlobal.gameFailure();
			//
			function cb():void{
				UI.create(UI.FAILURE,endUIDelay);
				if(!MyData.isEndContinueBackgroupMusic){
				    _global.soundMan.stopAll();
                }
				_global.soundMan.play("Sound_failure");
			}
			if(isCreateAnim)createEndLevelAnim("FailureAnim_mc",cb);
			else cb();
		}
		
		public function resetLevel():void{
			destroyCurLevel();
			gotoLevel(myGlobal.gameLevel);
		}
		public function nextLevel():void{
			destroyCurLevel();
			gotoLevel(myGlobal.gameLevel+1);
		}
		
		/**创建切场过渡动画*/
		public function createTransitionAnim(defName:String,atMaskAllFrame:int,destroyFunc:Function=null,newFunc:Function=null):MovieClip{
			var mc:MovieClip=LibUtil.getDefMovie(defName,null,true);
			mc.play();
			mc.addFrameScript(atMaskAllFrame-1,function():void{
				if(destroyFunc!=null)destroyFunc();
			});
			mc.addFrameScript(atMaskAllFrame,function():void{
				if(newFunc!=null)newFunc();
			});
			mc.addFrameScript(mc.totalFrames-1,function():void{
				mc.stop();
				mc.addFrameScript(atMaskAllFrame-1,null);
				mc.addFrameScript(atMaskAllFrame,null);
				mc.addFrameScript(mc.totalFrames-1,null);
				FuncUtil.removeChild(mc);
			});
			mc.scaleX=myGlobal.resizeMan.curWScale;
			mc.scaleY=myGlobal.resizeMan.curHScale;
			global.layerMan.uiLayer.addChild(mc);
			return mc;
		}
		
		private var _endLevelAnims:Vector.<MovieClip>=new Vector.<MovieClip>();
		/**创建关卡结束弹界面之前的动画*/
		private function createEndLevelAnim(mcDefName:String,onEndFrame:Function):void{
			var animMc:MovieClip=LibUtil.getDefMovie(mcDefName,null,false);
			animMc.x=(MyData.designW*0.5)*myGlobal.resizeMan.curWScale;
			animMc.y=(MyData.designH*0.5)*myGlobal.resizeMan.curHScale;
			animMc.scaleX=animMc.scaleY=myGlobal.resizeMan.curScale;
			global.layerMan.uiLayer.addChild(animMc);
			var endFrame:int=animMc.totalFrames-1;
			animMc.addFrameScript(endFrame,function():void{
				animMc.addFrameScript(endFrame,null);
				FuncUtil.removeChild(animMc);
				onEndFrame();
				
				var id:int=_endLevelAnims.indexOf(animMc);
				if(id>-1)_endLevelAnims.splice(id,1);
			});
			_endLevelAnims.push(animMc);
		}
		private function destoryAllEndLevelAnims():void{
			for(var i:int=0;i<_endLevelAnims.length;i++){
				var mc:MovieClip=_endLevelAnims[i];
				if(mc.parent)mc.parent.removeChild(mc);
				mc.stop();
			}
			_endLevelAnims.splice(0,_endLevelAnims.length);
		}
		public function computeSaveStarNum(gameLevel:int):void{
			//myGlobal.starNum=computeStarNum();
			saveStarNum(myGlobal.starNum,gameLevel);
		}
		/*public function computeStarNum():int{
			var starNum:int;
			var ratio:Number=myGlobal.coinCount/myGlobal.coinTotal;
			ratio*=100;
			if(ratio>=90){
				starNum=3;
			}else if(ratio>=65){
				starNum=2;
			}else if(ratio>=50){
				starNum=1;
			}else{
				starNum=0;
			}
			return starNum;
		}*/
		private function saveStarNum(starNum:int,gameLevel:int):void{
			var localMan:LocalManager=_global.localManager;
			localMan.save("starNum_"+gameLevel,starNum);
		}
		public function getLocalStarNum(gameLevel:int):int{
			var localMan:LocalManager=_global.localManager;
			return localMan.getInt("starNum_"+gameLevel,0);
		}
		
		public function gotoLevel(level:int):void{
			myGlobal.gotoLevel(level);
			// 播放背景音乐
            if(!MyData.isEndContinueBackgroupMusic){
                _global.soundMan.stopAll();
			    _global.soundMan.playLoop("Sound_bg",0.6);
            }else{
                _global.soundMan.stop("Sound_title");
                _global.soundMan.stop("Sound_failure");
                _global.soundMan.stop("Sound_win");
                var si:SoundInstance=_global.soundMan.getSoundInstance("Sound_bg");
                if(!si||!si.isPlaying){
                    _global.soundMan.playLoop("Sound_bg",0.6);
                }
            }
			//创建控制面板
			if(!MyData.isDisableControllBar) UI.create(UI.CONTROL_BAR);
			//创建地图
			var map:Map=Map.create();
			dispatchEvent(new MyEvent(MyEvent.CREATE_MAP_COMPLETE));
			//创建游戏信息界面
			GameMessageUI.create();
			
			//
			//TestObj.create();			
		}
		override protected function onDestroy():void{
			super.onDestroy();
		}
		public function get myGlobal():MyGlobal{return _global as MyGlobal;}
	};
}

