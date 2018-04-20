package g.tiled{
	import flash.geom.Point;
	import framework.system.ObjectPool;
	import framework.tiled.TiledMap;
	import framework.utils.LibUtil;
	import g.map.MapData;
	import g.map.MapModel;
	import g.MyData;
	import g.MyGame;
	
	public class MapTiledModel extends MapModel{
		
		public static function create(myGame:MyGame,offset:Number):MapTiledModel{
			var model:MapTiledModel=new MapTiledModel();
			//model.init(myGame,offset);
			return model;
		}
		
		public function MapTiledModel(){
			super();
		}
		
		private var _tiledMap:TiledMap;
		
		override public function init(myGame:MyGame,viewportW:Number,viewportH:Number):void{
			_myGame=myGame;
			this.width=MyData.designW+(10<<1);
			this.height=MyData.designH+(10<<1);
			var gameLevel:int=myGame.myGlobal.gameLevel;
			//bodiesXml=MapData.getBodiesXml(gameLevel);
			
			_tiledMap=new TiledMap(MapData.getTmx(gameLevel));
			
			var data:*=MapData.getDataObj(gameLevel);
			width=data.size.width;
			height=data.size.height;
			
			//mc_objs=LibUtil.getDefMovie(data.objs.name);
			//mc_objs.gotoAndStop(data.objs.frame);
			//mc_hit=LibUtil.getDefMovie(data.hit.name);
			//mc_hit.gotoAndStop(data.hit.frame);
			//mc_wallfrontEff=LibUtil.getDefMovie(data.wallFrontEff.name);
			//mc_wallfrontEff.gotoAndStop(data.wallFrontEff.frame);
			//mc_wall=LibUtil.getDefMovie(data.wall.name);
			//mc_wall.gotoAndStop(data.wall.frame);
			//mc_wallBehindEff=LibUtil.getDefMovie(data.wallBehindEff.name);
			//mc_wallBehindEff.gotoAndStop(data.wallBehindEff.frame);
			mc_bgMiddle=LibUtil.getDefMovie(data.bgMiddle.name);
			mc_bgMiddle.gotoAndStop(data.bgMiddle.frame);
			mc_bgBottom=LibUtil.getDefMovie(data.bgBottom.name);
			mc_bgBottom.gotoAndStop(data.bgBottom.frame);
			
			//var pool:ObjectPool=ObjectPool.getInstance();
			//bmd_wallSource=getSourceBitmapData("bmd_wallSource"+gameLevel,mc_wall,pool);
			//bmd_bgMiddleSource=getSourceBitmapData("bmd_bgMiddleSource"+gameLevel,mc_bgMiddle,pool);
			//bmd_bgBottomSource=getSourceBitmapData("bmd_bgBottomSource"+gameLevel,mc_bgBottom,pool);
/*[IF-FLASH-BEGIN]*/
			//bmd_wallView=getViewBitmapData(bmd_wallSource);
			//bmd_bgMiddleView=getViewBitmapData(bmd_bgMiddleSource);
			//bmd_bgBottomView=getViewBitmapData(bmd_bgBottomSource);
/*[IF-FLASH-END]*/
/*[IF-SCRIPT-BEGIN]
			//bmd_wallView=bmd_wallSource;
			bmd_bgMiddleView=bmd_bgMiddleSource;
			bmd_bgBottomView=bmd_bgBottomSource;
[IF-SCRIPT-END]*/
			//_pos_wall=new Point(0,0);
			//_pos_bgMiddle=new Point(0,0);
			//_pos_bgBottom=new Point(0,0);
		}
		
		/*override public function scroll(vx:int,vy:int):void{
			var vxx:Number=vx*0.2;
			var vyy:Number=vy*0.2;
			vxx=vxx>0?int(vxx+0.9):int(vxx-0.9);
			vyy=vyy>0?int(vyy+0.9):int(vyy-0.9);
			scrollBmd(bmd_bgBottomView,bmd_bgBottomSource,_pos_bgBottom,vxx,vyy);
			vxx=vx*0.5;
			vyy=vy*0.5;
			vxx=vxx>0?int(vxx+0.9):int(vxx-0.9);
			vyy=vyy>0?int(vyy+0.9):int(vyy-0.9);
			scrollBmd(bmd_bgMiddleView,bmd_bgMiddleSource,_pos_bgMiddle,vxx,vyy);
			//scrollBmd(bmd_wallView,bmd_wallSource,_pos_wall,vx,vy);
		}*/
		
		override public function dispose():void{
			super.dispose();
		}
		
		public function get tiledMap():TiledMap{ return _tiledMap; }
	};

}