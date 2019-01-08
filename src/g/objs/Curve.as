package g.objs{
	import flash.display.Sprite;
	import flash.geom.Point;
	import framework.game.Game;
	import g.objs.MyObj;
	/**
	 * var curve:Curve=Curve.create();
	 * var curvePoints:Vector.<Point>=curve.createCurve(originPoints);
	 * curve.draw(sprite,originPoints,curvePoints);
	 */
	public class Curve extends MyObj{
		
		public static function create():Curve{
			var game:Game=Game.getInstance();
			var info:*={};
			return game.createGameObj(new Curve(),info) as Curve;
		}
		
		public function Curve(){
			super();
		}
		
		override protected function init(info:*=null):void{
			super.init(info);
			
		}
		
		/**
		 * 创建曲线
		 * @param	originPoint 曲线要经过的点列表
		 * @param	curveRatio (0,1)曲线的疏密
		 * @param	isCap 是否闭合曲线
		 * @return 返回曲线上的点列表
		 */
		public function createCurve(originPoint:Vector.<Point>,curveRatio:Number=0.1,isCap:Boolean=false):Vector.<Point>{
			//控制点收缩系数 ，经调试0.6较好
			const scale:Number=0.6;
			const originCount:int=originPoint.length;
			var midpoints:Vector.<Point>=new Vector.<Point>();
			//生成中点       
			for(var i:int=0;i<originCount;i++){
				var nexti:int=(i+1)%originCount;
				midpoints[i]=new Point((originPoint[i].x + originPoint[nexti].x)/2.0,
									   (originPoint[i].y + originPoint[nexti].y)/2.0);
			}
			  
			//平移中点  
			var extrapoints:Vector.<Point>=new Vector.<Point>(2 * originCount,true);
			for(i=0;i<extrapoints.length;i++)extrapoints[i]=new Point();
			
			for(i=0;i<originCount;i++){
				nexti=(i+1)%originCount;
				var backi:int=(i+originCount-1)%originCount;
				var midinmid:Point=new Point((midpoints[i].x+midpoints[backi].x)/2.0,
											 (midpoints[i].y+midpoints[backi].y)/2.0);
				var offsetx:int=originPoint[i].x-midinmid.x;
				var offsety:int=originPoint[i].y-midinmid.y;
				var extraindex:int=2*i;
				extrapoints[extraindex].x=midpoints[backi].x+offsetx;
				extrapoints[extraindex].y=midpoints[backi].y+offsety;
				 //朝 originPoint[i]方向收缩
				var addx:int=(extrapoints[extraindex].x-originPoint[i].x)*scale;
				var addy:int=(extrapoints[extraindex].y-originPoint[i].y)*scale;
				extrapoints[extraindex].x=originPoint[i].x+addx;
				extrapoints[extraindex].y=originPoint[i].y+addy;
				
				var extranexti:int=(extraindex+1)%(2*originCount);
				extrapoints[extranexti].x=midpoints[i].x+offsetx;
				extrapoints[extranexti].y=midpoints[i].y+offsety;
				//朝 originPoint[i]方向收缩
				addx=(extrapoints[extranexti].x-originPoint[i].x)*scale;
				addy=(extrapoints[extranexti].y-originPoint[i].y)*scale;
				extrapoints[extranexti].x=originPoint[i].x+addx;
				extrapoints[extranexti].y=originPoint[i].y+addy;
				
			}
			var curvePoint:Vector.<Point>=new Vector.<Point>();
			var controlPoint:Vector.<Point>=new Vector.<Point>(4,true);
			//生成4控制点，产生贝塞尔曲线  
			for(i=0;i<originCount;i++){
				if(i>=originCount-1&&isCap==false)break;
				   controlPoint[0]=originPoint[i];
				   extraindex=2*i;
				   controlPoint[1]=extrapoints[extraindex + 1];
				   extranexti=(extraindex+2)%(2*originCount);
				   controlPoint[2]=extrapoints[extranexti];
				   nexti=(i+1)%originCount;
				   controlPoint[3]=originPoint[nexti];  
				   var u:Number=1;
				   while(u>=0){
					   var px:int=bezier3funcX(u,controlPoint);
					   var py:int=bezier3funcY(u,controlPoint);
					   //u的步长决定曲线的疏密  
					   u-=curveRatio;
					   var tempP:Point=new Point(px,py);
					   //存入曲线点
					   curvePoint.push(tempP);
				   }
			}
			return curvePoint;
		}
		//三次贝塞尔曲线  
		private function bezier3funcX(uu:Number,controlP:Vector.<Point>):Number{
		   var part0:Number=controlP[0].x*uu*uu*uu;
		   var part1:Number=3*controlP[1].x*uu*uu*(1-uu);
		   var part2:Number=3*controlP[2].x*uu*(1-uu)*(1-uu);
		   var part3:Number=controlP[3].x*(1-uu)*(1-uu)*(1-uu);
		   return part0+part1+part2+part3;
		}      
		private function bezier3funcY(uu:Number,controlP:Vector.<Point>):Number{
		   var part0:Number=controlP[0].y*uu*uu*uu;
		   var part1:Number=3*controlP[1].y*uu*uu*(1-uu);
		   var part2:Number=3*controlP[2].y*uu*(1-uu)*(1-uu);
		   var part3:Number=controlP[3].y*(1-uu)*(1-uu)*(1-uu);
		   return part0+part1+part2+part3;
		}
		
		public function draw(sp:Sprite,originPoints:Vector.<Point>,curvePoints:Vector.<Point>,isDrawCurveDot:Boolean=true):void{
			const color:uint=0xff0000;
			sp.graphics.lineStyle(1,color);
			for(var i:int=0;i<curvePoints.length;i++){
				if(i>0){
					sp.graphics.lineTo(curvePoints[i].x,curvePoints[i].y);
				}else{
					sp.graphics.moveTo(curvePoints[i].x,curvePoints[i].y);
				}
				//
				if(isDrawCurveDot){
					sp.graphics.drawCircle(curvePoints[i].x,curvePoints[i].y,3);
				}
			}
			
			//draw dot
			sp.graphics.lineStyle(1,0x0000ff,0.5);
			sp.graphics.beginFill(0x0000ff,0.5);
			for(i=0;i<originPoints.length;i++){
				sp.graphics.drawCircle(originPoints[i].x,originPoints[i].y,3);
			}
			sp.graphics.endFill();
		}
		
	};

}