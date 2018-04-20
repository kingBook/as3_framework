package g.map{
	import g.Assets;
	public class MapData{
		//关卡顺序列表
		private static var _levelOrderList:Array=[1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20];
		//最大关数
		public static function get maxLevel():int{return _levelOrderList.length;}
		private static var _datas:Array;
		
		private static function initDatas():void{
			_datas=[];
			var i:int, len:int=_levelOrderList.length;
			
			var levelConfig:XML=XML(Assets.getInstance().getFileWithName("levelConfig.xml"));
			var sizeList:XMLList=levelConfig.Size;
			
			var data:*={};
			for(i=1;i<=len;i++){
				data={};
				data.size={width:Number(sizeList[i-1].@x),height:Number(sizeList[i-1].@y)};
				data.wallEff={name:"WallEff_mc",frame:i};
				data.wallFrontEff={name:"WallFrontEff_mc",frame:i};
				data.wall={name:"Wall_mc",frame:i};
				data.wallBehindEff={name:"WallBehindEff_mc",frame:i};
				data.bgMiddle={name:"BgMiddle_mc",frame:i};
				data.bgBottom={name:"BgBottom_mc",frame:i};
				_datas[i]=data;
				
			}
		}
		
		public static function getDataObj(gameLevel:int):*{
			if(_datas==null)initDatas();
			var dataLevel:int=getDataLevel(gameLevel);
			return _datas[dataLevel];
		}
		
		public static function getLevelXml(gameLevel:int):XML{
			var dataLevel:int=getDataLevel(gameLevel);
			return XML(Assets.getInstance().getFileWithName("level_"+dataLevel+".xml"));
		}
		
		public static function getTmx(gameLevel:int):XML{
			var dataLevel:int=getDataLevel(gameLevel);
			return XML(Assets.getInstance().getFileWithName("level_"+dataLevel+".tmx"));
		}
		
		/**程序中需要在某特定关卡执行操作时，使用该函数返回特定关卡数，避免交换关卡时产生错误*/
		public static function getDataLevel(gameLevel:int):int{
			return _levelOrderList[gameLevel-1];
		}
		
		public function MapData(){}
		
		
	};

}