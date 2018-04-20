package g.fixtures{
	import Box2D.Dynamics.b2Body;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import framework.game.Game;
	import framework.objs.Clip;
	import framework.utils.Box2dUtil;
	import framework.utils.LibUtil;
	import g.MyData;
	import g.fixtures.SwitcherCtrlObj;
	import Box2D.Dynamics.b2World;
	
	/**显示/隐藏的开关控制对象*/
	public class SwitcherCtrlObjShowHide extends SwitcherCtrlObj{
		
		public function SwitcherCtrlObjShowHide(){
			super();
		}
		
		public static function create(childMc:MovieClip,world:b2World):void{
			//xx_red_s11_1
			//类型_颜色_开关名_是否打开
			var nameList:Array=childMc.name.split("_");
			var game:Game=Game.getInstance();
			var mc:MovieClip=LibUtil.getDefMovie("Tree_"+nameList[1]);
			mc.transform.matrix=childMc.transform.matrix;
			game.global.layerMan.items3Layer.addChild(mc);
			var info:*={};
			info.ctrlMySwitcherName=nameList[2];
			info.isOpen=Boolean(Number(nameList[3]));
			info.view=mc;
			info.body=Box2dUtil.createBoxWithDisObj(childMc,world,MyData.ptm_ratio);
			game.createGameObj(new SwitcherCtrlObjShowHide(),info);
		}
		
		private var _view:Sprite;
		private var _body:b2Body;
		
		override protected function init(info:* = null):void{
			super.init(info);
			_ctrlMySwitcherName=info.ctrlMySwitcherName;
			_isOpen=info.isOpen;
			_view=info.view;
			_body=info.body;
			_body.SetType(b2Body.b2_staticBody);
			syncView();
			
			_view.visible=_isOpen;
			_body.SetSensor(!_isOpen);
		}
		
		private function syncView():void{
			if(_view){
				_view.x=_body.GetPosition().x*MyData.ptm_ratio;
				_view.y=_body.GetPosition().y*MyData.ptm_ratio;
				_view.rotation=(_body.GetAngle()*57.3)%360;
			}
		}
		
		override protected function open():void{
			if(_view.visible)return;
			_isOpen=true;
			_body.SetSensor(false);
			_view.visible=true;
		}
		
		override protected function close():void{
			if(!_view.visible)return;
			_isOpen=false;
			_body.SetSensor(true);
			_view.visible=false;
			createEffect();
		}
		
		private function createEffect():void{
			var x:Number=_body.GetPosition().x*MyData.ptm_ratio;
			var y:Number=_body.GetPosition().y*MyData.ptm_ratio;
			var clip:Clip=Clip.fromDefName("TreeEffect",true,true,_game.global.layerMan.effLayer,x,y);
			clip.addFrameScript(clip.totalFrames-1,function ():void{
				if(clip.parent)clip.parent.removeChild(clip);
			});
		}
		
		override protected function onDestroy():void{
			_body.Destroy();
			_view.parent.removeChild(_view);
			_view=null;
			_body=null;
			super.onDestroy();
		}
		
	};

}