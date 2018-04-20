package g.components{
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.filters.GlowFilter;
	import flash.geom.Point;
	import framework.objs.Component;
	import framework.utils.RandomKb;
	/*
	private var _arc:Arc;
	_arc=this.addComponent(Arc) as Arc;
	_arc.initialize(x0,y0,x1,y1,_game.global.layerMan.items3Layer);
	
	override protected function update():void{
		//_arc.bindPos(x0,y0,x1,y1);
	}
	
	*/
	
	/**画电弧波浪线*/
	public class Arc extends Component{
		
		public function Arc(){
			super();
		}
		
		private var _canvas:Sprite;
		private var _shapes:Vector.<Shape>;
		private var _pos0:Point;
		private var _pos1:Point;
		private var _thickness:Number;
		private var _lineColor:uint;
		private var _filters:Array;
		
		public function initialize(x0:Number,y0:Number,x1:Number,y1:Number,parent:Sprite,deth:int=-1,thickness:Number=4,lineColor:uint=0xffffff,filters:Array=null):void{
			_pos0=new Point(x0,y0);
			_pos1=new Point(x1,y1);
			_thickness=thickness;
			_lineColor=lineColor;
			_filters=filters; _filters||=[new GlowFilter(0x00ffff,1,4,4,5)];
			_canvas=new Sprite();
			if(deth>-1)parent.addChildAt(_canvas,deth);
			else       parent.addChild(_canvas);
			_shapes=new Vector.<Shape>();
		}
		
		public function bindPos(x0:Number,y0:Number,x1:Number,y1:Number):void{
			_pos0.x=x0;
			_pos0.y=y0;
			_pos1.x=x1;
			_pos1.y=y1;
		}
		
		override protected function update():void{
			super.update();
			drawWaveLine();
			
			var i:int=_shapes.length;
			while (--i>=0){
				var s:Shape=_shapes[i];
				s.alpha-=0.2;
				if(s.alpha<=0){
					_canvas.removeChild(s);
					_shapes.splice(i,1);
				}
			}
		}
		
		private function drawWaveLine():void{
			var angle:Number=Math.atan2(_pos1.y-_pos0.y,_pos1.x-_pos0.x)*57.3;
			var len:Number=Point.distance(_pos0,_pos1);
			var sp:Shape=new Shape();
			sp.x=_pos0.x;
			sp.y=_pos0.y;
			sp.rotation=angle;
			sp.filters=_filters;
			_canvas.addChild(sp);
			
			sp.graphics.lineStyle(_thickness,_lineColor);
			var x:Number=0,y:Number=0;
			while(true){
				x+=RandomKb.range(10,20,true);
				y=RandomKb.range(0,6,true)*RandomKb.wave;
				if(x>=len){ x=len; y=0; }
				sp.graphics.lineTo(x,y);
				if(x>=len)break;
			}
			_shapes.push(sp);
		}
		
		override protected function onDestroy():void{
			if(_canvas.parent)_canvas.parent.removeChild(_canvas);
			_filters=null;
			_canvas=null;
			_shapes=null;
			super.onDestroy();
		}
		
	};

}