package g.tiled{
    public class TilemapSortOrder{
		
		private var _type:String;
		public function TilemapSortOrder(type:String){
			_type=type;
		}
		
		public function toString():String{
			return "{ type:"+_type+" }";
		}
		
		public static const topLeft:TilemapSortOrder= new TilemapSortOrder("topLeft");
		public static const topRight:TilemapSortOrder=new TilemapSortOrder("topRight");
		public static const bottomLeft:TilemapSortOrder=new TilemapSortOrder("bottomLeft");
		public static const bottomRight:TilemapSortOrder=new TilemapSortOrder("bottomRight");
    }
}