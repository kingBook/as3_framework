package g.fixtures {
	import Box2D.Collision.b2Manifold;
	import Box2D.Collision.b2WorldManifold;
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.Contacts.b2Contact;
	import flash.display.MovieClip;
	import framework.events.FrameworkEvent;
	import framework.game.Game;
	import framework.objs.Clip;
	import framework.game.UpdateType;
	import framework.system.SoundInstance;
	import framework.utils.Box2dUtil;
	import framework.utils.FuncUtil;
	import g.MyData;
	import g.map.Map;
	import Box2D.Dynamics.b2World;
	//名称：platform_类型_开关名_颜色_最小范围_最大范围_运动轴_运动速度_是否单向碰撞
	//platform_controlled_s11_red_0_10000_y_3_0
	//platform_auto_s11_red_0_10000_y_3_0
	//platform_fixed_s11_red_0_10000_y_3_0
	public class Platform extends SwitcherCtrlObj {
		
		protected var _type:String;//平台类型
		protected const CONTROLLED:String="controlled";
		protected const AUTO:String="auto";
		protected const FIXED:String="fixed";
		
		protected var _body:b2Body;
		protected var _clip:Clip;
		protected var _isOneWay:Boolean;
		protected var _minPos:b2Vec2;
		protected var _maxPos:b2Vec2;
		protected var _speed:Number=3;
		
		protected var _lastPos:b2Vec2;
		protected var _vx:Number=0;
		protected var _vy:Number=0;
		
		public function Platform() { super(); }
		
		static public function create(childMc:MovieClip,world:b2World):b2Body{
			var game:Game=Game.getInstance();
			
			var body:b2Body=Box2dUtil.createBox(childMc.width,childMc.height,childMc.x,childMc.y,world,MyData.ptm_ratio);
			
			var nameList:Array=childMc.name.split("_");
			//for(var i:int=0;i<nameList.length;i++)trace("i:"+i,nameList[i]);
			/*
			 i:0 platform
			 i:1 controlled
			 i:2 s11
			 i:3 red
			 i:4 267
			 i:5 367
			 i:6 y
			 i:7 3
			 i:8 0
			*/
			var color:String=nameList[3];
			var clip:Clip=Clip.fromDefName("Platform_"+color,true,true,game.global.layerMan.items3Layer);
			clip.transform=childMc.transform;
			game.createGameObj(new Platform(),{
				body:body,
				clip:clip,
				type:nameList[1],
				ctrlMySwitcherName:nameList[2],
				min:Number(nameList[4]),
				max:Number(nameList[5]),
				axis:nameList[6],
				speed:Number(nameList[7]),
				isOneWay:Boolean(int(nameList[8]))
			});
			return body;
		}
		
		override protected function init(info:*=null):void {
			super.init(info);
			_speed=info.speed;
			_body=info.body;
			_body.SetType(b2Body.b2_kinematicBody);
			_body.SetPreSolveCallback(preSolve);
			_body.SetUserData({thisObj:this,type:"Platform"});
			
			_isOneWay=info.isOneWay;
			_type=info.type;
			_ctrlMySwitcherName=info.ctrlMySwitcherName;
			_clip=info.clip;
			
			if(isKinematic()){
				var min:Number=info.min;
				var max:Number=info.max;
				
				var axis:String=info.axis;
				if(min||max){
					min/=MyData.ptm_ratio;
					max/=MyData.ptm_ratio;
					_minPos=new b2Vec2(axis=="x"?min:_body.GetPosition().x, axis=="y"?min:_body.GetPosition().y);
					_maxPos=new b2Vec2(axis=="x"?max:_body.GetPosition().x, axis=="y"?max:_body.GetPosition().y);
					
					var dMin:Number=b2Vec2.Distance(_body.GetPosition(),_minPos);
					var dMax:Number=b2Vec2.Distance(_body.GetPosition(),_maxPos);
					if(_type==CONTROLLED)_body.SetPosition(dMin<dMax?_minPos:_maxPos);//贴紧到靠近的一边 
					_isOpen=!(dMin<dMax);//靠近minPos则为关，靠近maxPos则为开
					//如果body.position等于minPos或maxPos则_isGotoEnd为true;
					_isGotoEnd=false;
					_isGotoEnd||=_body.GetPosition().x==_minPos.x&&_body.GetPosition().y==_minPos.y;
					_isGotoEnd||=_body.GetPosition().x==_maxPos.x&&_body.GetPosition().y==_maxPos.y;
					if(_isGotoEnd){//处理自动移动平台，与开始点/终点中的一点相等时不运动
						if(_type==AUTO)control(true);
					}
				}
			}
			_lastPos=_body.GetPosition().Copy();
			syncView();
		}
		
		protected function isKinematic():Boolean{ return _type==CONTROLLED||_type==AUTO; }
		
		protected var _worldManifold:b2WorldManifold;
		protected function preSolve(contact:b2Contact,oldManifold:b2Manifold,other:b2Body):void{
			if(!_isOneWay)return;
			if(!contact.IsTouching())return;
			var b1:b2Body=contact.GetFixtureA().GetBody();
			var b2:b2Body=contact.GetFixtureB().GetBody();
			//
			_worldManifold||=new b2WorldManifold();
			contact.GetWorldManifold(_worldManifold);
			var ny:Number=_worldManifold.m_normal.y; if(b2!=_body)ny=-ny;
			if(ny>0.7){}else{
				contact.SetEnabled(false);
			}
		}
		
		protected function syncView():void{
			if(!_clip)return;
			var pos:b2Vec2=_body.GetPosition();
			_clip.x=pos.x*MyData.ptm_ratio;
			_clip.y=pos.y*MyData.ptm_ratio;
		}
		
		override protected function update():void{
			if(isKinematic()){
				syncView();
				ai();
			}
		}
		
		protected function ai():void{
			if(!_isGotoEnd){
				_isGotoEnd=gotoPoint(_isOpen?_maxPos:_minPos);
				if(_isGotoEnd){
					playOrStopSound(true);
					if(_type==AUTO)control(true);
				}
			}
			
			_vx=_body.GetPosition().x-_lastPos.x;
			_vy=_body.GetPosition().y-_lastPos.y;
			_lastPos.x=_body.GetPosition().x;
			_lastPos.y=_body.GetPosition().y;
		}
		
		protected function gotoPoint(pos:b2Vec2):Boolean{
			var dx:Number=(pos.x-_body.GetPosition().x)*MyData.ptm_ratio;
			var dy:Number=(pos.y-_body.GetPosition().y)*MyData.ptm_ratio;
			var c:Number=Math.sqrt(dx*dx+dy*dy);
			if(c>_speed){
				var angleRadian:Number=Math.atan2(dy,dx);
				var vx:Number=Math.cos(angleRadian)*_speed;
				var vy:Number=Math.sin(angleRadian)*_speed;
				_body.SetLinearVelocity(new b2Vec2(vx,vy));
				_body.SetAwake(true);
			}else{
				_body.SetLinearVelocity(new b2Vec2(0,0));
				_body.SetPosition(pos);
				return true;
			}
			return false;
		}
		
		override protected function open():void {
			if(_isOpen)return;
			_isOpen=true;
			_isGotoEnd=false;
			playOrStopSound(false);
		}
		
		override protected function close():void {
			if(!_isOpen)return;
			_isOpen=false;
			_isGotoEnd=false;
			playOrStopSound(false);
		}
		
		protected function playOrStopSound(isStop:Boolean):void{
			if(_type==AUTO)return;
			var key:String="Sound_platform";
			var si:SoundInstance=_game.global.soundMan.getSoundInstance(key);
			if(isStop){
				si&&si.stop();
			}else{
				if(si&&si.isPlaying){}else{
					_game.global.soundMan.playLoop(key);
				}
			}
		}
		
		override protected function onDestroy():void {
			playOrStopSound(true);
			if(_body)_body.Destroy();
			FuncUtil.removeChild(_clip);
			_clip=null;
			_body=null;
			_minPos=null;
			_maxPos=null;
			_worldManifold=null;
			super.onDestroy();
		}
		
		public function get vx():Number{return _vx;}
		public function get vy():Number{return _vy;}
		
		
	};

}