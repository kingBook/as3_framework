package g.objs{
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import framework.game.Game;
	import g.objs.MyObj;
	/**实现拖列表a的对象到列表b中的匹配项位置*/
	public class MatchBehavior extends MyObj{
		
		private var _aList:*;
		private var _bList:*;
		private var _bTargetFrame:int;
		private var _curDragTarget:*;
		private var _aMatrixList:Array;
		private var _onInstallFinishCallback:Function;
		
		public static function create(aList:*,bList:*,aStopFrame:int,bInitFrame:int,bTargetFrame:int,onInstallFinishCallback:Function=null):MatchBehavior{
			var game:Game=Game.getInstance();
			var info:*={};
			info.aList=aList;
			info.bList=bList;
			info.bInitFrame=bInitFrame;
			info.bTargetFrame=bTargetFrame;
			info.aStopFrame=aStopFrame;
			info.onInstallFinishCallback=onInstallFinishCallback;
			return game.createGameObj(new MatchBehavior(),info);
		}
		
		public function MatchBehavior(){
			super();
		}
		
		override protected function init(info:*=null):void{
			super.init(info);
			_aList=info.aList;
			_bList=info.bList;
			_bTargetFrame=info.bTargetFrame;
			_onInstallFinishCallback=info.onInstallFinishCallback;
			
			for(var i:int=0;i<_aList.length;i++){
				var aMc:MovieClip=_aList[i];
				aMc.mouseChildren=false;
				aMc.gotoAndStop(info.aStopFrame);
				_aMatrixList||=[];
				_aMatrixList[i]=aMc.transform.matrix.clone();
			}
			for(var j:int=0;j<_bList.length;j++){
				var bMc:MovieClip=_bList[j];
				bMc.gotoAndStop(info.bInitFrame);
			}
			
			_game.global.stage.addEventListener(MouseEvent.MOUSE_DOWN,mouseHandler);
			_game.global.stage.addEventListener(MouseEvent.MOUSE_UP,mouseHandler);
			
		}
		
		private function mouseHandler(e:MouseEvent):void{
			if(e.type==MouseEvent.MOUSE_DOWN){
				var id:int=_aList.indexOf(e.target);
				if(id>-1){
					var aMc:MovieClip=_aList[id];
					if(aMc.visible&&_curDragTarget==null){
						_curDragTarget=aMc;
						aMc.transform.matrix=_bList[id].transform.matrix;
						syncCurDragTargetToMouseXY();
					}
				}
			}else{
				if(_curDragTarget){
					id=_aList.indexOf(_curDragTarget);
					var bMc:MovieClip=_bList[id];
					
					var dx:Number=bMc.x-_curDragTarget.x;
					var dy:Number=bMc.y-_curDragTarget.y;
					var d:Number=Math.sqrt(dx*dx+dy*dy);
					//
					var recordMat:Matrix=_aMatrixList[id];
					var matrix:Matrix=_curDragTarget.transform.matrix.clone();
					matrix.a=recordMat.a;
					matrix.b=recordMat.b;
					matrix.c=recordMat.c;
					matrix.d=recordMat.d;
					_curDragTarget.transform.matrix=matrix;
					moveTo(_curDragTarget,recordMat.tx,recordMat.ty,0.5);
					//
					_curDragTarget=null;
				}
			}
		}
		
		override protected function update():void{
			super.update();
			syncCurDragTargetToMouseXY();
			if(_curDragTarget){
				var id:int=_aList.indexOf(_curDragTarget);
				var bMc:MovieClip=_bList[id];
				
				var dx:Number=bMc.x-_curDragTarget.x;
				var dy:Number=bMc.y-_curDragTarget.y;
				var d:Number=Math.sqrt(dx*dx+dy*dy);
				if(d<15){
					_curDragTarget.visible=false;
					_curDragTarget=null;
					bMc.gotoAndStop(_bTargetFrame);
					if(getInstalled())onInstallFinish();
				}
			}
		}
		
		private function syncCurDragTargetToMouseXY():void{
			if(_curDragTarget){
				var rect:Rectangle=_curDragTarget.getBounds(_curDragTarget.parent);
				var centerX:Number=rect.x+rect.width*0.5;
				var centerY:Number=rect.y+rect.height*0.5;
				_curDragTarget.x=_curDragTarget.parent.mouseX-(centerX-_curDragTarget.x);
				_curDragTarget.y=_curDragTarget.parent.mouseY-(centerY-_curDragTarget.y);
			}
		}
		
		private function getInstalled():Boolean{
			var result:Boolean=true;
			for(var i:int=0;i<_aList.length;i++){
				if(_aList[i].visible){
					result=false;
					break;
				}
			}
			return result;
		}
		
		private function onInstallFinish():void{
			if(_onInstallFinishCallback!=null)_onInstallFinishCallback();
		}
		
		override protected function onDestroy():void{
			_game.global.stage.removeEventListener(MouseEvent.MOUSE_DOWN,mouseHandler);
			_game.global.stage.removeEventListener(MouseEvent.MOUSE_UP,mouseHandler);
			_aList=null;
			_bList=null;
			_aMatrixList=null;
			_curDragTarget=null;
			super.onDestroy();
		}
		
	};

}