package g.map{
	import flash.display.MovieClip;
	import framework.utils.LibUtil;
	import g.Assets;
	import g.map.MapData;
	import g.MyGame;

	public class MapModel{
		
		public static function create(myGame:MyGame,viewportW:Number,viewportH:Number):MapModel{
			var model:MapModel=new MapModel();
			model.init(myGame,viewportW,viewportH);
			return model;
		}
		
		public var width:int;
		public var height:int;
		public var sceneXml:XML;
		public var assetDatabaseXml:XML;
		public var mc_wallfrontEff:MovieClip;
		public var mc_wall:MovieClip;
		public var mc_wallBehindEff:MovieClip;
		public var mc_bgMiddle:MovieClip;
		public var mc_bgBottom:MovieClip;
		
		protected var _myGame:MyGame;
		protected var _viewportW:int;
		protected var _viewportH:int;
		public function dispose():void{
			sceneXml=null;
			assetDatabaseXml=null;
			mc_wallfrontEff=null;
			mc_wall=null;
			mc_wallBehindEff=null;
			mc_bgMiddle=null;
			mc_bgBottom=null;
			
			_myGame=null;
		}
		
		public function MapModel(){ super(); }
		
		public function init(myGame:MyGame,viewportW:Number,viewportH:Number):void{
			_myGame=myGame;
			
			var gameLevel:int=myGame.myGlobal.gameLevel;
			sceneXml=MapData.getLevelXml(gameLevel);
			assetDatabaseXml=XML(Assets.getInstance().getFileWithName("assetDatabase.xml"));
			
			var data:*=MapData.getDataObj(gameLevel);
			width=data.size.width;
			height=data.size.height;
			
			_viewportW=Math.min(width,viewportW);
			_viewportH=Math.min(height,viewportH);
			
			mc_wallfrontEff=LibUtil.getDefMovie(data.wallFrontEff.name);
			mc_wallfrontEff.gotoAndStop(data.wallFrontEff.frame);
			mc_wall=LibUtil.getDefMovie(data.wall.name);
			mc_wall.gotoAndStop(data.wall.frame);
			mc_wallBehindEff=LibUtil.getDefMovie(data.wallBehindEff.name);
			mc_wallBehindEff.gotoAndStop(data.wallBehindEff.frame);
			mc_bgMiddle=LibUtil.getDefMovie(data.bgMiddle.name);
			mc_bgMiddle.gotoAndStop(data.bgMiddle.frame);
			mc_bgBottom=LibUtil.getDefMovie(data.bgBottom.name);
			mc_bgBottom.gotoAndStop(data.bgBottom.frame);
		}
		
		public function get viewportW():int{ return _viewportW; }
		public function get viewportH():int{ return _viewportH; }
		
	};

}