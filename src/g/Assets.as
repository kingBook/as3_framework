package g{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.utils.setTimeout;
	import g.MyData;
	import g.AssetsLoader;
	import flash.utils.Dictionary;
	import g.map.MapData;
	
	public dynamic class Assets extends EventDispatcher{
		
		[Embed(source = '../../bin/assets/assetDatabase.xml', mimeType='application/octet-stream')]
		private const assetDatabase:Class;
		[Embed(source = '../../bin/assets/levelConfig.xml', mimeType='application/octet-stream')]
		private const levelConfig:Class;
		[Embed(source = '../../bin/assets/level_1.xml', mimeType='application/octet-stream')]
		private const level_1:Class;
		[Embed(source = '../../bin/assets/level_2.xml', mimeType='application/octet-stream')]
		private const level_2:Class;
		[Embed(source = '../../bin/assets/level_3.xml', mimeType='application/octet-stream')]
		private const level_3:Class;
		[Embed(source = '../../bin/assets/level_4.xml', mimeType='application/octet-stream')]
		private const level_4:Class;
		[Embed(source = '../../bin/assets/level_5.xml', mimeType='application/octet-stream')]
		private const level_5:Class;
		[Embed(source = '../../bin/assets/level_6.xml', mimeType='application/octet-stream')]
		private const level_6:Class;
		[Embed(source = '../../bin/assets/level_7.xml', mimeType='application/octet-stream')]
		private const level_7:Class;
		[Embed(source = '../../bin/assets/level_8.xml', mimeType='application/octet-stream')]
		private const level_8:Class;
		[Embed(source = '../../bin/assets/level_9.xml', mimeType='application/octet-stream')]
		private const level_9:Class;
		[Embed(source = '../../bin/assets/level_10.xml', mimeType='application/octet-stream')]
		private const level_10:Class;
		[Embed(source = '../../bin/assets/level_11.xml', mimeType='application/octet-stream')]
		private const level_11:Class;
		[Embed(source = '../../bin/assets/level_12.xml', mimeType='application/octet-stream')]
		private const level_12:Class;
		[Embed(source = '../../bin/assets/level_13.xml', mimeType='application/octet-stream')]
		private const level_13:Class;
		[Embed(source = '../../bin/assets/level_14.xml', mimeType='application/octet-stream')]
		private const level_14:Class;
		[Embed(source = '../../bin/assets/level_15.xml', mimeType='application/octet-stream')]
		private const level_15:Class;
		[Embed(source = '../../bin/assets/level_16.xml', mimeType='application/octet-stream')]
		private const level_16:Class;
		[Embed(source = '../../bin/assets/level_17.xml', mimeType='application/octet-stream')]
		private const level_17:Class;
		[Embed(source = '../../bin/assets/level_18.xml', mimeType='application/octet-stream')]
		private const level_18:Class;
		[Embed(source = '../../bin/assets/level_19.xml', mimeType='application/octet-stream')]
		private const level_19:Class;
		[Embed(source = '../../bin/assets/level_20.xml', mimeType='application/octet-stream')]
		private const level_20:Class;
		[Embed(source = '../../bin/assets/level_21.xml', mimeType='application/octet-stream')]
		private const level_21:Class;
		[Embed(source = '../../bin/assets/level_22.xml', mimeType='application/octet-stream')]
		private const level_22:Class;
		[Embed(source = '../../bin/assets/level_23.xml', mimeType='application/octet-stream')]
		private const level_23:Class;
		[Embed(source = '../../bin/assets/level_24.xml', mimeType='application/octet-stream')]
		private const level_24:Class;
		[Embed(source = '../../bin/assets/level_25.xml', mimeType='application/octet-stream')]
		private const level_25:Class;
		
		/*[Embed(source="../../bin/assets/level_1.tmx", mimeType="application/octet-stream")]
		private const level_1:Class;*/
		
		private var _assetsLoader:AssetsLoader;
		private var _files:Dictionary;

		public function init():void{
			new SwcClassConfig();
			if(MyData.isLoadLevelXML){
				loadFiles();
			}else{
				setTimeout(loaded,1);
			}
		}
		private function loadFiles():void{
			//initialize urls
			var urls:Array=[];
			urls.push('./bin/assets/assetDatabase.xml');
			urls.push('./bin/assets/levelConfig.xml');
			for(var i:int=1;i<=MapData.maxLevel;i++){
				urls.push('./bin/assets/level_'+i+'.xml');
			}
			//load urls
			_assetsLoader=new AssetsLoader();
			_assetsLoader.init();
			_assetsLoader.loadUrls(Vector.<String>(urls),loaded);
		}
		
		private function loaded(e:Event=null):void{
			e && e.target.removeEventListener(Event.COMPLETE, loaded);
			//
			_files=new Dictionary();
			var assetDatabaseFileName:String="assetDatabase";
			var levelConfigFileName:String="levelConfig";
			var fileName:String;
			var i:int;
			if(MyData.isLoadLevelXML){
				_files[assetDatabaseFileName+".xml"]=XML(_assetsLoader.getFileWithName(assetDatabaseFileName+".xml"));
				_files[levelConfigFileName+".xml"]=XML(_assetsLoader.getFileWithName(levelConfigFileName+".xml"));
				for(i=1;i<=MapData.maxLevel;i++){
					fileName="level_"+i+".xml";
					_files[fileName]=XML(_assetsLoader.getFileWithName(fileName));
				}
			}else{
				_files[assetDatabaseFileName+".xml"]=XML(getEmbedFileWithName(assetDatabaseFileName));
				_files[levelConfigFileName+".xml"]=XML(getEmbedFileWithName(levelConfigFileName));
				for(i=1;i<=MapData.maxLevel;i++){
					fileName="level_"+i+".xml";
					_files[fileName]=XML(getEmbedFileWithName("level_"+i));
				}
			}
			dispatchEvent(new Event(Event.COMPLETE));
		}

		public function getFileWithName(fileName:String):*{
			return _files[fileName];
		}
		private function getEmbedFileWithName(name:String):*{
			var _C:Class=this[name];
			if(_C){
				return new _C();
			}else{
				throw new Error("没有嵌入名为"+name+"的文件");
			}
			return null;
		}

		private function release():void{
			if(_assetsLoader){
				_assetsLoader.release();
				_assetsLoader=null;
			}
			for(var key:* in _files)delete _files[key];
			_files=null;
		}
		
		private static var _instance:Assets;
		public static function getInstance():Assets{
			return _instance||=new Assets();
		}
		public static function destroyInstance():void{
			if(_instance)_instance.release();
			_instance=null;
		}
		
	};

}

