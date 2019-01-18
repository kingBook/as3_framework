using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Curve{

	public List<Vector2> createCurve(Vector2[] originPoint,float curveRatio=0.1f,bool isCap=false){
		//控制点收缩系数 ，经调试0.6较好
		const float scale=0.6f;
		int originCount=originPoint.Length;
		//生成中点
		Vector2[] midpoints=new Vector2[originCount];
		for(int i=0;i<originCount;i++){
			int nexti=(i+1)%originCount;
			midpoints[i]=new Vector2((originPoint[i].x + originPoint[nexti].x)/2.0f, 
									 (originPoint[i].y + originPoint[nexti].y)/2.0f);
		}
		//平移中点 
		Vector2[] extrapoints=new Vector2[2*originCount];
		for(int i=0;i<extrapoints.Length;i++)extrapoints[i]=new Vector2();

		for(int i=0;i<originCount;i++){
			int nexti=(i+1)%originCount;
			int backi=(i+originCount-1)%originCount;
			Vector2 midinmid=new Vector2((midpoints[i].x+midpoints[backi].x)/2.0f,
										 (midpoints[i].y+midpoints[backi].y)/2.0f);
			int offsetx=(int)(originPoint[i].x-midinmid.x);
			int offsety=(int)(originPoint[i].y-midinmid.y);
			int extraindex=2*i;
			extrapoints[extraindex].x=midpoints[backi].x+offsetx;
			extrapoints[extraindex].y=midpoints[backi].y+offsety;
			//朝 originPoint[i]方向收缩
			int addx=(int)( (extrapoints[extraindex].x-originPoint[i].x)*scale );
			int addy=(int)( (extrapoints[extraindex].y-originPoint[i].y)*scale );
			extrapoints[extraindex].x=originPoint[i].x+addx;
			extrapoints[extraindex].y=originPoint[i].y+addy;
				
			int extranexti=(extraindex+1)%(2*originCount);
			extrapoints[extranexti].x=midpoints[i].x+offsetx;
			extrapoints[extranexti].y=midpoints[i].y+offsety;
			//朝 originPoint[i]方向收缩
			addx=(int)( (extrapoints[extranexti].x-originPoint[i].x)*scale );
			addy=(int)( (extrapoints[extranexti].y-originPoint[i].y)*scale );
			extrapoints[extranexti].x=originPoint[i].x+addx;
			extrapoints[extranexti].y=originPoint[i].y+addy;
				
		}
		List<Vector2> curvePoint=new List<Vector2>();
		Vector2[] controlPoint=new Vector2[4];
		//生成4控制点，产生贝塞尔曲线
		for(int i=0;i<originCount;i++){
			if(i>=originCount-1&&isCap==false)break;
				controlPoint[0]=originPoint[i];
				int extraindex=2*i;
				controlPoint[1]=extrapoints[extraindex + 1];
				int extranexti=(extraindex+2)%(2*originCount);
				controlPoint[2]=extrapoints[extranexti];
				int nexti=(i+1)%originCount;
				controlPoint[3]=originPoint[nexti];  
				float u=1.0f;
				while(u>=0){
					int px=(int)( bezier3funcX(u,controlPoint) );
					int py=(int)( bezier3funcY(u,controlPoint) );
					//u的步长决定曲线的疏密  
					u-=curveRatio;
					Vector2 tempP=new Vector2(px,py);
					//存入曲线点
					curvePoint.Add(tempP);
				}
		}
		return curvePoint;
	}

	//三次贝塞尔曲线  
	private float bezier3funcX(float uu,Vector2[] controlP){
		float part0=controlP[0].x*uu*uu*uu;
		float part1=3*controlP[1].x*uu*uu*(1-uu);
		float part2=3*controlP[2].x*uu*(1-uu)*(1-uu);
		float part3=controlP[3].x*(1-uu)*(1-uu)*(1-uu);
		return part0+part1+part2+part3;
	}      
	private float bezier3funcY(float uu,Vector2[] controlP){
		float part0=controlP[0].y*uu*uu*uu;
		float part1=3*controlP[1].y*uu*uu*(1-uu);
		float part2=3*controlP[2].y*uu*(1-uu)*(1-uu);
		float part3=controlP[3].y*(1-uu)*(1-uu)*(1-uu);
		return part0+part1+part2+part3;
	}


}
