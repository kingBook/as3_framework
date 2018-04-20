package g.objs{
	import framework.game.Game;
	import framework.utils.Box2dUtil;

	import g.MyData;
	import g.objs.StandardObject;
	import g.objs.TrailBall;
	import Box2D.Dynamics.b2World;
	/**托尾特效球*/
	public class TrailBall extends MovableObject{
		private var _radius:Number;
		private var _color:uint;
		private var _alpha:Number;
		public function TrailBall(){
			super();
		}
		public static function create(world:b2World,x_pixel:Number,y_pixel:Number,radius_pixel:Number,color:uint,alpha:Number=1):TrailBall{
			var game:Game=Game.getInstance();
			var info:*={};
			info.radius=radius_pixel;
			info.color=color;
			info.alpha=alpha;
			info.body=Box2dUtil.createCircle(radius_pixel,x_pixel,y_pixel,world,MyData.ptm_ratio);
			return game.createGameObj(new TrailBall(),info) as TrailBall;
		}
		override protected function init(info:*=null):void{
			super.init(info);
			_radius=info.radius;
			_color=info.color;
			_alpha=info.alpha;
		}
		override protected function fixedUpdate():void{
			super.fixedUpdate();
			createTrail();
		}
		override protected function update():void{
			super.update();
			
		}
		private function createTrail():void{
			var x:Number=_body.GetPosition().x*MyData.ptm_ratio;
			var y:Number=_body.GetPosition().y*MyData.ptm_ratio;
			BallView.create(x,y,_radius,_color,_alpha);
		}
		override protected function onDestroy():void{
			super.onDestroy();
		}
		
	};
}
import flash.display.Sprite;

import framework.game.Game;
import framework.objs.GameObject;

import g.objs.AlphaTo;
import g.objs.DisplayObj;
import g.objs.ScaleTo;
import framework.objs.Clip;

class BallView extends DisplayObj{
	private var _scaleTo:ScaleTo;
	public function BallView(){
		super();
	}
	public static function create(x:Number,y:Number,radius:Number,color:uint,alpha:Number=1):BallView{
		var game:Game=Game.getInstance();
		var circle:Sprite=createCircle(radius,color,alpha);
		var circleClip:Clip=Clip.fromDisplayObject(circle);
		var info:*={};
		info.x=x;
		info.y=y;
		info.view=circleClip;
		info.viewParent=game.global.layerMan.items2Layer;
		return game.createGameObj(new BallView(),info) as BallView;
	}
	private static function createCircle(radius:Number,color:uint,alpha:Number):Sprite{
		var sp:Sprite=new Sprite();
		sp.graphics.beginFill(color,alpha);
		sp.graphics.drawCircle(0,0,radius);
		sp.graphics.endFill();
		return sp;
	}
	override protected function init(info:*=null):void{
		super.init(info);
		_scaleTo=ScaleTo.create(_view,1,0.1,1,null,null,toComplete);
	}
	private function toComplete():void{
		GameObject.destroy(this);
	}
	override protected function onDestroy():void{
		GameObject.destroy(_scaleTo);
		_scaleTo=null;
		super.onDestroy();
	}
}