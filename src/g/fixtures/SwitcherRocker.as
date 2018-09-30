package g.fixtures{
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.Contacts.b2Contact;
	import Box2D.Dynamics.Contacts.b2ContactEdge;
	import flash.display.MovieClip;
	import framework.events.FrameworkEvent;
	import framework.game.Game;
	import framework.objs.Clip;
	import framework.objs.GameObject;
	import framework.utils.Box2dUtil;
	import framework.utils.FuncUtil;
	import g.MyData;
	import Box2D.Dynamics.b2World;
	//名称：switcher_类型_开关名_颜色_是否打开_是否只触发一次
	//switcher_button_s11_red_0_0
	//switcher_rocker_s11_red_1_0
	public class SwitcherRocker extends Switcher{
		
		public function SwitcherRocker(){ super(); }
		
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
			 i:1 rocker
			 i:2 s11
			 i:3 red
			 i:4 0 
			 i:5 0
			*/
			
			var color:String=nameList[3];
			var clip:Clip=Clip.fromDefName("SwitcherRocker_"+color,true,true,Game.getInstance().global.layerMan.items3Layer);
			clip.transform.matrix=childMc.transform.matrix;
			
			Game.getInstance().createGameObj(new SwitcherRocker(),{
				body:body,
				clip:clip,
				isOpen:Boolean(int(nameList[4])),
				myName:nameList[2],
				isOnce:Boolean(int(nameList[5]))
			});
		}
		
		override protected function init(info:*=null):void{
			super.init(info);
			_body.SetContactBeginCallback(contactBegin);
			_body.SetContactEndCallback(contactEnd);
		}
		
		override protected function handlingLinkObjects():void{
			var ctrlObjs:Array=_game.getGameObjList(SwitcherCtrlObj);
			var i:int=ctrlObjs.length;
			var ctrlObj:SwitcherCtrlObj;
			while (--i>=0){
				ctrlObj=SwitcherCtrlObj(ctrlObjs[i]);
				if(ctrlObj.ctrlMySwitcherName==_myName)ctrlObj.control(true);
			}
		}
		
		private function contactBegin(contact:b2Contact,other:b2Body):void{
			var b1:b2Body=contact.GetFixtureA().GetBody();
			var b2:b2Body=contact.GetFixtureB().GetBody();
			var ob:b2Body=b1==_body?b2:b1;
			var userData:*=ob.GetUserData();
			if(userData){
				if(_activeObjs.indexOf(userData.thisObj)>-1){
					if(!userData.swithcerRockerHit){
						userData.swithcerRockerHit=true;
						if(_isOnce){
							if(!_isTriggered){
								control(true);
								_isTriggered=true;
							}
						}else{
							control(true);
						}
					}
				}
			}
		}
		
		private function contactEnd(contact:b2Contact,other:b2Body):void{
			var b1:b2Body=contact.GetFixtureA().GetBody();
			var b2:b2Body=contact.GetFixtureB().GetBody(); 
			var ob:b2Body=b1==_body?b2:b1;
			var userData:*=ob.GetUserData();
			if(userData){
				if(_activeObjs.indexOf(userData.thisObj)>-1){
					var result:Boolean=true;
					result&&=userData.swithcerRockerHit;
					result&&=!checkContactsIsTouching(getContacts(b1,b2));//所有接触都分离
					if(result){
						userData.swithcerRockerHit=false;
					}
				}
			}
		}
		
		private function checkContactsIsTouching(contacts:Vector.<b2Contact>):Boolean{
			var i:int=contacts.length;
			var contact:b2Contact;
			while(--i>=0){
				contact=contacts[i];
				if(contact.IsTouching())return true;
			}
			return false;
		}
		
		private function getContacts(b1:b2Body,b2:b2Body):Vector.<b2Contact>{
			var list:Vector.<b2Contact>=new Vector.<b2Contact>();
			var ce:b2ContactEdge=b1.GetContactList();
			var contact:b2Contact,ba:b2Body,bb:b2Body;
			for(ce;ce;ce=ce.next){
				contact=ce.contact;
				ba=contact.GetFixtureA().GetBody();
				bb=contact.GetFixtureB().GetBody();
				var result:Boolean=false;
				result||=ba==b1&&bb==b2;
				result||=ba==b2&&bb==b1;
				if(result)list.push(contact);
			}
			return list;
		}
	};

}