package framework.utils {
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.system.ApplicationDomain;
	import framework.system.ObjectPool;
	
	public class LibUtil {
		
		public static function getClass(defName:String):Class {
			var c:Class;
			var curDomain:ApplicationDomain = ApplicationDomain.currentDomain;
			if (curDomain.hasDefinition(defName))
				c = curDomain.getDefinition(defName) as Class;
			else
				trace("警告：无法获取类：" + defName, "请确认类名正确，检查类所在的fla是否发布swf,swf是否正确嵌入");
			return c;
		}
		
		public static function getDefObj(defName:String,pool:ObjectPool=null):* {
			var obj:*;
			if(pool!=null){
				if (pool.has(defName)) {
					obj = pool.get(defName);
				}
				else {
					obj = getNewClass(defName);
					pool.add(obj,defName);
				}
			}else {
				obj = getNewClass(defName);
			}
			return obj;
		}
		
		private static function getNewClass(defName:String):*{
			var __O:Class = getClass(defName);
			var obj:* = __O ? new __O : null;
			return obj;
		}
		
		public static function getDefMovie(defName:String,pool:ObjectPool=null,isStop:Boolean=true):MovieClip {
			var mc:MovieClip = getDefObj(defName,pool) as MovieClip;
			if(mc&&isStop)mc.stop();
			return mc;
		}
		
		public static function getDefDisObj(defName:String,pool:ObjectPool=null):DisplayObject {
			return getDefObj(defName,pool) as DisplayObject;
		}
		
		public static function getDefSprite(defName:String,pool:ObjectPool=null):Sprite {
			return getDefObj(defName,pool) as Sprite;
		}
		
		public static function getDefBitmapData(defName:String,pool:ObjectPool=null):BitmapData{
			return getDefObj(defName,pool) as BitmapData;
		}
		
		public function LibUtil() {
		
		}
		
	};

}