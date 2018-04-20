package g.components{
	import Box2D.Collision.b2Manifold;
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.Contacts.b2Contact;
	import Box2D.Dynamics.b2Body;
	import flash.display.Shape;
	import framework.objs.Component;
	import framework.utils.Mathk;
	import g.MyData;
	import g.events.MyEvent;
	import g.objs.Delayer;
	
	/*
	//控制型
	private var _behavior:TelescopicBehavior;
	
	override protected function init(info:* = null):void{
		_body.SetPreSolveCallback(preSolve);
		_behavior=addComponent(TelescopicBehavior) as TelescopicBehavior;
		_behavior.initializeControl(_body,info.isOn,info.long/MyData.ptm_ratio,2);
	}
	
	override protected function on():void{
		if((_flags&e_isOn)>0)return;
		_flags|=e_isOn;
		_behavior.stretch();
	}
	
	override protected function off():void{
		if((_flags&e_isOn)==0)return;
		_flags&=~e_isOn;
		_behavior.shrink();
	}
	
	public function preSolve(contact:b2Contact,oldManifold:b2Manifold):void{
		_behavior.preSolve(contact,oldManifold);
	}
	
	override protected function onDestroy():void{
		removeComponent(_behavior);
		_behavior=null;
		super.onDestroy();
	}
	*/
	
	/*
	//自动型
	private var _behavior:TelescopicBehavior;
	
	override protected function init(info:* = null):void{
		_body.SetPreSolveCallback(preSolve);
		_behavior=addComponent(TelescopicBehavior) as TelescopicBehavior;
		
		var delayer:Delayer=Delayer.createAutoDelayer(2);
		_behavior.initializeAuto(_body,delayer,info.isOn,info.long/MyData.ptm_ratio,2);
	}
	
	public function preSolve(contact:b2Contact,oldManifold:b2Manifold):void{
		_behavior.preSolve(contact,oldManifold);
	}
	
	override protected function onDestroy():void{
		removeComponent(_behavior);
		_behavior=null;
		super.onDestroy();
	}
	*/
	
	//setPause(value:Boolean):void;//暂停运行
	
	/**伸缩行为组件*/
	public class TelescopicBehavior extends Component{
		
		public function TelescopicBehavior(){
			super();
		}
		/**
		 * 
		 * @param	body
		 * @param	isStretch
		 * @param	long b2World单位
		 * @param	speed
		 */
		public function initializeControl(body:b2Body,isStretch:Boolean,long:Number,speed:Number=2):void{
			_body=body;
			_body.SetType(b2Body.b2_kinematicBody);
			if(isStretch)_flags|=e_isStretch;
			_long=long;
			_speed=speed;
			
			var reAngle:Number=_body.GetAngle()+Math.PI;
			_botPos=_body.GetPosition().Copy();
			_botPos.Add(new b2Vec2(Math.cos(reAngle)*_long*0.5,Math.sin(reAngle)*_long*0.5));
			
			var offset:Number=2/MyData.ptm_ratio;//陷入地面一点点
			_minPos=_body.GetPosition().Copy();
			_minPos.Add(new b2Vec2(Math.cos(reAngle)*(_long+offset),Math.sin(reAngle)*(_long+offset)));
			
			_maxPos=_body.GetPosition().Copy();
			
			//初始化状态
			_body.SetPosition((_flags&e_isStretch)>0?_maxPos:_minPos);
		}
		
		public function initializeAuto(body:b2Body,delayer:Delayer,isStretch:Boolean,long:Number,speed:Number=2):void{
			_body=body;
			_body.SetType(b2Body.b2_kinematicBody);
			_delayer=delayer;
			_delayer.addEventListener(Delayer.EXECUTE,delayerExecute);
			if(isStretch)_flags|=e_isStretch;
			_long=long;
			_speed=speed;
			
			var reAngle:Number=_body.GetAngle()+Math.PI;
			_botPos=_body.GetPosition().Copy();
			_botPos.Add(new b2Vec2(Math.cos(reAngle)*_long*0.5,Math.sin(reAngle)*_long*0.5));
			
			var offset:Number=2/MyData.ptm_ratio;//陷入地面一点点
			_minPos=_body.GetPosition().Copy();
			_minPos.Add(new b2Vec2(Math.cos(reAngle)*(_long+offset),Math.sin(reAngle)*(_long+offset)));
			
			_maxPos=_body.GetPosition().Copy();
			
			//初始化状态
			_body.SetPosition((_flags&e_isStretch)>0?_maxPos:_minPos);
			
		}
		private function delayerExecute(e:MyEvent):void{
			if((_flags&e_isStretch)>0)shrink();
			else stretch();
		}
		
		override protected function update():void{
			if((_flags&e_isPause)>0)return;
			if((_flags&e_isRuning)>0){
				if(gotoPoint((_flags&e_isStretch)>0?_maxPos:_minPos)){
					_flags&=~e_isRuning;
				}
			}
		}
		
		private function gotoPoint(pos:b2Vec2):Boolean{
			var dx:Number=(pos.x-_body.GetPosition().x)*MyData.ptm_ratio;
			var dy:Number=(pos.y-_body.GetPosition().y)*MyData.ptm_ratio;
			var c:Number=Math.sqrt(dx*dx+dy*dy);
			if(c>_speed){
				var angleRadian:Number=Math.atan2(dy,dx);
				var vx:Number=Math.cos(angleRadian)*_speed;
				var vy:Number=Math.sin(angleRadian)*_speed;
				_body.SetLinearVelocity(new b2Vec2(vx,vy));
				_body.SetAwake(true);
			}else{
				_body.SetLinearVelocity(new b2Vec2(0,0));
				_body.SetPosition(pos);
				return true;
			}
			return false;
		}
		
		/**伸*/
		public function stretch():void{
			if((_flags&e_isStretch)>0)return;
			_flags|=e_isStretch;
			_flags|=e_isRuning;
		}
		
		/**缩*/
		public function shrink():void{
			if((_flags&e_isStretch)==0)return;
			_flags&=~e_isStretch;
			_flags|=e_isRuning;
		}
		
		public function preSolve(contact:b2Contact, oldManifold:b2Manifold):void{
			if(!contact.IsTouching())return;
			var b1:b2Body=contact.GetFixtureA().GetBody();
			var b2:b2Body=contact.GetFixtureB().GetBody();
			var ob:b2Body=b1==_body?b2:b1;
			if(!inAcceptRange(ob))contact.SetEnabled(false);
		}
		
		public function inAcceptRange(body:b2Body):Boolean{
			var len:Number=10/MyData.ptm_ratio;
			var angle1:Number=_body.GetAngle()-Math.PI*0.5;
			var angle2:Number=_body.GetAngle()+Math.PI*0.5;
			var p1:b2Vec2 = new b2Vec2(_botPos.x+len*Math.cos(angle1),_botPos.y+len*Math.sin(angle1));
			var p2:b2Vec2 = new b2Vec2(_botPos.x+len*Math.cos(angle2),_botPos.y+len*Math.sin(angle2));
			return pointOnSegment(body.GetPosition(),p1,p2) < 0;
		}
		private function pointOnSegment(p:b2Vec2,p1:b2Vec2,p2:b2Vec2):Number{
			var ax:Number = p2.x-p1.x;
			var ay:Number = p2.y-p1.y;
			
			var bx:Number = p.x-p1.x;
			var by:Number = p.y-p1.y;
			return ax*by-ay*bx;
		}
		
		public function createMaskShape(w:Number,h:Number,offset:Number=0):Shape {
			w-=offset;
			var shape:Shape = new Shape();
			shape.graphics.beginFill(0xff0000);
			shape.graphics.drawRect(0,-h*0.5, w, h);
			shape.graphics.endFill();
			shape.x=_botPos.x*MyData.ptm_ratio+Math.cos(_body.GetAngle())*offset;
			shape.y=_botPos.y*MyData.ptm_ratio+Math.sin(_body.GetAngle())*offset;
			shape.rotation=_body.GetAngle()*Mathk.Rad2Deg;
			return shape;
		}
		
		/**暂停接口*/
		public function setPause(value:Boolean):void{
			if(value){
				_flags|=e_isPause;
				_pauseVel=_body.GetLinearVelocity().Copy();
				_body.SetLinearVelocity(b2Vec2.MakeOnce(0,0));
			}else{
				_flags&=~e_isPause;
				if(_pauseVel){
					_body.SetLinearVelocity(_pauseVel);
					_pauseVel=null;
				}
			}
		}
		
		override protected function onDestroy():void{
			if(_delayer)_delayer.removeEventListener(Delayer.EXECUTE,delayerExecute);
			_body=null;
			_delayer=null;
			_botPos=null;
			_minPos=null;
			_maxPos=null;
			_pauseVel=null;
			super.onDestroy();
		}
		
		public function get botPos():b2Vec2{return _botPos;}
		public function get long():Number{return _long;}
		
		private const e_isStretch:uint=0x000001;
		private const e_isRuning:uint =0x000002;
		private const e_isPause:uint  =0x000004;
		private var _flags:uint;
		
		private var _body:b2Body;
		private var _delayer:Delayer;
		
		private var _long:Number;
		private var _botPos:b2Vec2;
		private var _minPos:b2Vec2;
		private var _maxPos:b2Vec2;
		private var _speed:Number;
		private var _pauseVel:b2Vec2;//暂停时记录运动向量
	};

}