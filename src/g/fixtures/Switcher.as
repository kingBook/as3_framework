package g.fixtures {
	import Box2D.Dynamics.b2Body;
	import framework.events.FrameworkEvent;
	import framework.objs.Clip;
	import framework.objs.GameObject;
	import framework.game.UpdateType;
	import framework.utils.FuncUtil;
	import g.objs.MyObj;
	
	//名称：switcher_类型_开关名_颜色_是否打开_是否只触发一次
	//switcher_button_s11_red_0_0
	//switcher_rocker_s11_red_1_0
	public class Switcher extends MyObj {
		/**激活开关的对象列表*/
		static protected var _activeObjs:Vector.<GameObject>=new Vector.<GameObject>();
		/**添加激活对象*/
		static public function AddActiveObj(obj:GameObject):void{
			if(_activeObjs.indexOf(obj)<0) _activeObjs.push(obj);
		}
		/**移除激活对象*/
		static public function RemoveActiveObj(obj:GameObject):void{
			var id:int=_activeObjs.indexOf(obj);
			if(id>-1) _activeObjs.splice(id,1);
		}
		
		protected var _body:b2Body;
		protected var _isOpen:Boolean;
		protected var _isGotoEnd:Boolean;
		
		protected var _count:int;
		protected var _total:int=5;
		
		protected var _clip:Clip;
		protected var _myName:String;
		protected var _isOnce:Boolean;//是否只触发一次
		protected var _isTriggered:Boolean;//已经触发过了
		public function Switcher() { super(); }
		
		private function destroyAll(e:FrameworkEvent):void{
			_activeObjs.splice(0,_activeObjs.length);
		}
		
		override protected function init(info:*=null):void {
			_body=info.body;
			_body.SetType(b2Body.b2_staticBody);
			_body.SetUserData({thisObj:this});
			_body.SetSensor(true);
			_isOpen=info.isOpen;
			_isGotoEnd=true;
			_myName=info.myName;
			_isOnce=info.isOnce;
			
			//初状态
			_count=_isOpen?_total:0;
			//
			_clip=info.clip;
			_clip.controlled=true;
			_clip.gotoAndStop(_isOpen?_clip.totalFrames:1);
			//
			_game.addEventListener(FrameworkEvent.DESTROY_ALL,destroyAll);
		}
		
		override protected function update():void{
			ai();
			if(!_isGotoEnd){
				_isGotoEnd=gotoPoint(_isOpen?_total:0);
				if(_isGotoEnd)handlingLinkObjects();
				updateProgress();
			}
		}
		protected function ai():void{ }
		protected function updateProgress():void{
			var rate:Number=_count/_total;
			var frame:int=_clip.totalFrames*rate;
			if(frame<1)frame=1; else if(frame>_clip.totalFrames)frame=_clip.totalFrames;
			_clip.gotoAndStop(frame);
		}
		
		private function gotoPoint(target:int):Boolean{
			var sign:int=target>_count?1:-1;
			_count+=sign;
			if(_count==target)return true;
			return false;
		}
		
		protected function handlingLinkObjects():void{ }
		
		private function open():void {
			if(_isOpen)return;
			_isOpen=true;
			_isGotoEnd=false;
			playSound();
		}
		
		private function close():void {
			if(!_isOpen)return;
			_isOpen=false;
			_isGotoEnd=false;
			playSound();
		}
		
		protected function playSound():void{
			_game.global.soundMan.play("Sound_switcher");
		}
		
		public function control(isAuto:Boolean=false,isDoOpen:Boolean=false):void{
			if(isAuto){
				if(_isOpen)close();else open();
			}else{
				if(isDoOpen)open();else close();
			}
		}
		
		override protected function onDestroy():void {
			_game.removeEventListener(FrameworkEvent.DESTROY_ALL,destroyAll);
			_body.Destroy();
			FuncUtil.removeChild(_clip);
			_clip=null;
			_body=null;
			super.onDestroy();
		}
	};

}