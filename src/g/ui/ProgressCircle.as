package g.ui{
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.text.TextField;
	import framework.game.Game;
	import framework.utils.LibUtil;
	import g.objs.DisplayObj;
	import g.objs.MyObj;
	
	public class ProgressCircle extends DisplayObj{
		
		private var _mc:MovieClip;
		
		public static function create(defName:String="Progress_mc"):ProgressCircle{
			var game:Game=Game.getInstance();
			var parent:Sprite=game.global.layerMan.uiLayer;
			var info:*={};
			info.x=game.global.stage.stageWidth*0.5-parent.x;
			info.y=game.global.stage.stageHeight*0.5-parent.y;
			info.view=LibUtil.getDefMovie(defName);
			info.viewParent=parent;
			return game.createGameObj(new ProgressCircle(),info) as ProgressCircle;
		}
		
		public function ProgressCircle(){
			super();
		}
		
		override protected function init(info:*=null):void{
			super.init(info);
			_mc=_view as MovieClip;
			_game.global.stage.addEventListener(Event.RESIZE,onResize);
		}
		
		private function onResize(e:Event):void{
			_mc.x=_game.global.stage.stageWidth*0.5-_mc.parent.x;
			_mc.y=_game.global.stage.stageHeight*0.5-_mc.parent.y;
		}
		
		public function setProgress(ratio:Number):void{
			var progress:Number=(ratio*100)|0;
			var txt:TextField=_mc.getChildByName("txt") as TextField;
			if(txt){
				txt.text=progress+"%";
			}
		}
		
		override protected function onDestroy():void{
			_game.global.stage.removeEventListener(Event.RESIZE,onResize);
			_mc=null;
			super.onDestroy();
		}
	};

}