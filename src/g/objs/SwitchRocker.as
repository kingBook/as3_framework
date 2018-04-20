package g.objs{
	import framework.game.Game;
	import g.components.SwitchBehavior;
	/**摇杆开关 基类 */
	public class SwitchRocker extends MovableObject{
		protected var _switchBehavior:SwitchBehavior;
		public static function create():void{
			var game:Game=Game.getInstance();
			var info:*={};

			game.createGameObj(new SwitchRocker(),info);
		}

		override protected function init(info:*=null):void{
			super.init(info);
			_switchBehavior=SwitchBehavior.create(this,info.name,on,off);
		}

		final public function control(isAuto:Boolean=false,isDoOn:Boolean=false):void{
			_switchBehavior.control(isAuto,isDoOn);
		}

		virtual protected function on():void{

		}
		
		virtual protected function off():void{
			
		}

		override protected function onDestroy():void{
			removeComponent(_switchBehavior);
			_switchBehavior=null;
			super.onDestroy();
		}

		public function get name():String{
			return _switchBehavior.name;
		}
	}
}