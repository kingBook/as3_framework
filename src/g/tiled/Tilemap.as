package g.tiled{
	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import framework.b2Editor.GameObjectData;
	import framework.b2Editor.TileData;
	import framework.b2Editor.TilemapData;
	import framework.game.Game;
	import framework.objs.GameObject;
	import g.objs.MyObj;

	public class Tilemap extends MyObj{
		
		private var _name:String;
		private var _cellSize:Point;
		private var _cellCap:Point;//格子间隙
		private var _cellSwizzle:String;
		
		private var _cellBounds:Rectangle;//int值
		
		private var _ptm_ratio:Number;
		private var _renderer:TilemapRenderer;
		private var _origin:Point;
		
		/**
		 * 存储格式:
		 * [
		 * 	x0:[Vector[TileBase,...],Vector[TileBase,...],...],
		 *  x1:[Vector[TileBase,...],Vector[TileBase,...],...],
		 *  ...
		 * ]。
		 * _tiles每一个元素表示一个格子位置上的所有TileBase列表(Vector.<TileBase>)
		 * unity中Tilemap节点下的GameObject也继承TileBase加入到_tiles
		 */
		private var _tiles:Array;
		
		/**
		 * 创建Tilemap
		 * @param	tilemapGameObjectData
		 * @param	createTileFunc瓦片构建回调 function(tilemap:Tilemap,tag:String,tagID:int,ix:int,iy:int,x:Number,y:Number,parent:Sprite):TileBase;
         * @param	createTilemapChildFunc function(gameObjectData:GameObjectData,tilemap:Tilemap,parent:Sprite,ptm_ratio:Number):TileBase
		 * @param	sortOrder
		 * @param	ptm_ratio
		 * @return
		 */
		public static function create(tilemapGameObjectData:GameObjectData,createTileFunc:Function,createTilemapChildFunc:Function,sortOrder:TilemapSortOrder,parent:Sprite,ptm_ratio:Number=100):Tilemap{
            var game:Game=Game.getInstance();
            
            var tilemapData:TilemapData=tilemapGameObjectData.tilemapData;
			
			var tileNames:Vector.<String>=new Vector.<String>();
			var spriteNames:Vector.<String>=new Vector.<String>();
			for(var i:int=0;i<tilemapData.tileDatas.length;i++){
				var tileData:TileData=tilemapData.tileDatas[i];
				tileNames[i]=tileData.name;
				spriteNames[i]=tileData.sprite;
			}
			
			var info:*={};
			info.name=tilemapData.name;
			info.cellSize=new Point(tilemapData.cellSize.x*ptm_ratio,tilemapData.cellSize.y*ptm_ratio);
			info.cellCap=new Point(tilemapData.cellGap.x*ptm_ratio,tilemapData.cellGap.y*ptm_ratio);
			info.cellSwizzle=tilemapData.cellSwizzle;
			info.cellBounds=transformBounds(tilemapData.cellBounds);
			info.tileNames=tileNames;
			info.spriteNames=spriteNames;
			info.data=transformMapData(tilemapData.data,info.cellBounds.size);
			info.createTileFunc=createTileFunc;
			info.sortOrder=sortOrder;
			info.parent=parent;
			info.ptm_ratio=ptm_ratio;
			info.subGameObjectDatas=tilemapGameObjectData.subGameObjectDatas;
			info.createTilemapChildFunc=createTilemapChildFunc;
			return game.createGameObj(new Tilemap(),info) as Tilemap;
		}
		
		public static function transformBounds(bounds:Rectangle,out:Rectangle=null):Rectangle{
			if(!out)out=new Rectangle();
			out.x=bounds.x;
			out.y=(-bounds.y)-bounds.size.y;
			out.width=bounds.width;
			out.height=bounds.height;
			return out;
		}
		
		public static function getPixelPosWithPosInt(posInt:Point,origin:Point,cellSize:Point,out:Point=null):Point{
			out||=new Point();
			out.x=posInt.x*cellSize.x+cellSize.x*0.5;
			out.y=posInt.y*cellSize.y+cellSize.y*0.5;
			return out;
		}
		
		public static function getPosIntWithPixelPos(pixelPos:Point,origin:Point,cellSize:Point,out:Point=null):Point{
			out||=new Point();
			
			var px:Number=(pixelPos.x-cellSize.x*0.5)/cellSize.x;
			var py:Number=(pixelPos.y-cellSize.y*0.5)/cellSize.y;
			out.x=int(px>=0?px+0.5:px-0.5);
			out.y=int(py>=0?py+0.5:py-0.5);
			return out;
		}
        
		private static function transformMapData(sourceMapData:String,boundsSize:Point,out:Vector.<int>=null):Vector.<int>{
			if(!out)out=new Vector.<int>();
			if(sourceMapData){
				var sourceMapDataList:Array=sourceMapData.split(",");
				if(sourceMapDataList.length!=boundsSize.x*boundsSize.y)throw new Error("the bounds size does't match the data length!");
				
				var count:int=sourceMapDataList.length,i:int,j:int,tag:int,xNum:int=boundsSize.x,yNum:int=boundsSize.y;
				var yVec:Vector.<Vector.<int>>=new Vector.<Vector.<int>>();
				var xVec:Vector.<int>=new Vector.<int>();
				for(i=0;i<count;i++){
					tag=int(sourceMapDataList[i]);
					xVec.push(tag);
					if((i+1)%xNum==0){
						yVec.push(xVec);
						xVec=new Vector.<int>();
					}
				}
				i=yVec.length;
				while (--i>=0){
					for(j=0;j<yVec[i].length;j++)out.push(yVec[i][j]);
				}
			}
			return out;
		}
		
		public function Tilemap(){
			super();
		}
		
		override protected function init(info:* = null):void{
			super.init(info);
			_name=info.name;
			_cellSize=info.cellSize;
			_cellCap=info.cellCap;
			_cellSwizzle=info.cellSwizzle;
			_cellBounds=info.cellBounds;
			_ptm_ratio=info.ptm_ratio;
			_origin=new Point(_cellBounds.x,_cellBounds.y);
			
			_tiles=[];
			createTiles(info.createTileFunc,info.data,info.tileNames,info.spriteNames,info.parent);
			createTilemapChildren(info.subGameObjectDatas,info.createTilemapChildFunc,info.parent);
			_renderer=TilemapRenderer.create(info.sortOrder,this,info.parent);
		}
		
		private function createTiles(createTileFunc:Function,data:Vector.<int>,tileNames:Vector.<String>,spriteNames:Vector.<String>,parent:Sprite):void{
			var xNum:int=_cellBounds.size.x;
			var i:int,ix:int=0,iy:int=0,tagID:int;
			var tileName:String,spriteName:String,tile:TileBase,cellPos:Point=new Point(),pos:Point=new Point();
			for(i=0;i<data.length;i++){
				//cellPos表示格子左上角整数坐标
				cellPos.x=ix+_origin.x, cellPos.y=iy+_origin.y;
				this.getPixelPosWithPosInt(cellPos,pos);
				tagID=data[i];
				tileName=tileNames[tagID];
				spriteName=spriteNames[tagID];
				tile=createTileFunc(this,tileName,spriteName,tagID,cellPos.x,cellPos.y,pos.x,pos.y,parent);
				addTile(tile);
				//
				ix++;
				if((i+1)%xNum==0){
					ix=0;
					iy++;
				}
			}
		}
		
		private function createTilemapChildren(gameObjectDatas:Vector.<GameObjectData>,createTilemapChildFunc:Function,parent:Sprite):void{
            if(gameObjectDatas!=null){
				var i:int,gameObjData:GameObjectData,tile:TileBase;
                for(i=0;i<gameObjectDatas.length;i++){
					gameObjData=gameObjectDatas[i];
					tile=createTilemapChildFunc(gameObjData,this,parent,_ptm_ratio);
					addTile(tile);
                }
            }
        }
		
		public function addTile(tile:TileBase):void{
			if(tile==null)return;
			if(tile.posInt==null)return;
			var ix:int=tile.posInt.x;
			var iy:int=tile.posInt.y;
			_tiles[ix]||=[];
			_tiles[ix][iy]||=new Vector.<TileBase>();
			var vec:Vector.<TileBase>=_tiles[ix][iy];
			var fId:int=vec.indexOf(tile);
			if(fId<0)vec.push(tile);
		}
		
		public function removeTile(tile:TileBase):void{
			if(tile==null)return;
			var ix:int=tile.posInt.x;
			var iy:int=tile.posInt.y;
			if(_tiles[ix]&&_tiles[ix][iy]){
				var vec:Vector.<TileBase>=_tiles[ix][iy];
				var fId:int=vec.indexOf(tile);
				if(fId>-1)vec.splice(fId,1);
			}
		}
		
		public function getTiles(posInt:Point):Vector.<TileBase>{
			var ix:int=posInt.x;
			var iy:int=posInt.y;
			if(_tiles[ix]&&_tiles[ix][iy]) return _tiles[ix][iy];
			return null;
		}
		
		/**判断指定的格子位置是否超出格子范围*/
		public function getPosIntOutCellBounds(posInt:Point):Boolean{
			var result:Boolean=false;
			result||=posInt.x<0;
			result||=posInt.y<0;
			result||=posInt.x>=_cellBounds.size.x;
			result||=posInt.y>=_cellBounds.size.y;
			return result;
		}
		
		public function getPixelPosWithPosInt(posInt:Point,out:Point=null):Point{
			return Tilemap.getPixelPosWithPosInt(posInt,origin,cellSize,out);
		}
		
		public function getPosIntWithPixelPos(pixelPos:Point,out:Point=null):Point{
			return Tilemap.getPosIntWithPixelPos(pixelPos,origin,cellSize,out);
		}
		
		/**
		 * 返回指定格子位置所有瓦片地图的所有瓦片(TileBase)
		 * @param	posInt 格子位置
		 * @param	out 
		 * @return 
		 */
        public function getTilesWithAllTilemapPosInt(posInt:Point,out:Vector.<TileBase>=null):Vector.<TileBase>{
			var pixelPos:Point=getPixelPosWithPosInt(posInt);
			return getTilesWithAllTilemapPixelPos(pixelPos,out);
		}
		/**
		 * 返回指定像素位置所有瓦片地图的所有瓦片(TileBase)
		 * @param	pixelPos 格子位置
		 * @param	out 
		 * @return 
		 */
        public function getTilesWithAllTilemapPixelPos(pixelPos:Point,out:Vector.<TileBase>=null):Vector.<TileBase>{
			out||=new Vector.<TileBase>();
			var tilemaps:Vector.<Tilemap>=Vector.<Tilemap>(_game.getGameObjList(Tilemap));
			var i:int,cellPos:Point=new Point(),map:Tilemap,tiles:Vector.<TileBase>;
			for(i=0;i<tilemaps.length;i++){
				map=tilemaps[i];
				map.getPosIntWithPixelPos(pixelPos,cellPos);
				tiles=map.getTiles(cellPos);
				if(tiles) out=out.concat(tiles);
			}
			return out;
        }
		
		
		override protected function onDestroy():void{
			GameObject.destroy(_renderer);
			_tiles=null;
			_cellSize=null;
			_cellCap=null;
			_cellBounds=null;
			_renderer=null;
			super.onDestroy();
		}
		
		public function get name():String{ return _name; }
		public function get cellSize():Point{ return _cellSize; }
		public function get cellCap():Point{ return _cellCap; }
		public function get cellSwizzle():String{ return _cellSwizzle; }
		/**cellBounds Rectngle int*/
		public function get cellBounds():Rectangle{ return _cellBounds; }
		public function get tiles():Array{ return _tiles; }
		public function get renderer():TilemapRenderer{ return _renderer; }
		public function get ptm_ratio():Number{ return _ptm_ratio; }
		/**origin point int*/
		public function get origin():Point{ return _origin; }
	};

}