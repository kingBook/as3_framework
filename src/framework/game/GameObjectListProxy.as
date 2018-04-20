package framework.game {
	import framework.objs.GameObject;
	import framework.namespaces.frameworkInternal;
	use namespace frameworkInternal;

	public class GameObjectListProxy{
		private var _gameObjectlist:*;
		private var _emptyList:Vector.<GameObject>=new Vector.<GameObject>();
		public function GameObjectListProxy(){
			_gameObjectlist={};
		}
		
		frameworkInternal function addGameObject(key:String,gameObject:GameObject):void{
			_gameObjectlist[key]||=new Vector.<GameObject>();
			_gameObjectlist[key].push(gameObject);
		}
		
		frameworkInternal function removeGameObject(key:String,gameObject:GameObject):void{
			var list:Vector.<GameObject>=_gameObjectlist[key];
			list.splice(list.indexOf(gameObject),1);
			if(list.length==0)delete _gameObjectlist[key];
		}
		
		frameworkInternal function getGameObjectList(key:String):Vector.<GameObject>{
			return _gameObjectlist[key]||_emptyList;
		}
		
		frameworkInternal function getGameObjectListToArray(key:String):Array{
			var list:Vector.<GameObject>=getGameObjectList(key);
			var len:int=list.length;
			var arr:Array=[];
			for (var i:int = 0; i < len; i++) arr[i]=list[i];
			return arr;
		}
		
		frameworkInternal function destroy():void{
			_emptyList=null;
			_gameObjectlist=null;
		}
	};

}