/*
* Copyright (c) 2006-2007 Erin Catto http://www.gphysics.com
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
using Box2D.Collision;
using Box2D.Common.Math;
using Box2D.Common;
using System.Collections.Generic;
using UnityEngine;

namespace Box2D.Dynamics.Contacts 
{	

public class b2PositionSolverManifold
{
	public b2PositionSolverManifold()
	{
		m_normal = new b2Vec2();
		m_separations = new float[b2Settings.b2_maxManifoldPoints];
		m_points = new b2Vec2[b2Settings.b2_maxManifoldPoints];
		for (int i=0; i<b2Settings.b2_maxManifoldPoints; i++) {
			m_points[i]=new b2Vec2();
		}
	}
	
	private static b2Vec2 circlePointA = new b2Vec2();
	private static b2Vec2 circlePointB = new b2Vec2();
	public void Initialize(b2ContactConstraint cc)
	{
		b2Settings.b2Assert(cc.pointCount > 0);
		
		int i;
		float clipPointX;
		float clipPointY;
		b2Mat22 tMat;
		b2Vec2 tVec;
		float planePointX;
		float planePointY;
		
		if(cc.type==b2Manifold.e_circles)
		{
			//var pointA:b2Vec2 = cc.bodyA.GetWorldPoint(cc.localPoint);
			tMat = cc.bodyA.m_xf.R;
			tVec = cc.localPoint;
			float pointAX = cc.bodyA.m_xf.position.x + (tMat.col1.x * tVec.x + tMat.col2.x * tVec.y);
			float pointAY = cc.bodyA.m_xf.position.y + (tMat.col1.y * tVec.x + tMat.col2.y * tVec.y);
			//var pointB:b2Vec2 = cc.bodyB.GetWorldPoint(cc.points[0].localPoint);
			tMat = cc.bodyB.m_xf.R;
			tVec = cc.points[0].localPoint;
			float pointBX = cc.bodyB.m_xf.position.x + (tMat.col1.x * tVec.x + tMat.col2.x * tVec.y);
			float pointBY = cc.bodyB.m_xf.position.y + (tMat.col1.y * tVec.x + tMat.col2.y * tVec.y);
			float dX = pointBX - pointAX;
			float dY = pointBY - pointAY;
			float d2 = dX * dX + dY * dY;
			if (d2 > 0.0f/*float.MinValue*float.MinValue*/)
			{
				float d = Mathf.Sqrt(d2);
				m_normal.x = dX/d;
				m_normal.y = dY/d;
			}
			else
			{
				m_normal.x = 1.0f;
				m_normal.y = 0.0f;
			}
			m_points[0].x = 0.5f * (pointAX + pointBX);
			m_points[0].y = 0.5f * (pointAY + pointBY);
			m_separations[0] = dX * m_normal.x + dY * m_normal.y - cc.radius;
		}
		else if(cc.type==b2Manifold.e_faceA)
		{
			//m_normal = cc.bodyA.GetWorldVector(cc.localPlaneNormal);
			tMat = cc.bodyA.m_xf.R;
			tVec = cc.localPlaneNormal;
			m_normal.x = tMat.col1.x * tVec.x + tMat.col2.x * tVec.y;
			m_normal.y = tMat.col1.y * tVec.x + tMat.col2.y * tVec.y;
			//planePoint = cc.bodyA.GetWorldPoint(cc.localPoint);
			tMat = cc.bodyA.m_xf.R;
			tVec = cc.localPoint;
			planePointX = cc.bodyA.m_xf.position.x + (tMat.col1.x * tVec.x + tMat.col2.x * tVec.y);
			planePointY = cc.bodyA.m_xf.position.y + (tMat.col1.y * tVec.x + tMat.col2.y * tVec.y);
			
			tMat = cc.bodyB.m_xf.R;
			for (i = 0; i < cc.pointCount;++i)
			{
				//clipPoint = cc.bodyB.GetWorldPoint(cc.points[i].localPoint);
				tVec = cc.points[i].localPoint;
				clipPointX = cc.bodyB.m_xf.position.x + (tMat.col1.x * tVec.x + tMat.col2.x * tVec.y);
				clipPointY = cc.bodyB.m_xf.position.y + (tMat.col1.y * tVec.x + tMat.col2.y * tVec.y);
				m_separations[i] = (clipPointX - planePointX) * m_normal.x + (clipPointY - planePointY) * m_normal.y - cc.radius;
				m_points[i].x = clipPointX;
				m_points[i].y = clipPointY;
			}
		}
		else if(cc.type==b2Manifold.e_faceB)
		{
			//m_normal = cc.bodyB.GetWorldVector(cc.localPlaneNormal);
			tMat = cc.bodyB.m_xf.R;
			tVec = cc.localPlaneNormal;
			m_normal.x = tMat.col1.x * tVec.x + tMat.col2.x * tVec.y;
			m_normal.y = tMat.col1.y * tVec.x + tMat.col2.y * tVec.y;
			//planePoint = cc.bodyB.GetWorldPoint(cc.localPoint);
			tMat = cc.bodyB.m_xf.R;
			tVec = cc.localPoint;
			planePointX = cc.bodyB.m_xf.position.x + (tMat.col1.x * tVec.x + tMat.col2.x * tVec.y);
			planePointY = cc.bodyB.m_xf.position.y + (tMat.col1.y * tVec.x + tMat.col2.y * tVec.y);
			
			tMat = cc.bodyA.m_xf.R;
			for (i = 0; i < cc.pointCount;++i)
			{
				//clipPoint = cc.bodyA.GetWorldPoint(cc.points[i].localPoint);
				tVec = cc.points[i].localPoint;
				clipPointX = cc.bodyA.m_xf.position.x + (tMat.col1.x * tVec.x + tMat.col2.x * tVec.y);
				clipPointY = cc.bodyA.m_xf.position.y + (tMat.col1.y * tVec.x + tMat.col2.y * tVec.y);
				m_separations[i] = (clipPointX - planePointX) * m_normal.x + (clipPointY - planePointY) * m_normal.y - cc.radius;
				m_points[i].Set(clipPointX, clipPointY);
			}
			
			// Ensure normal points from A to B
			m_normal.x *= -1.0f;
			m_normal.y *= -1.0f;
		}
		
	}
	
	public b2Vec2 m_normal;
	public b2Vec2[] m_points;
	public float[] m_separations;
}
	
}