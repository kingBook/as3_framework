package framework.b2Editor{
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Common.Math.b2Vec3;
	import framework.game.Game;
	import framework.namespaces.frameworkInternal;
	import framework.objs.GameObject;
	import framework.utils.Mathk;
	use namespace frameworkInternal;
	
	public class UTransform extends UComponent{
		
		public var _rotation:Number=0;
		public var _localRotation:Number=0;
		private var _position:b2Vec2=new b2Vec2(0,0);
		private var _localPosition:b2Vec2=new b2Vec2(0,0);
		private var _lossyScale:b2Vec2=new b2Vec2(1,1);
		private var _localScale:b2Vec2=new b2Vec2(1,1);
		
		private var _parent:UTransform;
		private var _children:Vector.<UTransform>=new Vector.<UTransform>();
		
		public static function addToUGameObject(uGameObject:UGameObject,parent:UTransform=null,transformData:TransformData=null):UTransform{
			return uGameObject.addComponent(UTransform,{parent:parent, transformData:transformData}) as UTransform;
		}
		
		public function UTransform(){
			super();
		}
		
		override frameworkInternal function init_internal(gameObj:GameObject,game:Game,info:*=null):void{
			var parent:UTransform=info.parent;
			var transformData:TransformData=info.transformData;
			if(transformData) setWithData(transformData);
			if(parent) setParent(parent);
			super.init_internal(gameObj,game,info);
		}
		
		private function setWithData(transformData:TransformData):void{
			_position.x=transformData.position.x;
			_position.y=transformData.position.y;
			_localPosition.x=transformData.localPosition.x;
			_localPosition.y=transformData.localPosition.y;
			_rotation=transformData.rotation.z;
			_localRotation=transformData.localRotation.z;
			_lossyScale.x=transformData.lossyScale.x;
			_lossyScale.y=transformData.lossyScale.y;
			_localScale.x=transformData.localScale.x;
			_localScale.y=transformData.localScale.y;
		}
		
		/**设置全局坐标和旋转角*/
		public function setPositionAndRotation(x:Number,y:Number,rotation:Number,isSetBodyObject:Boolean=false):void{
			setPosition(x,y,isSetBodyObject);
			setRotation(rotation,isSetBodyObject);
		}
		
		public function setPosition(x:Number,y:Number,isSetBodyObject:Boolean=false):void{
			var ox:Number=x-_position.x;
			var oy:Number=y-_position.y;
			_position.x=x;
			_position.y=y;
			if(isSetBodyObject){
				if(bodyObject)bodyObject.setPositionAndRotation(position.x,position.y,NaN);
			}
			updateChildrenPosition(ox,oy,isSetBodyObject);//对齐children全局坐标
		}
		public function setPositionV(v:b2Vec2):void{
			setPosition(v.x,v.y);
		}
		public function setPositionV3(v:b2Vec3):void{
			setPosition(v.x,v.y);
		}

		public function setLocalPosition(x:Number,y:Number,isSetBodyObject:Boolean=false):void{
			var ox:Number=x-_localPosition.x;
			var oy:Number=y-_localPosition.y;
			_localPosition.x=x;
			_localPosition.y=y;
			setPosition(_position.x+ox,_position.y+oy,isSetBodyObject);//对齐全局坐标
		}
		public function setLocalPositionV(v:b2Vec2,isSetBodyObject:Boolean=false):void{
			setLocalPosition(v.x,v.y,isSetBodyObject);
		}
		public function setLocalPositionV3(v:b2Vec3,isSetBodyObject:Boolean=false):void{
			setLocalPosition(v.x,v.y,isSetBodyObject);
		}
		
		public function setLossyScale(x:Number,y:Number):void{
			_lossyScale.x=x;
			_lossyScale.y=y;
			
			setLocalScale(_localScale.x*x,_localScale.y*y);
			updateChildrenLossyScale(x,y);//对齐子对象的缩放比例
		}
		public function setLossyScaleV(v:b2Vec2):void{
			setLossyScale(v.x,v.y);
		}
		public function setLossyScaleV3(v:b2Vec3):void{
			setLossyScale(v.x,v.y);
		}
		
		public function setLocalScale(x:Number,y:Number):void{
			_localScale.x=x;
			_localScale.y=y;
		}
		public function setLocalScaleV(v:b2Vec2):void{
			setLocalScale(v.x,v.y);
		}
		public function setLocalScaleV3(v:b2Vec3):void{
			setLocalScale(v.x,v.y);
		}
		
		public function setLocalRotation(value:Number,isSetBodyObject:Boolean=false):void{
			value=Mathk.getRotationToFlash(value);
			var or:Number=Mathk.getFlashRotationOffset(_localRotation,value);
			_localRotation=value;
			
			setRotation(rotation+or,isSetBodyObject);//对齐全局旋转角
		}
		public function setRotation(value:Number,isSetBodyObject:Boolean=false):void{
			value=Mathk.getRotationToFlash(value);
			var or:Number=Mathk.getFlashRotationOffset(_rotation,value);
			_rotation=value;
			if(isSetBodyObject){
				if(bodyObject)bodyObject.setPositionAndRotation(NaN,NaN,rotation*Mathk.Deg2Rad);
			}
			updateChildrenRotation(or,isSetBodyObject);//对齐children全局旋转角
		}
		
		/**设置父级UTransform*/
		public function setParent(transform:UTransform):void{
			if(transform==this)return;
			_parent=transform;
			
			if(_parent){
				var x:Number=_parent.position.x+_localPosition.x;
				var y:Number=_parent.position.y+_localPosition.y;
				setPosition(x,y);
				
				setRotation(_parent.rotation+_localRotation);
				
				x=_parent.lossyScale.x*_localScale.x;
				y=_parent.lossyScale.y*_localScale.y;
				setLossyScale(x,y);
			}
		}
		
		frameworkInternal function addChild(transform:UTransform):void{
			_children.push(transform);
		}
		
		/**更新子对象的全局坐标*/
		private function updateChildrenPosition(offsetX:Number,offsetY:Number,isSetBodyObject:Boolean=false):void{
			var i:int,t:UTransform,len:int=_children.length;
			for(i=0;i<len;i++){
				t=_children[i];
				t.setPosition(t.position.x+offsetX,t.position.y+offsetY,isSetBodyObject);
			}
		}
		
		/**更新子对象的全局旋转角*/
		private function updateChildrenRotation(offset:Number,isSetBodyObject:Boolean=false):void{
			var i:int,t:UTransform,len:int=_children.length;
			for(i=0;i<len;i++){
				t=_children[i];
				t.setRotation(t.rotation+offset,isSetBodyObject);
			}
		}
		
		/**更新子对象的全局缩放比例*/
		private function updateChildrenLossyScale(x:Number,y:Number):void{
			var i:int,t:UTransform,len:int=_children.length;
			for(i=0;i<len;i++){
				t=_children[i];
				t.setLossyScale(x,y);
			}
		}
		
		public function get localRotation():Number{ return _localRotation; }
		public function get rotation():Number{ return _rotation; }
		public function get position():b2Vec2{ return _position; }
		public function get localPosition():b2Vec2{ return _localPosition; }
		public function get lossyScale():b2Vec2{ return _lossyScale; }
		public function get localScale():b2Vec2{ return _localScale; }
		public function get parent():UTransform{ return _parent; }
		public function get childCount():int{ return _children.length; }
		frameworkInternal function get children():Vector.<UTransform>{ return _children; }
		
		override protected function onDestroy():void{
			_position=null;
			_localPosition=null;
			_lossyScale=null;
			_localScale=null;
			_parent=null;
			_children=null;
			super.onDestroy();
		}
		
		
	};

}