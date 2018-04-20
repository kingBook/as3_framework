package g.fixtures {
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
	//名称: switcherMovieOneClip_开关名_颜色_是否伸出
	//switcherMovieOneClip_s11_red_1
	public class SwitcherMovieOneClip extends SwitcherMovie{
		private var _clip:Clip;
		private var _maskSp:Sprite;
		
		public function SwitcherMovieOneClip() { super(); }
		
		static public function create(childMc:MovieClip,world:b2World):void{
			var angleRadian:Number=childMc.rotation*0.01745;
			var w:Number=FuncUtil.getTransformWidth(childMc);
			var h:Number=FuncUtil.getTransformHeight(childMc);
			var body:b2Body=Box2dUtil.createBox(w,h,childMc.x,childMc.y,world,MyData.ptm_ratio);
			body.SetAngle(angleRadian);
			
			var nameList:Array=childMc.name.split("_");
			//for(var i:int=0;i<nameList.length;i++)trace("i:"+i,nameList[i]);
			/*
			 i:0 switcherMovieOneClip
			 i:1 s11
			 i:2 red
			 i:3 1
			 */
			var parent:Sprite=Game.getInstance().global.layerMan.items3Layer;
			var color:String=nameList[2];
			var clip:Clip=Clip.fromDefName("SwitcherMovieOneClip_"+color,true,true,parent);
			clip.transform.matrix=childMc.transform.matrix;
			
			var maskW:Number=w+2; var maskH:Number=h+20;
			var maskSp:Sprite=new Sprite();
			maskSp.graphics.beginFill(0,1);
			maskSp.graphics.drawRect(-maskW*0.5,-maskH*0.5,maskW,maskH);
			maskSp.graphics.endFill();
			maskSp.x=childMc.x,
			maskSp.y=childMc.y,
			maskSp.rotation=childMc.rotation;
			parent.addChild(maskSp);
			
			Game.getInstance().createGameObj(new SwitcherMovieOneClip(),{
				body:body,
				long:w,
				clip:clip,
				maskSp:maskSp,
				ctrlMySwitcherName:nameList[1],
				isOpen:Boolean(int(nameList[3]))
			});
		}
		
		override protected function init(info:*=null):void {
			super.init(info);
			_clip=info.clip;
			_clip.controlled=true;
			_clip.gotoAndStop(_isOpen?_clip.totalFrames:1);
			_maskSp=info.maskSp;
			_clip.mask=_maskSp;
		}
		
		override protected function updateProgress():void {
			var d:Number=b2Vec2.Distance(_body.GetPosition(),_isOpen?_maxPos:_minPos);
			var rate:Number=d/_long; if(_isOpen)rate=1-rate;
			var frame:Number=int(_clip.totalFrames*rate);
			if(frame<1)frame=1; else if(frame>_clip.totalFrames)frame=_clip.totalFrames;
			_clip.gotoAndStop(frame);
		}
		
		override protected function onDestroy():void {
			if(_clip&&_clip.parent)_clip.parent.removeChild(_clip);
			if(_maskSp&&_maskSp.parent)_maskSp.parent.removeChild(_maskSp);
			_clip=null;
			_maskSp=null;
			super.onDestroy();
		}
		
	};

}