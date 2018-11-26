package g.objs{
	import flash.display.DisplayObjectContainer;
	import framework.objs.AlphaTo;
	import framework.objs.MoveTo;
	import framework.utils.LibUtil;
	import g.objs.DisplayObj;
	import framework.game.Game;
	import framework.objs.Clip;
	
	public class FloatClipEffect extends DisplayObj{
		
		private var _moveTo:MoveTo;
		private var _alphaTo:AlphaTo;
		private var _offsetTopY:Number;
		private var _stayTime:Number;
		/**
		 * 
		 * @param	x
		 * @param	y
		 * @param	stopFrame
		 * @param	parent
		 * @param	defName
		 * @param	scale
		 * * @param	offsetTopY 向上漂动的距离
		 */
		public static function create(x:Number,y:Number,stopFrame:int,parent:DisplayObjectContainer=null,defName:String="NumberMc_view",scale:Number=1,offsetTopY:Number=100,isClip:Boolean=true,stayTime:Number=1):FloatClipEffect{
			var game:Game=Game.getInstance();
			
			if(defName=="NumberMc_view"){
				game.global.soundMan.play("Sound_num"+stopFrame);
			}
			
			var clip:*;
			if(isClip)clip=Clip.fromDefName(defName,true);
			else clip=LibUtil.getDefMovie(defName);
			
			clip.mouseEnabled=false;
			clip.mouseChildren=false;
			
			clip.scaleX=scale;
			clip.scaleY=scale;
			if(parent==null)parent=game.global.layerMan.effLayer;
			
			var info:*={};
			info.x=x;
			info.y=y;
			info.view=clip;
			info.viewParent=parent;
			info.stopFrame=stopFrame
			info.offsetTopY=offsetTopY;
			info.stayTime=stayTime;
			return game.createGameObj(new FloatClipEffect(),info) as FloatClipEffect;
		}
		
		public function FloatClipEffect(){
			super();
		}
		
		override protected function init(info:*=null):void{
			super.init(info);
			_offsetTopY=info.offsetTopY;
			_stayTime=info.stayTime;
			Object(_view).gotoAndStop(info.stopFrame);
			_moveTo=MoveTo.create(_view,_view.x,_view.y-_offsetTopY,0.5,onMoveToComplete);
		}
		
		private function onMoveToComplete():void{
			scheduleOnce(onScheduleComplete,_stayTime);
		}
		
		private function onScheduleComplete():void{
			_alphaTo=AlphaTo.create(_view,1,0,0.5,null,null,onAlphaToComplete);
		}
		
		private function onAlphaToComplete():void{
			if(_onCompleteCB!=null)_onCompleteCB();
			destroy(this);
		}
		
		private var _onCompleteCB:Function;
		public function setOnComplete(value:Function):void{
			_onCompleteCB=value;
		}
		
		override protected function onDestroy():void{
			unschedule(onScheduleComplete);
			destroy(_alphaTo);
			destroy(_moveTo);
			_moveTo=null;
			_alphaTo=null;
			super.onDestroy();
		}
		
		public function get clip():*{return _view;}
		
	};
}