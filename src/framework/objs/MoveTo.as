package framework.objs{
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.b2Body;
	import fl.transitions.Tween;
	import fl.transitions.TweenEvent;
	import fl.transitions.easing.None;
	import flash.geom.Point;
	import framework.events.FrameworkEvent;
	import framework.game.Game;
	import framework.objs.GameObject;
	public class MoveTo extends ActionToObj{
		
		public static function create(target:*,targetX:Number,targetY:Number,duration:Number,
		onComplete:Function=null,onCompleteParams:Array=null,
		onUpdate:Function=null,onUpdateParams:Array=null):MoveTo{
			var game:Game=Game.getInstance();
			var info:*={};
			info.target=target;
			info.targetX=targetX;
			info.targetY=targetY;
			info.duration=duration;
			info.onComplete=onComplete;
			info.onCompleteParams=onCompleteParams;
            info.onUpdate=onUpdate;
            info.onUpdateParams=onUpdateParams;
			return game.createGameObj(new MoveTo(),info) as MoveTo;
		}
		
		public function MoveTo(){ super(); }
		
		private var _target:*;
		private var _runtimeTarget:Point;
		private var _targetPos:Point;
		private var _duration:Number;
		private var _onComplete:Function;
		private var _onCompleteParams:Array;
        private var _onUpdate:Function;
		private var _onUpdateParams:Array;
		
		private var _xTween:Tween;
		private var _yTween:Tween;
		
		override protected function init(info:*=null):void{
			_target=info.target;
			_targetPos=new Point(info.targetX,info.targetY);
			_duration=info.duration;
			_onComplete=info.onComplete;
			_onCompleteParams=info.onCompleteParams;
            _onUpdate=info.onUpdate;
            _onUpdateParams=info.onUpdateParams;
			
			//起点
			_runtimeTarget=new Point(getX(),getY());

            _xTween=new Tween(_runtimeTarget,"x",None.easeNone,_runtimeTarget.x,_targetPos.x,_duration,true);
            _yTween=new Tween(_runtimeTarget,"y",None.easeNone,_runtimeTarget.y,_targetPos.y,_duration,true);
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
			setPos(_runtimeTarget.x,_runtimeTarget.y);
			if(_onUpdate!=null) _onUpdate.apply(null,_onUpdateParams);
		}
		
		private function motionFinish(e:TweenEvent):void{
			setPos(_runtimeTarget.x,_runtimeTarget.y);
			if(_onComplete!=null) _onComplete.apply(null,_onCompleteParams);
			destroy(this);
		}
		
		private function getX():Number{
			var x:Number;
			if(_target is b2Body)x=_target.GetPosition().x;
			else x=_target.x;
			return x;
		}
		private function getY():Number{
			var y:Number;
			if(_target is b2Body)y=_target.GetPosition().y;
			else y=_target.y;
			return y;
		}
		
		private function setPos(x:Number,y:Number):void{
			if(_target is b2Body){
				_target.SetPosition(b2Vec2.MakeOnce(x,y));
			}else{
				_target.x=x;
				_target.y=y;
			}
		}
		
		override protected function onDestroy():void{
			_game.removeEventListener(FrameworkEvent.PAUSE,pauseOrResumeHandler);
			_game.removeEventListener(FrameworkEvent.RESUME,pauseOrResumeHandler);
			
			_xTween.stop();
			_yTween.stop();
			_yTween.removeEventListener(TweenEvent.MOTION_CHANGE,motionChange);
			_yTween.removeEventListener(TweenEvent.MOTION_FINISH,motionFinish);
			_xTween=null;
			_yTween=null;
			
			_target=null;
			_runtimeTarget=null;
			_targetPos=null;
			
            _onComplete=null;
            _onCompleteParams=null;
            _onUpdate=null;
            _onUpdateParams=null;
			super.onDestroy();
		}
		
	};

}