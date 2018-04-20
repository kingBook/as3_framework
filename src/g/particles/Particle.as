package g.particles{
	import flash.utils.getTimer;
	import framework.game.Game;
	import framework.objs.Clip;
	import framework.objs.GameObject;
	import g.objs.DisplayObj;

	public class Particle extends DisplayObj{
		private var _angle:Number;
		private var _moveSpeed:Number;
		private var _life:Number;
		private var _scaleStart:Number;
		private var _scaleEnd:Number;
		private var _time:int;

		public static function create(x:Number,y:Number,angle:Number,particleConfig:ParticleConfig):Particle{
			var game:Game=Game.getInstance();
			var info:*={};
			info.x=x;
			info.y=y;
			info.view=Clip.fromDefName(particleConfig.viewDefName,true);
			info.viewParent=particleConfig.viewParent;
			info.angle=angle;
			info.config=particleConfig;
			return game.createGameObj(new Particle(),info) as Particle;
		}

		override protected function init(info:*=null):void{
			super.init(info);
			_angle=info.angle;
			var config:ParticleConfig=info.config;
			_moveSpeed=config.moveSpeed;
			_life=Math.random()*(config.lifeMax-config.lifeMin)+config.lifeMin;
			_scaleStart=config.scaleStart;
			_scaleEnd=config.scaleEnd;
			if(_view){
				_view.rotation=_angle*180/Math.PI;
			}
			_time=getTimer();
		}

		override protected function update():void{
			super.update();
			var isDestroySelf:Boolean=false;
			var tmpLife:int=getTimer()-_time;
			
			if(_view){
				var vx:Number=Math.cos(_angle)*_moveSpeed;
				var vy:Number=Math.sin(_angle)*_moveSpeed;
				_view.x+=vx;
				_view.y+=vy;

				var lifeRadio:Number=Math.min(1,tmpLife/_life);
				var dScale:Number=_scaleEnd-_scaleStart;
				_view.scaleX=_view.scaleY=_scaleStart+dScale*lifeRadio;
			}

			if(tmpLife>=_life){
				isDestroySelf=true;
			}
			if(isDestroySelf){
				GameObject.destroy(this);
			}
		}

		override protected function onDestroy():void{
			super.onDestroy();
		}
	}
}