package g.objs{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import framework.game.Game;
	import framework.objs.Clip;
	import framework.utils.LibUtil;
	import g.objs.MyObj;
	
	public class DisplayObj extends MyObj{
		
		protected var _view:DisplayObject;
		
		public static function create(x:Number,y:Number,view:DisplayObject,viewParent:DisplayObjectContainer):void{
			var game:Game=Game.getInstance();
			var info:*={};
			info.x=x;
			info.y=y;
			info.view=view;
			info.viewParent=viewParent;
			game.createGameObj(new DisplayObj(),info);
		}
		
		public static function createDefClip(x:Number,y:Number,defName:String,viewParent:DisplayObjectContainer):void{
			var game:Game=Game.getInstance();
			var info:*={};
			info.x=x;
			info.y=y;
			info.view=Clip.fromDefName(defName,true);
			info.viewParent=viewParent;
			game.createGameObj(new DisplayObj(),info);
		}
		
		public static function createDefMovieClip(x:Number,y:Number,defName:String,viewParent:DisplayObjectContainer):void{
			var game:Game=Game.getInstance();
			var info:*={};
			info.x=x;
			info.y=y;
			info.view=LibUtil.getDefMovie(defName,null,false);
			info.viewParent=viewParent;
			game.createGameObj(new DisplayObj(),info);
		}
		
		public function DisplayObj(){
			super();
		}
		
		override protected function init(info:* = null):void{
			if(info){
				if(info.view){
					info.view.x=info.x||0;
					info.view.y=info.y||0;
				}
				if(info.viewParent){
					info.viewParent.addChild(info.view);
				}
				
				_view=info.view;
			
			}
		}
		
		override protected function onDestroy():void{
			if(_view){
				if(_view.parent)_view.parent.removeChild(_view);
				_view=null;
			}
			super.onDestroy();
		}
		
		public function get view():DisplayObject{ return _view; }
		
	};

}