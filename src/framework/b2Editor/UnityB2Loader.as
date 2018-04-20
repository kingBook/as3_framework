package framework.b2Editor{
	import Box2D.Box2DSeparator.b2Separator;
	import Box2D.Collision.Shapes.b2CircleShape;
	import Box2D.Collision.Shapes.b2PolygonShape;
	import Box2D.Collision.Shapes.b2Shape;
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Common.Math.b2Vec3;
	import Box2D.Dynamics.Joints.b2Joint;
	import Box2D.Dynamics.Joints.b2RevoluteJoint;
	import Box2D.Dynamics.Joints.b2RevoluteJointDef;
	import Box2D.Dynamics.Joints.b2RopeJoint;
	import Box2D.Dynamics.Joints.b2RopeJointDef;
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.b2BodyDef;
	import Box2D.Dynamics.b2FixtureDef;
	import Box2D.Dynamics.b2World;
	import flash.geom.Rectangle;
	import framework.game.Game;
	import framework.namespaces.frameworkInternal;
	import framework.objs.Component;
	import framework.objs.GameObject;
	import framework.utils.Mathk;
	import flash.geom.Point;
	use namespace frameworkInternal;
	/**unity box2d 加载器 */
	public class UnityB2Loader extends GameObject{
		
		public static function create(assetDatabaseXml:XML,sceneXml:XML):UnityB2Loader{
			var game:Game=Game.getInstance();
			var info:*={};
			info.assetDatabaseXml=assetDatabaseXml;
			info.sceneXml=sceneXml;
			return game.createGameObj(new UnityB2Loader(),info) as UnityB2Loader;
		}
		
		private var _assetDatabaseXml:XML;
		private var _sceneXml:XML;
		private var _world:b2World;
		
		private var _sceneName:String;
		
		private var _worldData:WorldData;
		private var _worldNodePos:b2Vec2;
		private var _sceneRootGameObjectDatas:Vector.<GameObjectData>=new Vector.<GameObjectData>();
		private var _bodies:Vector.<b2Body>=new Vector.<b2Body>();
		
		private var _prefabGameObjectDatas:Vector.<GameObjectData>=new Vector.<GameObjectData>();
        private var _tilemapGameObjectDatas:Vector.<GameObjectData>=new Vector.<GameObjectData>();
		
		override protected function init(info:* = null):void{
			super.init(info);
			_assetDatabaseXml=info.assetDatabaseXml;
			_sceneXml=info.sceneXml;
			
			parseAssetDatabase(_assetDatabaseXml);
			parseScene(_sceneXml);

		}
		
		private function parseAssetDatabase(assetDatabaseXml:XML):void{
			parseGameObject(assetDatabaseXml.Prefab.GameObject,_prefabGameObjectDatas);
		}
		/**实例化预制件*/
		public function instantiatePrefab(prefabName:String,xpos:Number=NaN,ypos:Number=NaN,rotation:Number=NaN):UGameObject{
			var i:int,uGameObject:UGameObject=null,gameObjectData:GameObjectData,b2Bodies:Vector.<b2Body>=new Vector.<b2Body>();
			var body:b2Body,uTransforms:Vector.<Component>,jointDatas:Vector.<JointData>,uTransform:UTransform;
			for(i=0;i<_prefabGameObjectDatas.length;i++){
				gameObjectData=_prefabGameObjectDatas[i];
				if(gameObjectData.name==prefabName){
					uGameObject=UGameObject.create(gameObjectData,this,null,xpos,ypos,rotation);
					break;
				}
			}
			//创建关节
			if(uGameObject){
				uTransforms=uGameObject.getComponentsInChildren(UTransform);
				//查找b2Bodies
				uGameObject.getBodiesInChildren(b2Bodies);
				//构建
				for(i=0;i<uTransforms.length;i++){
					uTransform=UTransform(uTransforms[i]);
					if(uTransform.bodyObject){
						body=uTransform.body;
						jointDatas=uTransform.bodyObject.jointDatas;
						if(jointDatas.length>0) createJoints(jointDatas,body,b2Bodies,_world);
					}
				}
			}
			return uGameObject;
		}
		
		private function parseScene(sceneXml:XML):void{
			_sceneName=sceneXml.@name;
			//解析对象数据
			parseGameObject(sceneXml.GameObject,_sceneRootGameObjectDatas);
			//构建世界
			_world=createWorldWithData(_worldData);
			//构建刚体
			createBodiesWithGameObjectDatas(_sceneRootGameObjectDatas,_bodies);
			fixUserDatas(_bodies);
			//构建关节
			createJointsWithGameObjectDatas(_sceneRootGameObjectDatas);
		}
		
		private function createJointsWithGameObjectDatas(gameObjectDatas:Vector.<GameObjectData>):void{
			var i:int,len:int=gameObjectDatas.length,gameObjectData:GameObjectData;
			for(i=0;i<len;i++){
				gameObjectData=gameObjectDatas[i];
				createJoints(gameObjectData.jointDatas,gameObjectData.body,_bodies,_world);
				if(gameObjectData.subGameObjectDatas){
					createJointsWithGameObjectDatas(gameObjectData.subGameObjectDatas);
				}
			}
		}
		
		private function createBodiesWithGameObjectDatas(gameObjectDatas:Vector.<GameObjectData>,outBodies:Vector.<b2Body>=null):Vector.<b2Body>{
			outBodies||=new Vector.<b2Body>();
			var i:int,gameObjectData:GameObjectData;
			for(i=0;i<gameObjectDatas.length;i++){
				gameObjectData=gameObjectDatas[i];
				createBodyWithGameObjectData(gameObjectData,outBodies,true);
			}
			return outBodies;
		}
		
		private function fixUserDatas(bodies:Vector.<b2Body>):void{
			var i:int,j:int,len:int=bodies.length,userData1:*,userData2:*,key1:*,key2:*,bodyProp1:B2BodyObjectProperty;
			for(i=0;i<len;i++){
				userData1=bodies[i].GetUserData();
				for(key1 in userData1){
					if(key1=="ID")continue;
					if(userData1[key1] is B2BodyObjectProperty){
						bodyProp1=userData1[key1] as B2BodyObjectProperty;
						for(j=0;j<len;j++){
							userData2=bodies[j].GetUserData();
							if(bodyProp1.instanceID==userData2["ID"]){
								userData1[key1]=bodies[j];
							}
						}
					}
				}
				
			}
		}
		
		/**根据gameObjectData创建刚体*/
		public function createBodyWithGameObjectData(gameObjData:GameObjectData,outBodies:Vector.<b2Body>,isCreateChild:Boolean):b2Body{
			var i:int,userData:*,body:b2Body=null,bodyDef:b2BodyDef=gameObjData.bodyDef;
			// 设置刚体属性
			if(bodyDef){
				//add TransformData to userData
				userData=gameObjData.userData;
				userData.transformData=gameObjData.transformData;
				bodyDef.userData=userData;
				//apply TransformData
				bodyDef.angle=gameObjData.transformData.rotation.z*Mathk.Deg2Rad;
				bodyDef.position=new b2Vec2(gameObjData.transformData.position.x,gameObjData.transformData.position.y);
				//
				body=_world.CreateBody(bodyDef);
				//create fixture
				if(gameObjData.fixtureDefs){
					for(i=0;i<gameObjData.fixtureDefs.length;i++){
						scaleShapeWithTransformData(gameObjData.fixtureDefs[i].shape,gameObjData.transformData);
						body.CreateFixture(gameObjData.fixtureDefs[i]);
					}
				}
				//
				gameObjData.body=body;
				//save every one body to bodies
				outBodies.push(gameObjData.body);
			}
			//create sub gameobject bodies
			if(isCreateChild){
				if(gameObjData.subGameObjectDatas){
					createBodiesWithGameObjectDatas(gameObjData.subGameObjectDatas,outBodies);
				}
			}
			return body;
		}
		
		private function createWorldWithData(data:WorldData):b2World{
			var world:b2World=null;
			if(data!=null)world=new b2World(new b2Vec2(data.gravityX,data.gravityY),data.allowSleep);
			return world;
		}
		
		private function scaleShapeWithTransformData(shape:b2Shape,transformData:TransformData):void{
			if(shape is b2PolygonShape){
				var poly:b2PolygonShape=shape as b2PolygonShape;
				var vertices:Vector.<b2Vec2>=poly.GetVertices();
				for(var i:int=0;i<vertices.length;i++){
					vertices[i].x*=transformData.lossyScale.x;
					vertices[i].y*=transformData.lossyScale.y;
				}
			}else if(shape is b2CircleShape){
				var circle:b2CircleShape=shape as b2CircleShape;
				var scale:Number=Math.max(transformData.lossyScale.x,transformData.lossyScale.y);
				circle.SetRadius(circle.GetRadius()*scale);
				var offset:b2Vec2=circle.GetLocalPosition();
				offset.x*=transformData.lossyScale.x;
				offset.y*=transformData.lossyScale.y;
				circle.SetLocalPosition(offset);
			}
		}
		
		private function parseGameObject(xmlList:XMLList,gameObjectDatas:Vector.<GameObjectData>,parentGameObjectData:GameObjectData=null):void{
			var name:String,tag:String,activeSelf:Boolean,gameObjectXml:XML,gameObjectData:GameObjectData;
			var i:int,len:int=xmlList.length(),instanceID:int;
			for(i=0;i<len;i++){
				gameObjectXml=xmlList[i];
				name=gameObjectXml.@name;
				tag=gameObjectXml.@tag;
				activeSelf=gameObjectXml.@activeSelf=="True";
				instanceID=int(gameObjectXml.@instanceID);
				
				if(activeSelf){
					gameObjectData=new GameObjectData(instanceID,tag,name);
                    if(parentGameObjectData!=null&&parentGameObjectData.isHasTilemapComponent)gameObjectData.isTilemapChild=true;
					parseComponent(gameObjectXml.Component,gameObjectData);
                    
					//解析子对象
					if(gameObjectXml.GameObject.length()>0){
						gameObjectData.subGameObjectDatas=new Vector.<GameObjectData>();
						parseGameObject(gameObjectXml.GameObject,gameObjectData.subGameObjectDatas,gameObjectData);
					}
					
					gameObjectDatas.push(gameObjectData);
				}
			}
		}
		
		private function parseComponent(xmlList:XMLList,gameObjectData:GameObjectData):void{
			const UnityEngineNS:String="UnityEngine";
			var name:String,ns:String,instanceID:int,enabled:Boolean,componentXml:XML,i:int;
			var len:int=xmlList.length();
			for(i=0;i<len;i++){
				componentXml=xmlList[i];
				name=componentXml.@name;
				ns=componentXml.@nameSpace;
				instanceID=int(componentXml.@instanceID);
				enabled=componentXml.@enabled=="True";
				
				switch (name){
					case "Transform":
						if(ns==UnityEngineNS) gameObjectData.transformData=parseTransform(componentXml);
						break;
					case "b2WorldObject":
						if(ns==UnityEngineNS&&enabled){
							_worldData=parseB2WorldObject(componentXml);
							_worldNodePos=new b2Vec2(gameObjectData.transformData.localPosition.x,gameObjectData.transformData.localPosition.y);
						}
						break;
					case "b2BodyObject":
						if(ns==UnityEngineNS&&enabled) gameObjectData.bodyDef=parseB2BodyObject(componentXml);
						break;
					case "BoxCollider2D":
						if(ns==UnityEngineNS&&enabled) gameObjectData.addFixtureDef(parseBoxCollider2D(componentXml));
						break;
					case "CircleCollider2D":
						if(ns==UnityEngineNS&&enabled) gameObjectData.addFixtureDef(parseCircleCollider2D(componentXml));
						break;
					case "PolygonCollider2D":
						if(ns==UnityEngineNS&&enabled) gameObjectData.concatFixtureDefs(parsePolygonCollider2D(componentXml));
						break;
					case "UserData":
						if(ns==UnityEngineNS&&enabled) gameObjectData.userData=parseUserData(componentXml);
						break;
					case "b2RevoluteJointObject":
						if(ns==UnityEngineNS&&enabled) gameObjectData.addJointData(parseB2RevoluteJointObject(componentXml));
						break;
					case "b2RopeJointObject":
						if(ns==UnityEngineNS&&enabled) gameObjectData.addJointData(parseB2RopeJointObject(componentXml));
						break;
                    case "Tilemap":
                        if(ns=="UnityEngine.Tilemaps"&&enabled){
                            gameObjectData.isHasTilemapComponent=true;
                            gameObjectData.tilemapData=parseTilemap(componentXml,gameObjectData.name);
                            _tilemapGameObjectDatas.push(gameObjectData);
                        }
                        break;
					default:
						break;
				}
			}
		}
		
		private function parseTransform(componentXml:XML):TransformData{
			var transformData:TransformData=new TransformData();
			
			var position:b2Vec3=new b2Vec3(
				Number(componentXml.Position.@x),
				-Number(componentXml.Position.@y),
				Number(componentXml.Position.@z)
			);
			var localPosition:b2Vec3=new b2Vec3(
				Number(componentXml.LocalPosition.@x),
				-Number(componentXml.LocalPosition.@y),
				Number(componentXml.LocalPosition.@z)
			);
			
			var rotation:b2Vec3=new b2Vec3(
				Number(componentXml.Rotation.@x),
				Number(componentXml.Rotation.@y),
				-Mathk.getRotationToFlash(Number(componentXml.Rotation.@z))
			);
			var localRotation:b2Vec3=new b2Vec3(
				Number(componentXml.LocalRotation.@x),
				Number(componentXml.LocalRotation.@y),
				-Mathk.getRotationToFlash(Number(componentXml.LocalRotation.@z))
			);
			
			var lossyScale:b2Vec3=new b2Vec3(
				Number(componentXml.LossyScale.@x),
				Number(componentXml.LossyScale.@y),
				Number(componentXml.LossyScale.@z)
			);
			var localScale:b2Vec3=new b2Vec3(
				Number(componentXml.LocalScale.@x),
				Number(componentXml.LocalScale.@y),
				Number(componentXml.LocalScale.@z)
			);
			transformData.position=position;
			transformData.localPosition=localPosition;
			transformData.rotation=rotation;
			transformData.localRotation=localRotation;
			transformData.lossyScale=lossyScale;
			transformData.localScale=localScale;
			return transformData;
		}
		
		private function parseB2WorldObject(componentXml:XML):WorldData{
			var worldData:WorldData=new WorldData();
			worldData.gravityX=Number(componentXml.Gravity.@x);;
			worldData.gravityY=-Number(componentXml.Gravity.@y);
			worldData.allowSleep=componentXml.AllowSleep=="True";
			worldData.dt=Number(componentXml.Dt);
			worldData.velocityIterations=int(componentXml.VelocityIterations);
			worldData.positionIterations=int(componentXml.PositionIterations);
			return worldData;
		}
		
		private function parseB2BodyObject(componentXml:XML):b2BodyDef{
			var bodyDef:b2BodyDef=new b2BodyDef();
			bodyDef.linearDamping=Number(componentXml.LinearDamping);
			bodyDef.angularDamping=Number(componentXml.AngularDamping);
			bodyDef.inertiaScale=Number(componentXml.InertiaScale);
			bodyDef.allowBevelSlither=componentXml.AllowBevelSlither=="True";
			bodyDef.allowMovement=componentXml.AllowMovement=="True";
			bodyDef.allowSleep=componentXml.AllowSleep=="True";
			bodyDef.bullet=componentXml.Bullet=="True";
			bodyDef.fixedRotation=componentXml.FixedRotation=="True";
			bodyDef.isIgnoreFrictionX=componentXml.IsIgnoreFrictionX=="True";
			bodyDef.isIgnoreFrictionY=componentXml.IsIgnoreFrictionY=="True";
			bodyDef.type=int(componentXml.Type);
			return bodyDef;
		}
		
		private function parseBoxCollider2D(componentXml:XML):b2FixtureDef{
			var fixtureDef:b2FixtureDef=new b2FixtureDef();
			
			if(componentXml.Material.length()>0){
				var friction:Number=componentXml.Material.@Friction;
				var bounciness:Number=componentXml.Material.@Bounciness;
				
				fixtureDef.friction=friction;
				fixtureDef.restitution=bounciness;
			}
			var isTrigger:Boolean=componentXml.IsTrigger=="True";
			
			var offsetX:Number=Number(componentXml.Offset.@x);
			var offsetY:Number=-Number(componentXml.Offset.@y);
			var sizeX:Number=Number(componentXml.Size.@x);
			var sizeY:Number=Number(componentXml.Size.@y);
			var density:Number=Number(componentXml.Density);
			
			fixtureDef.isSensor=isTrigger;
			fixtureDef.density=density;
			var s:b2PolygonShape=b2PolygonShape.AsOrientedBox(sizeX*0.5,sizeY*0.5,new b2Vec2(offsetX,offsetY),0);
			fixtureDef.shape=s;
			
			return fixtureDef;
		}
		
		private function parseCircleCollider2D(componentXml:XML):b2FixtureDef{
			var fixtureDef:b2FixtureDef=new b2FixtureDef();
			
			if(componentXml.Material.length()>0){
				var friction:Number=componentXml.Material.@Friction;
				var bounciness:Number=componentXml.Material.@Bounciness;
				
				fixtureDef.friction=friction;
				fixtureDef.restitution=bounciness;
			}
			var isTrigger:Boolean=componentXml.IsTrigger=="True";
			
			var offsetX:Number=Number(componentXml.Offset.@x);
			var offsetY:Number=-Number(componentXml.Offset.@y);
			var radius:Number=Number(componentXml.Radius);
			var density:Number=Number(componentXml.Density);
			
			fixtureDef.isSensor=isTrigger;
			fixtureDef.density=density;
			var s:b2CircleShape=new b2CircleShape(radius);
			s.SetLocalPosition(new b2Vec2(offsetX,offsetY));
			fixtureDef.shape=s;
			
			return fixtureDef;
		}
		
		private function parsePolygonCollider2D(componentXml:XML):Vector.<b2FixtureDef>{
			var friction:Number=NaN,bounciness:Number=NaN;
			if(componentXml.Material.length()>0){
				friction=componentXml.Material.@Friction;
				bounciness=componentXml.Material.@Bounciness;
			}
			var isTrigger:Boolean=componentXml.IsTrigger=="True";
			var offsetX:Number=Number(componentXml.Offset.@x);
			var offsetY:Number=-Number(componentXml.Offset.@y);
			var density:Number=Number(componentXml.Density);
			//Paths
			var pathsXMLList:XMLList=componentXml.Points.Paths;
			var pathCount:int=int(pathsXMLList.@Size);
			
			var fixtureDefs:Vector.<b2FixtureDef>=new Vector.<b2FixtureDef>();
			var fixtureDef:b2FixtureDef=new b2FixtureDef();
			if(!isNaN(friction))fixtureDef.friction=friction;
			if(!isNaN(bounciness))fixtureDef.restitution=bounciness;
			fixtureDef.isSensor=isTrigger;
			fixtureDef.density=density;
			//Path
			var pathXMLList:XMLList=pathsXMLList.Path;
			for(var i:int=0;i<pathCount;i++){
				var pathXml:XML=pathXMLList[i];
				var pathLength:int=int(pathXml.@Length);
				
				var vertices:Vector.<b2Vec2>=new Vector.<b2Vec2>(pathLength,true);
				for(var j:int=0;j<pathLength;j++){
					var vertexXml:XML=pathXml.Vertex[j];
					var x:Number=Number(vertexXml.@x);
					var y:Number=-Number(vertexXml.@y);
					vertices[j]=new b2Vec2(x,y);
				}
				/*for(j=0;j<vertices.length;j++){
					trace(vertices[j]);
				}*/
				
				var sep:b2Separator=new b2Separator();
				var sepFixtureDefs:Vector.<b2FixtureDef>=sep.SeparateNoBody(fixtureDef,vertices,true,offsetX,offsetY);
				fixtureDefs=fixtureDefs.concat(sepFixtureDefs);
			}
			return fixtureDefs;
		}
		
		private function parseUserData(componentXml:XML):*{
			var xmlList:XMLList=componentXml.Element;
			var len:int=xmlList.length();
			var i:int,elementXml:XML,data:*={},name:String,type:String,value:String;
			for(i=0;i<len;i++){
				elementXml=xmlList[i];
				name=elementXml.@name;
				type=elementXml.@type;
				value=elementXml.@value;
				
				if(type=="String") 	   		  data[name]=value;
				else if(type=="Int")   		  data[name]=int(value);
				else if(type=="Float") 		  data[name]=Number(value);
				else if(type=="Bool")  		  data[name]=value=="True";
				else if(type=="B2BodyObject"){
					if(name=="ID")data[name]=value;
					else data[name]=value=="null"?null:new B2BodyObjectProperty(value);//null | B2BodyObjectProperty(instanceID)
				}else if(type=="B2Vec2")       data[name]=new b2Vec2(Number(elementXml.@x),-(elementXml.@y));
				else if(type=="ListB2Vec2"){
					var vec2XMLList:XMLList=elementXml.Vec2;
					var vec2Count:int=vec2XMLList.length();
					var vertices:Vector.<b2Vec2>=new Vector.<b2Vec2>();
					for(var j:int=0;j<vec2Count;j++){
						var vec2Xml:XML=vec2XMLList[j];
						vertices[j]=new b2Vec2(Number(vec2Xml.@x),-Number(vec2Xml.@y));
					}
					data[name]=vertices;
				}else if(type=="GameObject"){
                    data[name]=value=="null"?null:value;//null | instanceID
                }
			}
			return data;
		}
		
		private function parseB2RevoluteJointObject(componentXml:XML):JointData{
			var jointData:RevoluteJointData=new RevoluteJointData();
			jointData.enableCollision=componentXml.EnableCollision=="True";
			jointData.connectedB2BodyObject=componentXml.ConnectedB2BodyObject;//null | instanceID
			jointData.autoConfigureAnchor=componentXml.AutoConfigureAnchor=="True";
			jointData.localAnchor1X=Number(componentXml.LocalAnchor1.@x);
			jointData.localAnchor1Y=-Number(componentXml.LocalAnchor1.@y);
			jointData.localAnchor2X=Number(componentXml.LocalAnchor2.@x);
			jointData.localAnchor2Y=-Number(componentXml.LocalAnchor2.@y);
			jointData.enableLimit=componentXml.EnableLimit=="True";
			jointData.referenceAngle=Number(componentXml.ReferenceAngle);
			jointData.lowerAngle=Number(componentXml.LowerAngle);
			jointData.upperAngle=Number(componentXml.UpperAngle);
			jointData.enableMotor=componentXml.EnableMotor=="True";
			jointData.motorSpeed=-Number(componentXml.MotorSpeed);
			jointData.maxMotorTorque=Number(componentXml.MaxMotorTorque);
			return jointData;
		}
		
		private function parseB2RopeJointObject(componentXml:XML):JointData{
			var jointData:RopeJointData=new RopeJointData();
			jointData.enableCollision=componentXml.EnableCollision=="True";
			jointData.connectedB2BodyObject=componentXml.ConnectedB2BodyObject;//null | instanceID
			jointData.autoConfigureAnchor=componentXml.AutoConfigureAnchor=="True";
			jointData.localAnchor1X=Number(componentXml.LocalAnchor1.@x);
			jointData.localAnchor1Y=-Number(componentXml.LocalAnchor1.@y);
			jointData.localAnchor2X=Number(componentXml.LocalAnchor2.@x);
			jointData.localAnchor2Y=-Number(componentXml.LocalAnchor2.@y);
			jointData.maxLength=Number(componentXml.MaxLength);
			return jointData;
		}
		
		private function parseTilemap(componentXml:XML,gameObjectName:String):TilemapData{
			var tilemapData:TilemapData=new TilemapData();
			tilemapData.name=gameObjectName;
			tilemapData.orientation=componentXml.Orientation;
			
			var layoutGrid:XMLList=componentXml.LayoutGrid;
			tilemapData.cellSize=new Point(Number(layoutGrid.CellSize.@x),Number(layoutGrid.CellSize.@y));
			tilemapData.cellGap=new Point(Number(layoutGrid.CellGap.@x),Number(layoutGrid.CellGap.@y));
			tilemapData.cellSwizzle=layoutGrid.CellSwizzle;
			
			var tilesXml:XMLList=componentXml.Tiles;
			var cellBounds:XMLList=tilesXml.CellBounds;
			tilemapData.cellBounds=new Rectangle(int(cellBounds.@x),
											     int(cellBounds.@y),
												 int(cellBounds.@sizeX),
												 int(cellBounds.@sizeY));
			
			var tilesBlock:XMLList=tilesXml.TilesBlock;
			var tileXml:XMLList=tilesBlock.Tile;
			var len:int=tileXml.length();
			var tileDatas:Vector.<TileData>=new Vector.<TileData>();
			for(var i:int=0;i<len;i++){
				var tileData:TileData=new TileData();
				tileData.id=int(tileXml[i].@id);
				tileData.name=tileXml[i].@name;
				tileData.sprite=tileXml[i].@sprite;
				tileDatas[i]=tileData;
			}
			tilemapData.tileDatas=tileDatas;
			
			tilemapData.data=tilesBlock.Data;
			return tilemapData;
		}
		
		/**创建关节*/
		private function createJoints(jointDatas:Vector.<JointData>,b1:b2Body,b2Bodies:Vector.<b2Body>,world:b2World):void{
			var i:int,j:int,jointData:JointData,b2:b2Body,b2_ID:int,tmpID:int;
			for(i=0;i<jointDatas.length;i++){
				jointData=jointDatas[i];
				
				if(jointData.connectedB2BodyObject=="null"){
					b2=world.GetGroundBody();
				}else{
					b2_ID=int(jointData.connectedB2BodyObject);
					for(j=0;j<b2Bodies.length;j++){
						tmpID=int(b2Bodies[j].GetUserData().ID);
						if(tmpID==b2_ID) b2=b2Bodies[j];
					}
				}
				
				if(jointData is RevoluteJointData){
					createRevoluteJoint(jointData as RevoluteJointData,b1,b2,world);
				}else if(jointData is RopeJointData){
					createRopeJoint(jointData as RopeJointData,b1,b2,world);
				}
			}
		}
		
		/**创建旋转关节*/
		private function createRevoluteJoint(jointData:RevoluteJointData,bodyA:b2Body,bodyB:b2Body,world:b2World):b2RevoluteJoint{
			var joint:b2RevoluteJoint;
			var jointDef:b2RevoluteJointDef=new b2RevoluteJointDef();
			jointDef.Initialize(bodyA,bodyB,bodyA.GetPosition());
			jointDef.collideConnected=jointData.enableCollision;
			
			jointDef.enableLimit=jointData.enableLimit;
			jointDef.referenceAngle=jointData.referenceAngle;
			jointDef.lowerAngle=jointData.lowerAngle;
			jointDef.upperAngle=jointData.upperAngle;
			
			jointDef.enableMotor=jointData.enableMotor;
			jointDef.motorSpeed=jointData.motorSpeed;
			jointDef.maxMotorTorque=jointData.maxMotorTorque;
			
			joint=world.CreateJoint(jointDef) as b2RevoluteJoint;
			joint.m_localAnchor1.x=jointData.localAnchor1X;
			joint.m_localAnchor1.y=jointData.localAnchor1Y;
			joint.m_localAnchor2.x=jointData.localAnchor2X;
			joint.m_localAnchor2.y=jointData.localAnchor2Y;
			
			return joint;
		}
		
		/**创建绳子关节*/
		private function createRopeJoint(jointData:RopeJointData,bodyA:b2Body,bodyB:b2Body,world:b2World):b2RopeJoint{
			var joint:b2RopeJoint;
			var jointDef:b2RopeJointDef=new b2RopeJointDef();
			
			var anchorA:b2Vec2=bodyA.GetWorldPoint(new b2Vec2(jointData.localAnchor1X,jointData.localAnchor1Y));
			var anchorB:b2Vec2=bodyB.GetWorldPoint(new b2Vec2(jointData.localAnchor2X,jointData.localAnchor2Y));
			jointDef.Initialize(bodyA,bodyB,anchorA,anchorB,jointData.maxLength);
			jointDef.collideConnected=jointData.enableCollision;
			
			joint=world.CreateJoint(jointDef) as b2RopeJoint;
			return joint;
		}
		
		private function clearWorld(world:b2World):void{
			for(var j:b2Joint=world.GetJointList(); j; j=j.GetNext()) world.DestroyJoint(j);
			for(var b:b2Body=world.GetBodyList(); b; b=b.GetNext()) world.DestroyBody(b);
		}
		
		override protected function onDestroy():void{
			if(_world)clearWorld(_world);
			if(_bodies){
				var i:int=_bodies.length;
				while (--i>=0){
					_bodies[i].Destroy();
				}
			}
			_assetDatabaseXml=null;
			_sceneXml=null;
			_world=null;
			
			_worldData=null;
			_sceneRootGameObjectDatas=null;
			_bodies=null;
			super.onDestroy();
		}
		
		public function get sceneName():String{ return _sceneName; }
		public function get bodies():Vector.<b2Body>{ return _bodies; }
		public function get worldData():WorldData{ return _worldData; }
		public function get world():b2World{ return _world; }
        public function get tilemapGameObjectDatas():Vector.<GameObjectData>{ return _tilemapGameObjectDatas; }
		
	};

}