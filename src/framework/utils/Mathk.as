package framework.utils{
	import Box2D.Common.Math.b2Vec2;
	import flash.geom.Point;
	/**数学类*/
	public class Mathk{
		
		public function Mathk(){
			
		}
		
		/**两点的斜率*/
		public static function getKWithPoints(x1:Number,y1:Number,x2:Number,y2:Number):Number{
			return (y2-y1)/(x2-x1);
		}
		
		/**
		 * 判断两直线垂直
		 * @param	k1 直线1斜率
		 * @param	k2 直线2斜率
		 * @return  Boolean
		 */
		public static function isPerp(k1:Number,k2:Number):Boolean{
			return k1*k2==-1;
		}
		
		/**
		 * 求两直线的交点(需保证两直线有交点)
		 * @param	x1 直线1上的一点x
		 * @param	y1 直线1上的一点y
		 * @param	k1 直线1的斜率
		 * @param	x2 直线2上的一点x
		 * @param	y2 直线2上的一点y
		 * @param	k2 直线2的斜率
		 * @param	output 输出的Point
		 * @return
		 */
		public static function getLineIntersect(x1:Number,y1:Number,k1:Number,
										     x2:Number,y2:Number,k2:Number,output:Point=null):Point{
			var pt:Point=output; pt||=new Point();
			pt.x = (k1*x1-k2*x2+y2-y1)/(k1-k2);
			pt.y = k1*(pt.x-x1)+y1;
			return pt;
		}
		
		/**
		 * 求两直线是否有交点
		 * @param	x1 直线1上的一点x
		 * @param	y1 直线1上的一点y
		 * @param	k1 直线1的斜率
		 * @param	x2 直线2上的一点x
		 * @param	y2 直线2上的一点y
		 * @param	k2 直线2的斜率
		 * @return
		 */
		public static function isLineHasIntersect(/*x1:Number,y1:Number,*/k1:Number,
												/*x2:Number,y2:Number,*/k2:Number):Boolean{
			//var b1:Number=getBY(x1,y1,k1);
			//var b2:Number=getBY(x2,y2,k2);
			//1. k1!=k2 有一个交点
			//2. k1==k2时
			//   如果b1==b2，则两直线垂叠有无数个交点
			//   如果b1!=b2，没有交点
			return k1!=k2;
		}
		
		/**返回直线y轴上的截距*/
		public static function getBY(x1:Number,y1:Number,k1:Number):Number{
			//点斜式: (y-y1)=k(x-x1);
			// y-y1=k*x-k*x1
			// y=k*x-k*x1+y1
			//x=0时,截距y=-k*x1+y1;
			return -k1*x1+y1;
		}
		
		/**
		 * 旋转坐标
		 * @param	p 要旋转的坐标
		 * @param	rotateAngle 要旋转的弧度
		 * @param	output
		 * @return
		 */
		public static function rotatePoint(p:Point,rotateAngle:Number,output:Point=null):Point{
			if(output==null)output=new Point();
			var x:Number=p.x;
			var y:Number=p.y;
			var cos:Number=Math.cos(rotateAngle);
			var sin:Number=Math.sin(rotateAngle);
			output.x=x*cos-y*sin;
			output.y=x*sin+y*cos;
			return output;
		}
		/**
		 * 旋转坐标
		 * @param	p 要旋转的坐标
		 * @param	rotateAngle 要旋转的弧度
		 * @param	output
		 * @return
		 */
		public static function rotateV(p:b2Vec2,rotateAngle:Number,output:b2Vec2=null):b2Vec2{
			if(output==null)output=new b2Vec2();
			var x:Number=p.x;
			var y:Number=p.y;
			var cos:Number=Math.cos(rotateAngle);
			var sin:Number=Math.sin(rotateAngle);
			output.x=x*cos-y*sin;
			output.y=x*sin+y*cos;
			return output;
		}

		
		/**
		 * 旋转坐标
		 * @param	x 要旋转的坐标x
		 * @param	y 要旋转的坐标y
		 * @param	rotateAngle 要旋转的弧度
		 * @param	output
		 * @return
		 */
		public static function rotateXY(x:Number,y:Number,rotateAngle:Number,output:Point=null):Point{
			if(output==null)output=new Point();
			var cos:Number=Math.cos(rotateAngle);
			var sin:Number=Math.sin(rotateAngle);
			output.x=x*cos-y*sin;
			output.y=x*sin+y*cos;
			return output;
		}
		
		/**
		 * 绕着某点旋转坐标
		 * @param	p 要旋转的坐标
		 * @param	rotateAngle 要旋转的弧度
		 * @param	origin 旋转的中心
		 * @param	output
		 * @return
		 */
		public static function rotatePointWithOrigin(p:Point,rotateAngle:Number,origin:Point,output:Point=null):Point{
			if(output==null)output=new Point();
			var tmp:Point=new Point(p.x-origin.x,p.y-origin.y);
			rotatePoint(tmp,rotateAngle,output);
			output.x+=origin.x;
			output.y+=origin.y;
			return output;
		}
		/**
		 * 绕着某点旋转坐标
		 * @param	p 要旋转的坐标
		 * @param	rotateAngle 要旋转的弧度
		 * @param	origin 旋转的中心
		 * @param	output
		 * @return
		 */
		public static function rotateVWithOrigin(p:b2Vec2,rotateAngle:Number,origin:b2Vec2,output:b2Vec2=null):b2Vec2{
			if(output==null)output=new b2Vec2();
			var tmp:b2Vec2=new b2Vec2(p.x-origin.x,p.y-origin.y);
			rotateV(tmp,rotateAngle,output);
			output.x+=origin.x;
			output.y+=origin.y;
			return output;
		}
		
		/**
		 * 绕着某点旋转坐标
		 * @param	x 要旋转的坐标x
		 * @param	y 要旋转的坐标y
		 * @param	rotateAngle 要旋转的弧度
		 * @param	originX 旋转的中心x
		 * @param	originY 旋转的中心y
		 * @param	output
		 * @return
		 */
		public static function rotateXYWithXY(x:Number,y:Number,rotateAngle:Number,originX:Number,originY:Number,output:Point=null):Point{
			if(output==null)output=new Point();
			rotateXY(x-originX,y-originY,rotateAngle,output);
			output.x+=originX;
			output.y+=originY;
			return output;
		}
		
		/**点在线段上的关系最好以0.1小数误差判断*/
		public static function getPointOnLine(x:Number,y:Number,x1:Number,y1:Number,x2:Number,y2:Number):Number{
			var ax:Number = x2-x1;
			var ay:Number = y2-y1;
			
			var bx:Number = x-x1;
			var by:Number = y-y1;
			return ax*by-ay*bx;
		}
		/**点在线段上的关系 */
		public static function getPointOnLineWithVec2(checkPos:b2Vec2,pt1:b2Vec2,pt2:b2Vec2):Number{
			return getPointOnLine(checkPos.x,checkPos.y,pt1.x,pt1.y,pt2.x,pt2.y);
		}
		/**点在线段上的关系 */
		public static function getPointOnLineWithPoint(checkPos:Point,pt1:Point,pt2:Point):Number{
			return getPointOnLine(checkPos.x,checkPos.y,pt1.x,pt1.y,pt2.x,pt2.y);
		}
		
		/**返回点在线的左右边∈{0,1(顺时针),-1(逆时针)}*/
		public static function getPointOnLineDirction(x:Number,y:Number,x1:Number,y1:Number,x2:Number,y2:Number,ref:Number=0.1):int{
			var dir:int=0;
			var onLine:Number=getPointOnLine(x,y, x1,y1, x2,y2);
			if(onLine>ref)dir=-1;
			else if(onLine<-ref)dir=1;
			return dir;
		}
		/**返回点在线的左右边∈{0,1(顺时针),-1(逆时针)}Vec2*/
		public static function getPointOnLineDirctionWithVec2(checkPos:b2Vec2,pt1:b2Vec2,pt2:b2Vec2,ref:Number=0.1):int{
			return getPointOnLineDirction(checkPos.x,checkPos.y,pt1.x,pt1.y,pt2.x,pt2.y,ref);
		}
		/**返回点在线的左右边∈{0,1(顺时针),-1(逆时针)}Point*/
		public static function getPointOnLineDirctionWithPoint(checkPos:Point,pt1:Point,pt2:Point,ref:Number=0.1):int{
			return getPointOnLineDirction(checkPos.x,checkPos.y, pt1.x,pt1.y, pt2.x,pt2.y,ref);
		}
		
		/**将大于180°或小于-180°的角度转换为-180°~180之间，并返回转换后的角度*/
		public static function getRotationToFlash(rotation:Number):Number{
			rotation%=360;
			if     (rotation>180)rotation-=360;
			else if(rotation<-180)rotation+=360;
			return rotation;
		}
		
		/**计算出两个Flash角度(-180°~180°)之间的差,并返回这个差的值*/
		public static function getFlashRotationOffset(rotation:Number,targetRotation:Number):Number{
			//rotation=getRotationToFlash();
			rotation=getFlashRotationTo360(rotation);
			targetRotation=getFlashRotationTo360(targetRotation);
			return targetRotation-rotation;
		}
		
		/**将Flash角度(-180°~180°)转换为0°~360°之间的值,并返回转换后的值*/
		public static function getFlashRotationTo360(rotation:Number):Number{
			//rotation=getRotationToFlash();
			if(rotation<0) rotation+=360;
			return rotation;
		}
		
		/**求垂足点*/
		public static  function getPerpendicularPt(x:Number,y:Number,x1:Number,y1:Number,x2:Number,y2:Number,out:*):void{
			//以x1,y1为坐标原点得到向量a，b
			var ax:Number=x-x1;
			var ay:Number=y-y1;
			var bx:Number=x2-x1;
			var by:Number=y2-y1;
			//求向量a,b的点积
			var dot:Number=ax*bx+ay*by;
			//向量b模的平方
			//var bl:Number=Math.sqrt(bx*bx+by*by);
			//var sq:Number=bl*bl;
			//简化
			var sq:Number=bx*bx+by*by;
			//垂点
			var l:Number=dot/sq;
			var ppx:Number=l*bx;
			var ppy:Number=l*by;
			ppx+=x1;
			ppy+=y1;
			//
			out.x=ppx;
			out.y=ppy;
		}
		/**求垂足点Point*/
		public static function getPerpendicularPoint(x:Number,y:Number,x1:Number,y1:Number,x2:Number,y2:Number,out:Point=null):Point{
			out||=new Point();
			getPerpendicularPt(
				x,y,
				x1,y1,
				x2,y2,
				out);
			return out;
		}
		/**求垂足点b2Vec2*/
		public static function getPerpendicularb2Vec2(x:Number,y:Number,x1:Number,y1:Number,x2:Number,y2:Number,out:b2Vec2=null):b2Vec2{
			out||=new b2Vec2();
			getPerpendicularPt(
				x,y,
				x1,y1,
				x2,y2,
				out);
			return out;
		}
		/**线段ab与线段cd的交点,有交点返回交点，没有交点返回null*/
		public static function getSegmentsIntersect(a:*,b:*,c:*,d:*):*{
			// 三角形abc 面积的2倍  
			var area_abc:Number = (a.x - c.x) * (b.y - c.y) - (a.y - c.y) * (b.x - c.x);  
		  
			// 三角形abd 面积的2倍  
			var area_abd:Number = (a.x - d.x) * (b.y - d.y) - (a.y - d.y) * (b.x - d.x);   
		  
			// 面积符号相同则两点在线段同侧,不相交 (对点在线段上的情况,本例当作不相交处理);  
			if (area_abc*area_abd>=0) {  
				return null;  
			}  
		  
			// 三角形cda 面积的2倍  
			var area_cda:Number = (c.x - a.x) * (d.y - a.y) - (c.y - a.y) * (d.x - a.x);  
			// 三角形cdb 面积的2倍  
			// 注意: 这里有一个小优化.不需要再用公式计算面积,而是通过已知的三个面积加减得出.  
			var area_cdb:Number = area_cda + area_abc - area_abd ;  
			if (  area_cda * area_cdb >= 0 ) {  
				return null;  
			}  
			//计算交点坐标  
			var t:Number = area_cda / ( area_abd- area_abc );
			var dx:Number= t*(b.x - a.x);
			var dy:Number= t*(b.y - a.y);
			return {x:a.x + dx, y:a.y + dy};
		}
		
		/**Math.PI/180*/
		public static const Deg2Rad:Number=0.0174532925;
		/**180/Math.PI*/
		public static const Rad2Deg:Number=57.2957795130;
		
	};

}