package g.ui{
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.utils.getQualifiedClassName;
	import framework.game.Game;
	import framework.utils.FuncUtil;
	import framework.utils.LibUtil;
	import flash.display.DisplayObject;
	import flash.geom.Vector3D;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.display.Stage;
	import flash.geom.PerspectiveProjection;
	import flash.events.MouseEvent;
	import framework.utils.Mathk;
	import g.objs.MyObj;

	/**滑动选关页*/
	public class PhotoSelectPage extends MyObj{
		private static var _lastClickLevel:int;
		private var _ui:UI;
		private var _mc:MovieClip;
		private var _prevPage:MovieClip;
		private var _nextPage:MovieClip;
		private var _container:Sprite;
		private var _items:Array=[];
		private var _radius:Number=1200;//3d绕y轴的圆半径
		private var _targetAngle:Number;
		private var _maxLevel:int;
		
		
		public static function create(ui:UI,mc:MovieClip,unlockLevel:int,maxLevel:int):void{
			var game:Game=Game.getInstance();
			var info:*={};
			info.ui=ui;
			info.mc=mc;
			info.unlockLevel=unlockLevel;
			info.maxLevel=maxLevel;
			game.createGameObj(new PhotoSelectPage(),info);
		}
		
		public function PhotoSelectPage(){
			super();
		}
		
		override protected function init(info:* = null):void{
			super.init(info);
			_ui=info.ui;
			_maxLevel=info.maxLevel;
			_mc=info.mc;			
			
			_prevPage=_mc["prevPage"];
			_nextPage=_mc["nextPage"];
			
			var numMc:MovieClip=_mc["numMc"];//多帧的数字元件,将获取类链接名再制多个进行排列
			_container=new Sprite();
			_container.y=0;
			_container.z=0;
			_container.scaleX=_container.scaleY=_container.scaleZ=0.3;
			var showLevel:int=_lastClickLevel>0?_lastClickLevel:info.unlockLevel;
			_container.rotationY=(Math.PI*2/info.maxLevel*(showLevel-1))*Mathk.Rad2Deg+90;//滚动到解锁的关卡
			_container.transform.perspectiveProjection=new PerspectiveProjection();
			_container.transform.perspectiveProjection.projectionCenter=new Point(0,0);
			_targetAngle=_container.rotationY;
			_mc.addChildAt(_container,0);
			FuncUtil.removeChild(numMc);
			
			var defName:String=getQualifiedClassName(numMc);
			createItems(defName,info.unlockLevel,info.maxLevel);
			sortItems();
			
			_mc.addEventListener(MouseEvent.CLICK,clickHandler);
			
		}
		
		private function clickHandler(e:MouseEvent):void{
			if(e.target==_prevPage){
				_targetAngle-=(Math.PI*2/_maxLevel*(4-1))*Mathk.Rad2Deg;//4表示正面能看的关卡按钮个数
			}else if(e.target==_nextPage){
				_targetAngle+=(Math.PI*2/_maxLevel*(4-1))*Mathk.Rad2Deg;
			}else if(_items.indexOf(e.target)>-1){//点击关卡数字按钮
				var numMc:MovieClip=e.target as MovieClip;
				if(numMc){
					var numMcName:String=e.target.name;
					var level:int=int(numMcName.substr(3));
					_lastClickLevel=level;
					
					_ui.skipToLevel(level);
					destroy(this);
				}
			}
		}
		
		override protected function update():void{
			super.update();
			_container.rotationY+=(_targetAngle-_container.rotationY)*0.05;
			_container.rotationX=(_mc.mouseY-_container.y)*0.02;
			_prevPage.rotationX=(_mc.mouseY-_container.y)*0.02;
			_nextPage.rotationX=(_mc.mouseY-_container.y)*0.02;
			sortItems();
		}
		
		private function sortItems():void{
			_items.sort(depthSort);
			for(var i:int=0;i<_items.length;i++){
				_container.addChildAt(_items[i],i);
			}
		}
		
		private function depthSort(objA:DisplayObject, objB:DisplayObject):int{
			var posA:Vector3D=objA.transform.matrix3D.position;
			posA=_container.transform.matrix3D.deltaTransformVector(posA);
			var posB:Vector3D=objB.transform.matrix3D.position;
			posB=_container.transform.matrix3D.deltaTransformVector(posB);
			return posB.z-posA.z;
		}
		
		private function createItems(defName:String,unlockLevel:int,maxLevel:int):void{
			for(var i:int=0;i<maxLevel;i++){
				var imc:MovieClip=LibUtil.getDefMovie(defName);
				
				var ilevel:Number=i+1;
				var frameNum:int=(ilevel<=unlockLevel)?ilevel:imc.totalFrames;
				imc.name="num"+ilevel;
				imc.gotoAndStop(frameNum);
				
				var angle:Number=Math.PI*2/maxLevel*i;
				imc.x=Math.cos(angle)*_radius;
				imc.z=Math.sin(angle)*_radius;
				imc.rotationY=-360/maxLevel*i+90+180;
				_container.addChild(imc);
				
				_items.push(imc);
				
			}
		}
		
		override protected function onDestroy():void{
			_mc.removeEventListener(MouseEvent.CLICK,clickHandler);
			FuncUtil.removeChild(_mc);
			FuncUtil.removeChild(_container);
			_prevPage=null;
			_nextPage=null;
			_items=null;
			_container=null;
			_mc=null;
			_ui=null;
			super.onDestroy();
		}
		
	};

}