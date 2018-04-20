package g.fixtures{
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.Contacts.b2Contact;
	import Box2D.Dynamics.Contacts.b2ContactEdge;
	import flash.display.MovieClip;
	import framework.game.Game;
	import framework.objs.Clip;
	import framework.objs.GameObject;
	import framework.utils.Box2dUtil;
	import framework.utils.FuncUtil;
	import g.MyData;
	import Box2D.Dynamics.b2World;
	//名称：switcher_类型_开关名_颜色_是否打开_是否只触发一次
	//switcher_button_s11_red_0_0
	public class SwitcherButton extends Switcher{
		private var _isHit:Boolean;
		public function SwitcherButton(){ super(); }
		
		public static function create(childMc:MovieClip,world:b2World):void{
			var angleRadian:Number=childMc.rotation*0.01745;
			var w:Number=FuncUtil.getTransformWidth(childMc);
			var h:Number=FuncUtil.getTransformHeight(childMc);
			var body:b2Body=Box2dUtil.createBox(w,h,childMc.x,childMc.y,world,MyData.ptm_ratio);
			body.SetAngle(angleRadian);
			
			var nameList:Array=childMc.name.split("_");
			//for(var i:int=0;i<nameList.length;i++)trace("i:"+i,nameList[i]);
			/*
			 i:0 switcher
			 i:1 button
			 i:2 s11
			 i:3 red
			 i:4 0
			 i:5 0
			*/
			
			var color:String=nameList[3];
			var clip:Clip=Clip.fromDefName("SwitcherButton_"+color,true,true,Game.getInstance().global.layerMan.items3Layer);
			clip.transform.matrix=childMc.transform.matrix;
			
			Game.getInstance().createGameObj(new SwitcherButton(),{
				body:body,
				clip:clip,
				isOpen:Boolean(int(nameList[4])),
				myName:nameList[2],
				isOnce:Boolean(int(nameList[5]))
			});
		}
		
		override protected function init(info:* = null):void{
			super.init(info);
			control(false,!_isHit);
		}
		
		override protected function ai():void{
			checkIsHit();
			control(false,!_isHit);
		}
		
		/**操作这个开关控制的对象*/
		override protected function handlingLinkObjects():void{
			//当松开这个按钮开关时，如果还有另一个按钮开关处于按下状态，不操作控制的对象
			if(_isOpen){
				var switcherBtns:Vector.<GameObject>=_game.getGameObjList(SwitcherButton);
				var i:int=switcherBtns.length;
				var sbtn:SwitcherButton;
				while(--i>=0){
					sbtn=SwitcherButton(switcherBtns[i]);
					if(sbtn==this)continue;
					if(sbtn._myName==_myName&&!sbtn._isOpen)return;
				}
			}
			//
			var ctrlObjs:Vector.<GameObject>=_game.getGameObjList(SwitcherCtrlObj);
			i=ctrlObjs.length;
			var ctrlObj:SwitcherCtrlObj;
			while(--i>=0){
				ctrlObj=SwitcherCtrlObj(ctrlObjs[i]);
				if(ctrlObj.ctrlMySwitcherName==_myName)ctrlObj.control(false,_isOpen?ctrlObj.initIsOpen:!ctrlObj.initIsOpen);
			}
		}
		
		private function checkIsHit():void{
			if(_isOnce&&_isTriggered)return;
			var isHit:Boolean=false;
			var ce:b2ContactEdge=_body.GetContactList();
			var contact:b2Contact,b1:b2Body,b2:b2Body,ob:b2Body,userData:*;
			for(ce;ce;ce=ce.next){
				contact=ce.contact;
				if(!contact.IsTouching())continue;
				b1=contact.GetFixtureA().GetBody();
				b2=contact.GetFixtureB().GetBody();
				ob=b1==_body?b2:b1;
				userData=ob.GetUserData();
				if(userData){
					if(_activeObjs.indexOf(userData.thisObj)>-1){
						isHit=true;
						break;
					}
				}
			}
			_isHit=isHit;
			if(_isHit&&_isOnce)_isTriggered=true;
		}
	};

}