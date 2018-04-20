package demo{
	import framework.game.Game;
	import framework.objs.GameObject;
	import framework.tiled.TiledLayer;
	import framework.tiled.TiledMap;
	import framework.tiled.TiledObject;
	import framework.tiled.TiledObjectLayer;
	import framework.tiled.TiledReader;
	import framework.tiled.TiledTileLayer;
	public class TestTiledMap extends GameObject{
		public static function create():void{
			var game:Game=Game.getInstance();
			game.createGameObj(new TestTiledMap());
		}
		
		public function TestTiledMap(){
			super();
		}
		
		[Embed(source="../../bin/assets/1.tmx", mimeType="application/octet-stream")]
		private const WORLD:Class;
		override protected function init(info:* = null):void{
			var reader:TiledReader=new TiledReader();
			var map:TiledMap = reader.loadFromEmbedded(WORLD);
			
			var layerHit:TiledTileLayer=map.layers.getByNameLayers("hit")[0] as TiledTileLayer;
			
			//trace(layerHit.name);
			
			trace(layerHit.toDataString());
			
			var layerObj:TiledObjectLayer=map.layers.getByNameLayers("objs")[0] as TiledObjectLayer;
			trace(layerObj.name);
			
			var objs:Vector.<TiledObject>=layerObj.objects;
			for(var i:int=0;i<objs.length;i++){
				var o:TiledObject=objs[i];
				trace(o.type,o.x,o.y,o.rotation);
			}
			
			
			
			
		}
	};

}