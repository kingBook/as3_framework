package demo {
	import Box2D.Dynamics.b2Body;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import framework.game.Game;
	import framework.events.FrameworkEvent;
	import framework.game.UpdateType;
	import framework.utils.FuncUtil;
	import g.events.MyEvent;
	import g.MyGame;
	import g.objs.MyObj;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;

	public class TestObj extends MyObj{
		public static function create():void{
			var game:Game=Game.getInstance();
			game.createGameObj(new TestObj());
		}
		
		private var sp:Sprite;
		private var bb:Sprite;
		private var cc:Sprite;
		private var b:b2Body;
		public function TestObj() {
			super();
			trace("new player");
		}
		
		override protected function init(info:*=null):void {
			//胜利按钮
			bb = createBtn(150, 100, "胜利", _game.global.layerMan.uiLayer);
			bb.name = "胜利";
			//失败按钮
			cc = createBtn(250, 100, "失败", _game.global.layerMan.uiLayer);
			cc.name = "失败";
			bb.addEventListener(MouseEvent.CLICK, clickHandler);
			cc.addEventListener(MouseEvent.CLICK, clickHandler);
			
			//滚动地图
			//_game.global.scorllMan.addToTargetList(b);
			
			MapScorllTest.create();
		}
		
		private function clickHandler(e:MouseEvent):void {
			var targetName:String=e.target["name"];
			switch (targetName) {
				case "胜利":
					trace("发送胜利");
					_myGame.win();
					break;
				case "失败":
					trace("发送失败");
					_myGame.failure();
					break;
				default:
			}
		}
		
		private function createBtn(x:Number,y:Number,text:String, parent:Sprite):Sprite {
			var sp:Sprite = new Sprite();
			sp.x = x;
			sp.y = y;
			sp.graphics.beginFill(0xcccccc, 1);
			sp.graphics.drawRect(0, 0, 60, 20);
			sp.graphics.endFill();
			
			var tf:TextFormat=new TextFormat();
			tf.align=TextFormatAlign.CENTER;
			
			var txt:TextField = new TextField();
			txt.defaultTextFormat=tf;
			txt.textColor = 0x000000;
			txt.text = text;
			txt.width = sp.width;
			txt.height = sp.height;
			
			sp.addChild(txt);
			parent.addChild(sp);
			
			sp.mouseChildren = false;
			sp.buttonMode = true;
			return sp;
		}
		
		override protected function update():void{
		}
		
		override protected function onDestroy():void {
			trace("destroy TestObj");
			bb.removeEventListener(MouseEvent.CLICK, clickHandler);
			cc.removeEventListener(MouseEvent.CLICK, clickHandler);
			FuncUtil.removeChild(bb);
			FuncUtil.removeChild(cc);
			FuncUtil.removeChild(sp);
			if(b) b.Destroy();
			b = null;
			bb = null;
			cc = null;
			sp = null;
			super.onDestroy();
		}
	}

}