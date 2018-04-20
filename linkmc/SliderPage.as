package {
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	public class SliderPage{
		
		private var _target:DisplayObject;
		private var _isMouseDown:Boolean;
		private var _xmouse:Number;
		private var _pts:Vector.<Number>;
		private var _pageID:int;
		private var _vx:Number;
		private var _isDoSetPageing:Boolean;
		
		public static function create(target:DisplayObject,pts:Vector.<Number>,pageID:int=0):SliderPage{
			var spage:SliderPage=new SliderPage();
			spage.init(target,pts,pageID);
			return spage;
		}
		
		private function init(target:DisplayObject,pts:Vector.<Number>,pageID:int):void{
			_target=target;
			_pts=pts;
			_pageID=pageID;
			_target.x=_pts[_pageID];
			_vx=0;
		}
		
		public function update():void{
			if(_isMouseDown){
				_vx=_target.mouseX-_xmouse;
				var xmax:Number=_pts[0];
				var xmin:Number=_pts[_pts.length-1];
				if(_target.x<xmin)_vx*=0.2;
				else if(_target.x>xmax)_vx*=0.2;
				_target.x+=_vx;
				_xmouse=_target.mouseX;
			}else{
				var nearestPageId:int=getNearestPageID();;
				if(_isDoSetPageing){//强制设置到某页时，如果当前内容页是设定页,则不再强制
					if(nearestPageId==_pageID) _isDoSetPageing=false;
				}else{
					_pageID=nearestPageId;
				}
				tweenToPt(0.2,_pts[_pageID]);
			}
		}
		
		private function getNearestPageID():int{
			var id:int;
			var d:Number=1e6;
			for(var i:int=0;i<_pts.length;i++){
				var tmpd:Number=Math.abs(_pts[i]-_target.x);
				if(tmpd<d){
					d=tmpd;
					id=i;
				}
			}
			return id;
		}
		
		private function tweenToPt(friction:Number,pt:Number):void{
			_vx=(pt-_target.x)*friction;
			_target.x+=_vx;
		}
		
		public function setMouseDown(value:Boolean):void{
			_isMouseDown=value;
			if(_isMouseDown){
				_xmouse=_target.mouseX;
			}
		}
		
		public function prevPage():void{
			_pageID--;
			if(_pageID<0)_pageID=_pts.length-1;
			_isDoSetPageing=true;
		}
		public function nextPage():void{
			_pageID++;
			if(_pageID>=_pts.length)_pageID=0;
			_isDoSetPageing=true;
		}
		
		public function destroy():void{
			_target=null;
			_pts=null;
			
		}
		
		/**0~pts.length-1*/
		public function get pageID():int{return _pageID;}
		public function get isScrolling():Boolean{return Math.abs(_target.x-_pts[_pageID])>1;}
		
	};

}