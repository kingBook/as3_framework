package g.components{
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.b2Body;
	import framework.objs.Component;
	import framework.utils.Box2dUtil;
	
	/**人物行为组件 (抽象类)*/
	public class CharacterBehavior extends Component{
		
		public function CharacterBehavior(){
			super();
		}
		
		protected const e_isInAir:uint=0x000001;
		protected const e_isDeath:uint=0x000002;
		protected var _flags:uint;
		
		protected var _body:b2Body;
		protected var _dropGroundCallback:Function=null;
		
		public function applyImpulse(ix:Number=0,iy:Number=0):void{
			_body.ApplyImpulse(b2Vec2.MakeOnce(ix,iy),_body.GetWorldCenter());
		}
		
		override protected function update():void{
			//检测空中
			if(Box2dUtil.getIsOnGround(_body,0.7,null)){
				if((_flags&e_isInAir)>0){
					onDropGround();
					if(_dropGroundCallback!=null) _dropGroundCallback();
				}
				_flags&=~e_isInAir;
			}else{
				_flags|=e_isInAir;
			}
			onSetInAIr((_flags&e_isInAir)>0);				
		}
		
		virtual protected function onSetInAIr(isInAir:Boolean):void{
            
        }
		
		virtual protected function onDropGround():void{
			
		}
		
		public function applyUpImpulse(upForce:Number=15):void{
			applyImpulse(0,-upForce);
		}
		
		protected function walk(vx:Number=0):void{
			var v:b2Vec2=_body.GetLinearVelocity();
			var ix:Number=_body.GetMass()*(vx-v.x);
			_body.ApplyImpulse(b2Vec2.MakeOnce(ix,0),_body.GetWorldCenter());
		}
		
		/**死亡接口*/
		public function deathHandler(vx:Number=0,vy:Number=0,isSensor:Boolean=true):void{
			if((_flags&e_isDeath)>0)return;
			_flags|=e_isDeath;
			_body.SetLinearVelocity(new b2Vec2(vx,vy));
			_body.SetSensor(isSensor);
			_body.SetCustomGravity(null);
		}
		
		override protected function onDestroy():void{
			_body=null;
			super.onDestroy();
		}
		
		/**
		 * 设置落地回调函数
		 * @param	func: function():void;
		 */
		public function setDropGroundCallback(func:Function):void{
			_dropGroundCallback=func;
		}
		
		public function get isInAir():Boolean{return (_flags&e_isInAir)>0;}
		public function get isDeath():Boolean{return (_flags&e_isDeath)>0;}
		public function get body():b2Body{return _body;}
		
	};

}