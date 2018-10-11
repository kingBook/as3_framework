package framework.objs{
	import fl.transitions.Tween;
	import fl.transitions.TweenEvent;
	import fl.transitions.easing.None;
	import framework.events.FrameworkEvent;
    import framework.objs.GameObject;
    import framework.game.Game;
    import g.MyData;

    public class ScaleTo extends ActionToObj{
        private var _v:Number;
		private var _target:*;
		private var _scaleInit:Number;
		private var _scaleTarget:Number;
		private var _duration:Number;
		private var _updateFunc:Function;
		private var _updateParams:Array;
		private var _completeFunc:Function;
		private var _completeParams:Array;
		private var _xTween:Tween;
		private var _yTween:Tween;
		
        public function ScaleTo(){
            super();
        }
        public static function create(target:*,scaleInit:Number=1,scaleTarget:Number=0,duration:Number=1,
		onComplete:Function=null,onCompleteParams:Array=null,
		onUpdate:Function=null,onUpdateParams:Array=null):ScaleTo{
			var game:Game=Game.getInstance();
			var info:*={};
			info.target=target;
			info.scaleInit=scaleInit;
			info.scaleTarget=scaleTarget;
			info.duration=duration;
			info.onComplete=onComplete;
			info.onCompleteParams=onCompleteParams;
            info.onUpdate=onUpdate;
            info.onUpdateParams=onUpdateParams;
			return game.createGameObj(new ScaleTo(),info) as ScaleTo;
		}
        override protected function init(info:* = null):void{
			super.init(info);
			_target=info.target;
			_scaleInit=info.scaleInit;
			_scaleTarget=info.scaleTarget;
			_duration=info.duration;
			_updateFunc=info.onUpdate;
			_updateParams=info.onUpdateParams;
			_completeFunc=info.onComplete;
			_completeParams=info.onCompleteParams;
			
			_v=(_scaleTarget-_scaleInit)/(_duration*MyData.frameRate);
			_target.scaleX=_target.scaleY=_scaleInit;
			
			
			_xTween=new Tween(_target,"scaleX",None.easeNone,_scaleInit,_scaleTarget,_duration,true);
			_yTween=new Tween(_target,"scaleY",None.easeNone,_scaleInit,_scaleTarget,_duration,true);
			_yTween.addEventListener(TweenEvent.MOTION_CHANGE,motionChange);
			_yTween.addEventListener(TweenEvent.MOTION_FINISH,motionFinish);
			
			_game.addEventListener(FrameworkEvent.PAUSE,pauseOrResumeHandler);
			_game.addEventListener(FrameworkEvent.RESUME,pauseOrResumeHandler);
			
		}
		
		private function pauseOrResumeHandler(e:FrameworkEvent):void{
			if(e.type==FrameworkEvent.PAUSE){
				if(_xTween.isPlaying)_xTween.stop();
				if(_yTween.isPlaying)_yTween.stop();
			}else{
				if(_xTween.time<_xTween.finish)_xTween.resume();
				if(_yTween.time<_yTween.finish)_xTween.resume();
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
			_game.removeEventListener(FrameworkEvent.PAUSE,pauseOrResumeHandler);
			_game.removeEventListener(FrameworkEvent.RESUME,pauseOrResumeHandler);
			_xTween.stop();
			_yTween.stop();
			_yTween.removeEventListener(TweenEvent.MOTION_CHANGE,motionChange);
			_yTween.removeEventListener(TweenEvent.MOTION_FINISH,motionFinish);
			_target=null;
			_updateFunc=null;
			_updateParams=null;
			_completeFunc=null;
			_completeParams=null;
			_xTween=null;
			_yTween=null;
			super.onDestroy();
		}
		
    }
}