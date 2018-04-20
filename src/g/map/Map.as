package g.map{
	import Box2D.Dynamics.b2Body;
	import flash.display.DisplayObject;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.geom.Point;
	import framework.b2Editor.GameObjectData;
	import framework.b2Editor.UnityB2Loader;
	import framework.game.Game;
	import framework.objs.GameObject;
	import framework.system.Box2dManager;
	import framework.utils.Box2dUtil;
	import g.MyData;
	import g.objs.MapAnimClip;
	import g.objs.MapBg;
	import g.objs.MapWall;
	import g.objs.MyObj;
	import g.tiled.TileBase;
	import g.tiled.Tilemap;
	import g.tiled.TilemapSortOrder;

	public class Map extends MyObj{
		protected var _mapModel:MapModel;
		protected var _camera:MapCamera;
		protected var _unityB2Loader:UnityB2Loader;
		protected var _box2dMan:Box2dManager;
		protected var _mask:DisplayObject;
				
		public function Map(){super();}
		
		public static function create():Map{
			var game:Game=Game.getInstance();
			return game.createGameObj(new Map()) as Map;
		}
		
		override protected function init(info:* = null):void{
			createModel();
			//创建相机
			createCamera();
			//创建背景
			createBg();
			//创建unity关卡加载器
			createUnityB2Loader();
			//创建box2d管理
			if(_unityB2Loader.world)createBox2dManger();
			//创建世界边缘刚体
			//createWorldEdgeBodies(0,-100,0,100);
			//从刚体列表创建对象
			createObjsWithBodies(_unityB2Loader.bodies);
			//创建Tilemap
			createTilemapWithDatas(_unityB2Loader.tilemapGameObjectDatas);
			//创建遮罩
			if(!MyData.isAIR) createMask();
		}
		
		private function createModel():void{
			var tmpW:int,tmpH:int;
			if(MyData.isAIR){
				tmpW=_game.global.stage.stageWidth;
				tmpH=_game.global.stage.stageHeight;
			}else{
				tmpW=MyData.designW;
				tmpH=MyData.designH;
			}
			_mapModel=MapModel.create(_myGame,tmpW,tmpH);
		}
		
		private function createCamera():void{
			var cameraSize:Point=new Point(_mapModel.viewportW,_mapModel.viewportH);
			var cameraTarget:DisplayObject=_game.global.layerMan.gameLayer;
			_camera=MapCamera.create(cameraSize,_mapModel.width,_mapModel.height,cameraTarget);
		}
		
		private function createBg():void{
			var sprite:Sprite=_game.global.layerMan.items0Layer;
			if(_mapModel.mc_bgBottom.numChildren>0){
				var mapBg0:MapBg=MapBg.create(_mapModel.mc_bgBottom,sprite,_camera,0.5,true);
			}
			if(_mapModel.mc_bgMiddle.numChildren>0){
				var mapBg1:MapBg=MapBg.create(_mapModel.mc_bgMiddle,sprite,_camera,0.2,true);
			}
			//创建云朵
			//CloudBackgroup.create("Cloud_view",0.5,2,0,this.width,20,this.height*0.5,mapBg0.sprite);
		}
		
		protected function createWorldEdgeBodies(offsetL:Number=0,offsetT:Number=0,offsetR:Number=0,offsetD:Number=0):Vector.<b2Body>{
			var x:Number=offsetL;
			var y:Number=offsetT;
			var w:Number=_mapModel.width-offsetL+offsetR;
			var h:Number=_mapModel.height-offsetT+offsetD;
			var bodies:Vector.<b2Body>=Box2dUtil.createWrapWallBodies(x,y,w,h,_box2dMan.world,MyData.ptm_ratio);
			var i:int=bodies.length;
			while (--i>=0){
				bodies[i].SetType(b2Body.b2_staticBody);
				bodies[i].GetFixtureList().SetFriction(0);
				bodies[i].SetUserData({type:"EdgeGround"});
			}
			return bodies;
		}
		
		private function createMask():void{
			var target:Sprite=_game.global.layerMan.shakeLayer;
			var maskW:Number=camera.size.x;
			var maskH:Number=camera.size.y;
			var shape:Shape=new Shape();
			shape.graphics.beginFill(0,1);
			shape.graphics.drawRect(0,0,maskW,maskH);
			shape.graphics.endFill();
			target.parent.addChild(shape);
			target.mask = shape;
			_mask=shape;
		}
		
		private function createWall(body:b2Body):void{
			var sprite:Sprite=_game.global.layerMan.items2Layer;
			//创建墙后的clip
			if(_mapModel.mc_wallBehindEff.numChildren>0){
				MapAnimClip.create(_mapModel.mc_wallBehindEff,sprite);
			}
			//创建墙
			if(_mapModel.mc_wall.numChildren>0){
				MapWall.create(_mapModel.mc_wall,sprite,body);
			}
			//创建墙前的clip
			if(_mapModel.mc_wallfrontEff.numChildren>0){
				MapAnimClip.create(_mapModel.mc_wallfrontEff,sprite);
			}
		}
		
		private function createUnityB2Loader():void{
			var editorLoader:UnityB2Loader=UnityB2Loader.create(_mapModel.assetDatabaseXml,_mapModel.sceneXml);
			_unityB2Loader=editorLoader;
			GameObject.dontDestroyOnDestroyAll(_unityB2Loader);
		}
		
		private function createBox2dManger():void{
			var worldSprite:Sprite=_game.global.layerMan.gameLayer;
			var box2dMan:Box2dManager=Box2dManager.create(worldSprite,MyData.isDebugDraw,MyData.useMouseJoint,_unityB2Loader.world,
				MyData.ptm_ratio,_unityB2Loader.worldData.dt,_unityB2Loader.worldData.velocityIterations,_unityB2Loader.worldData.positionIterations);
			_box2dMan=box2dMan;
			GameObject.dontDestroyOnDestroyAll(_box2dMan);
		}
		
		private function createTilemapWithDatas(tilemapGameObjectDatas:Vector.<GameObjectData>):void{
            var tilemapRoot:Sprite=_game.global.layerMan.items3Layer;
			var i:int,sp:Sprite;
			for(i=0;i<tilemapGameObjectDatas.length;i++){
				sp=new Sprite();
				tilemapRoot.addChild(sp);
				var tilemap:Tilemap=Tilemap.create(tilemapGameObjectDatas[i],createTile,createTilemapChild,TilemapSortOrder.topLeft,sp);
			}
		}
		
		private function createTile(tilemap:Tilemap,tileName:String,spriteName:String,tagID:int,ix:int,iy:int,x:Number,y:Number,parent:Sprite):TileBase{
            var tile:TileBase=null;
			if(tileName=="None"){
				tile=null;
			}else{
				tile=TileBase.create(tilemap,ix,iy,x,y,parent,tileName,spriteName);
			}
			
			if(tileName!="None"&&!tile)throw new Error("在创建"+tileName+"时，变量tile没有被正确赋值");
			return tile;
		}
		
		private function createTilemapChild(gameObjectData:GameObjectData,tilemap:Tilemap,parent:Sprite,ptm_ratio:Number):TileBase{
			var tile:TileBase=null;
			var tag:String=gameObjectData.tag;
            var x:Number=gameObjectData.transformData.position.x*ptm_ratio;
            var y:Number=gameObjectData.transformData.position.y*ptm_ratio;
			var userData:*=gameObjectData.userData;
			
			if(tag=="Enemy1"){
				//tile=Enemy1.create(tilemap,x,y,parent);
			}
			if(gameObjectData&&!tile)throw new Error("变量tile没有被正确赋值");
			return tile;
        }
		
		private function createObjsWithBodies(bodies:Vector.<b2Body>):void{
			for(var i:int=0;i<bodies.length;i++){
				var body:b2Body=bodies[i];
				var userData:*=body.GetUserData();
				var name:String=userData.name;
				var tag:String=userData.tag;
				//
				if(tag=="Wall"){
					createWall(body);
				}
			}
		}
		
		public function get width():int{return _mapModel.width;}
		public function get height():int{return _mapModel.height;}
		public function get camera():MapCamera{ return _camera; }
		public function get unityB2Loader():UnityB2Loader{ return _unityB2Loader; }
		public function get box2dMan():Box2dManager{ return _box2dMan; }
		public function get viewportW():Number{ return _mapModel.viewportW; }
		public function get viewportH():Number{ return _mapModel.viewportH; }
		
		override protected function onDestroy():void{
			if(_mask){
				_game.global.layerMan.shakeLayer.mask=null;
				if(_mask.parent)_mask.parent.removeChild(_mask);
				_mask=null;
			}
			if(_unityB2Loader){
				GameObject.destroy(_unityB2Loader);
				_unityB2Loader=null;
			}
			if(_box2dMan){
				GameObject.destroy(_box2dMan);
				_box2dMan=null;
			}
			if(_camera){
				GameObject.destroy(_camera);
				_camera=null;
			}
			if(_mapModel){
				_mapModel.dispose();
				_mapModel=null;
			}
			super.onDestroy();
		}
		
		
	};

}