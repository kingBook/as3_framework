/*
* Copyright (c) 2006-2007 Adam Newgas
*
* This software is provided 'as-is', without any express or implied
* warranty.  In no event will the authors be held liable for any damages
* arising from the use of this software.
* Permission is granted to anyone to use this software for any purpose,
* including commercial applications, and to alter it and redistribute it
* freely, subject to the following restrictions:
* 1. The origin of this software must not be misrepresented; you must not
* claim that you wrote the original software. If you use this software
* in a product, an acknowledgment in the product documentation would be
* appreciated but is not required.
* 2. Altered source versions must be plainly marked as such, and must not be
* misrepresented as being the original software.
* 3. This notice may not be removed or altered from any source distribution.
*/
using Box2D.Common.Math;
using Box2D.Dynamics;
using UnityEngine;

namespace Box2D.Dynamics.Controllers{


/**
 * Applies simplified gravity between every pair of bodies 
 */
public class b2GravityController : b2Controller
{	
	/**
	 * Specifies the strength of the gravitiation force
	 */
	public float G = 1;
	/**
	 * If true, gravity is proportional to r^-2, otherwise r^-1
	 */
	public bool invSqr = true;
	
	public override void Step(b2TimeStep step){
		//Inlined
		b2ControllerEdge i = null;
		b2Body body1 = null;
		b2Vec2 p1 = null;
		float mass1 = 0.0f;
		b2ControllerEdge j = null;
		b2Body body2 = null;
		b2Vec2 p2 = null;
		float dx = 0.0f;
		float dy = 0.0f;
		float r2 = 0.0f;
		b2Vec2 f = null;
		if(invSqr){
			for(i=m_bodyList;i!=null;i=i.nextBody){
				body1 = i.body;
				p1 = body1.GetWorldCenter();
				mass1 = body1.GetMass();
				for(j=m_bodyList;j!=i;j=j.nextBody){
					body2 = j.body;
					p2 = body2.GetWorldCenter();
					dx = p2.x - p1.x;
					dy = p2.y - p1.y;
					r2 = dx*dx+dy*dy;
					if(r2<float.MinValue)
						continue;
					f = new b2Vec2(dx,dy);
					f.Multiply(G / r2 / Mathf.Sqrt(r2) * mass1* body2.GetMass());
					if(body1.IsAwake())
						body1.ApplyForce(f,p1);
					f.Multiply(-1.0f);
					if(body2.IsAwake())
						body2.ApplyForce(f,p2);
				}
			}
		}else{
			for(i=m_bodyList;i!=null;i=i.nextBody){
				body1 = i.body;
				p1 = body1.GetWorldCenter();
				mass1 = body1.GetMass();
				for(j=m_bodyList;j!=i;j=j.nextBody){
					body2 = j.body;
					p2 = body2.GetWorldCenter();
					dx = p2.x - p1.x;
					dy = p2.y - p1.y;
					r2 = dx*dx+dy*dy;
					if(r2<float.MinValue)
						continue;
					f = new b2Vec2(dx,dy);
					f.Multiply(G / r2 * mass1 * body2.GetMass());
					if(body1.IsAwake())
						body1.ApplyForce(f,p1);
					f.Multiply(-1);
					if(body2.IsAwake())
						body2.ApplyForce(f,p2);
				}
			}
		}
	}
}

}