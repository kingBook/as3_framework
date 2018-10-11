package framework.objs{
	import framework.namespaces.frameworkInternal;
	use namespace frameworkInternal;
	
	public class ActionToObj extends GameObject{
		
		private var _poolList:*;
		
		public function ActionToObj(){
			super();
		}
		
		/**设置当销毁要从中移除的列表*/
		frameworkInternal function setPoolList(list:*):void{
			_poolList=list;
		}
		
		override protected function onDestroy():void{
			if(_poolList){
				var id:int=_poolList.indexOf(this);
				if(id>-1)_poolList[id]=null;
				_poolList=null;
			}
			super.onDestroy();
		}
		
	};

}