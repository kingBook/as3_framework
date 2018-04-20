package g.components
{
	import g.components.SimplePendulum;
	import framework.objs.Component;
	import flash.display.Shape;
	import flash.geom.Point;
	import framework.game.Game;
	import framework.objs.GameObject;
	
	public class Rope extends Component
	{
		
		private var _ptm_ratio:Number = 100;//像素/米
		private var _gravity:Point = new Point(0, 9.81);
		private var _dt:Number = 1 / 30;
		private var _lenNode:Number = 4 / _ptm_ratio;//绳节长度,单位：米
		private var _nodeCount:int = 20; //节数
		
		private var _ropeInitAngle:Number = 0 * 0.01745;//绳子初始朝向角度 单位：弧度
		
		private var _origin:Point;//绳子悬挂点,单位：米
		
		/**自定义最后绳节的位置*/
		private var _customEndPosX:Number = NaN;
		private var _customEndPosY:Number = NaN;
		
		private var _oldPosList:Vector.<Point>;
		private var _posList:Vector.<Point>;
		
		public function Rope()
		{
			super();
		}
		
		/**
		 * 初始化
		 * @param	originX 绳子悬挂点x 单位：像素
		 * @param	originY 绳子悬挂点y 单位：像素
		 * @param	ropeInitAngle 绳子初始朝向角度 单位：弧度
		 * @param	lenNode 绳节长度,单位：米
		 * @param	gravityX 重力加速度x，单位：米
		 * @param	gravityY 重力加速度y，单位：米
		 * @param	ptm_ratio 像素/米
		 */
		public function initialize(originX:Number = 400, originY:Number = 200, ropeInitAngle:Number = 0, lenNode:Number = 4, nodeCount:Number = 20, gravityX:Number = 0, gravityY:Number = 9.81, ptm_ratio:Number = 100):void
		{
			_ptm_ratio = ptm_ratio;
			_origin = new Point(originX / _ptm_ratio, originY / _ptm_ratio);
			_ropeInitAngle = ropeInitAngle;
			_lenNode = lenNode / _ptm_ratio;
			_nodeCount = nodeCount;
			_gravity.x = gravityX;
			_gravity.y = gravityY;
			
			_posList = new Vector.<Point>(_nodeCount, true);
			_oldPosList = new Vector.<Point>(_nodeCount, true);
			
			for (var i:uint = 0; i < _nodeCount; i++)
			{
				var x:Number = _origin.x + Math.cos(_ropeInitAngle) * _lenNode * i;
				var y:Number = _origin.y + Math.sin(_ropeInitAngle) * _lenNode * i;
				_oldPosList[i] = new Point(x, y);
				_posList[i] = new Point(x, y);
			}
		
		}
		
		/**
		 * 绑定最后一个绳节的位置,设置NaN时取消绑定
		 * @param	endPosX 单位：像素
		 * @param	endPosY 单位：像素
		 */
		public function bindEndPos(endPosX:Number, endPosY:Number):void
		{
			_customEndPosX = endPosX / _ptm_ratio;
			_customEndPosY = endPosY / _ptm_ratio;
		}
		
		override protected function update():void
		{
			super.update();
			step();
		}
		
		private function step():void
		{
			verlet();
			fixedStartAndEnd();
			setConstraints();
		
			//drawRope();
		
		}
		
		private function fixedStartAndEnd():void{
			_posList[0].x = _origin.x;
			_posList[0].y = _origin.y;
			if (!isNaN(_customEndPosX)) _posList[_nodeCount - 1].x = _customEndPosX;
			if (!isNaN(_customEndPosY)) _posList[_nodeCount - 1].y = _customEndPosY;
		}
		
		/**重力加速度模拟*/
		private function verlet():void
		{
			for (var i:uint = 0; i < _nodeCount; i++)
			{
				var tmpx:Number = _posList[i].x;
				_posList[i].x += (_posList[i].x - _oldPosList[i].x) + (_gravity.x * _dt * _dt);
				
				var tmpy:Number = _posList[i].y;
				_posList[i].y += (_posList[i].y - _oldPosList[i].y) + (_gravity.y * _dt * _dt);
				
				_oldPosList[i].x = tmpx;
				_oldPosList[i].y = tmpy;
			}
		}
		
		/**约束绳节间的距离*/
		private function setConstraints():void
		{
			for (var c:uint = 0; c < _nodeCount; c++)
			{
				fixedStartAndEnd();
				for (var i:uint = 1; i < _nodeCount; i++)
				{
					//Distance of two rope node
					var dx:Number = _posList[i].x - _posList[i - 1].x;
					var dy:Number = _posList[i].y - _posList[i - 1].y;
					var d:Number = Math.sqrt(dx * dx + dy * dy);
					
					var diff:Number = d - _lenNode;
					var f:Number = 0.5;
					_posList[i].x -= (dx / d) * diff * f;
					_posList[i].y -= (dy / d) * diff * f;
					
					_posList[i - 1].x += (dx / d) * diff * f;
					_posList[i - 1].y += (dy / d) * diff * f;
				}
			}
		}
		
		private var _shape:Shape;
		
		private function drawRope():void
		{
			if (_shape == null)
			{
				_shape = new Shape();
				Game.getInstance().global.layerMan.effLayer.addChild(_shape);
			}
			
			_shape.graphics.clear();
			_shape.graphics.lineStyle(1, 0xff0000, 2);
			_shape.graphics.moveTo(_posList[0].x * _ptm_ratio, _posList[0].y * _ptm_ratio);
			for (var i:uint = 1; i < _nodeCount; i++)
			{
				_shape.graphics.lineTo(_posList[i].x * _ptm_ratio, _posList[i].y * _ptm_ratio);
			}
		}
		
		override protected function onDestroy():void
		{
			if (_shape && _shape.parent)
			{
				_shape.parent.removeChild(_shape);
				_shape = null;
			}
			super.onDestroy();
		}
		
		private var _len:Number;
		
		public function get len():Number
		{
			return _len ||= _nodeCount * _lenNode * _ptm_ratio;
		}
		
		public function get posList():Vector.<Point>
		{
			return _posList;
		}
		
		public function get ptm_ratio():Number  { return _ptm_ratio; }
		public function get gravity():Point{return _gravity;}
		public function get origin():Point{return _origin;}
	}
	;

}