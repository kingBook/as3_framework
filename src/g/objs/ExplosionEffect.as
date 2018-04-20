package g.objs{
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.b2World;
	import flash.display.BitmapData;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.filters.GlowFilter;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import framework.game.Game;
	import framework.objs.Clip;
	import framework.utils.Box2dUtil;
	import framework.utils.LibUtil;
	import framework.utils.RandomKb;
	import g.MyData;
	import g.objs.MyObj;
	import g.objs.Fragment;
	import framework.objs.GameObject;
	/**冰块等破碎特效*/
	public class ExplosionEffect extends MyObj{
		
		public static function create(pos:b2Vec2,explosionCenter:b2Vec2,explosionMcDefName:String,world:b2World,minX_pixel:Number,minY_pixel:Number,maxX_pixel:Number,maxY_pixel:Number,velocity:Number=8,customGravityX:Number=NaN,customGravityY:Number=NaN):ExplosionEffect{
			var game:Game=Game.getInstance();
			var info:*={};
			info.pos=pos;
			info.explosionCenter=explosionCenter;
			info.explosionMcDefName=explosionMcDefName;
			info.minX=minX_pixel;
			info.maxX=maxX_pixel;
			info.minY=minY_pixel;
			info.maxY=maxY_pixel;
			info.velocity=velocity;
			info.world=world;
			info.customGravityX=customGravityX;
			info.customGravityY=customGravityY;
			return game.createGameObj(new ExplosionEffect(),info) as ExplosionEffect;
		}
		
		/**
		 * @param pos 世界坐标
		 * @param explosionCenter 世界坐标
		 * @param matrix 应用到explosionMcDefName所建的MovieClip
		 * 
		 * example 创建与_view一样大小与旋转角度的ExplosionEffect, 位置由pos参数决定
		 * var matrix:Matrix=_view.transform.matrix;
		 * ExplosionEffect.createWithMatrix(cen,exCen,matrix,...);
		 */
		public static function createWithMatrix(pos:b2Vec2,explosionCenter:b2Vec2,matrix:Matrix,explosionMcDefName:String,world:b2World,minX_pixel:Number,minY_pixel:Number,maxX_pixel:Number,maxY_pixel:Number,velocity:Number=8,customGravityX:Number=NaN,customGravityY:Number=NaN):ExplosionEffect{
			var game:Game=Game.getInstance();
			var info:*={};
			info.pos=pos;
			info.explosionCenter=explosionCenter;
			info.matrix=matrix;
			info.explosionMcDefName=explosionMcDefName;
			info.minX=minX_pixel;
			info.maxX=maxX_pixel;
			info.minY=minY_pixel;
			info.maxY=maxY_pixel;
			info.velocity=velocity;
			info.world=world;
			info.customGravityX=customGravityX;
			info.customGravityY=customGravityY;
			return game.createGameObj(new ExplosionEffect(),info) as ExplosionEffect;
		}
		
		private var _fragments:Vector.<Fragment>;
		
		override protected function init(info:* = null):void{
			var explosionCenter:b2Vec2=info.explosionCenter;
			var pos:b2Vec2=info.pos;
			var velocity:Number=info.velocity;
			var defName:String=info.explosionMcDefName;
			var matrix:Matrix=info.matrix;
			matrix.tx=matrix.ty=0;
			var mc:MovieClip=LibUtil.getDefMovie(defName);
			if(matrix) mc.transform.matrix=matrix;
			var minX:Number=info.minX/MyData.ptm_ratio;
			var maxX:Number=info.maxX/MyData.ptm_ratio;
			var minY:Number=info.minY/MyData.ptm_ratio;
			var maxY:Number=info.maxY/MyData.ptm_ratio;
			var drawSp:Sprite=new Sprite();
			drawSp.addChild(mc);

			var customGrav:b2Vec2=null;
			if(!isNaN(info.customGravityX)||!isNaN(info.customGravityY)){
				var gx:Number=info.customGravityX||0;
				var gy:Number=info.customGravityY||0;
				customGrav=new b2Vec2(gx,gy);
			}

			var len:int=mc.totalFrames;
			_fragments=new Vector.<Fragment>();
			for(var i:int=0;i<len;i++){
				mc.gotoAndStop(i+1);
				var r:Rectangle=mc.getBounds(drawSp);
				
				//trace(r);
				var x:Number=pos.x*MyData.ptm_ratio+(r.x+r.width*0.5);
				var y:Number=pos.y*MyData.ptm_ratio+(r.y+r.height*0.5);
				var angleRadian:Number=Math.atan2(y-explosionCenter.y*MyData.ptm_ratio, x-explosionCenter.x*MyData.ptm_ratio);
				var body:b2Body=Box2dUtil.createBox(r.width,r.height,x,y,info.world,MyData.ptm_ratio);
				body.SetSensor(true);
				body.SetLinearVelocity(b2Vec2.MakeFromAngle(angleRadian,velocity));
				body.SetAngularVelocity(RandomKb.wave*10);
				if(customGrav)body.SetCustomGravity(new b2Vec2(customGrav.x,customGrav.y));
				
				var bmd:BitmapData=new BitmapData(int(r.width+0.9),int(r.height+0.9),true,0);
				var mat:Matrix=new Matrix();
				mat.tx=-r.x;
				mat.ty=-r.y;
				bmd.draw(drawSp,mat);
				var clip:Clip=Clip.fromBitmapData(bmd);
				clip.x=-bmd.width>>1;
				clip.y=-bmd.height>>1;
				clip.smoothing=true;
				var sp:Sprite=new Sprite();
				sp.addChild(clip);
				sp.filters=[new GlowFilter(0,1,2,2)];
				
				_fragments.push(Fragment.create(body,minX,maxX,minY,maxY,sp,_game.global.layerMan.effLayer));
			}
			drawSp.removeChild(mc);
			drawSp=null;
		}
		
		override protected function onDestroy():void{
			for(var i:int=0;i<_fragments.length;i++){
				GameObject.destroy(_fragments[i]);
			}
			_fragments=null;
			super.onDestroy();
		}
		
	};

}