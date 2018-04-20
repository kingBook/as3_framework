package g.components{
	import framework.objs.Component;
	import flash.geom.Point;
	import flash.display.Sprite;
	/**下雪背景*/
	public class Snow extends Component{
		
		public function Snow(){
			super();
		}
		
		private var _snowFlakes:Vector.<Snowflake>;
		private var _count:int;
		
		public function initialize(parent:Sprite=null,rmin:Number=1,rmax:Number=4,vymin:Number=0.5,vymax:Number=2,xmin:Number=0,xmax:Number=800,ymin:Number=0,ymax:Number=600,count:int=150):void{
			_count=count;
			_snowFlakes=new Vector.<Snowflake>();
			for(var i:int=0;i<count;i++){
				var snowFlake:Snowflake=new Snowflake();
				snowFlake.initialize(parent,rmin,rmax,vymin,vymax,xmin,xmax,ymin,ymax);
				_snowFlakes.push(snowFlake);
			}
		}
		
		override protected function update():void{
			for(var i:int=0;i<_count;i++){
				_snowFlakes[i].update();
			}
		}
		
		override protected function onDestroy():void{
			var i:int=_snowFlakes.length;
			while(--i>=0) _snowFlakes[i].dispose();
			_snowFlakes=null;
			super.onDestroy();
		}
	}
}
import flash.display.GradientType;
import flash.display.Sprite;
import flash.display.BitmapData;
import flash.display.Shape;
import flash.display.Bitmap;
import flash.geom.Matrix;
import flash.geom.Point;

/**雪花*/
class Snowflake{
	public function Snowflake(){super();}
	
	private var _vy:Number;
	private var _xmin:Number;
	private var _xmax:Number;
	private var _ymin:Number;
	private var _ymax:Number;
	private var _bmp:Bitmap;
	private var _radius:int;
	private var _pos:Point;
	
	
	
	public function initialize(parent:Sprite,rmin:Number,rmax:Number,vymin:Number,vymax:Number,xmin:Number,xmax:Number,ymin:Number,ymax:Number):void{
		_vy=Math.random()*(vymax-vymin)+vymin;;
		_xmin=xmin;
		_xmax=xmax;
		_ymin=ymin;
		_ymax=ymax;
		_radius=int(Math.random()*(rmax-rmin)+rmin);
		
		var x:Number=Math.random()*(xmax-xmin)+xmin;
		var y:Number=Math.random()*(ymax-ymin)+ymin;
		
		_bmp=getDraw();
		_bmp.x=x-_radius;
		_bmp.y=y-_radius;
		if(parent)parent.addChild(_bmp);

	}
	
	private function getDraw():Bitmap{
		var sp:Shape=new Shape();
		
		/*var colors:Array=[0xffffff,0xffffff];
		var alphas:Array=[1,0];
		var ratios:Array=[0,20];
		sp.graphics.beginGradientFill(GradientType.RADIAL,colors,alphas,ratios);*/
		
		sp.graphics.beginFill(0xffffff,Math.random()*(1-0.5)+0.5);
		sp.graphics.drawCircle(0,0,_radius);
		sp.graphics.endFill();
		
		var bmd:BitmapData=new BitmapData(int(sp.width+0.9),int(sp.height+0.9),true,0x000000);
		var matrix:Matrix=new Matrix();
		matrix.tx=_radius;
		matrix.ty=_radius;
		bmd.draw(sp,matrix);
		return new Bitmap(bmd);
	}
	
	public function update():void{
		_bmp.y+=_vy;
		if(_bmp.y>=_ymax){
			_bmp.y=_ymin-_bmp.height;
		}
		
	}
	
	public function dispose():void{
		if(_bmp){
			if(_bmp.parent){
				_bmp.parent.removeChild(_bmp);
				_bmp.bitmapData.dispose();
			}
			_bmp=null;
		}
		_pos=null;
	}
	
}