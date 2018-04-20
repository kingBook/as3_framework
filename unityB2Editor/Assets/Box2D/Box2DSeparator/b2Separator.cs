/*
* Convex Separator for Box2D Flash
*
* This class has been written by Antoan Angelov. 
* It is designed to work with Erin Catto's Box2D physics library.
*
* Everybody can use this software for any purpose, under two restrictions:
* 1. You cannot claim that you wrote this software.
* 2. You can not remove or alter this notice.
*
*/

using Box2D.Collision.Shapes;
using Box2D.Common.Math;
using Box2D.Dynamics;
using System.Collections.Generic;
using System.Collections;
using UnityEngine;

namespace Box2D.Box2DSeparator
{
	

	public class b2Separator
	{
		public b2Separator()
		{
		}
		
		/**
		 * Separates a non-convex polygon into convex polygons and adds them as fixtures to the <code>body</code> parameter.<br/>
		 * There are some rules you should follow (otherwise you might get unexpected results) :
		 * <ul>
		 * <li>This class is specifically for non-convex polygons. If you want to create a convex polygon, you don't need to use this class - Box2D's <code>b2PolygonShape</code> class allows you to create convex shapes with the <code>setAsArray()</code>/<code>setAsVector()</code> method.</li>
		 * <li>The vertices must be in clockwise order.</li>
		 * <li>No three neighbouring points should lie on the same line segment.</li>
		 * <li>There must be no overlapping segments and no "holes".</li>
		 * </ul> <p/>
		 * @param body The b2Body, in which the new fixtures will be stored.
		 * @param fixtureDef A b2FixtureDef, containing all the properties (friction, density, etc.) which the new fixtures will inherit.
		 * @param verticesVec The vertices of the non-convex polygon, in clockwise order.
		 * @param scale <code>[optional]</code> The scale which you use to draw shapes in Box2D. The bigger the scale, the better the precision. The default value is 30. 
		 * @see b2PolygonShape
		 * @see b2PolygonShape.SetAsArray()
		 * @see b2PolygonShape.SetAsVector()
		 * @see b2Fixture
		 * */
		
        public b2Fixture[] Separate(b2Body body, b2FixtureDef fixtureDef, b2Vec2[] verticesVec, float scale = 100,float offsetX=0,float offsetY=0)
		{
			int i; 
			int n=verticesVec.Length;
			int j;
			int m;
            List<b2Vec2> vec = new List<b2Vec2>();
			ArrayList figsVec;
			b2PolygonShape polyShape;
			
			for(i=0; i<n; i++) vec.Add(new b2Vec2((verticesVec[i].x+offsetX)*scale, (verticesVec[i].y+offsetY)*scale));
			if(!getIsConvexPolygon(vec,vec.Count)){
				int validate=Validate(vec);
				if(validate==2||validate==3){
					vec.Reverse();//add by kingBook 2017.2.14
				}
			}
            //Debug.Log(string.Format("Validate:{0}",Validate(vec)));
			figsVec = calcShapes(vec);
			n = figsVec.Count;	



            b2Fixture[] fixtures=new b2Fixture[n];

			for(i=0; i<n; i++)
			{
				vec = (List<b2Vec2>)figsVec[i];
                vec.Reverse();//add by kingBook 2017.2.14
				m = vec.Count;
                verticesVec = new b2Vec2[m];
				for(j=0; j<m; j++) verticesVec[j]=new b2Vec2(vec[j].x/scale, vec[j].y/scale);
				
				polyShape = new b2PolygonShape();
				polyShape.SetAsArray(verticesVec,m);
				fixtureDef.shape = polyShape;
                fixtures[i]=body.CreateFixture(fixtureDef);
			}
            return fixtures;
		}

        /**判断多边形是不是凸多边形*/
        private bool getIsConvexPolygon(List<b2Vec2> vec,int count){
            b2Vec2 p,p1,p2;
            int id=0,id1=0,id2=0;
            while(true){
                p1=vec[id1];
                
                id=id1+1;if(id==count)id=0;
                p=vec[id];
                
                id2=id+1;if(id2==count)id2=0;
                p2=vec[id2];
                //
                if(pointOnSegment(p,p1,p2)>0)return false;
                //
                id1++;
                if(id1==count)break;
            }

            return true;
        }

        private float pointOnSegment(b2Vec2 p,b2Vec2 p1,b2Vec2 p2){
            float ax = p2.x-p1.x;
            float ay = p2.y-p1.y;
                
            float bx = p.x-p1.x;
            float by = p.y-p1.y;
            return ax*by-ay*bx;
        }

		/**
		 * Checks whether the vertices in <code>verticesVec</code> can be properly distributed into the new fixtures (more specifically, it makes sure there are no overlapping segments and the vertices are in clockwise order). 
		 * It is recommended that you use this method for debugging only, because it may cost more CPU usage.
		 * <p/>
		 * @param verticesVec The vertices to be validated.
		 * @return An integer which can have the following values:
		 * <ul>
		 * <li>0 if the vertices can be properly processed.</li>
		 * <li>1 If there are overlapping lines.</li>
		 * <li>2 if the points are <b>not</b> in clockwise order.</li>
		 * <li>3 if there are overlapping lines <b>and</b> the points are <b>not</b> in clockwise order.</li>
		 * </ul> 
		 * */
		
        public int Validate(List<b2Vec2> verticesVec)
		{
            int i; int n=verticesVec.Count; int j, j2, i2, i3; float d; int ret=0;
            bool fl; bool fl2 = false;
			
			for(i=0; i<n; i++)
			{
				i2 = (i<n-1?i+1:0);
				i3 = (i>0?i-1:n-1);
				
				fl = false;
				for(j=0; j<n; j++)
				{
					if(j!=i&&j!=i2)
					{
						if(!fl)
						{
							d = det(verticesVec[i].x, verticesVec[i].y, verticesVec[i2].x, verticesVec[i2].y, verticesVec[j].x, verticesVec[j].y);
							if(d>0) fl = true;
						}
						
						if(j!=i3)
						{
							j2 = (j<n-1?j+1:0);
							if(hitSegment(verticesVec[i].x,verticesVec[i].y,verticesVec[i2].x,verticesVec[i2].y,verticesVec[j].x,verticesVec[j].y,verticesVec[j2].x,verticesVec[j2].y) != null)
								ret = 1;
						}
					}
				}
				
				if(!fl) fl2 = true;			
			}
			
			if(fl2)
			{
				if(ret==1) ret = 3;
				else ret = 2;
			}
			
			return ret;
		}
		
        private ArrayList calcShapes(List<b2Vec2> verticesVec)
		{
            List<b2Vec2> vec;
            int i,n,j;
            float d,t,dx,dy,minLen;
            int i1,i2,i3; b2Vec2 p1,p2,p3;
            int j1,j2; b2Vec2 v1,v2; int k=0,h=0;
            List<b2Vec2> vec1,vec2;
            b2Vec2 v,hitV=null;
            bool isConvex;
            ArrayList figsVec=new ArrayList(); ArrayList queue=new ArrayList();
			
			queue.Add(verticesVec);
			
			while(queue.Count>0)
			{
				vec = (List<b2Vec2>)queue[0];
				n = vec.Count;
				isConvex = true;
				
				for(i=0; i<n; i++)
				{
					i1 = i;
					i2 = (i<n-1?i+1:i+1-n);
					i3 = (i<n-2?i+2:i+2-n);

					p1 = vec[i1];
					p2 = vec[i2];
					p3 = vec[i3];
					
					d = det(p1.x, p1.y, p2.x, p2.y, p3.x, p3.y);
					if(d<0)
					{
						isConvex = false;
						minLen = float.MaxValue;
						
						for(j=0; j<n; j++)
						{
							if(j!=i1&&j!=i2)
							{
								j1 = j;
								j2 = (j<n-1?j+1:0);

								v1 = vec[j1];
								v2 = vec[j2];

								v = hitRay(p1.x, p1.y, p2.x, p2.y, v1.x, v1.y, v2.x, v2.y);
								if(v!=null)
								{
									dx = p2.x-v.x;
									dy = p2.y-v.y;
									t = dx*dx+dy*dy;
									if(t<minLen)
									{
										h = j1;
										k = j2;
										hitV = v;
										minLen = t;
									}
								}
							}
						}
						if(minLen==float.MaxValue) err();
						
						vec1 = new List<b2Vec2>();
                        vec2 = new List<b2Vec2>();
						
						j1 = h;
						j2 = k;
						v1 = vec[j1];
						v2 = vec[j2];
						
						if(!pointsMatch(hitV.x, hitV.y, v2.x, v2.y)) vec1.Add(hitV);
                        if(!pointsMatch(hitV.x, hitV.y, v1.x, v1.y)) vec2.Add(hitV);
												
						h = -1;
						k = i1;
						while(true)
						{
                            if(k!=j2) vec1.Add(vec[k]);
							else
							{
								if(h<0||h>=n) err();
                                if(!this.isOnSegment(v2.x, v2.y, vec[h].x, vec[h].y, p1.x, p1.y)) vec1.Add(vec[k]);
								break;
							}

							h = k;
							if(k-1<0) k = n-1;
							else k--;
						}
                        vec1.Reverse();
						
						h = -1;
						k = i2;
						while(true)
						{
							if(k!=j1) vec2.Add(vec[k]);
							else
							{
								if(h<0||h>=n) err();
								if(k==j1&&!this.isOnSegment(v1.x, v1.y, vec[h].x, vec[h].y, p2.x, p2.y)) vec2.Add(vec[k]);
								break;
							}

							h = k;
							if(k+1>n-1) k = 0;
							else k++;
						}
						
						queue.Add(vec1);
                        queue.Add(vec2);
                        queue.RemoveAt(0);

						break;
					}
				}
				
				if(isConvex){
                    figsVec.Add(queue[0]);
                    queue.RemoveAt(0);
                }
			}
			
			return figsVec;
		}
				
        private b2Vec2 hitRay(float x1, float y1, float x2, float y2, float x3, float y3, float x4, float y4)
		{
            float t1 = x3 - x1; float t2 = y3 - y1; float t3 = x2 - x1; float t4 = y2 - y1; 
            float t5 = x4 - x3; float t6 = y4 - y3; float t7 = t4 * t5 - t3 * t6; float a;
			
			a = (t5*t2-t6*t1)/t7;
            float px = x1 + a * t3; float py = y1+a*t4;
			bool b1 = isOnSegment(x2, y2, x1, y1, px, py);
			bool b2 = isOnSegment(px, py, x3, y3, x4, y4);
			
			if(b1&&b2) return new b2Vec2(px, py);
			
			return null;
		}
		
        private b2Vec2 hitSegment(float x1, float y1, float x2, float y2, float x3, float y3, float x4, float y4)
		{
            float t1 = x3 - x1; float t2 = y3 - y1; float t3 = x2 - x1; float t4 = y2 - y1; 
            float t5 = x4 - x3; float t6 = y4 - y3; float t7 = t4 * t5 - t3 * t6; float a;
			
			a = (t5*t2-t6*t1)/t7;
            float px = x1 + a * t3; float py = y1+a*t4;
			bool b1 = isOnSegment(px, py, x1, y1, x2, y2);
			bool b2 = isOnSegment(px, py, x3, y3, x4, y4);
			
			if(b1&&b2) return new b2Vec2(px, py);
			
			return null;
		}
		
        private bool isOnSegment(float px, float py, float x1, float y1, float x2, float y2)
		{
            bool b1 = ((x1+0.1f>=px&&px>=x2-0.1f)||(x1-0.1f<=px&&px<=x2+0.1f));
            bool b2 = ((y1+0.1f>=py&&py>=y2-0.1f)||(y1-0.1f<=py&&py<=y2+0.1f));
			return (b1&&b2&&isOnLine(px, py, x1, y1, x2, y2));
		}
		
        private bool pointsMatch(float x1, float y1, float x2, float y2)
		{
            float dx = (x2 >= x1 ? x2 - x1 : x1 - x2); float dy = (y2>=y1?y2-y1:y1-y2);
			return (dx<0.1&&dy<0.1f);
		}
		
        private bool isOnLine(float px, float py, float x1, float y1, float x2, float y2)
		{
			if(x2-x1>0.1f||x1-x2>0.1f)
			{
                float a = (y2-y1)/(x2-x1); float possibleY = a*(px-x1)+y1; float diff = (possibleY>py?possibleY-py:py-possibleY);
				return (diff<0.1f);
			}
			return (px-x1<0.1f||x1-px<0.1f);
			
		}
		
        private float det(float x1, float y1, float x2, float y2, float x3, float y3)
		{
			return x1*y2+x2*y3+x3*y1-y1*x2-y2*x3-y3*x1;    
		}
		
		private void err()
		{
            Debug.LogError("A problem has occurred. Use the Validate() method to see where the problem is.");
		}
	}
}