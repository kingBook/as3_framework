package g.objs{
	import Box2D.Dynamics.Contacts.b2ContactEdge;
	import Box2D.Dynamics.b2Body;
	import framework.game.Game;
	import framework.objs.Clip;
	import g.components.SwitchBehavior;
	import g.objs.SwitchButton;

	public class SwButton extends SwitchButton{
	
		private var _clip:Clip;
		
		public static function create(body:b2Body,name:String,viewDefName:String=null):void{
			var game:Game=Game.getInstance();
			var info:*={};
			info.body=body;
			if(viewDefName){
				info.view=Clip.fromDefName(viewDefName,true,true,null,0,0,true);
				info.viewParent=game.global.layerMan.items2Layer;
			}
			info.name=name;
			game.createGameObj(new SwButton(),info);
		}

		override protected function init(info:*=null):void{
			super.init(info);
			_clip=_view as Clip;
		}

		override protected function on():void{
			if(_clip)_clip.gotoAndStop(2);
			controlObjs(true);
		}
		
		override protected function off():void{
			if(_clip)_clip.gotoAndStop(1);
			controlObjs(false);
		}

		private function controlObjs(isOn:Boolean):void{
			/*var objs:Vector.<SwMovie>=Vector.<SwMovie>(_game.getGameObjList(SwMovie));
			for(var i:int=0;i<objs.length;i++){
				var swMovie:SwMovie=objs[i];
				if(swMovie.ctrlMyNames.indexOf(_switchBehavior.name)>-1){
					swMovie.control(true);
				}
			}*/
		}

		public function getHasBodyContact(body:b2Body):Boolean{
			var ce:b2ContactEdge=_body.GetContactList();
			for(ce;ce;ce=ce.next){
				if(!ce.contact.IsTouching())continue;
				if(ce.other==body)return true;
			}
			return false;
		}
		
		override protected function onDestroy():void{
			_clip=null;
			super.onDestroy();
		}
	}
}