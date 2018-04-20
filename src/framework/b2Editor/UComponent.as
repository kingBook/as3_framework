package framework.b2Editor{
	import Box2D.Dynamics.b2Body;
	import framework.game.Game;
	import framework.namespaces.frameworkInternal;
	import framework.objs.Component;
	import framework.objs.GameObject;
	use namespace frameworkInternal;
	
	public class UComponent extends Component{
		
		private var _uGameObject:UGameObject;
		
		public function UComponent(){
			super();
		}
		
		override frameworkInternal function init_internal(gameObj:GameObject,game:Game,info:*=null):void{
			_uGameObject=gameObj as UGameObject;
			super.init_internal(gameObj,game,info);
		}
		
		/**返回自身或子对象的指定类型组件*/
		final public function getComponentInChildren(type:Class):Component{
			return _uGameObject.getComponentInChildren(type);
		}
		
		/**返回自身或父级对象的指定类型组件*/
		final public function getComponentInParent(type:Class):Component{
			return _uGameObject.getComponentInParent(type);
		}
		
		/**返回自身和子对象的指定类型组件列表*/
		final public function getComponentsInChildren(type:Class,result:Vector.<Component>=null):Vector.<Component>{
			return _uGameObject.getComponentsInChildren(type,result);
		}
		
		/**返回自身和父级对象的指定类型组件列表*/
		final public function getComponentsInParent(type:Class,result:Vector.<Component>=null):Vector.<Component>{
			return _uGameObject.getComponentsInParent(type,result);
		}
		
		/**返回自身和子对象的指刚体列表*/
		final public function getBodiesInChildren(result:Vector.<b2Body>=null):Vector.<b2Body>{
			return _uGameObject.getBodiesInChildren(result);
		}
		
		/**返回自身和父级对象的刚体列表*/
		final public function getBodiesInParent(result:Vector.<b2Body>=null):Vector.<b2Body>{
			return _uGameObject.getBodiesInParent(result);
		}
			
		override protected function onDestroy():void{
			_uGameObject=null;
			super.onDestroy();
		}
		
		public function get uGameObject():UGameObject{ return _uGameObject; }
		public function get transform():UTransform{ return _uGameObject.transform; }
		public function get bodyObject():UBodyObject{ return _uGameObject.bodyObject; }
		public function get body():b2Body{ return _uGameObject.body; }
		
	};

}