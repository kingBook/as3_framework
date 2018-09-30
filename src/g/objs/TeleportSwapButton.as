package g.objs{
	import Box2D.Collision.Shapes.b2Shape;
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.b2Body;
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import framework.game.Game;
	import framework.objs.Clip;
	import framework.objs.GameObject;
	import framework.utils.Box2dUtil;
	import g.MyData;
	import g.fixtures.Switcher;
	import g.fixtures.SwitcherCtrlObj;
	import Box2D.Dynamics.b2World;
	//名称:TeleportSwapButton_开关名
	//TeleportSwapButton_s111
	/**传送口的状态切换按钮*/
	public class TeleportSwapButton extends Switcher{
		
		public static function create(childMc:MovieClip,viewDefName:String,world:b2World):void{
			var game:Game=Game.getInstance();
			var nameList:Array=childMc.name.split("_");
			/*
			 i:0 TeleportSwapButton
			 i:1 s111
			*/
			var info:*={};
			info.body=Box2dUtil.createCircle(childMc.width>>1,childMc.x,childMc.y,world,MyData.ptm_ratio);
			info.clip=Clip.fromDefName(viewDefName,true,true,game.global.layerMan.items3Layer,childMc.x,childMc.y,true);
			info.myName=nameList[1];
			game.createGameObj(new TeleportSwapButton(),info);
		}
		
		private var _isMouseDown:Boolean;
		
		public function TeleportSwapButton(){
			super();
		}
		
		override protected function init(info:* = null):void{
			_myName=info.myName;
			
			_body=info.body;
			_body.SetType(b2Body.b2_staticBody);
			_body.SetSensor(true);
			_body.SetUserData({type:"teleportSwapButton",thisObj:this});
			
			_clip=info.clip;
			_game.global.stage.addEventListener(MouseEvent.MOUSE_DOWN,mouseHandler);
			_game.global.stage.addEventListener(MouseEvent.MOUSE_UP,mouseHandler);
			//_game.global.stage.addEventListener(Event.DEACTIVATE,);
		}
		
		private function mouseHandler(e:MouseEvent):void{
			var mouseX:Number=e.stageX/MyData.ptm_ratio;
			var mouseY:Number=e.stageY/MyData.ptm_ratio;
			if(e.type==MouseEvent.MOUSE_DOWN){
				_isMouseDown=true;
				if(getContainsPos(mouseX,mouseY)){
					_clip.gotoAndStop(2);
					handlingLinkObjects();
					playSound();
				}
			}else{
				if(_clip.currentFrame!=1)_clip.gotoAndStop(1);
				_isMouseDown=false;
			}
		}
		
		private function getContainsPos(x:Number,y:Number):Boolean{
			var shape:b2Shape=_body.GetFixtureList().GetShape();
			return shape.TestPoint(_body.GetTransform(),b2Vec2.MakeOnce(x,y));
		}
		
		override protected function handlingLinkObjects():void{
			var ctrlObjs:Array=_game.getGameObjList(SwitcherCtrlObj);
			var i:int=ctrlObjs.length;
			var ctrlObj:SwitcherCtrlObj;
			while(--i>=0){
				ctrlObj=SwitcherCtrlObj(ctrlObjs[i]);
				if(ctrlObj.ctrlMySwitcherName==_myName)ctrlObj.control();
			}
		}
		
		override protected function update():void{
			var mouseX:Number=_game.global.stage.mouseX/MyData.ptm_ratio;
			var mouseY:Number=_game.global.stage.mouseY/MyData.ptm_ratio;
			var isContainsMouse:Boolean=getContainsPos(mouseX,mouseY);
			//if(isContainsMouse)Mouse.setMouseCursorButton();
			//else Mouse.setMouseCursorArrow();

			if(_isMouseDown){
				if(!isContainsMouse){
					if(_clip.currentFrame!=1)_clip.gotoAndStop(1);
				}
			}
		}
		
		override protected function onDestroy():void{
			_game.global.stage.removeEventListener(MouseEvent.MOUSE_DOWN,mouseHandler);
			_game.global.stage.removeEventListener(MouseEvent.MOUSE_UP,mouseHandler);
			super.onDestroy();
		}
		
	};

}