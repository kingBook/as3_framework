package g.components{
	import flash.geom.Point;
	import framework.objs.Component;
	import framework.objs.GameObject;
	//根据一元二次方程返回两点间指定抛物高度任意x位置的y坐标
	//var parabolaLine:ParabolaLine=ParabolaLine.create(new Point(a.x,a.y),new Point(b.x,b.y));
	//var y:Number=parabolaLine.getY(a.x);
	public class ParabolaLine extends Component{
		
		private var _startPt:Point;
		private var _endPt:Point;
		private var _vertexPt:Point;
		private var _a:Number;
		private var _b:Number;
		private var _c:Number;
		
		public static function create(gameObj:GameObject,pt1:Point,pt2:Point,waveHeight:Number=140):ParabolaLine{
			var info:*={};
			info.pt1=pt1;
			info.pt2=pt2;
			info.waveHeight=waveHeight;
			return gameObj.addComponent(ParabolaLine,info) as ParabolaLine;
		}
		
		override protected function init(info:*=null):void{
			super.init(info);
			_startPt=info.pt1;
			_endPt=info.pt2;
			parse(info.waveHeight);
		}
		
		private function parse(waveHeight:Number):void{
			_vertexPt=new Point(_startPt.x+(_endPt.x-_startPt.x)/2,_endPt.y-waveHeight);
			
			var x1:Number=_startPt.x;
			var x2:Number=_endPt.x;
			var x3:Number=_vertexPt.x;
			
			var y1:Number=_startPt.y;
			var y2:Number=_endPt.y;
			var y3:Number=_vertexPt.y;
			
			_b=((y1-y3)*(x1*x1-x2*x2)-(y1-y2)*(x1*x1-x3*x3))/((x1-x3)*(x1*x1-x2*x2)-(x1-x2)*(x1*x1-x3*x3));
			_a=((y1-y2)-_b*(x1-x2))/(x1*x1-x2*x2);
			_c=y1-_a*x1*x1-_b*x1;
		}
		
		public function getY(posX:Number):Number{
			var posY:Number=_a*posX*posX+_b*posX+_c;
			return posY;
		}
		
	};

}