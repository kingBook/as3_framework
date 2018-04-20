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
		
		public function MapBg(){
			super();
		}
		
		public static function create(mc:MovieClip,parent:Sprite,mapCamera:MapCamera,friction:Number=1,isScorll:Boolean=true):MapBg{
			var game:Game=Game.getInstance();
			var info:*={};
			info.mc=mc;
			info.mapCamera=mapCamera;
			info.view=new Sprite();
			info.viewParent=parent;
			info.friction=friction;
			info.isScorll=isScorll;
			return game.createGameObj(new MapBg(),info) as MapBg;
		}
		
		override protected function init(info:* = null):void{
			super.init(info);
			_friction=info.friction;
			_isScorll=info.isScorll;
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
		}
		
		private function cameraMove(e:MyEvent):void{
			var vx:int=e.info.vx;
			var vy:int=e.info.vy;
			if(_isScorll){
				vx*=_friction;
				vy*=_friction;
				vx=vx>0?int(vx-0.9):int(vx+0.9);
				vy=vy>0?int(vy-0.9):int(vy+0.9);
				_sprite.x+=vx;
				_sprite.y+=vy;
			}else{
				_sprite.x+=vx;
				_sprite.y+=vy;
			}
		}
		
		override protected function onDestroy():void{
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