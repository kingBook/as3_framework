package g{
	import flash.display.Loader;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.events.Event;
	import flash.utils.Dictionary;

	public class AssetsLoader{
		private var _loader:URLLoader;
		private var _urls:Vector.<String>;
		private var _loadCount:int;
		private var _onLoaderFilesComplete:Function;
		private var _dict:Dictionary;
		public function init():void{
			_loader=new URLLoader();
			_dict=new Dictionary();
		}
		/**加载多个文件 */
		public function loadUrls(urls:Vector.<String>,complete:Function=null):void{
			_urls=urls;
			_onLoaderFilesComplete=complete;
			_loadCount=0;
			load(_urls[_loadCount]);
		
		}
		private function load(url:String):void{
			_loader.load(new URLRequest(url));
			_loader.addEventListener(Event.COMPLETE,onComplete);
		}
		private function onComplete(e:Event):void{
			//存到字典里
			var data:*=_loader.data;
			var key:String=_urls[_loadCount];
			key=key.substr(key.lastIndexOf("/")+1);//只留名称和后缀如：“level_1.xml”
			_dict[key]=data;
			//加载下一个文件
			if(_loadCount<_urls.length-1){
				_loadCount++;
				load(_urls[_loadCount]);
			}else{
				if(_onLoaderFilesComplete!=null){
					_onLoaderFilesComplete();
				}
			}
		}
		/**
		 * 根据名称获取文件
		 * #example
		 * var xml:XML=XML(assetsLoader.getFileWithName(“level_1.xml”));
		 */
		public function getFileWithName(fileName:String):*{
			return _dict[fileName];
		}
		public function release():void{
			for(var key:String in _dict)delete _dict[key];
			_loader.removeEventListener(Event.COMPLETE,onComplete);
			_urls=null;
			_loader=null;
			_onLoaderFilesComplete=null;
			_dict=null;
		}
	}
	
}