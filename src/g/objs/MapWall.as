package g.objs{
	import Box2D.Dynamics.b2Body;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.geom.Rectangle;
	import framework.game.Game;
	import framework.utils.FuncUtil;
	import g.map.MapCamera;
	import g.events.MyEvent;
	
	public class MapWall extends DisplayObj{
		
		private var _bmd:BitmapData;
		private var _sprite:Sprite;
		private var _friction:Number;
		private var _body:b2Body;
		
		
		public function MapWall(){
			super();
		}
		
		public static function create(mc:MovieClip,parent:Sprite,body:b2Body):MapWall{
			var game:Game=Game.getInstance();
			var info:*={};
			info.mc=mc;
			info.view=new Sprite();
			info.viewParent=parent;
			info.body=body;
			return game.createGameObj(new MapWall(),info) as MapWall;
		}
		
		override protected function init(info:* = null):void{
			super.init(info);
			_body=info.body;
			_friction=info.friction;
			_sprite=_view as Sprite;
			var mc:MovieClip=info.mc;
			
			var rect:Rectangle=mc.getBounds(mc);
			_bmd=FuncUtil.getBmdFromDisObj(mc);
			var bmp:Bitmap=new Bitmap(_bmd,"auto",true);
			bmp.x=rect.x;
			bmp.y=rect.y;
			_sprite.addChild(bmp);
		}
		
		override protected function onDestroy():void{
			if(_body)_body.Destroy();
			_bmd.dispose();
			_sprite=null;
			_bmd=null;
			_body=null;
			super.onDestroy();
		}
		
		public function get sprite():Sprite{
			return _sprite;
		}
	};

}