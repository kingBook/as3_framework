package framework.system{
	import framework.game.Game;
	import framework.objs.GameObject;

	public class Input extends GameObject{
		internal var _lookup:Object;
		public var _map:Array;
		internal const _total:uint = 256;

		public function Input(){
			super();
		}
		
		override protected function init(info:* = null):void{
			super.init(info);
			_lookup = new Object();
			_map = new Array(_total);
		}
		
		public function updateKeyStates():void{
			var i:uint = 0;
			while(i < _total){
				var o:Object = _map[i++];
				if(o == null) continue;
				if((o.last == -1) && (o.current == -1)) o.current = 0;
				else if((o.last == 2) && (o.current == 2)) o.current = 1;
				o.last = o.current;
			}
		}
		
		public function reset():void{
			var i:uint = 0;
			while(i < _total){
				var o:Object = _map[i++];
				if(o == null) continue;
				this[o.name] = false;
				o.current = 0;
				o.last = 0;
			}
		}
		
		public function pressed(Key:String):Boolean { return this[Key]; }
		
		public function justPressed(Key:String):Boolean { return _map[_lookup[Key]].current == 2; }
		
		public function justReleased(Key:String):Boolean { return _map[_lookup[Key]].current == -1; }
		
		public function record():Array{
			var data:Array = null;
			var i:uint = 0;
			while(i < _total){
				var o:Object = _map[i++];
				if((o == null) || (o.current == 0)) continue;
				if(data == null) data = new Array();
				data.push({code:i-1,value:o.current});
			}
			return data;
		}
		
		public function playback(Record:Array):void{
			var i:uint = 0;
			var l:uint = Record.length;
			var o:Object;
			var o2:Object;
			while(i < l){
				o = Record[i++];
				o2 = _map[o.code];
				o2.current = o.value;
				if(o.value > 0)this[o2.name] = true;
			}
		}
		
		public function getKeyCode(KeyName:String):int{
			return _lookup[KeyName];
		}
		
		public function any():Boolean{
			var i:uint = 0;
			while(i < _total){
				var o:Object = _map[i++];
				if((o != null) && (o.current > 0)) return true;
			}
			return false;
		}
		
		protected function addKey(KeyName:String,KeyCode:uint):void{
			_lookup[KeyName] = KeyCode;
			_map[KeyCode] = { name: KeyName, current: 0, last: 0 };
		}
		
		override protected function onDestroy():void{
			_lookup = null;
			_map = null;
			super.onDestroy();
		}
	}
}
