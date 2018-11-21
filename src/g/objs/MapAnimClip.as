package g.objs{
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.utils.getQualifiedClassName;
	import framework.objs.Clip;
	import framework.game.Game;
	import framework.utils.FuncUtil;
	
	public class MapAnimClip extends DisplayObj{
		
		private var _listObjs:Array;
		
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
			_listObjs=transformChildsToClips(info.mc,Sprite(_view));
			
		}
		
		private function transformChildsToClips(container:MovieClip,parent:Sprite,outputList:Array=null):Array{
			var list:Array=outputList?outputList:[];
			var clip:*;
			var len:int=container.numChildren;
			var child:DisplayObject;
			for(var i:int=0;i<len;i++){
				child=container.getChildAt(i);
				if(child is MovieClip){
					if(child.name.indexOf("ignore")>-1){//名称含有"ignore"不转换
						clip=child;
					}else{
						var qName:String=getQualifiedClassName(child);
						var isCustomLinkClass:Boolean=qName.indexOf("::MovieClip")<0;
						if(isCustomLinkClass){
							clip=Clip.fromDefName(qName,true);
							clip.transform=child.transform;
							clip.smoothing=true;
						}else{
							clip=Clip.fromDisplayObject(child);
						}
					}
				}else{
					clip=Clip.fromDisplayObject(child);
				}
				clip.filters=child.filters;
				list.push(clip);
			}
			for(i=0;i<list.length;i++){
				parent.addChild(list[i]);
			}
			return list;
		}
		
		override protected function onDestroy():void{
			FuncUtil.removeChildList(_listObjs);
			_listObjs=null;
			super.onDestroy();
		}
	};

}