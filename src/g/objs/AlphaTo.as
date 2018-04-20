package g.objs{
	import fl.transitions.Tween;
	import fl.transitions.TweenEvent;
	import fl.transitions.easing.None;
	import framework.events.FrameworkEvent;
	import framework.game.Game;
	import framework.objs.GameObject;
	
	public class AlphaTo extends GameObject{
		
		public static function create(target:*,alphaInit:Number=1,alphaTarget:Number=0,duration:Number=1,
		updateFunc:Function=null,updateParams:Array=null,completeFunc:Function=null,completeParams:Array=null):AlphaTo{
			var game:Game=Game.getInstance();
			var info:*={};
			info.target=target;
			info.alphaInit=alphaInit;
			info.alphaTarget=alphaTarget;
			info.duration=duration;
			info.updateFunc=updateFunc;
			info.updateParams=updateParams;
			info.completeFunc=completeFunc;
			info.completeParams=completeParams;
			return game.createGameObj(new AlphaTo(),info) as AlphaTo;
		}
		
		private var _target:*;
		private var _alphaInit:Number;
		private var _alphaTarget:Number;
		private var _duration:Number;
		private var _updateFunc:Function;
		private var _updateParams:Array;
		private var _completeFunc:Function;
		private var _completeParams:Array;
		private var _tween:Tween;
		
		public function AlphaTo(){
			super();
		}
		
		override protected function init(info:* = null):void{
			super.init(info);
			_target=info.target;
			_alphaInit=info.alphaInit;
			_alphaTarget=info.alphaTarget;
			_duration=info.duration;
			_updateFunc=info.updateFunc;
			_updateParams=info.updateParams;
			_completeFunc=info.completeFunc;
			_completeParams=info.completeParams;
			
			_target.alpha=_alphaInit;
			
			_tween=new Tween(_target,"alpha",None.easeNone,_alphaInit,_alphaTarget,_duration,true);
			_tween.addEventListener(TweenEvent.MOTION_CHANGE,motionChange);
			_tween.addEventListener(TweenEvent.MOTION_FINISH,motionFinish);
			
			_game.addEventListener(FrameworkEvent.PAUSE,pauseOrResumeHandler);
			_game.addEventListener(FrameworkEvent.RESUME,pauseOrResumeHandler);
			
		}
		
		private function pauseOrResumeHandler(e:FrameworkEvent):void{
			if(e.type==FrameworkEvent.PAUSE){
				if(_tween.isPlaying)_tween.stop();
			}else{
				if(_tween.time<_tween.finish)_tween.resume();
			}
		}
		
		private function motionChange(e:TweenEvent):void{
			if(_updateFunc!=null) _updateFunc.apply(null,_updateParams);
		}
		
		private function motionFinish(e:TweenEvent):void{
			if(_completeFunc!=null) _completeFunc.apply(null,_completeParams);
			destroy(this);
		}
		
		override protected function onDestroy():void{
			_tween.stop();
			_tween.removeEventListener(TweenEvent.MOTION_CHANGE,motionChange);
			_tween.removeEventListener(TweenEvent.MOTION_FINISH,motionFinish);
			
			_game.removeEventListener(FrameworkEvent.PAUSE,pauseOrResumeHandler);
			_game.removeEventListener(FrameworkEvent.RESUME,pauseOrResumeHandler);
			
			_target=null;
			_updateFunc=null;
			_updateParams=null;
			_completeFunc=null;
			_completeParams=null;
			_tween=null;
			super.onDestroy();
		}
		
		
		
	};

}