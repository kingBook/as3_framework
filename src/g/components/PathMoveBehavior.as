package g.components{
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.b2Body;

	import framework.objs.Component;
	import framework.objs.GameObject;

	import g.MyData;
	/*路径移动*/
	public class PathMoveBehavior extends Component{

		private var _speed:Number;
		private var _curID:int;
		private var _body:b2Body;
		private var _points:Vector.<b2Vec2>;
		private var _isReverse:Boolean;
		private var _dt:Number;
		private var _onGotoPoint:Function;//function(curID:int,nextID:int):void;
		
		public static function create(gameObject:GameObject,body:b2Body,points:Vector.<b2Vec2>,dt:Number,speed:Number=3,isReverse:Boolean=false,onGotoPoint:Function=null):PathMoveBehavior{
			var info:*={};
			info.body=body;
			info.points=points;
			info.dt=dt;
			info.speed=speed;
			info.isReverse=isReverse;
			info.onGotoPoint=onGotoPoint;
			return gameObject.addComponent(PathMoveBehavior,info) as PathMoveBehavior;
		}

		override protected function init(info:*=null):void{
			super.init(info);
			_points=info.points;
			_dt=info.dt;
			_speed=info.speed;
			_body=info.body;
			_isReverse=info.isReverse;
			_onGotoPoint=info.onGotoPoint;
			
			//设最近点为起点
			var dList:Array=[],pos:b2Vec2=_body.GetPosition();
			var i:int=_points.length;
			while(--i>=0) dList.push({id:i,distance:b2Vec2.Distance(_points[i],pos)});
			dList.sortOn("distance",Array.NUMERIC);
			_curID=dList.length>=2?dList[0].id:0;
		}

		override protected function fixedUpdate():void{
			super.fixedUpdate();
			if(_points.length<2)return;
			if(gotoPoint(_points[_curID])){
				var nextID:int=getNextID(_curID);
				if(_onGotoPoint!=null)_onGotoPoint(_curID,nextID);
				_curID=nextID;
			}
		}

		private function getNextID(curID:int):int{
			if(_isReverse){
				curID--; if(curID<0)curID=_points.length-1;
			}else{
				curID++; if(curID>=_points.length)curID=0;
			}
			return curID;
		}
		
		private function gotoPoint(target:b2Vec2):Boolean{
			var pos:b2Vec2=_body.GetPosition();
			var dx:Number=target.x-pos.x;
			var dy:Number=target.y-pos.y;
			var d:Number=Math.sqrt(dx*dx+dy*dy);
			var angle:Number=Math.atan2(dy,dx);
			if(d>=_speed*_dt){
				_body.SetLinearVelocity(b2Vec2.MakeOnce(Math.cos(angle)*_speed,Math.sin(angle)*_speed));
			}else{
				_body.SetLinearVelocity(b2Vec2.MakeOnce(Math.cos(angle)*d,Math.sin(angle)*d));
				return true;
			}
			return false;
		}
		
		override protected function onDestroy():void{
			_points=null;
			_body=null;
			_onGotoPoint=null;
			super.onDestroy();
		}
		
		public function get points():Vector.<b2Vec2>{
			return _points;
		}
	};

}