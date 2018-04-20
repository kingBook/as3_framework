package g.objs {
	import Box2D.Collision.b2Manifold;
	import Box2D.Collision.b2WorldManifold;
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.Contacts.b2Contact;
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.b2Fixture;
	import flash.display.MovieClip;
	import framework.game.Game;
	import framework.events.FrameworkEvent;
	import framework.objs.Clip;
	import framework.objs.GameObject;
	import framework.utils.Box2dUtil;
	import framework.utils.FuncUtil;
	import g.objs.Animator;
	import g.MyData;
	import Box2D.Dynamics.b2World;
	
	/**
	 * 破碎的砖块
	 * @author kingBook
	 * 2015/6/15 16:50
	 */
	public class BrokenBrick extends GameObject {
		/**激活对象列表*/
		static private var _activeObjs:Vector.<GameObject>=new Vector.<GameObject>();
		/**添加激活对象*/
		static public function AddActiveObj(obj:GameObject):void{
			if(_activeObjs.indexOf(obj)<0) _activeObjs.push(obj);
		}
		/**移除激活对象*/
		static public function RemoveActiveObj(obj:GameObject):void{
			var id:int=_activeObjs.indexOf(obj);
			if(id>-1) _activeObjs.splice(id,1);
		}
		
		public function BrokenBrick() {
			super();
		}
		
		private function destroyAll(e:FrameworkEvent):void{
			e.target.removeEventListener(FrameworkEvent.DESTROY_ALL,destroyAll);
			_activeObjs.splice(0,_activeObjs.length);
		}
		
		public static function create(childMc:MovieClip,world:b2World):void{
			var game:Game=Game.getInstance();
			var body:b2Body=Box2dUtil.createBox(childMc.width,childMc.height,childMc.x,childMc.y,world,MyData.ptm_ratio);
			var info:*={};
			info.isForeverDestroy=true;
			info.body=body;
			info.isTwoView=true;
			info.isOneWay=true;
			game.createGameObj(new BrokenBrick(),info);
		}
		
		private var _isTwoView:Boolean;
		private var _isOneWay:Boolean;
		private var _isForeverDestroy:Boolean;
		
		private var _body:b2Body;
		
		private var _animator:Animator;
		private var _standardClip:Clip;
		private var _disappearClip:Clip;
		
		override protected function init(info:* = null):void{
			_isTwoView=info.isTwoView;
			_isOneWay=info.isOneWay;
			_isForeverDestroy=info.isForeverDestroy;
			
			_body = info.body;
			_body.SetType(b2Body.b2_staticBody);
			_body.SetUserData({thisObj:this, type:"BrokenBrick"});
			_body.SetPreSolveCallback(preSolve);
			
			_standardClip=Clip.fromDefName("BrokenBrick_view_1");
			
			if(_isTwoView){
				_animator = Animator.create(_game.global.layerMan.items2Layer);
				//
				_animator.addAnimation("standard", _standardClip);
				//
				var clip:Clip = Clip.fromDefName("BrokenBrick_view_2");
				clip.addFrameScript(clip.totalFrames-1,function ():void {
					clip.stop();
				});
				clip.addFrameScript(0,function ():void {
					clip.play();
				});
				_disappearClip = clip;
				_animator.addAnimation("disappear", clip);
				//
				_animator.setDefaultAnimation("standard");
				_animator.addTransitionCondition(null, "standard", function():Boolean { return _body&&_body.IsActive(); } );
				_animator.addTransitionCondition(null, "disappear", function():Boolean { return _body&&!_body.IsActive(); } );
			}else{
				_standardClip.x=_body.GetPosition().x*MyData.ptm_ratio;
				_standardClip.y=_body.GetPosition().y*MyData.ptm_ratio;
				
				_game.global.layerMan.items1Layer.addChild(_standardClip);
			}
			syncView();
			_game.addEventListener(FrameworkEvent.DESTROY_ALL,destroyAll);
		}
		
		private function fixtureIsBodyFoot(fixture:b2Fixture,b:b2Body):Boolean{
			var y0:Number=fixture.GetAABB().upperBound.y;
			var f:b2Fixture=b.GetFixtureList();
			var y1:Number;
			for(f;f;f=f.GetNext()){
				y1=f.GetAABB().upperBound.y;
				if(Math.abs(y1-y0)<0.001)return true;
			}
			return false;
		}
		
		private var _worldManifold:b2WorldManifold=new b2WorldManifold();
		private function preSolve(contact:b2Contact,oldManifold:b2Manifold):void{
			if(!contact.IsTouching())return;
			var b1:b2Body=contact.GetFixtureA().GetBody();
			var b2:b2Body=contact.GetFixtureB().GetBody();
			var ob:b2Body=b1==_body?b2:b1;
			var oFixture:b2Fixture=b1==ob?contact.GetFixtureA():contact.GetFixtureB();
			var oUserData:*=ob.GetUserData();
			var othis:*=oUserData.thisObj;
			
			contact.GetWorldManifold(_worldManifold);
			
			var ny:Number=_worldManifold.m_normal.y;if(ob!=b1)ny=-ny;
			//var top_y:Number=Number(_body.GetFixtureList().GetAABB().lowerBound.y.toFixed(1));
			//var hit_y:Number=Number(_worldManifold.m_points[0].y.toFixed(1));
			if(ny>0.8){
				if(othis && _activeObjs.indexOf(othis)>-1){
					var vy:int=int(ob.GetLinearVelocity().y);
					if(vy>=0){
						delayBroken();
					}
				}
			}else{
				contact.SetEnabled(false);
			}
			
		}
		
		private function syncView():void {
			var pos:b2Vec2=_body.GetPosition();
			if(_animator){
				_animator.x = pos.x*MyData.ptm_ratio;
				_animator.y = pos.y*MyData.ptm_ratio;
			}
		}
		
		private var _isBrokening:Boolean;
		/**延时破碎接口（外部调用）*/
		public function delayBroken():void {
			if(_isBrokening)return;
			_isBrokening = true;
			scheduleOnce(broken,0.5);
		}
		
		/**破碎*/
		private function broken():void {
			_body.SetActive(false);
			if(!_isTwoView) _standardClip.visible=false;
			
			//如果不是永远消除则重建
			if(!_isForeverDestroy) scheduleOnce(resume,2)
		}
		
		private function resume():void{
			_isBrokening = false;
			_body.SetActive(true);
			if(_isTwoView)_disappearClip.gotoAndStop(1);
			else _standardClip.visible=true;
		}
		
		override protected function onDestroy():void {
			if(_animator){
				GameObject.destroy(_animator);
				_animator=null;
			}
			unschedule(broken);
			unschedule(resume);
			if(_body)_body.Destroy();
			FuncUtil.removeChild(_standardClip);
			FuncUtil.removeChild(_disappearClip);
			_body = null;
			_standardClip = null;
			_disappearClip = null;
			super.onDestroy();
		}
	}

}