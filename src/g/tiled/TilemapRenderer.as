package g.tiled{
	import flash.utils.getTimer;
	import g.objs.MyObj;
	import framework.game.Game;
	import flash.display.Sprite;
	import framework.utils.FuncUtil;
	import flash.display.DisplayObject;

	public class TilemapRenderer extends MyObj{
		
		private var _sortOrder:TilemapSortOrder;
		private var _tilemap:Tilemap;
		private var _sprite:Sprite;
        private var _tiles:Vector.<TileBase>;
		/**
		 * 创建TilemapRenderer
		 * @param sortOrder TilemapSortOrder.topLeft|topRight|bottomLeft|bottomRight
		 * @param tilemap
		 * @param sprite 
		 */
		public static function create(sortOrder:TilemapSortOrder,tilemap:Tilemap,sprite:Sprite):TilemapRenderer{
			var game:Game=Game.getInstance();
			var info:*={};
			info.sortOrder=sortOrder;
			info.tilemap=tilemap;
			info.sprite=sprite;
			return game.createGameObj(new TilemapRenderer(),info) as TilemapRenderer;
		}
		
		public function TilemapRenderer(){
			super();
		}
		
		override protected function init(info:*=null):void{
			super.init(info);
			_sortOrder=info.sortOrder;
			_tilemap=info.tilemap;
			_sprite=info.sprite;
            _tiles=new Vector.<TileBase>();
			sortHandler();
		}
		override protected function lateUpdate():void{
			super.lateUpdate();
			
			sortHandler();
		}
		
		private function sortHandler():void{
            getTiles(_tiles);
			sortDepth(_tiles);
            _tiles.splice(0,_tiles.length);
		}
        
        private function getTiles(out:Vector.<TileBase>=null):Vector.<TileBase>{
            out||=new Vector.<TileBase>();
            var allTiles:Vector.<TileBase>=Vector.<TileBase>(_game.getGameObjList(TileBase));
            var i:int,len:int=allTiles.length,tile:TileBase;
            for(i=0;i<len;i++){
                tile=allTiles[i];
                if(tile.view&&tile.view.parent&&tile.view.parent==_sprite){
                    out.push(tile);
                }
            }
            return out;
        }
		
		private function sortDepth(list:Vector.<TileBase>):void{
			list=list.sort(compare);
			var i:int,view:DisplayObject,tile:TileBase;
			for(i=0;i<list.length;i++){
				tile=list[i];
				view=tile.view;
				_sprite.addChild(view);
				/*if(i>0){
					trace("y:",tilemapChild.pos.y>=list[i-1].pos.y,view.y>=list[i-1].view.y);
					if(tilemapChild.pos.y==list[i-1].pos.y)trace("x:",tilemapChild.pos.x>=list[i-1].pos.x, view.x>=list[i-1].view.x);
				}*/
			}
			/*trace("--------------");
			for(i=0;i<list.length;i++){
				var index:int=_sprite.getChildIndex(list[i].view);
				trace(i,index,list[i].pos);
			}
			trace("==============");*/
		}
		private function compare(a:TileBase,b:TileBase):Number{
			var result:Number=0;
            var dz:int=a.zOrder-b.zOrder;
			var dx:Number=(a.view.x-_tilemap.cellSize.x*0.5)-(b.view.x+_tilemap.cellSize.x*0.5);
			var dy:Number=a.view.y-b.view.y;
			if(dz!=0){
                result=dz;
            }else if(dy!=0){
                result=dy;
            }else if(dx!=0){
                result=dx;
            }
			return result;
		}
		
		override protected function onDestroy():void{
			FuncUtil.removeChild(_sprite);
			_sortOrder=null;
			_tilemap=null;
			_sprite=null;
            _tiles=null;
			super.onDestroy();
		}
		
		public function get sortOrder():TilemapSortOrder{ return _sortOrder; }
		public function get sprite():Sprite{ return _sprite; }
	}
}