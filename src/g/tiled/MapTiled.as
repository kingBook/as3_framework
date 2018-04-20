package g.tiled{
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.geom.Point;
	import framework.game.Game;
	import framework.game.UpdateType;
	import g.map.Map;
	import g.map.MapCamera;
	import g.MyData;

	public class MapTiled extends Map{
		
		public static function create():void{
			var game:Game=Game.getInstance();
			game.createGameObj(new MapTiled());
		}
		
		public function MapTiled(){ super(); }
		
		override protected function init(info:* = null):void{
			_mapModel=MapTiledModel.create(_myGame,10);
			//_view=MapTiledView.create(_mapModel as MapTiledModel,_game);
			//createMapBodies();
			//createObjs();
			
			var cameraSize:Point=new Point(MyData.designW,MyData.designH);
			var cameraTarget:DisplayObject=_game.global.layerMan.gameLayer;
			_camera=MapCamera.create(cameraSize,_mapModel.width,_mapModel.height,cameraTarget);
		}
		
		/*override protected function createMapBodies():void{
			//_model.createXmlBodies();
			createWorldEdgeBodies(0,-100,0,100);
		}*/
		
		
		
		override protected function onDestroy():void{
			super.onDestroy();
		}
		
		
	};

}