package g.objs{
	import flash.geom.Point;
	
	public class PathMotion{
		
		private var  _id:int=-1;
		private var _path:Vector.<Point>;
		private var _pos:Point=new Point();
		private var _speed:Number;
		//reset
		private var _initPos:Point;
		private var _startIndex:int;
		
		/**
		 * 计算路径点运动(path[0]向path[startIndex]开始运动)
		 * @param	path 要做运动的路径点列表
		 * @param	speed 运动速度
		 * @param	startIndex 路径开始位置id
		 */
		public static function create(path:Vector.<Point>,speed:Number=2,startIndex:int=0):PathMotion{
			var pm:PathMotion=new PathMotion();
			pm.init(path,path[0],speed,startIndex);
			return pm;
		}
		
		/**
		 * 计算路径点运动(initPos向path[startIndex]开始运动)
		 * @param	path 路径
		 * @param	initPos 运动开始前的初始位置
		 * @param	speed 运动速度
		 * @param	startIndex 路径开始位置id
		 */
		public static function createWithInitPos(path:Vector.<Point>,initPos:Point,speed:Number=2,startIndex:int=1):PathMotion{
			var pm:PathMotion=new PathMotion();
			pm.init(path,initPos,speed,startIndex);
			return pm;
		}
		
		/**
		 * 计算路径点运动
		 */
		public function PathMotion(){
			super();
		}
		
		private function init(path:Vector.<Point>,initPos:Point,speed:Number,startIndex:int):void{
			_path=path;
			_initPos=new Point(initPos.x,initPos.y);
			_startIndex=startIndex;
			_speed=speed;
			
			setHandler();
		}
		
		public function reset():void{
			setHandler();
		}
		
		private function setHandler():void{
			_pos.setTo(_initPos.x,_initPos.y);
			_id=_startIndex;
		}
		
		/**
		 * 迭代
		 * @return 是否到达终点
		 */
		public function step(index:int):Boolean{
			var isGotoIndexPoint:Boolean=false;
			var target:Point=_path[_id];
			var dx:Number=target.x-_pos.x;
			var dy:Number=target.y-_pos.y;
			var d:Number=Math.sqrt(dx*dx+dy*dy);
			
			var rad:Number=Math.atan2(dy,dx);
			var vx:Number=Math.cos(rad)*_speed;
			var vy:Number=Math.sin(rad)*_speed;
			
			if(d>_speed){
				_pos.offset(vx,vy);
			}else if(d<_speed){
				if(_id<_path.length-1){
					var offset:Number=_speed-d;
					
					var next:Point=_path[_id+1];
					dx=next.x-target.x;
					dy=next.y-target.y;
					
					rad=Math.atan2(dy,dx);
					vx=Math.cos(rad)*offset;
					vy=Math.sin(rad)*offset;
					
					_pos.setTo(target.x+vx,target.y+vy);
					isGotoIndexPoint=(index==_id);
					//
					_id++;
				}else{
					//走到终点
					_pos.setTo(target.x,target.y);
					isGotoIndexPoint=(index==_id);
				}
				
			}else{
				//d==_speed
				//走到终点
				_pos.setTo(target.x,target.y);
				isGotoIndexPoint=(index==_id);
				if(_id<_path.length-1)_id++;
			}
			return isGotoIndexPoint;
		}
		
		public function get x():Number{return _pos.x;}
		public function get y():Number{return _pos.y;}
		public function get path():Vector.<Point>{return _path;}
		
		
	};

}