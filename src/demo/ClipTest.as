package demo {
	import framework.game.Game;
	import framework.game.UpdateType;
	import framework.objs.Clip;
	import framework.objs.GameObject;
	import flash.display.Sprite;
	
	

	public class ClipTest extends GameObject{
		public static function create(clipDefName:String):void{
			var game:Game=Game.getInstance();
			game.createGameObj(new ClipTest(),{defName:clipDefName});
		}
		
		public function ClipTest(){
			super();
		}
		
		override protected function init(info:*=null):void{
			var sp:Sprite = new Sprite();
			_game.global.main.addChild(sp);

			var clip:Clip=Clip.fromDefName(info.defName,true,true,_game.global.main);
			
			super.init(info);
		}
		
		override protected function update():void{
			
		}
	};
}