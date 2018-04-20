package framework.system {
	import Box2D.Dynamics.b2DebugDraw;
	import Box2D.Dynamics.b2World;
	import flash.display.Sprite;
	import framework.game.Game;
	import framework.objs.GameObject;
	import framework.utils.FuncUtil;
	public class Box2dDebug extends GameObject {
		private var _debugDraw:b2DebugDraw;
		private var _sprite:Sprite;
		private var _world:b2World;
		public function Box2dDebug(){
			super();
		}
		public static function create(world:b2World,ptm_ratio:Number):Box2dDebug{
			var game:Game=Game.getInstance();
			var info:*={};
			info.world=world;
			info.ptm_ratio=ptm_ratio;
			return game.createGameObj(new Box2dDebug(),info) as Box2dDebug;
		}
		override protected function init(info:* = null):void{
			super.init(info);
			_sprite=new Sprite();
			_sprite.name = "DebugDrawSprite";
			_game.global.layerMan.gameLayer.addChild(_sprite);
			_debugDraw=new b2DebugDraw();
			_debugDraw.SetSprite(_sprite);
			_debugDraw.SetDrawScale(info.ptm_ratio);
			_debugDraw.SetFillAlpha(0);
			_debugDraw.SetLineThickness(0.5);
			_debugDraw.SetFlags(b2DebugDraw.e_shapeBit|b2DebugDraw.e_jointBit/*|b2DebugDraw.e_centerOfMassBit*/);
			_world=info.world;
			drawWorld(_world);
		}
		private function drawWorld(world:b2World):void{
			_world = world;
			_world.SetDebugDraw(_debugDraw);
		}
		public function clear():void{
			if(_sprite)_sprite.graphics.clear();
		}
		override protected function onDestroy():void{
			clear();
			if(_world)_world.SetDebugDraw(null);
			FuncUtil.removeChild(_sprite);
			_debugDraw=null;
			_sprite=null;
			_world=null;
			super.onDestroy();
		}
		
		public function get debugDraw():b2DebugDraw{ return _debugDraw; }
	}

}