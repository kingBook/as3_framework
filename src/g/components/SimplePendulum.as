package g.components{
	import flash.display.Shape;
	import flash.geom.Point;
	import framework.game.Game;
	import framework.objs.Component;
	
	/**单摆*/
	public class SimplePendulum extends Component{
		
		public function SimplePendulum(){
			super();
		}
		
		private var _g:Number;
		private var _currentW:Number;//瞬时角速度
		private var _l:Number;//摆线长度
		private var _startAngle:Number;//初始角度
		private var _currentAngle:Number;//当前角度
		private var _delta:Number;
		private var _ptm:Number;
		
		private var _o:Point;//固定点
		private var _pos:Point;
		
		public function initialize(originX:Number,originY:Number,gravity:Number=9.81,long:Number=100,startAngle:Number=90,delta:Number=1/60,ptm_ratio:Number=100):void{
			_g=gravity;
			_currentW=0;
			_l=long/ptm_ratio;
			_startAngle=_currentAngle=startAngle*0.01745;
			_delta=delta;
			_ptm=ptm_ratio;
			
			_o=new Point();
			_o.x=originX;
			_o.y=originY;
			
			_pos=new Point();
			_pos.x=_o.x+Math.sin(_currentAngle)*_l*_ptm;
			_pos.y=_o.y+Math.cos(_currentAngle)*_l*_ptm;
		}
		
		override protected function update():void{
			var k1:Number,k2:Number,k3:Number,k4:Number;
			var l1:Number,l2:Number,l3:Number,l4:Number;
			{
				k1=_currentW;
				l1=-(_g/_l)*Math.sin(_currentAngle);
				
				k2=_currentW+_delta*l1/2;
				l2=-(_g/_l)*Math.sin(_currentAngle+_delta*k1/2);
				
				k3=_currentW+_delta*l2/2;
				l3=-(_g/_l)*Math.sin(_currentAngle+_delta*k2/2);
				
				k4=_currentW+_delta*l3;
				l4=-(_g/_l)*Math.sin(_currentAngle*_delta*k3);
				
				_currentAngle+=_delta*(k1+2*k2+2*k3+k4)/(6/*2*Math.PI*/);
				
				_currentW+=_delta*(l1+2*l2+2*l3+l4)/(6/*2*Math.PI*/);
				
			}
			//
			_pos.x=_o.x+Math.sin(_currentAngle)*_l*_ptm;
			_pos.y=_o.y+Math.cos(_currentAngle)*_l*_ptm;
			//
			//draw();
		}
		
		private var _shape:Shape;
		private function draw():void{
			if (_shape == null) {
				_shape = new Shape();
				Game.getInstance().global.layerMan.effLayer.addChild(_shape);
			}
			_shape.graphics.clear();
			_shape.graphics.lineStyle(1,0xff0000);
			_shape.graphics.moveTo(_o.x,_o.y);
			_shape.graphics.lineTo(_pos.x,_pos.y);
		}
		
		override protected function onDestroy():void{
			if (_shape && _shape.parent){
				_shape.parent.removeChild(_shape);
				_shape = null;
			}
			super.onDestroy();
		}
		
		/**瞬时角速度*/
		private function getW():Number{
			var w:Number=Math.sqrt(2/_l*_l)*
						 Math.sqrt(_g*_l* (Math.cos(_currentAngle)-Math.cos(_startAngle)) );
			return w;
		}
		
		/**返回单摆周期*/
		private function getT():Number{
			var t:Number=(2*Math.PI*Math.sqrt(_l/_g))/
						 (1-0.062*_startAngle*_startAngle);
			return t;
		}
		
		public function get pos():Point{
			return _pos;
		}
	};

}