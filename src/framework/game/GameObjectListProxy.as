package framework.game {
	import framework.objs.GameObject;
	import framework.namespaces.frameworkInternal;
	use namespace frameworkInternal;

	public class GameObjectListProxy{
		private var _gameObjectlist:*;
		private var _emptyList:Array=[];
		public function GameObjectListProxy(){
			_gameObjectlist={};
		}
		
		frameworkInternal function addGameObject(key:String,gameObject:GameObject):void{
			_gameObjectlist[key]||=[];
			_gameObjectlist[key].push(gameObject);
		}
		
		frameworkInternal function removeGameObject(key:String,gameObject:GameObject):void{
			var list:Array=_gameObjectlist[key];
			list.splice(list.indexOf(gameObject),1);
			if(list.length==0)delete _gameObjectlist[key];
		}
		
		frameworkInternal function getGameObjectList(key:String):Array{
			return _gameObjectlist[key]||_emptyList;
		}
		
		frameworkInternal function destroy():void{
			_emptyList=null;
			_gameObjectlist=null;
		}
	};

}