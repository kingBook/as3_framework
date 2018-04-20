package g.tiled{
	import flash.display.DisplayObjectContainer;
	import flash.geom.Point;
	import framework.game.Game;
	import framework.objs.Clip;
	import g.objs.DisplayObj;
    /**瓦片*/
    public class TileBase extends DisplayObj{
		
		/**表示在容器中的排序优先级,优先级越高则越上面,相同优先级TileBase则在TilemapRenderer中根据规则再排序*/
        protected var _zOrder:int=0;
		
		private var _tilemap:Tilemap;
        private var _pos:Point;
		private var _posInt:Point;
		
		private var _tileName:String;
		private var _spriteName:String;
//BEGIN STATIC
		public static function create(tilemap:Tilemap,ix:int,iy:int,x:Number,y:Number,parent:DisplayObjectContainer,tileName:String=null,spriteName:String=null):TileBase{
			var game:Game=Game.getInstance();
			var info:*={};
			info.ix=ix;
			info.iy=iy;
			info.x=x;
			info.y=y;
			info.view=Clip.fromDefName(spriteName);
			info.viewParent=parent;
			info.tilemap=tilemap;
            info.tileName=tileName;
			info.spriteName=spriteName;
			return game.createGameObj(new TileBase(),info) as TileBase;
		}
		
		/**
		 * 返回一个随机方向的V2Point
		 * @return
		 */
        public static function getRandomV2Int():Point{
            var pt:Point=new Point(0,0);
            var isSetX:Boolean=Math.random()>0.5;
            var isUnsigned:Boolean=Math.random()>0.5;
            if(isSetX){
                pt.x=isUnsigned?1:-1;
            }else{
                pt.y=isUnsigned?1:-1;
            }
            return pt;
        }
//END STATIC
		public function TileBase(){
			super();
		}
        
        override protected function init(info:* = null):void{
			super.init(info);
			if(info){
				_tilemap=info.tilemap;
				_pos=new Point(info.x,info.y);
				_posInt=new Point(info.ix,info.iy);
				
				_tileName=info.tileName;
				_spriteName=info.spriteName;
			}
		}
        
        override protected function update():void{
            super.update();
            syncView();
        }
        
        protected function syncView():void{
            if(_view){
                _view.x=_pos.x;
                _view.y=_pos.y;
            }
        }
        
		
        private function setPosIntWithPixelPos(pixelPos:Point,isUpdateMapTiles:Boolean=true):void{
			setPosIntWithPointInt(getPosIntWithPixelPos(pixelPos),isUpdateMapTiles);
        }
		private function setPosInt(ix:int,iy:int,isUpdateMapTiles:Boolean=true):void{
            if(ix!=_posInt.x||iy!=_posInt.y){
				if(isUpdateMapTiles)_tilemap.removeTile(this);
                _posInt.setTo(ix,iy);
				if(isUpdateMapTiles)_tilemap.addTile(this);
            }
        }
		private function setPosIntWithPointInt(pointInt:Point,isUpdateMapTiles:Boolean=true):void{
			setPosInt(pointInt.x,pointInt.y,isUpdateMapTiles);
		}
		final protected function getPosIntWithPixelPos(pixelPos:Point,out:Point=null):Point{
			return tilemap.getPosIntWithPixelPos(pixelPos,out);
		}
		final protected function getPosWithPosInt(posInt:Point,out:Point=null):Point{
			return tilemap.getPixelPosWithPosInt(posInt,out);
		}
		
		
		final protected function movePos(vx:Number=0,vy:Number=0,isUpdatePosInt:Boolean=true):void{
			if(vx!=0||vy!=0){
				_pos.offset(vx,vy);
				setPosIntWithPixelPos(_pos,isUpdatePosInt);
			}
		}
		final protected function setPos(x:Number,y:Number,isUpdatePosInt:Boolean=true):void{
			_pos.setTo(x,y);
			setPosIntWithPixelPos(_pos,isUpdatePosInt);
		}
		
		
		/**
		 * 返回指定格子位置所有瓦片
		 * @param	posInt 格子位置
		 * @param   out
		 * @return 
		 */
		final public function getTilesWithAllTilemapPosInt(posInt:Point,out:Vector.<TileBase>=null):Vector.<TileBase>{
			return tilemap.getTilesWithAllTilemapPosInt(posInt,out);
		}
		
		/**
		 * 返回指定像素位置所有瓦片
		 * @param	pixelPos 格子位置
		 * @param   out
		 * @return 
		 */
		final protected function getTilesWithAllTilemapPixelPos(pixelPos:Point,out:Vector.<TileBase>):Vector.<TileBase>{
			return tilemap.getTilesWithAllTilemapPixelPos(pixelPos,out);
		}
		/**返回当前格子是否有指定类型的瓦片*/
		final protected function getHasTypeAllTilemapPosInt(type:Class,posInt:Point):Boolean{
			var tiles:Vector.<TileBase>=getTilesWithAllTilemapPosInt(posInt);
			for(var i:int=0;i<tiles.length;i++){
				var child:TileBase=tiles[i];
				if(child is type){
					return true;
					break;
				}
			}
            return false;
		}
		
		override protected function onDestroy():void{
			if(_tilemap){
				_tilemap.removeTile(this);
				_tilemap=null;
			}
            _pos=null;
            _posInt=null;
			super.onDestroy();
		}
		
        public function get pos():Point{ return _pos; }
        public function get tilemap():Tilemap{ return _tilemap; }
        public function get posInt():Point{ return _posInt; }
		public function get tileName():String{ return _tileName; }
		public function get spriteName():String{ return _spriteName; }
		public function get zOrder():int{ return _zOrder; }
        
    }
}