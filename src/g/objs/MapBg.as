package g.objs{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.geom.Rectangle;
	import framework.game.Game;
	import framework.utils.FuncUtil;
	import g.map.MapCamera;
	import g.events.MyEvent;
	
	public class MapBg extends DisplayObj{
		
		private var _mapCamera:MapCamera;
		private var _bmd:BitmapData;
		private var _sprite:Sprite;
		private var _friction:Number;
		private var _isScorll:Boolean;
		private var _isFitStage:Boolean;
		
		public function MapBg(){
			super();
		}
		
		/**
		 * 创建
		 * @param	mc
		 * @param	parent
		 * @param	mapCamera
		 * @param	friction
		 * @param	isScorll
		 * @param	isFitStage 是否拉伸适合舞台（一般用于不需要滚动地图的游戏，MapCamera也不拉伸的情况下）
		 * @return
		 */
		public static function create(mc:MovieClip,parent:Sprite,mapCamera:MapCamera,friction:Number=1,isScorll:Boolean=true,isFitStage:Boolean=false):MapBg{
			var game:Game=Game.getInstance();
			var info:*={};
			info.mc=mc;
			info.mapCamera=mapCamera;
			info.view=new Sprite();
			info.viewParent=parent;
			info.friction=friction;
			info.isScorll=isScorll;
			info.isFitStage=isFitStage;
			return game.createGameObj(new MapBg(),info) as MapBg;
		}
		
		override protected function init(info:* = null):void{
			super.init(info);
			_friction=info.friction;
			_isScorll=info.isScorll;
			_isFitStage=info.isFitStage;
			_sprite=_view as Sprite;
			var mc:MovieClip=info.mc;
			
			var rect:Rectangle=mc.getBounds(mc);
			_bmd=FuncUtil.getBmdFromDisObj(mc);
			var bmp:Bitmap=new Bitmap(_bmd,"auto",true);
			bmp.x=rect.x;
			bmp.y=rect.y;
			_sprite.addChild(bmp);
			
			_mapCamera=info.mapCamera;
			_mapCamera.addEventListener(MapCamera.MOVE,cameraMove);
			
			if(_isFitStage){
				resize();
				_myGame.myGlobal.resizeMan.addListener(resize);
			}
		}
		
		private function resize():void{
			if(_isFitStage){
				_myGame.myGlobal.resizeMan.resizeBg_topLeft(_sprite);
			}
		}
		
		private function cameraMove(e:MyEvent):void{
			var vx:int=e.info.vx;
			var vy:int=e.info.vy;
			if(_isScorll){
				_sprite.x+=vx*_friction;//vx*_friction为Number
				_sprite.y+=vy*_friction;//vy*_friction为Number
			}else{
				_sprite.x+=vx;
				_sprite.y+=vy;
			}
		}
		
		override protected function onDestroy():void{
			if(_isFitStage){
				_myGame.myGlobal.resizeMan.removeListener(resize);
				_myGame.myGlobal.resizeMan.removeByNativePos(_sprite);
			}
			_bmd.dispose();
			_mapCamera.removeEventListener(MapCamera.MOVE,cameraMove);
			_sprite=null;
			_mapCamera=null;
			_bmd=null;
			super.onDestroy();
		}
		
		public function get sprite():Sprite{
			return _sprite;
		}
		
	};

}