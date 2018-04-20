package g.objs{
	import Box2D.Dynamics.b2Body;
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import framework.game.Game;
	import framework.events.FrameworkEvent;
	import framework.objs.Clip;
	import framework.objs.GameObject;
	import framework.utils.Box2dUtil;
	import framework.utils.FuncUtil;
	import g.MyData;
	import g.objs.StandardObject;
	import Box2D.Dynamics.b2World;
	/**
	 * 游戏中玩家要收集的东西
	 * @author kingBook
	 * 2015/11/10 9:30
	 */
	public class Item extends StandardObject{
		public static var itemCount:int=0;
		public static var itemTotal:int=0;
		
		public function Item(){
			super();
		}
		
		public static function create(childMc:MovieClip,world:b2World):void{
			var game:Game=Game.getInstance();
			//矩形刚体
			//var body:b2Body=Box2dUtil.createBox(childMc.width,childMc.height,childMc.x,childMc.y,game.global.curWorld,MyData.ptm_ratio);
			//圆形刚体
			var body:b2Body=Box2dUtil.createCircle(childMc.width*0.5,childMc.x,childMc.y,world,MyData.ptm_ratio);
			var clip:Clip=Clip.fromDefName("Item_view",true,true,game.global.layerMan.items3Layer,childMc.x,childMc.y);
			game.createGameObj(new Item(),{body:body,view:clip});
			Item.itemTotal++;
		}
		
		override protected function init(info:* = null):void{
			super.init(info);
			_body.SetType(b2Body.b2_staticBody);
			_body.SetSensor(true);
			_game.addEventListener(FrameworkEvent.DESTROY_ALL,destroyAll);
		}
		
		private var _isDestroying:Boolean;
		public function tweenDestroy():void{
			if(_isDestroying)return; 
			_isDestroying=true;
			_game.global.soundMan.play("Sound_getItem");
			Item.itemCount++;
			createEffect("ItemDestroyEffect",_body.GetPosition().x*MyData.ptm_ratio,_body.GetPosition().y*MyData.ptm_ratio,_game.global.layerMan.effLayer);
			GameObject.destroy(this);
		}
		
		/**创建特效*/
		public function createEffect(defName:String,x:Number,y:Number,parent:DisplayObjectContainer):void{
			var clip:Clip=Clip.fromDefName(defName);
			clip.x=x,clip.y=y;
			clip.addFrameScript(clip.totalFrames-1,function():void{
				FuncUtil.removeChild(clip);
			});
			parent.addChild(clip);
		}
		
		private function destroyAll(e:FrameworkEvent):void{
			e.target.removeEventListener(FrameworkEvent.DESTROY_ALL,destroyAll);
			Item.itemCount=0;
			Item.itemTotal=0;
		}
		
		override protected function onDestroy():void{
			_body.SetUserData({isDestroy:true});
			super.onDestroy();
		}
		
		
	};

}