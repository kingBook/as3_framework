package g.objs{
	import Box2D.Dynamics.b2Body;
	import flash.display.MovieClip;
	import framework.game.Game;
	import framework.objs.Clip;
	import framework.utils.Box2dUtil;
	import framework.utils.FuncUtil;
	import g.objs.MovableObject;
	import g.MyData;
	import Box2D.Dynamics.b2World;
	/**旋转的箱子、木条*/
	public class RotateBox extends MovableObject{
		
		public static function create(childMc:MovieClip,world:b2World):void{
			var nameList:Array=childMc.name.split("_");
			//rotateBox_1_45_3
			//[0] rotateBox 名称
			//[1] 1 是否逆时针旋转
			//[2] 45 初始的角度
			//[3] 3 旋转角速度
			var game:Game=Game.getInstance();
			var w:Number=FuncUtil.getTransformWidth(childMc);
			var h:Number=FuncUtil.getTransformHeight(childMc);
			var body:b2Body=Box2dUtil.createBox(w,h,childMc.x,childMc.y,world,MyData.ptm_ratio);
			var clip:Clip=Clip.fromDefName("Seesaw_view",true,true,game.global.layerMan.items2Layer,childMc.x,childMc.y);
			clip.smoothing=true;
			
			var info:*={};
			info.body=body;
			info.view=clip;
			info.isCCW=Boolean(int(nameList[1]));
			info.angle=(Number(nameList[2])||0)*0.01745;
			info.angleSpeed=Number(nameList[3])||0;
			game.createGameObj(new RotateBox(),info);
		}
		
		public function RotateBox(){ super(); }
		
		private var _isCCW:Boolean;
		private var _angleSpeed:Number=1;
		
		override protected function init(info:* = null):void{
			super.init(info);
			_isCCW=info.isCCW;
			_angleSpeed=info.angleSpeed||_angleSpeed; 
			var angleV:Number=_isCCW?-_angleSpeed:_angleSpeed;
			
			_body.SetType(b2Body.b2_kinematicBody);
			_body.SetAngle(info.angle);
			_body.SetAngularVelocity(angleV);
		}
		
	};

}