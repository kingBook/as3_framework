package g.objs{
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.utils.getQualifiedClassName;
	import framework.objs.Clip;
	import framework.game.Game;
	
	public class MapAnimClip extends DisplayObj{
		
		private var _sprite:Sprite;
		
		public function MapAnimClip(){
			super();
		}
		
		public static function create(mc:MovieClip,parent:Sprite):MapAnimClip{
			var game:Game=Game.getInstance();
			var info:*={};
			info.mc=mc;
			info.view=new Sprite();
			info.viewParent=parent;
			return game.createGameObj(new MapAnimClip(),info) as MapAnimClip;
		}
		
		override protected function init(info:* = null):void{
			super.init(info);
			_sprite=_view as Sprite;
			transformChildsToClips(info.mc,_sprite);
			
		}
		
		private function transformChildsToClips(container:MovieClip,parent:Sprite,outputList:Vector.<Clip>=null):Vector.<Clip>{
			var list:Vector.<Clip>=outputList?outputList:new Vector.<Clip>();
			var clip:Clip;
			var len:int=container.numChildren;
			var child:DisplayObject;
			for(var i:int=0;i<len;i++){
				child=container.getChildAt(i);
				if(child is MovieClip){
					var qName:String=getQualifiedClassName(child);
					var isCustomLinkClass:Boolean=qName.indexOf("::MovieClip")<0;
					if(isCustomLinkClass){
						clip=Clip.fromDefName(qName,true);
						clip.transform=child.transform;
						clip.smoothing=true;
					}else{
						clip=Clip.fromDisplayObject(child);
					}
				}else{
					clip=Clip.fromDisplayObject(child);
				}
				clip.filters=child.filters;
				list.push(clip);
				parent.addChild(clip);
			}
			return list;
		}
		
		override protected function onDestroy():void{
			_sprite=null;
			super.onDestroy();
		}
	};

}