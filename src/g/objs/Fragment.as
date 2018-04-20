package g.objs{
	import Box2D.Dynamics.b2Body;
	import framework.game.Game;
	import framework.objs.GameObject;
	import g.objs.MovableObject;
	import Box2D.Collision.b2AABB;
	/**碎片*/
	public class Fragment extends MovableObject{
		
		public static function create(body:b2Body,minX:Number,maxX:Number,minY:Number,maxY:Number,view:*=null,viewParent:*=null):Fragment{
			var game:Game=Game.getInstance();
			var info:*={};
			info.body=body;
			info.view=view;
			info.viewParent=viewParent;
			info.minX=minX;
			info.maxX=maxX;
			info.minY=minY;
			info.maxY=maxY;
			return game.createGameObj(new Fragment(),info) as Fragment;
		}
		
		public function Fragment(){
			super();
		}
		
		private var _minX:Number;
		private var _maxX:Number;
		private var _minY:Number;
		private var _maxY:Number;
		
		override protected function init(info:* = null):void{
			super.init(info);
			_minX=info.minX;
			_maxX=info.maxX;
			_minY=info.minY;
			_maxY=info.maxY;
		}
		
		override protected function update():void{
			super.update();
			var aabb:b2AABB=_body.GetAABB();
			var lx:Number=aabb.lowerBound.x;
			var ly:Number=aabb.lowerBound.y;
			var ux:Number=aabb.upperBound.x;
			var uy:Number=aabb.upperBound.y;
			if(ly>_maxY||lx>_maxX || uy<_minY||ux<_minX){
				GameObject.destroy(this);
			}
		}
		


	};

}