package g.objs{
	import Box2D.Dynamics.b2Body;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import framework.game.Game;
	import framework.game.UpdateType;
	import framework.objs.Clip;
	import framework.utils.Box2dUtil;
	import framework.utils.LibUtil;
	import g.MyData;
	import g.fixtures.SwitcherCtrlObj;
	import Box2D.Dynamics.b2World;
	//名称:名称_类型_是否打开_开关名_传送编号
	//teleport_fixed_1_xxx_11
	//teleport_controlled_0_s11_11
	/**传送点*/
	public class Teleport extends SwitcherCtrlObj{
		
		private static const FIXED:String="fixed";//固定一个状态，不存在打开/关闭
		private static const CONTROLLED:String="controlled";//通过controll接口，控制打开/关闭
		
		public static function create(world:b2World,childMc:MovieClip,viewDefName:String,isMovieClipView:Boolean=false,openFrames:Vector.<int>=null,closeFrames:Vector.<int>=null):void{
			var game:Game=Game.getInstance();
			
			var nameList:Array=childMc.name.split("_");
			//for(var i:int=0;i<nameList.length;i++)trace("i:"+i, nameList[i]);
			/*
			 i:0 teleport
			 i:1 controlled
			 i:2 0
			 i:3 s11
			 i:4 11
			*/
			var info:*={};
			info.id=uint(nameList[4]);
			info.type=nameList[1];
			info.isOpen=info.type==CONTROLLED?Boolean(int(nameList[2])):true;
			info.ctrlMySwitcherName=nameList[3];
			var parent:Sprite=game.global.layerMan.items2Layer;
			if(isMovieClipView){
				info.clip=LibUtil.getDefMovie(viewDefName);
				info.clip.x=childMc.x;
				info.clip.y=childMc.y;
				parent.addChild(info.clip);
			}else{
				info.clip=Clip.fromDefName(viewDefName,true,true,parent,childMc.x,childMc.y,true);
			}
			//info.body=Box2dUtil.createCircle(int(childMc.width)>>1,childMc.x,childMc.y,world,MyData.ptm_ratio);
			info.body=Box2dUtil.createBox(childMc.width,childMc.height,childMc.x,childMc.y,world,MyData.ptm_ratio);
			info.closeFrames=closeFrames;
			info.openFrames=openFrames;
			game.createGameObj(new Teleport(),info);
		}
		
		private var _type:String;
		private var _clip:*;//Clip/MovieClip;
		private var _body:b2Body;
		private var _id:uint;//传送门对应的编号
		
		//不可传送状态的帧,长度为2分别是开始，结束帧,如果状态只有一帧则开始和结束都填相同的帧
		private var _closeFrames:Vector.<int>;
		
		//可传送状态的帧,长度为2分别是开始，结束帧,如果状态只有一帧则开始和结束都填相同的帧
		private var _openFrames:Vector.<int>;
		
		public function Teleport(){
			super();
		}
		
		override protected function init(info:* = null):void{
			super.init(info);
			_id=info.id;
			_type=info.type;
			_isOpen=info.isOpen;
			_ctrlMySwitcherName=info.ctrlMySwitcherName;
			_clip=info.clip;
			_body=info.body;
			_body.SetType(b2Body.b2_staticBody);
			_body.SetSensor(true);
			_body.SetUserData({type:"Teleport",thisObj:this});
			_closeFrames=info.closeFrames;
			_openFrames=info.openFrames;
			
			//初始停止在打开/关闭状态的第一帧
			if(_isOpen){
				if(_openFrames) _clip.gotoAndStop(_openFrames[0]);
			}else{
				if(_closeFrames) _clip.gotoAndStop(_closeFrames[0]);
			}
		}
		
		override public function control(isAuto:Boolean=false, isDoOpen:Boolean=false):void{
			if(_type==CONTROLLED){
				_isOpen=!_isOpen;
				
				//跳至状态的第一帧
				var frames:Vector.<int>=_isOpen?_openFrames:_closeFrames;
				if(frames) _clip.gotoAndStop(frames[0]);
			}
		}
		
		override protected function update():void{
			var frames:Vector.<int>=_isOpen?_openFrames:_closeFrames;
			//在打开/关闭状态循环播放
			if(frames && frames[0]!=frames[1]) _clip.gotoAndStop(_clip.currentFrame+1>frames[1] ? frames[0] : _clip.currentFrame+1);
		}
		
		override protected function onDestroy():void{
			if(_clip&&_clip.parent)_clip.parent.removeChild(_clip);
			_body.Destroy();
			super.onDestroy();
		}
		
		public function get id():uint{return _id;}
		public function get isOpen():Boolean{return _isOpen;}
		public function get x():Number{return _body.GetPosition().x*MyData.ptm_ratio;}
		public function get y():Number{return _body.GetPosition().y*MyData.ptm_ratio;}
	};

}