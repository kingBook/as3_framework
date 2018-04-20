package g.objs{
	import Box2D.Dynamics.b2Body;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.utils.getQualifiedClassName;
	import framework.game.Game;
	import framework.b2Editor.TransformData;
	import g.MyData;
	import g.objs.BodyObject;
	import framework.utils.Mathk;

	public class StandardObject extends BodyObject{
		
		public static function create(body:b2Body,view:DisplayObject=null,viewParent:DisplayObjectContainer=null,viewMask:DisplayObject=null):StandardObject{
			var game:Game=Game.getInstance();
			var info:*={};
			info.body=body;
			info.view=view;
			info.viewParent=viewParent;
			info.viewMask=viewMask;
			return game.createGameObj(new StandardObject(),info) as StandardObject;
		}
		
		protected var _view:DisplayObject;
		public function StandardObject(){super();}
		
		override protected function init(info:*=null):void{
			super.init(info);
			_view=info.view;
			if(_view){
				if(_body){
					var transformData:TransformData=_body.GetUserData().transformData;
					if(transformData){
						_view.scaleX=transformData.lossyScale.x;
						_view.scaleY=transformData.lossyScale.y;
					}
					syncView();
				}
				if(info.viewParent){
					info.viewParent.addChild(_view);
					if(info.viewMask){
						info.viewParent.addChild(info.viewMask);
						_view.mask=info.viewMask;
					}
				}
			}
		}
		
		protected function syncView():void{
			if(_view&&_body){
				_view.x=_body.GetPosition().x*MyData.ptm_ratio;
				_view.y=_body.GetPosition().y*MyData.ptm_ratio;
				_view.rotation=Mathk.getRotationToFlash((_body.GetAngle()*Mathk.Rad2Deg));
			}
		}
		
		override protected function onDestroy():void{
			if(_view){
				if(_view.parent)_view.parent.removeChild(_view);
				if(_view.mask){
					if(_view.mask.parent)_view.mask.parent.removeChild(_view.mask);
					_view.mask=null;
				}
			_view=null;
			}
			super.onDestroy();
		}
		
		public function get view():DisplayObject{ return _view; }
		
	};
}