package g.map{
	import Box2D.Collision.Shapes.b2Shape;
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.b2Fixture;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import framework.game.Game;
	import framework.utils.FuncUtil;
	import g.MyData;
	import g.map.MapCamera;
	import g.events.MyEvent;
	import g.objs.DisplayObj;
	
	public class MapWall extends DisplayObj{
		
		private var _bmd:BitmapData;
		private var _sprite:Sprite;
		private var _friction:Number;
		private var _body:b2Body;
		private var _offset:Point;
		
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
			_offset=new Point(bmp.x,bmp.y);
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
		
		public function hitTestPoint(x:int,y:int):Boolean{
			x-=_offset.x;
			y-=_offset.y;
			var pixel:uint=_bmd.getPixel32(x,y);
			return pixel>0;
		}
		
		/**
		 * 检测某点与刚体碰撞
		 * @param	x 像素单位
		 * @param	y 像素单位
		 * @return
		 */
		public function hitBodyPoint(x:Number,y:Number):Boolean{
			var result:Boolean=false;
			var p:b2Vec2=b2Vec2.MakeOnce(x/MyData.ptm_ratio,y/MyData.ptm_ratio);
			for(var fixture:b2Fixture=_body.GetFixtureList();fixture;fixture=fixture.GetNext()){
				var shape:b2Shape=fixture.GetShape();
				if(shape.TestPoint(_body.GetTransform(),p)){
					result=true;
					break;
				}
			}
			return result;
		}
		
		public function get sprite():Sprite{
			return _sprite;
		}
	};

}