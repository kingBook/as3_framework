package framework.b2Editor{
	import flash.geom.Point;
	import flash.geom.Rectangle;
    public class TilemapData{
		public var name:String;
		//orientation
		public var orientation:String;
		//layoutGrid
        public var cellSize:Point;
		public var cellGap:Point;
		public var cellSwizzle:String;
		//cellBounds
		public var cellBounds:Rectangle;
		//tilesBlock
		public var tileDatas:Vector.<TileData>;
		public var data:String;
        
        public var childGameObjectData:Vector.<GameObjectData>=new Vector.<GameObjectData>();
    }
}