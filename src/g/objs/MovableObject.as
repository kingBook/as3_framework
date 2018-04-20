package g.objs{
	import Box2D.Dynamics.b2Body;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import framework.game.UpdateType;
	import framework.game.Game;
	import framework.b2Editor.TransformData;
	import framework.objs.Clip;
	import framework.utils.LibUtil;

	public class MovableObject extends StandardObject{
		
		public static function create(body:b2Body,view:*=null,viewParent:*=null,viewMask:*=null):MovableObject{
			var game:Game=Game.getInstance();
			var info:*={};
			info.body=body;
			info.view=view;
			info.viewParent=viewParent;
			info.viewMask=viewMask;
			return game.createGameObj(new MovableObject(),info) as MovableObject;
		}
		
		public static function createWithViewDefName(body:b2Body,viewDefName:String=null,viewParent:DisplayObjectContainer=null,isToClip:Boolean=true,isSmoothing:Boolean=true):MovableObject{
			var clip:Sprite;
			if(viewDefName){
				if(isToClip){
					clip=Clip.fromDefName(viewDefName,true);
					Clip(clip).smoothing=isSmoothing;
				}else{
					clip=LibUtil.getDefMovie(viewDefName);
				}
			}
			
			return create(body,clip,viewParent);
		}
		
		public function MovableObject(){
			super();
		}

		override protected function update():void{
			syncView();
		}
		
		override protected function onDestroy():void{
			super.onDestroy();
		}
	};
}