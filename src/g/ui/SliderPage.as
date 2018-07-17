package g.ui{
	import flash.events.MouseEvent;
	import framework.game.Game;
	import g.objs.MyObj;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	/**滑页*/
	public class SliderPage extends MyObj{
		
		private var _targets:Vector.<DisplayObject>;
		private var _isMouseDown:Boolean;
		private var _xmouse:Number;
		private var _pts0:Vector.<Number>;
		private var _pts:Vector.<Number>;
		private var _pageID:int;
		private var _vx:Number;
		private var _isDoSetPageing:Boolean;
		public var enabledMouse:Boolean=true;
		
		/**
		 * 创建一个x滑页
		 * @param	targets 目标显示对象列表
		 * @param	pts 每页targets[0]的x坐标
		 * @param	pageID 初始页id
		 * @return
		 */
		public static function create(targets:Array,pts:Vector.<Number>,pageID:int=0):SliderPage{
			var game:Game=Game.getInstance();
			var info:*={};
			info.targets=Vector.<DisplayObject>(targets);
			info.pts=pts;
			info.pageID=pageID;
			return game.createGameObj(new SliderPage(),info) as SliderPage;
		}
		
		override protected function init(info:* = null):void{
			super.init(info);
			_targets=info.targets;
			_pts=info.pts;
			_pts0=_pts.concat();
			_pageID=info.pageID;
			move(_pts[_pageID]-_targets[0].x);
			_vx=0;
			_game.global.stage.addEventListener(MouseEvent.MOUSE_DOWN,mouseHandler);
			_game.global.stage.addEventListener(MouseEvent.MOUSE_UP,mouseHandler);
			_game.global.stage.addEventListener(Event.RESIZE,onResize);
			onResize();
		}
		
		private function mouseHandler(e:MouseEvent):void{
			if(enabledMouse){
				setMouseDown(e.type==MouseEvent.MOUSE_DOWN);
			}
		}
		
		private function onResize(e:Event=null):void{
			for(var i:int=0;i<_pts.length;i++){
				_pts[i]=_pts0[i]*_myGame.myGlobal.resizeMan.curWScale;
			}
		}
		
		override protected function update():void{
			super.update();
			if(_isMouseDown){
				var target0:DisplayObject=_targets[0];
				_vx=_game.global.stage.mouseX-_xmouse;
				var xmax:Number=_pts[0];
				var xmin:Number=_pts[_pts.length-1];
				if(target0.x<xmin)_vx*=0.2;
				else if(target0.x>xmax)_vx*=0.2;
				move(_vx);
				_xmouse=_game.global.stage.mouseX;
			}else{
				var nearestPageId:int=getNearestPageID();
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
				var tmpd:Number=Math.abs(_pts[i]-_targets[0].x);
				if(tmpd<d){
					d=tmpd;
					id=i;
				}
			}
			return id;
		}
		
		private function tweenToPt(friction:Number,pt:Number):void{
			_vx=(pt-_targets[0].x)*friction;
			move(_vx);
		}
		
		public function setMouseDown(value:Boolean):void{
			_isMouseDown=value;
			if(_isMouseDown){
				_xmouse=_game.global.stage.mouseX;
			}else{
				var nearestPageId:int=getNearestPageID();
				if(Math.abs(_vx)>=3){
					if(_vx>0)gotoPage(nearestPageId-1);
					else     gotoPage(nearestPageId+1);
				}
			}
		}
		
		public function prevPage():void{
			gotoPage(_pageID-1);
		}
		public function nextPage():void{
			gotoPage(_pageID+1);
		}
		
		private function gotoPage(pageID:int):void{
			_pageID=Math.max(Math.min(_pts.length-1,pageID),0);
			_isDoSetPageing=true;
		}
		
		private function move(vx:Number):void{
			var len:Number=Math.abs(vx);
			if(len<1)return;
			
			var dir:int=vx>=0?1:-1;
			vx=int(len+0.5)*dir;
			
			var i:int=_targets.length;
			while (--i>=0){
				_targets[i].x+=vx;
			}
		}
		
		override protected function onDestroy():void{
			_game.global.stage.removeEventListener(MouseEvent.MOUSE_DOWN,mouseHandler);
			_game.global.stage.removeEventListener(MouseEvent.MOUSE_UP,mouseHandler);
			_game.global.stage.removeEventListener(Event.RESIZE,onResize);
			_targets=null;
			_pts=null;
			_pts0=null;
			super.onDestroy();
		}
		
		/**0~pts.length-1*/
		public function get pageID():int{return _pageID;}
		public function get isScrolling():Boolean{return Math.abs(_targets[0].x-_pts[_pageID])>1;}
		
	};

}