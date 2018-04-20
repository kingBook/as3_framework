package g.particles{
	import framework.game.Game;
	import g.objs.MyObj;
	import flash.geom.Point;
	import framework.utils.Mathk;

	public class ParticleEmitter extends MyObj{
		private var _position:Point;
		private var _particleConfig:ParticleConfig;
		private var _emitInterval:Number;
		private var _radius:Number;
		private var _angleMin:Number;
		private var _angleMax:Number;
		private var _onceEmitParticleNum:Number;
		private var _isEmiting:Boolean;

		public static function create(x_pixel:Number,y_pixel:Number,particleConfig:ParticleConfig,
									  emitInterval:Number=30,emitterRadius_pixel:Number=20,
									  angleRadianMin:Number=0,angleRadianMax:Number=2*Math.PI,onceEmitParticleNum:Number=3):ParticleEmitter{
			var game:Game=Game.getInstance();
			var info:*={};
			info.x=x_pixel;
			info.y=y_pixel;
			info.particleConfig=particleConfig;
			info.emitInterval=emitInterval;
			info.radius=emitterRadius_pixel;
			info.angleMin=angleRadianMin;
			info.angleMax=angleRadianMax;
			info.onceEmitParticleNum=onceEmitParticleNum;
			return game.createGameObj(new ParticleEmitter(),info) as ParticleEmitter;
		}

		override protected function init(info:*=null):void{
			super.init(info);
			_position=new Point(info.x,info.y);
			_particleConfig=info.particleConfig;
			_emitInterval=info.emitInterval;
			_radius=info.radius;
			_angleMin=info.angleMin;
			_angleMax=info.angleMax;
			_onceEmitParticleNum=info.onceEmitParticleNum;
			
		}

		private function emitHandler():void{
			for(var i:int=0;i<_onceEmitParticleNum;i++){
				createParticle();
			}
			scheduleOnce(emitHandler,_emitInterval/1000);
		}

		private function createParticle():void{
			var angle:Number=Math.random()*(_angleMax-_angleMin)+_angleMin;
			var c:Number=Math.random()*_radius;
			var x:Number=_position.x+Math.cos(angle)*c;
			var y:Number=_position.y+Math.sin(angle)*c;
			Particle.create(x,y,angle,_particleConfig);
		}

		public function start():void{
			if(_isEmiting)return;
			_isEmiting=true;
			emitHandler();
		}
		public function stop():void{
			if(!_isEmiting)return;
			_isEmiting=false;
			unschedule(emitHandler);
		}

		override protected function onDestroy():void{
			unschedule(emitHandler);
			_position=null;
			_particleConfig=null;
			super.onDestroy();
		}

		public function set position(value:Point):void{
			_position=value;
		}
		public function get position():Point{
			return _position;
		}


	}
}