package framework.b2Editor{
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.b2BodyDef;
	import Box2D.Dynamics.b2FixtureDef;
	/**每一个游戏对象一个GameObjectData*/
	public class GameObjectData{
		
        public var isHasTilemapComponent:Boolean=false;
        public var isTilemapChild:Boolean=false;
        public var tilemapData:TilemapData;
        //
		public var name:String;
		public var tag:String;
		public var instanceID:int;
		public var transformData:TransformData;
		public var bodyDef:b2BodyDef;
		public var userData:*;
		private var _fixtureDefs:Vector.<b2FixtureDef>=new Vector.<b2FixtureDef>();
		private var _jointDatas:Vector.<JointData>=new Vector.<JointData>();
		public var subGameObjectDatas:Vector.<GameObjectData>=null;//子对象数据
		//
		//
		public var body:b2Body=null;
		//
		public function GameObjectData(instanceID:int,tag:String,name:String=null){
			this.name=name;
			this.tag=tag;
			this.instanceID=instanceID;
		}
		
		public function addFixtureDef(fixtureDef:b2FixtureDef):void{
			_fixtureDefs.push(fixtureDef);
		}
		public function concatFixtureDefs(fixtureDefs:Vector.<b2FixtureDef>):Vector.<b2FixtureDef>{ 
			_fixtureDefs=_fixtureDefs.concat(fixtureDefs);
			return _fixtureDefs;
		}
		
		public function addJointData(jointData:JointData):void{
			_jointDatas.push(jointData);
		}
		
		public function get fixtureDefs():Vector.<b2FixtureDef>{  return _fixtureDefs; }
		
		public function get jointDatas():Vector.<JointData>{ return _jointDatas; }
		
		/*public function ParseData(){
			
		}*/
		
	};

}