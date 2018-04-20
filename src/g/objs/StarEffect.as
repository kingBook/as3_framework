package g.objs{
	import flash.geom.Point;
	import framework.objs.GameObject;
	import framework.game.Game;
	import framework.objs.Clip;
	import flash.display.Sprite;
	import flash.display.DisplayObject;
	import framework.game.UpdateType;

	public class StarEffect extends GameObject{
		public static function create(pos0:Point,pos1:Point,completeCallback:Function=null,viewDefName:String=null,viewParent:Sprite=null):void{
			var game:Game=Game.getInstance();
			var clip:Clip=null;
			if(viewDefName){
				clip=Clip.fromDefName(viewDefName,true);
				clip.smoothing=true;
			}
			var info:*={};
			info.pos0=pos0;
			info.pos1=pos1;
			info.view=clip;
			info.viewParent=viewParent;
			info.completeCallback=completeCallback;
			game.createGameObj(new StarEffect(),info);
		}
		public function StarEffect(){
			super();
		}
		
		private const friction:Number=0.01;
		private var _x:Number;
		private var _y:Number;
		private var _view:DisplayObject;
		private var _pos1:Point;
		private var _gravity:Point=new Point(0,1);
		private var _vx:Number=0;
		private var _vy:Number=0;
		private var _completeCallback:Function;
		private var _speed:Number=15;
		
		override protected function init(info:*=null):void{
			var pos0:Point=info.pos0;
			_pos1=info.pos1;
			_completeCallback=info.completeCallback;
			_view=info.view;
			if(_view){
				var viewParent:Sprite=info.viewParent;
				if(viewParent)viewParent.addChild(_view);
			}
			_x=pos0.x; _y=pos0.y;
			syncView();
			_view.scaleX=_view.scaleY=1.5;
		}
		
		private function syncView():void{
			_view.x=_x;
			_view.y=_y;
			_view.rotation+=15;
			_view.scaleX=_view.scaleY=_view.scaleX<1?1:(_view.scaleX-0.05);
		}
		
		override protected function update():void{
			_vx+=_gravity.x;
			_vy+=_gravity.y;
			
			if(_gravity.y>0){
				if(_vy>6)_gravity.y=0;
			}else if(_gravity.y==0){
				var dy:Number=_pos1.y-_y;
				var dx:Number=_pos1.x-_x;
				var angleRadian:Number=Math.atan2(dy,dx);
				
				_vx=Math.cos(angleRadian)*_speed;
				_vy=Math.sin(angleRadian)*_speed;
			}
			
			dx=_pos1.x-_x;
			dy=_pos1.y-_y;
			var d:Number=Math.sqrt(dx*dx+dy*dy);
			if(d>=_speed){
				_x+=_vx;
				_y+=_vy;
				syncView();
			}else{
				_x=_pos1.x;
				_y=_pos1.y;
				syncView();
				if(_completeCallback!=null)_completeCallback();
				GameObject.destroy(this);
			}
		}
		
		override protected function onDestroy():void{
			if(_view && _view.parent)_view.parent.removeChild(_view);
			_completeCallback=null;
			super.onDestroy();
		}
	}
}














