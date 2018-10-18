package g{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.utils.Dictionary;
	import flash.utils.setTimeout;
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
		

		public function init():void{
			new SwcClassConfig();
			setTimeout(loaded,1);
		}
		
		private function loaded(e:Event=null):void{
			e && e.target.removeEventListener(Event.COMPLETE, loaded);
			//
			dispatchEvent(new Event(Event.COMPLETE));
		}
		
		/**
		 * 返回指定名称的嵌入文件
		 * @param	name 嵌入代码下一行的Class成员名称
		 * @return 
		 */
		public function getEmbedFileWithName(name:String):*{
			var _C:Class=this[name];
			if(_C){
				return new _C();
			}else{
				throw new Error("没有嵌入名为"+name+"的文件");
			}
			return null;
		}

		private function onDestroy():void{
			//
		}
		
		private static var _instance:Assets;
		public static function getInstance():Assets{
			return _instance||=new Assets();
		}
		public static function destroy():void{
			if(_instance)_instance.onDestroy();
			_instance=null;
		}
		
	};

}

