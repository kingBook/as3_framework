package g.components{
	import Box2D.Collision.b2AABB;
	import Box2D.Collision.b2Manifold;
	import Box2D.Collision.b2WorldManifold;
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.Contacts.b2Contact;
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.b2Fixture;
	import framework.objs.Component;
	import framework.system.KeyboardManager;
	import framework.utils.Box2dUtil;
	import g.MyData;
	/*
	 //使用方法：
	 private var _climbBehavior:ClimbLadderBehavior;
	 override protected function init(info:* = null):void{
	 	_climbBehavior=addComponent(ClimbLadderBehavior) as ClimbLadderBehavior;
	 	_climbBehavior.initialize(_body,km,upKeys,leftKeys,rightKeys,downKeys);
	 }
	 private function preSolve(contact:b2Contact, oldManifold:b2Manifold):void{
	 	_climbBehavior.preSolve(contact,oldManifold);
	 }
	 override protected function onDestroy():void{
	 	removeComponent(_climbBehavior);
	 	_climbBehavior=null;
	 	super.onDestroy();
	 }
	*/
	/**爬梯子行为*/
	public class ClimbLadderBehavior extends Component{
		private const _ladderType:String="Ladder";
		private const _groundTypes:Vector.<String>=new <String>["Ground"];
		
		private var _body:b2Body;
		private var _km:KeyboardManager;
		private var _isClimbing:Boolean;
		private var _worldManifold:b2WorldManifold=new b2WorldManifold();
		private var _upKeys:Vector.<String>;
		private var _leftKeys:Vector.<String>;
		private var _rightKeys:Vector.<String>;
		private var _downKeys:Vector.<String>;
		private var _speed:Number=2;
		
		private var _ladderX:Number;
		private var _ladderY:Number;
		private var _climbMinX:Number;
		private var _climbMaxX:Number;
		private var _isSensorLadder:Boolean=false;
		private var _isSensorGround:Boolean=false;
		
		public function ClimbLadderBehavior(){
			super();
		}
		
		public function initialize(body:b2Body,km:KeyboardManager,upKeys:Vector.<String>,leftKeys:Vector.<String>,rightKeys:Vector.<String>,downKeys:Vector.<String>,sleepingAllowed:Boolean=false):void{
			_body=body;
			_body.SetSleepingAllowed(sleepingAllowed);
			_km=km;
			_upKeys=upKeys;
			_leftKeys=leftKeys;
			_rightKeys=rightKeys;
			_downKeys=downKeys;
		}
		
		private var _ladderEnabledCallback:Function=null;
		/**func=function(ladderBody:b2Body):Boolean; 默认返回true*/
		public function setLadderEnabledCallback(func:Function):void{
			_ladderEnabledCallback=func;
		}
		
		/**外部调用实现*/
		public function preSolve(contact:b2Contact,oldManifold:b2Manifold):void{
			if(!contact.IsTouching())return;
			var b1:b2Body=contact.GetFixtureA().GetBody();
			var b2:b2Body=contact.GetFixtureB().GetBody();
			var ob:b2Body=b1==_body?b2:b1;
			var oType:String=ob.GetUserData().type;
			contact.GetWorldManifold(_worldManifold);
			var ny:Number=_worldManifold.m_normal.y; if(b1!=_body)ny=-ny;
			
			if(oType == _ladderType){
				//爬到梯子顶部，恢复和梯子的碰撞
				var vy:int=int(_body.GetLinearVelocity().y);
				var enabled:Boolean=true;
				enabled&&=ny>0.9&&vy>=0;
				enabled&&=!_km.p_keys(_downKeys)&&!_isClimbing;
				
				if(_ladderEnabledCallback!=null){
					var isEnabledLadder:Boolean=_ladderEnabledCallback(ob);
					if(!isEnabledLadder)contact.SetSensor(true);
					enabled||=!isEnabledLadder;
				}
				contact.SetEnabled(enabled);
				// check is sensor ladder
				_isSensorLadder||=getIsSensorLadder(contact,ob);
			}else if(_groundTypes.indexOf(oType)>-1){
				if(ny>0.9){
					var nextBottomHasLadder:b2Body=getNextBottomHasLadder();//预判下方是否有梯子
					if(_isClimbing){
						if(!nextBottomHasLadder){
							_isClimbing=false;
							contact.SetEnabled(true);
							_body.SetCustomGravity(null);
						}else{
							contact.SetEnabled(false);//忽略与地面的碰撞
						}
					}else{
						//从地面下梯子
						if(_km.p_keys(_downKeys)){
							if(nextBottomHasLadder){
								var ladderAABB:b2AABB=nextBottomHasLadder.GetAABB();
								var myAABB:b2AABB=_body.GetAABB();
								var isOnLadderRange:Boolean=myAABB.lowerBound.x>=ladderAABB.lowerBound.x && myAABB.upperBound.x<=ladderAABB.upperBound.x;//左右范围在梯子内
								if(isOnLadderRange){
									contact.SetEnabled(false);
									Box2dUtil.setContactBodiesAwake(_body,true);
									_isClimbing=true;
									_body.SetCustomGravity(new b2Vec2(0,0));//必须设置，否则从地面下梯子不按下键也下滑
								}
							}
						}
					}
				}else if(_isClimbing){
					contact.SetEnabled(false);
				}
				// check is sensor ground
				_isSensorGround||=getIsSensorGround(contact,ob);
			}
		}
		
		/**预判下方是否有梯子*/
		private function getNextBottomHasLadder():b2Body{
			var bounds:b2AABB=_body.GetAABB();
			var w:Number=bounds.GetExtents().x*2;
			var h:Number=4/MyData.ptm_ratio;
			var cx:Number=bounds.GetCenter().x;
			var cy:Number=(bounds.upperBound.y+h*0.5)+6/MyData.ptm_ratio;//向下偏移
			var aabb:b2AABB=b2AABB.MakeWH(w,h,cx,cy);
			return getAABBHasType(_ladderType,aabb);
		}
		
		private function getAABBHasType(type:String,aabb:b2AABB):b2Body{
			var result:b2Body=null;
			function cb(fixture:b2Fixture):Boolean{
				var otype:String=fixture.GetBody().GetUserData().type;
				if(otype==type){
					result=fixture.GetBody();
					return false;
				}
				return true;
			}
			_body.GetWorld().QueryAABB(cb,aabb);
			return result;
		}
		
		private function getIsSensorLadder(contact:b2Contact,other:b2Body):Boolean{
			if(contact.IsEnabled())return false;
			var offset:Number=other.GetFixtureList().GetAABB().GetExtents().x*0.9;
			var minX:Number=other.GetPosition().x-offset;
			var maxX:Number=other.GetPosition().x+offset;
			if(_body.GetPosition().x>=minX && _body.GetPosition().x<=maxX){
				_ladderX=other.GetPosition().x;
				_ladderY=other.GetPosition().y;
				_climbMinX=minX;
				_climbMaxX=maxX;
				return true;
			}
			return false;
		}
		
		private function getIsSensorGround(contact:b2Contact,other:b2Body):Boolean{
			if(contact.IsEnabled())return false;
			return true;
		}
		
		/**外部调用更新*/
		override protected function update():void{
			if(_isSensorLadder){
				var pUp:Boolean=_km.p_keys(_upKeys);
				var pDown:Boolean=_km.p_keys(_downKeys);
				var pLeft:Boolean=_km.p_keys(_leftKeys);
				var pRight:Boolean=_km.p_keys(_rightKeys);
				var px:Number=_body.GetPosition().x;
				var py:Number=_body.GetPosition().y;
				var vx:Number=_body.GetLinearVelocity().x;
				var vy:Number=_body.GetLinearVelocity().y;
				
				//设置y方向: dirY
				var dirY:int=0;
				if(pUp)dirY=-1;
				else if(pDown)dirY=1;
				else dirY=0;
				
				//设置x方向：dirX
				var dirX:int=0;
				if(pLeft)dirX=-1;
				else if(pRight)dirX=1;
				else dirX=0;
				
				if(!_isClimbing){
					//在梯子的中下方按上键爬梯子/在梯子中上方按下键爬梯子，避免在梯子中下方跳飞过不按键也爬
					if(py>_ladderY){
						if(dirY<0){
							_body.SetCustomGravity(new b2Vec2(0,0));
							_isClimbing=true;
						}
					}else if(py<_ladderY){
						if(dirY>0){
							_body.SetCustomGravity(new b2Vec2(0,0));
							_isClimbing=true;
						}
					}
				}
				if(_isClimbing){
					var isPLR:Boolean=pLeft||pRight;
					var isPUD:Boolean=pUp||pDown;
					if(isPUD&&!isPLR)_body.SetPosition(b2Vec2.MakeOnce(_ladderX,py));//让人在梯子中间爬
					var vx1:Number=dirX*_speed; 
					var vy1:Number=dirY*_speed;
					var tmpX:Number=_body.GetPosition().x+vx1*(1/MyData.ptm_ratio);
					if(_isSensorGround){//梯子与地面重叠时限制左右运动范围
						if(tmpX<=_climbMinX||tmpX>=_climbMaxX)vx1=0;
					}
					_body.SetLinearVelocity(b2Vec2.MakeOnce(vx1,vy1),true);
				}
				
			}else{
				if(_isClimbing){
					_body.SetCustomGravity(null);
					_isClimbing=false;
				}
				
			}
			////还原
			_isSensorLadder=false;
			_isSensorGround=false;
		}
		
		override protected function onDestroy():void{
			_body=null;
			_km=null;
			_worldManifold=null;
			super.onDestroy();
		}
		
		//public function get isSensorLadder():Boolean{ return _isSensorLadder; }
		public function get isClimbing():Boolean{ return _isClimbing; }
		
	};

}