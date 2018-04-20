package framework.b2Editor{
	import Box2D.Dynamics.b2Body;
	import framework.game.Game;
	import framework.namespaces.frameworkInternal;
	import framework.objs.Component;
	import framework.objs.GameObject;
	import framework.utils.Mathk;
	use namespace frameworkInternal;
	
	public class UGameObject extends GameObject{
		
		public var name:String="UGameObject";
		protected var _instanceID:int;
		protected var _transform:UTransform=null;
		protected var _unityB2Loader:UnityB2Loader;
		protected var _body:b2Body;
		protected var _bodyObject:UBodyObject;
		
		public static function create(gameObjectData:GameObjectData,unityB2Loader:UnityB2Loader,parent:UTransform=null,xpos:Number=NaN,ypos:Number=NaN,rotation:Number=NaN):UGameObject{
			var game:Game=Game.getInstance();
			var info:*={};
			info.gameObjectData=gameObjectData;
			info.unityB2Loader=unityB2Loader;
			info.parent=parent;
			info.xpos=xpos;
			info.ypos=ypos;
			info.rotation=rotation;
			return game.createGameObj(new UGameObject(),info) as UGameObject;
		}
		
		public function UGameObject(){
			super();
		}
		
		override frameworkInternal function initPre_internal(info:*=null):void{
			super.initPre_internal(info);
			var parent:UTransform=info.parent;
			var gameObjectData:GameObjectData=info.gameObjectData;
			var xpos:Number=info.xpos;
			var ypos:Number=info.ypos;
			var rotation:Number=info.rotation;
			_unityB2Loader=info.unityB2Loader;
			this.name=gameObjectData.name;
			_instanceID=gameObjectData.instanceID;
			
			//添加UTransform组件
			_transform=UTransform.addToUGameObject(this,parent,gameObjectData.transformData);
			
			//添加UBodyObject组件
			var body:b2Body=_unityB2Loader.createBodyWithGameObjectData(gameObjectData,_unityB2Loader.bodies,false);
			if(body){
				_body=body;
				_bodyObject=UBodyObject.addToUGameObject(this,body,gameObjectData.jointDatas);
			}
			//创建子对象
			if(gameObjectData.subGameObjectDatas) createChildren(gameObjectData.subGameObjectDatas);
			
			//应用位置和角度
			if(isNaN(xpos))xpos=_transform.localPosition.x;
			if(isNaN(ypos))ypos=_transform.localPosition.y;
			_transform.setLocalPosition(xpos,ypos,true);
			if(!isNaN(rotation))_transform.setLocalRotation(rotation,true);
		}
		
		/**创建子对象*/
		private function createChildren(gameObjectDatas:Vector.<GameObjectData>):void{
			for(var i:int=0;i<gameObjectDatas.length;i++){
				var uo:UGameObject=UGameObject.create(gameObjectDatas[i],_unityB2Loader,_transform);
				_transform.addChild(uo.transform);
			}
		}
		
		/**返回自身或子对象的指定类型组件*/
		final public function getComponentInChildren(type:Class):Component{
			var c:Component=getComponent(type);
			if(c==null){
				if(_transform.parent){
					_transform.parent.getComponentInChildren(type);
				}
			}
			return c;
		}
		
		/**返回自身或父级对象的指定类型组件*/
		final public function getComponentInParent(type:Class):Component{
			var c:Component=getComponent(type);
			if(c==null){
				if(_transform.parent){
					_transform.parent.getComponentInParent(type);
				}
			}
			return c;
		}
		
		/**返回自身和子对象的指定类型组件列表*/
		final public function getComponentsInChildren(type:Class,result:Vector.<Component>=null):Vector.<Component>{
			result||=new Vector.<Component>();
			getComponents(type,result);
			
			for(var i:int=0;i<_transform.childCount;i++){
				var ct:UTransform=_transform.children[i];
				ct.getComponentsInChildren(type,result);
			}
			return result;
		}
		
		/**返回自身和父级对象的指定类型组件列表*/
		final public function getComponentsInParent(type:Class,result:Vector.<Component>=null):Vector.<Component>{
			result||=new Vector.<Component>();
			getComponents(type,result);
			
			if(_transform.parent){
				_transform.parent.getComponentsInParent(type,result);
			}
			return result;
		}
		
		/**返回自身和子对象的指刚体列表*/
		final public function getBodiesInChildren(result:Vector.<b2Body>=null):Vector.<b2Body>{
			result||=new Vector.<b2Body>();
			if(_body)result.push(_body);
			
			for(var i:int=0;i<_transform.childCount;i++){
				var ct:UTransform=_transform.children[i];
				ct.getBodiesInChildren(result);
			}
			return result;
		}
		
		/**返回自身和父级对象的刚体列表*/
		final public function getBodiesInParent(result:Vector.<b2Body>=null):Vector.<b2Body>{
			result||=new Vector.<b2Body>();
			if(_body)result.push(_body);
			if(_transform.parent){
				_transform.parent.getBodiesInParent(result);
			}
			return result;
		}
		
		override protected function onDestroy():void{
			_unityB2Loader=null;
			_transform=null;
			_body=null;
			_bodyObject=null;
			super.onDestroy();
		}
		
		public function get transform():UTransform{ return _transform; }
		public function get instanceID():int{ return _instanceID; }
		public function get bodyObject():UBodyObject{ return _bodyObject; }
		public function get body():b2Body{ return _body; }
		
	};

}