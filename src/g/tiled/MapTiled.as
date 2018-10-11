package g.tiled{
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.geom.Point;
	import framework.game.Game;
	import framework.game.UpdateType;
	import g.map.Map;
	import g.map.MapCamera;
	import g.MyData;
	import framework.tiled.TiledMap;
	import g.map.MapData;
	import framework.utils.LibUtil;

	public class MapTiled extends Map{
		private var _tiledMap:TiledMap;
		
		public static function create():void{
			var game:Game=Game.getInstance();
			game.createGameObj(new MapTiled());
		}
		
		public function MapTiled(){ super(); }
		
		override protected function init(info:* = null):void{
			_width=MyData.designW+(10<<1);
			_height=MyData.designH+(10<<1);
			var gameLevel:int=_myGame.myGlobal.gameLevel;
			
			_tiledMap=new TiledMap(MapData.getTmx(gameLevel));
			
			var data:*=MapData.getDataObj(gameLevel);
			_width=data.size.width;
			_height=data.size.height;
			
			_mc_bgMiddle=LibUtil.getDefMovie(data.bgMiddle.name);
			_mc_bgMiddle.gotoAndStop(data.bgMiddle.frame);
			_mc_bgBottom=LibUtil.getDefMovie(data.bgBottom.name);
			_mc_bgBottom.gotoAndStop(data.bgBottom.frame);
			
			//_view=MapTiledView.create(_mapModel as MapTiledModel,_game);
			//createMapBodies();
			//createObjs();
			
			var cameraSize:Point=new Point(MyData.designW,MyData.designH);
			var cameraTarget:DisplayObject=_game.global.layerMan.gameLayer;
			_camera=MapCamera.create(cameraSize,_width,_height,cameraTarget);
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