package framework.b2Editor{
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.b2Body;
	import framework.game.Game;
	import framework.namespaces.frameworkInternal;
	import framework.objs.GameObject;
	import framework.utils.Mathk;
	use namespace frameworkInternal;
	public class UBodyObject extends UComponent{
		
		private var _linkBody:b2Body;
		private var _jointDatas:Vector.<JointData>;
		
		public static function addToUGameObject(uGameObject:UGameObject,body:b2Body,jointDatas:Vector.<JointData>=null):UBodyObject{
			return uGameObject.addComponent(UBodyObject,{body:body, jointDatas:jointDatas}) as UBodyObject;
		}
		
		public function UBodyObject(){
			super();
		}
		
		override frameworkInternal function init_internal(gameObj:GameObject,game:Game,info:*=null):void{
			_linkBody=info.body;
			
			_jointDatas=info.jointDatas;
			_jointDatas||=new Vector.<JointData>();
			
			super.init_internal(gameObj,game,info);
		}
		
		public function setPositionAndRotation(x:Number=NaN,y:Number=NaN,angleRadian:Number=NaN):void{
			if(isNaN(x))x=_linkBody.GetPosition().x;
			if(isNaN(y))y=_linkBody.GetPosition().y;
			if(isNaN(angleRadian))angleRadian=_linkBody.GetAngle();
			
			var pos:b2Vec2=new b2Vec2(x,y);
			_linkBody.SetPositionAndAngle(pos,angleRadian);
			
			transform.setPositionAndRotation(x,y,angleRadian*Mathk.Deg2Rad);
			updateChildrenPositionAndRotation();
		}
		
		private function updateChildrenPositionAndRotation():void{
			var i:int,len:int=transform.children.length,t:UTransform;
			for(i=0;i<len;i++){
				t=transform.children[i];
				if(t.bodyObject){
					t.bodyObject.setPositionAndRotation(t.position.x,t.position.y,t.rotation);
				}
			}
		}
		
		override protected function fixedUpdate():void{
			super.fixedUpdate();
			//同步transform的位置和旋转角
			var pos:b2Vec2=_linkBody.GetPosition();
			transform.setPositionAndRotation(pos.x,pos.y,_linkBody.GetAngle()*Mathk.Deg2Rad);
		}
		
		override protected function onDestroy():void{
			if(_linkBody)_linkBody.Destroy();
			_linkBody=null;
			_jointDatas=null;
			super.onDestroy();
		}
		
		frameworkInternal function get jointDatas():Vector.<JointData>{ return _jointDatas; }
		
	};

}