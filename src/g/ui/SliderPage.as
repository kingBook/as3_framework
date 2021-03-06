﻿package g.ui{
	import flash.display.InteractiveObject;
	import flash.display.Stage;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import framework.game.Game;
	import g.events.MyEvent;
	import g.objs.MyObj;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	/**滑页*/
	public class SliderPage extends MyObj{
		public static const SCORLL_END:String="scorllEnd";
		public static const ENTER_PAGE:String="enterPage";//除了第一次初始页不派发，之后每次进入新页都派发
		private var _scorllEndEvent:MyEvent=new MyEvent(SCORLL_END);
		private var _enterPageEvent:MyEvent=new MyEvent(ENTER_PAGE,{pageId:0});
		
		private var _targets:Vector.<DisplayObject>;
		private var _isMouseDown:Boolean;
		private var _xmouse:Number;
		private var _pts0:Vector.<Number>;
		private var _pts:Vector.<Number>;
		private var _pageID:int;
		private var _recordScorllEndPageId:int;
		private var _vx:Number;
		private var _isTweenToPtEnd:Boolean;//用于避免重复发送SCORLL_END事件
		private var _isDoSetPageing:Boolean;
		private var _isResisePts:Boolean;
		private var _isSetTargetsMouseEnabled:Boolean;
		private var _targetsMouseEnabled:Boolean=true;
		public var enabledMouse:Boolean=true;
		
		private var _stageRect:Rectangle;
		
		/**
		 * 创建一个x滑页
		 * @param	targets 目标显示对象列表
		 * @param	pts 每页targets[0]的x坐标
		 * @param	pageID 初始页id
		 * @param	isResisePts 改变舞台大小是否更新pts里的坐标
		 * @param	isSetTargetsMouseEnabled 滚动时禁止点击target(防止在滚动时触发点击target)
		 * @return
		 */
		public static function create(targets:Array,pts:Vector.<Number>,pageID:int=0,isResisePts:Boolean=true,isSetTargetsMouseEnabled:Boolean=true):SliderPage{
			var game:Game=Game.getInstance();
			var info:*={};
			info.targets=Vector.<DisplayObject>(targets);
			info.pts=pts;
			info.pageID=pageID;
			info.isResisePts=isResisePts;
			info.isSetTargetsMouseEnabled=isSetTargetsMouseEnabled;
			return game.createGameObj(new SliderPage(),info) as SliderPage;
		}
		
		override protected function init(info:* = null):void{
			super.init(info);
			_targets=info.targets;
			_pts=info.pts;
			_pts0=_pts.concat();
			_pageID=info.pageID;
			_recordScorllEndPageId=_pageID;
			_isResisePts=info.isResisePts;
			_isSetTargetsMouseEnabled=info.isSetTargetsMouseEnabled;
			addVToTargets(_pts[_pageID]-_targets[0].x);
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
			if(e.type==MouseEvent.MOUSE_DOWN){
				_isTweenToPtEnd=false;
			}
		}
		
		private function onResize(e:Event=null):void{
			if(_isResisePts){
				for(var i:int=0;i<_pts.length;i++){
					_pts[i]=_pts0[i]*_myGame.myGlobal.resizeMan.curWScale;
				}
			}
			checkOutsideStage();
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
				if(Math.abs(_vx)>=1){
					setTargetsMouseEnabled(false);
				}
			}else{
				var nearestPageId:int=getNearestPageID();
				if(_isDoSetPageing){//强制设置到某页时，如果当前内容页是设定页,则不再强制
					if(nearestPageId==_pageID) _isDoSetPageing=false;
				}else{
					_pageID=nearestPageId;
				}
				tweenToPt(0.2,_pts[_pageID]);
			}
			
			//舞台外部的隐藏
			checkOutsideStage();
		}
		
		private function checkOutsideStage():void{
			var stage:Stage=_game.global.stage;
			
			const offset:int=10;
			_stageRect=new Rectangle();
			_stageRect.x=-offset;
			_stageRect.y=-offset;
			_stageRect.width=stage.stageWidth+offset;
			_stageRect.height=stage.stageHeight+offset;
			
			for(var i:int=0;i<_targets.length;i++){
				var target:DisplayObject=_targets[i];
				var targetRect:Rectangle=target.getBounds(stage);
				target.visible=targetRect.intersects(_stageRect);
			}
			
			/*var str:String="";
			for(i=0;i<_targets.length;i++){
				str+=_targets[i].visible+","
			}
			trace(str);*/
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
			if(Math.abs(_vx)<1){
				if(!_isTweenToPtEnd){
					addVToTargets(pt-_targets[0].x);
					setTargetsMouseEnabled(true);
					_isTweenToPtEnd=true;
					
					dispatchEvent(_scorllEndEvent);
					if(_pageID!=_recordScorllEndPageId){
						_enterPageEvent.info.pageId=_pageID;
						dispatchEvent(_enterPageEvent);
						_recordScorllEndPageId=_pageID;
					}
				}
			}else{
				_isTweenToPtEnd=false;
			}
		}
		
		private function setTargetsMouseEnabled(value:Boolean):void{
			if(!_isSetTargetsMouseEnabled)return;
			if(_targetsMouseEnabled==value)return;
			_targetsMouseEnabled=value;
			var i:int=_targets.length;
			while(--i>=0){
				var target:InteractiveObject=_targets[i] as InteractiveObject;
				if(target){
					target.mouseEnabled=_targetsMouseEnabled;
				}
			}
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
			pageID=Math.max(Math.min(_pts.length-1,pageID),0);
			if(_pageID!=pageID){
				_pageID=pageID;
				_isTweenToPtEnd=false;
				_isDoSetPageing=true;
			}
		}
		
		private function move(vx:Number):void{
			var len:Number=Math.abs(vx);
			if(len<1)return;
			
			var dir:int=vx>=0?1:-1;
			vx=int(len+0.5)*dir;//必须取整，否则反复会出现精度不准确位置
			
			addVToTargets(vx);
		}
		private function addVToTargets(vx:Number,vy:Number=0):void{
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
			_scorllEndEvent=null;
			_enterPageEvent=null;
			_stageRect=null;
			super.onDestroy();
		}
		
		/**0~pts.length-1*/
		public function get pageID():int{return _pageID;}
		public function get isScrolling():Boolean{return Math.abs(_targets[0].x-_pts[_pageID])>1;}
		
	};

}