package g.objs{
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.b2Body;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import framework.game.Game;
	import framework.game.UpdateType;
	import g.objs.MovableObject;
	import g.MyData;
	/**
	 * 给一个路径点列表，根据这个列表上的点移动,不存在顺逆时针
	 * @author kingBook
	 * 2015/10/30 12:05
	 */
	public class PathMobileObj extends MovableObject{
		public static function create(body:b2Body,points:Vector.<b2Vec2>,speed:Number=3,view:DisplayObject=null,viewParent:Sprite=null):void{
			var game:Game=Game.getInstance();
			var info:*={};
			info.body=body;
			info.view=view;
			info.viewParent=viewParent;
			info.speed=speed;
			info.points=points;
			game.createGameObj(new PathMobileObj(),info);
		}
		public function PathMobileObj(){
			super();
		}
		
		protected var _speed:Number;
		protected var _points:Vector.<b2Vec2>;//b2World为单位
		protected var _curId:int;
		
		override protected function init(info:* = null):void{
			super.init(info);
			_speed=info.speed;
			_points=info.points;
			
			_body.SetType(b2Body.b2_kinematicBody);
			//设最近点为起点
			var dList:Array=[],pos:b2Vec2=_body.GetPosition();
			var i:int=_points.length;
			while(--i>=0) dList.push({id:i,distance:b2Vec2.Distance(_points[i],pos)});
			dList.sortOn("distance",Array.NUMERIC);
			_curId=dList.length>=2?dList[0].id:0;
			
		}
		override protected function update():void{
			if(_points.length<2)return;
			if(gotoPoint(_points[_curId])){
				_curId++; if(_curId>=_points.length)_curId=0;
			}
			super.update();
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
		override protected function onDestroy():void{
			_points=null;
			super.onDestroy();
		}
	};

}