package framework.system {
	import flash.display.BitmapData;
	import flash.utils.Dictionary;
	import framework.game.Game;
	import framework.objs.GameObject;

	public class ObjectPool extends GameObject{
		private var _dict:Dictionary;
		public function ObjectPool(){
			super();
		}
		public static function create():ObjectPool{
			var game:Game=Game.getInstance();
			return game.createGameObj(new ObjectPool()) as ObjectPool;
		}
		override protected function init(info:* = null):void{
			super.init(info);
			_dict=new Dictionary();
		}
		public function add(obj:Object, key:*=null):void{
			if (key) {
				if(!has(key))_dict[key]=obj;
				else error(key);
			}else {
				if(!has(obj))_dict[obj]=obj;
				else error(obj);
			}
		}
		private function error(key:*):void {
			throw new Error(key+"已经存在对象池中!");
		}
		
		public function remove(key:*):void{
			if(has(key))delete _dict[key];
		}
		
		public function get(key:*):*{
			if (has(key)) return _dict[key];
			else return null;
		}
		
		public function has(key:*):Boolean{
			return Boolean(_dict[key]);
		}
		
		public function clear():void{
			for (var k:* in _dict) delete _dict[k];
		}
		
		override protected function onDestroy():void{
			if(_dict){
				for each(var obj:* in _dict){
					if(obj is BitmapData){
						var bmd:BitmapData=obj as BitmapData;
						if(bmd)bmd.dispose();
					}
				}
				clear();
			}
			
			_dict=null;
			
			super.onDestroy();
		}
	};
}