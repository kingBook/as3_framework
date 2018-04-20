package g.objs{
	import g.objs.MovableObject;
	import g.components.TwoPtMotionBehavior;
	import g.objs.Delayer;
	import g.events.MyEvent;
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.Contacts.b2Contact;
	import Box2D.Collision.b2Manifold;
	import Box2D.Dynamics.b2Body;
	import flash.utils.Dictionary;
	import framework.objs.GameObject;
	/**关卡内保持相同的延时时间一致、两点间自由运动的对象(如自由伸缩的刺、自由伸缩的机关)(延时时间必须大于两点运动的时间) */
	public class SyncDelayTwoPtMotionObj extends MovableObject{

		//为保证同步，所有初始状态一样的都使用同一个delayer,从静态p字典中取出
		//存储格式{1.5:delayer,2.3:delayer}
		//在onDestroyAll时清空释放
		private static var _initOutDict:Dictionary;
		private static var _initNotOutDict:Dictionary;

		private var _twoPtBehavior:TwoPtMotionBehavior;
		private var _offWaitDelayer:Delayer;
		private var _onWaitDelayer:Delayer;
		/*public static function create(body:b2Body,dt:Number,viewDefName:String=null):void{
			var game:Game=Game.getInstance();
			var info:*={};
			info.body=body;
			if(viewDefName){
				info.view=Clip.fromDefName(viewDefName,true);
				info.viewParent=game.global.layerMan.items2Layer;
			}
			info.motionDistance=motionDistance;
			info.pos0=pos0;
			info.pos1=pos1;
			info.target=target;
			info.speed=speed;
			info.dt=dt;
			info.offWaitDelay=offWaitDelay;
			info.onWaitDelay=onWaitDelay;
			game.createGameObj(new XXX(),info);
		}*/
		override protected function init(info:*=null):void{
			super.init(info);
			var isInitOut:Boolean=info.target==info.pos1;
			//_offWaitDelayer=createWithDict(info.offWaitDelay,isInitOut);
			//_onWaitDelayer=createWithDict(info.onWaitDelay,isInitOut);
			_offWaitDelayer=Delayer.create(this,info.offWaitDelay,false);
			_onWaitDelayer=Delayer.create(this,info.onWaitDelay,false);

			_twoPtBehavior=TwoPtMotionBehavior.create(this,_body,info.pos0,info.pos1,info.target,info.speed,info.dt);
			
			this.addEventListener(Delayer.EXECUTE,executeHandler);
			this.addEventListener(Delayer.EXECUTE,executeHandler);
		}
		private function createWithDict(delay:Number,isInitOut:Boolean):Delayer{
			var delayer:Delayer;
			if(isInitOut){
				_initOutDict||=new Dictionary();
				delayer=_initOutDict[delay];
				if(delayer==null){
					delayer=Delayer.create(this,delay,false);
					_initOutDict[delay]=delayer;
				}
			}else{
				_initNotOutDict||=new Dictionary();
				delayer=_initNotOutDict[delay];
				delayer=Delayer.create(this,delay,false);
				_initNotOutDict[delay]=delayer;
			}
			return delayer;
		}
		override protected function fixedUpdate():void{
			super.fixedUpdate();
			if(_twoPtBehavior.gotoTarget()){
				if(_twoPtBehavior.isTargetEqualPos0()){
					_offWaitDelayer.startDelayer();
				}else{
					_onWaitDelayer.startDelayer();
				}
			}
		}
		private function executeHandler(e:MyEvent):void{
			_twoPtBehavior.swapTarget();
		}
		public function inAcceptRange(checkPt:b2Vec2):Boolean{
			return _twoPtBehavior.inAcceptRange(checkPt);
		}
		override protected function preSolve(contact:b2Contact,oldManifold:b2Manifold,other:b2Body):void{
			super.preSolve(contact,oldManifold,other);
			if(!inAcceptRange(other.GetPosition())){
				contact.SetSensor(true);
			}
		}
		override protected function onDestroyAll():void{
			var key:*;
			if(_initOutDict){
				for(key in _initOutDict){
					GameObject.destroy(_initOutDict[key]);
					delete _initOutDict[key];
				}
				_initOutDict=null;
			}
			if(_initNotOutDict){
				for(key in _initNotOutDict){
					GameObject.destroy(_initNotOutDict[key]);
					delete _initNotOutDict[key];
				}
				_initNotOutDict=null;
			}
			super.onDestroyAll();
		}
		override protected function onDestroy():void{
			this.removeEventListener(Delayer.EXECUTE,executeHandler);
			this.removeEventListener(Delayer.EXECUTE,executeHandler);
			removeComponent(_twoPtBehavior);
			_twoPtBehavior=null;
			_offWaitDelayer=null;
			_onWaitDelayer=null;
			super.onDestroy();
		}
		public function get isOuting():Boolean{
			return !_twoPtBehavior.isTargetEqualPos0();
		}
	}
}