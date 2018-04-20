package g.objs{
	import g.objs.MovableObject;
	import g.components.SwitchBehavior;
	/**按钮开关 基类 */
	public class SwitchButton extends MovableObject{
		protected var _switchBehavior:SwitchBehavior;

		/*public static function create(body:b2Body,name:String,viewDefName:String=null):void{
			var game:Game=Game.getInstance();
			var info:*={};
			info.body=body;
			if(viewDefName){
				info.view=Clip.fromDefName(viewDefName,true,true,null,0,0,true);
				info.viewParent=game.global.layerMan.items2Layer;
			}
			info.name=name;
			game.createGameObj(new XXX(),info);
		}*/

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
	}
}