package g.fixtures{
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.b2Body;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import framework.events.FrameworkEvent;
	import framework.game.Game;
	import framework.objs.Clip;
	import framework.utils.Box2dUtil;
	import framework.utils.FuncUtil;
	import g.MyData;
	import Box2D.Dynamics.b2World;
	//名称: switcherMovieTwoClip_开关名_颜色_是否伸出
	//switcherMovieTwoClip_s11_red_1
	public class SwitcherMovieTwoClip extends SwitcherMovie{
		private var _clipAMask:Sprite;
		private var _clipA:Clip;//主体
		private var _clipB:Clip;//底座
		
		public function SwitcherMovieTwoClip(){ super(); }
		
		static public function create(childMc:MovieClip,world:b2World):void{
			var angleRadian:Number=childMc.rotation*0.01745;
			var w:Number=FuncUtil.getTransformWidth(childMc);
			var h:Number=FuncUtil.getTransformHeight(childMc);
			var body:b2Body=Box2dUtil.createBox(w,h,childMc.x,childMc.y,world,MyData.ptm_ratio);
			body.SetAngle(angleRadian);
			
			var nameList:Array=childMc.name.split("_");
			//for(var i:int=0;i<nameList.length;i++)trace("i:"+i,nameList[i]);
			/*
			 i:0 switcherMovieTwoClip
			 i:1 s11
			 i:2 red
			 i:3 1
			 */
			
			var parent:Sprite=Game.getInstance().global.layerMan.items3Layer;
			var color:String=nameList[2];
			var clipA:Clip=Clip.fromDefName("SwitcherMovieTwoClipA_"+color,true,true,parent);
			clipA.transform.matrix=childMc.transform.matrix;
			var clipB:Clip=Clip.fromDefName("SwitcherMovieTwoClipB_"+color,true,true,parent);
			clipB.transform.matrix=childMc.transform.matrix;
			
			var maskW:Number=w+4; var maskH:Number=h+4;
			var clipAMask:Sprite=new Sprite();
			clipAMask.graphics.beginFill(0,1);
			clipAMask.graphics.drawRect(-maskW*0.5,-maskH*0.5,maskW,maskH);
			clipAMask.graphics.endFill();
			clipAMask.x=childMc.x,clipAMask.y=childMc.y,clipAMask.rotation=childMc.rotation;
			parent.addChild(clipAMask);
			
			Game.getInstance().createGameObj(new SwitcherMovieTwoClip(),{
				body:body,
				long:w,
				clipA:clipA,
				clipB:clipB,
				clipAMask:clipAMask,
				ctrlMySwitcherName:nameList[1],
				isOpen:Boolean(int(nameList[3]))
			});
		}
		
		override protected function init(info:*=null):void{
			super.init(info);
			_clipA=info.clipA;
			_clipB=info.clipB;
			_clipAMask=info.clipAMask;
			
			_clipB.x=_botPos.x*MyData.ptm_ratio;
			_clipB.y=_botPos.y*MyData.ptm_ratio;
			_clipA.mask=_clipAMask;
			syncClipA();
		}
		
		private function syncClipA():void{
			var pos:b2Vec2=_body.GetPosition();
			_clipA.x=pos.x*MyData.ptm_ratio;
			_clipA.y=pos.y*MyData.ptm_ratio;
		}
		
		override protected function updateProgress():void{
			syncClipA();
		}
		
		override protected function onDestroy():void{
			if(_clipA&&_clipA.parent)_clipA.parent.removeChild(_clipA);
			if(_clipB&&_clipB.parent)_clipB.parent.removeChild(_clipB);
			if(_clipAMask&&_clipAMask.parent)_clipAMask.parent.removeChild(_clipAMask);
			_clipAMask=null;
			_clipA=null;
			_clipB=null;
			super.onDestroy();
		}
		
	};

}