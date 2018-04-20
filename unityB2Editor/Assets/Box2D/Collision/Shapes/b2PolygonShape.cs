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

using UnityEngine;
using Box2D.Collision;
using Box2D.Common.Math;
using Box2D.Common;
using System.Collections.Generic;

namespace Box2D.Collision.Shapes{


/**
* Convex polygon. The vertices must be in CCW order for a right-handed
* coordinate system with the z-axis coming out of the screen.
* @see b2PolygonDef
*/

public class b2PolygonShape : b2Shape
{
	public override b2Shape Copy() 
	{
		b2PolygonShape s = new b2PolygonShape();
		s.Set(this);
		return s;
	}
	
	public override void Set(b2Shape other) 
	{
		base.Set(other);
		if (other is b2PolygonShape)
		{
			b2PolygonShape other2 = other as b2PolygonShape;
			m_centroid.SetV(other2.m_centroid);
			m_vertexCount = other2.m_vertexCount;
			Reserve(m_vertexCount);
			for (int i = 0; i < m_vertexCount; i++)
			{
				m_vertices[i].SetV(other2.m_vertices[i]);
				m_normals[i].SetV(other2.m_normals[i]);
			}
		}
	}
	
	/**
	 * Copy vertices. This assumes the vertices define a convex polygon.
	 * It is assumed that the exterior is the the right of each edge.
	 */
	public void SetAsArray(b2Vec2[] vertices, int vertexCount = 0)
	{
		List<b2Vec2> v = new List<b2Vec2>();
		for(int i=0;i<vertexCount;i++) v.Add(vertices[i]);
		SetAsVector(v, vertexCount);
	}
	
	public static b2PolygonShape AsArray(b2Vec2[] vertices, int vertexCount)
	{
		b2PolygonShape polygonShape = new b2PolygonShape();
		polygonShape.SetAsArray(vertices, vertexCount);
		return polygonShape;
	}
	
	/**
	 * Copy vertices. This assumes the vertices define a convex polygon.
	 * It is assumed that the exterior is the the right of each edge.
	 */
	public void SetAsVector(List<b2Vec2> vertices, int vertexCount = 0)
	{
		if (vertexCount == 0)
			vertexCount = vertices.Count;
			
		b2Settings.b2Assert(2 <= vertexCount);
		m_vertexCount = vertexCount;
		
		Reserve(vertexCount);
		
		int i;
		
		// Copy vertices
		for (i = 0; i < m_vertexCount; i++)
		{
			b2Vec2 v=vertices[i];
				m_vertices[(m_vertexCount-1)-i].SetV(v);//改为逆时针顺序添加
			/*if(Application.platform==RuntimePlatform.FlashPlayer){
				v.y=-v.y;
				m_vertices[i].SetV(v);
			}else{
				m_vertices[(m_vertexCount-1)-i].SetV(v);//改为逆时针顺序添加
			}*/
		}
		
		// Compute normals. Ensure the edges have non-zero length.
		for (i = 0; i < m_vertexCount; ++i)
		{
			int i1 = i;
			int i2 = i + 1 < m_vertexCount ? i + 1 : 0;
			b2Vec2 edge = b2Math.SubtractVV(m_vertices[i2], m_vertices[i1]);
			b2Settings.b2Assert(edge.LengthSquared() > float.MinValue /* * Number.MIN_VALUE*/);
			m_normals[i].SetV(b2Math.CrossVF(edge, 1.0f));
			m_normals[i].Normalize();
		}
		
//#ifdef _DEBUG
		// Ensure the polygon is convex and the interior
		// is to the left of each edge.
		//for (int32 i = 0; i < m_vertexCount; ++i)
		//{
			//int32 i1 = i;
			//int32 i2 = i + 1 < m_vertexCount ? i + 1 : 0;
			//b2Vec2 edge = m_vertices[i2] - m_vertices[i1];
			//for (int32 j = 0; j < m_vertexCount; ++j)
			//{
				// Don't check vertices on the current edge.
				//if (j == i1 || j == i2)
				//{
					//continue;
				//}
				//
				//b2Vec2 r = m_vertices[j] - m_vertices[i1];
				// Your polygon is non-convex (it has an indentation) or
				// has colinear edges.
				//float32 s = b2Cross(edge, r);
				//b2Assert(s > 0.0f);
			//}
		//}
//#endif

		// Compute the polygon centroid

			m_centroid = ComputeCentroid(m_vertices, (uint)m_vertexCount);
	}
	
	public static b2PolygonShape AsVector(List<b2Vec2> vertices, int vertexCount)
	{
		b2PolygonShape polygonShape = new b2PolygonShape();
		polygonShape.SetAsVector(vertices, vertexCount);
		return polygonShape;
	}
	
	/**
	* Build vertices to represent an axis-aligned box.
	* @param hx the half-width.
	* @param hy the half-height.
	*/
	public void SetAsBox(float hx, float hy) 
	{
		m_vertexCount = 4;
		Reserve(4);
		m_vertices[0].Set(-hx, -hy);
		m_vertices[1].Set( hx, -hy);
		m_vertices[2].Set( hx,  hy);
		m_vertices[3].Set(-hx,  hy);
		m_normals[0].Set(0.0f, -1.0f);
		m_normals[1].Set(1.0f, 0.0f);
		m_normals[2].Set(0.0f, 1.0f);
		m_normals[3].Set(-1.0f, 0.0f);
		m_centroid.SetZero();
	}
	
	public static b2PolygonShape AsBox(float hx, float hy)
	{
		b2PolygonShape polygonShape = new b2PolygonShape();
		polygonShape.SetAsBox(hx, hy);
		return polygonShape;
	}
	
	/**
	* Build vertices to represent an oriented box.
	* @param hx the half-width.
	* @param hy the half-height.
	* @param center the center of the box in local coordinates.
	* @param angle the rotation of the box in local coordinates.
	*/
	static private b2Mat22 s_mat = new b2Mat22();
	public void SetAsOrientedBox(float hx, float hy, b2Vec2 center = null, float angle = 0.0f)
	{
		m_vertexCount = 4;
		Reserve(4);
		m_vertices[0].Set(-hx, -hy);
		m_vertices[1].Set( hx, -hy);
		m_vertices[2].Set( hx,  hy);
		m_vertices[3].Set(-hx,  hy);
		m_normals[0].Set(0.0f, -1.0f);
		m_normals[1].Set(1.0f, 0.0f);
		m_normals[2].Set(0.0f, 1.0f);
		m_normals[3].Set(-1.0f, 0.0f);
		m_centroid = center;

		b2Transform xf = new b2Transform();
		xf.position = center;
		xf.R.Set(angle);

		// Transform vertices and normals.
		for (int i = 0; i < m_vertexCount; ++i)
		{
			m_vertices[i] = b2Math.MulX(xf, m_vertices[i]);
			m_normals[i] = b2Math.MulMV(xf.R, m_normals[i]);
		}
	}
	
	public static b2PolygonShape AsOrientedBox(float hx, float hy, b2Vec2 center = null, float angle = 0.0f)
	{
		b2PolygonShape polygonShape = new b2PolygonShape();
		polygonShape.SetAsOrientedBox(hx, hy, center, angle);
		return polygonShape;
	}
	
	/**
	 * Set this as a single edge.
	 */
	public void SetAsEdge(b2Vec2 v1, b2Vec2 v2)
	{
		m_vertexCount = 2;
		Reserve(2);
		m_vertices[0].SetV(v1);
		m_vertices[1].SetV(v2);
		m_centroid.x = 0.5f * (v1.x + v2.x);
		m_centroid.y = 0.5f * (v1.y + v2.y);
		m_normals[0] = b2Math.CrossVF(b2Math.SubtractVV(v2, v1), 1.0f);
		m_normals[0].Normalize();
		m_normals[1].x = -m_normals[0].x;
		m_normals[1].y = -m_normals[0].y;
	}
	
	/**
	 * Set this as a single edge.
	 */
	static public b2PolygonShape AsEdge(b2Vec2 v1, b2Vec2 v2)
	{
		b2PolygonShape polygonShape = new b2PolygonShape();
		polygonShape.SetAsEdge(v1, v2);
		return polygonShape;
	}
	
	
	/**
	* @inheritDoc
	*/
	public override bool TestPoint(b2Transform xf, b2Vec2 p){
		b2Vec2 tVec;
		
		//b2Vec2 pLocal = b2MulT(xf.R, p - xf.position);
		b2Mat22 tMat = xf.R;
		float tX = p.x - xf.position.x;
		float tY = p.y - xf.position.y;
		float pLocalX = (tX*tMat.col1.x + tY*tMat.col1.y);
		float pLocalY = (tX*tMat.col2.x + tY*tMat.col2.y);
		
		for (int i = 0; i < m_vertexCount; ++i)
		{
			//float32 dot = b2Dot(m_normals[i], pLocal - m_vertices[i]);
			tVec = m_vertices[i];
			tX = pLocalX - tVec.x;
			tY = pLocalY - tVec.y;
			tVec = m_normals[i];
			float dot = (tVec.x * tX + tVec.y * tY);
			if (dot > 0.0f)
			{
				return false;
			}
		}
		
		return true;
	}

	/**
	 * @inheritDoc
	 */
	public override bool RayCast(b2RayCastOutput output, b2RayCastInput input, b2Transform transform)
	{
		float lower = 0.0f;
		float upper = input.maxFraction;
	
		float tX;
		float tY;
		b2Mat22 tMat;
		b2Vec2 tVec;
		
		// Put the ray into the polygon's frame of reference. (AS3 Port Manual inlining follows)
		//b2Vec2 p1 = b2MulT(transform.R, segment.p1 - transform.position);
		tX = input.p1.x - transform.position.x;
		tY = input.p1.y - transform.position.y;
		tMat = transform.R;
		float p1X = (tX * tMat.col1.x + tY * tMat.col1.y);
		float p1Y = (tX * tMat.col2.x + tY * tMat.col2.y);
		//b2Vec2 p2 = b2MulT(transform.R, segment.p2 - transform.position);
		tX = input.p2.x - transform.position.x;
		tY = input.p2.y - transform.position.y;
		tMat = transform.R;
		float p2X = (tX * tMat.col1.x + tY * tMat.col1.y);
		float p2Y = (tX * tMat.col2.x + tY * tMat.col2.y);
		//b2Vec2 d = p2 - p1;
		float dX = p2X - p1X;
		float dY = p2Y - p1Y;
		int index = -1;
		
		for (int i = 0; i < m_vertexCount; ++i)
		{
			// p = p1 + a * d
			// dot(normal, p - v) = 0
			// dot(normal, p1 - v) + a * dot(normal, d) = 0
			
			//float32 numerator = b2Dot(m_normals[i], m_vertices[i] - p1);
			tVec = m_vertices[i];
			tX = tVec.x - p1X;
			tY = tVec.y - p1Y;
			tVec = m_normals[i];
			float numerator = (tVec.x*tX + tVec.y*tY);
			//float32 denominator = b2Dot(m_normals[i], d);
			float denominator = (tVec.x * dX + tVec.y * dY);
			
			if (denominator == 0.0f)
			{
				if (numerator < 0.0f)
				{
					return false;
				}
			}
			else
			{
				// Note: we want this predicate without division:
				// lower < numerator / denominator, where denominator < 0
				// Since denominator < 0, we have to flip the inequality:
				// lower < numerator / denominator <==> denominator * lower > numerator.
				if (denominator < 0.0f && numerator < lower * denominator)
				{
					// Increase lower.
					// The segment enters this half-space.
					lower = numerator / denominator;
					index = i;
				}
				else if (denominator > 0.0f && numerator < upper * denominator)
				{
					// Decrease upper.
					// The segment exits this half-space.
					upper = numerator / denominator;
				}
			}
			
			/*if (upper < lower - float.MinValue)
			{
				return false;
			}*/
			//改
			if (upper < lower)
			{
				return false;
			}
		}
		
		//b2Settings.b2Assert(0.0 <= lower && lower <= input.maxLambda);
		
		if (index >= 0)
		{
			output.fraction = lower;
			//output.normal = b2Mul(transform.R, m_normals[index]);
			tMat = transform.R;
			tVec = m_normals[index];
			output.normal.x = (tMat.col1.x * tVec.x + tMat.col2.x * tVec.y);
			output.normal.y = (tMat.col1.y * tVec.x + tMat.col2.y * tVec.y);
			return true;
		}
		
		return false;
	}


	/**
	 * @inheritDoc
	 */
	public override void ComputeAABB(b2AABB aabb, b2Transform xf)
	{
		//var lower:b2Vec2 = b2Math.MulX(xf, m_vertices[0]);
		b2Mat22 tMat = xf.R;
		b2Vec2 tVec = m_vertices[0];
		float lowerX = xf.position.x + (tMat.col1.x * tVec.x + tMat.col2.x * tVec.y);
		float lowerY = xf.position.y + (tMat.col1.y * tVec.x + tMat.col2.y * tVec.y);
		float upperX = lowerX;
		float upperY = lowerY;
		
		for (int i = 1; i < m_vertexCount; ++i)
		{
			tVec = m_vertices[i];
			float vX = xf.position.x + (tMat.col1.x * tVec.x + tMat.col2.x * tVec.y);
			float vY = xf.position.y + (tMat.col1.y * tVec.x + tMat.col2.y * tVec.y);
			lowerX = lowerX < vX ? lowerX : vX;
			lowerY = lowerY < vY ? lowerY : vY;
			upperX = upperX > vX ? upperX : vX;
			upperY = upperY > vY ? upperY : vY;
		}

		aabb.lowerBound.x = lowerX - m_radius;
		aabb.lowerBound.y = lowerY - m_radius;
		aabb.upperBound.x = upperX + m_radius;
		aabb.upperBound.y = upperY + m_radius;
	}


	/**
	* @inheritDoc
	*/
	public override void ComputeMass(b2MassData massData, float density){
		// Polygon mass, centroid, and inertia.
		// Let rho be the polygon density in mass per unit area.
		// Then:
		// mass = rho * int(dA)
		// centroid.x = (1/mass) * rho * int(x * dA)
		// centroid.y = (1/mass) * rho * int(y * dA)
		// I = rho * int((x*x + y*y) * dA)
		//
		// We can compute these integrals by summing all the integrals
		// for each triangle of the polygon. To evaluate the integral
		// for a single triangle, we make a change of variables to
		// the (u,v) coordinates of the triangle:
		// x = x0 + e1x * u + e2x * v
		// y = y0 + e1y * u + e2y * v
		// where 0 <= u && 0 <= v && u + v <= 1.
		//
		// We integrate u from [0,1-v] and then v from [0,1].
		// We also need to use the Jacobian of the transformation:
		// D = cross(e1, e2)
		//
		// Simplification: triangle centroid = (1/3) * (p1 + p2 + p3)
		//
		// The rest of the derivation is handled by computer algebra.
		
		//b2Settings.b2Assert(m_vertexCount >= 2);
		
		// A line segment has zero mass.
		if (m_vertexCount == 2)
		{
			massData.center.x = 0.5f * (m_vertices[0].x + m_vertices[1].x);
			massData.center.y = 0.5f * (m_vertices[0].y + m_vertices[1].y);
			massData.mass = 0.0f;
			massData.I = 0.0f;
			return;
		}
		
		//b2Vec2 center; center.Set(0.0f, 0.0f);
		float centerX = 0.0f;
		float centerY = 0.0f;
		float area = 0.0f;
		float I = 0.0f;
		
		// pRef is the reference point for forming triangles.
		// It's location doesn't change the result (except for rounding error).
		//b2Vec2 pRef(0.0f, 0.0f);
		float p1X = 0.0f;
		float p1Y = 0.0f;
		/*#if 0
		// This code would put the reference point inside the polygon.
		for (int32 i = 0; i < m_vertexCount; ++i)
		{
			pRef += m_vertices[i];
		}
		pRef *= 1.0f / count;
		#endif*/
		
			float k_inv3 = 1.0f / 3.0f;
		
		for (int i = 0; i < m_vertexCount; ++i)
		{
			// Triangle vertices.
			//b2Vec2 p1 = pRef;
			//
			//b2Vec2 p2 = m_vertices[i];
			b2Vec2 p2 = m_vertices[i];
			//b2Vec2 p3 = i + 1 < m_vertexCount ? m_vertices[i+1] : m_vertices[0];
			b2Vec2 p3 = i + 1 < m_vertexCount ? m_vertices[(int)(i+1)] : m_vertices[0];
			
			//b2Vec2 e1 = p2 - p1;
			float e1X = p2.x - p1X;
			float e1Y = p2.y - p1Y;
			//b2Vec2 e2 = p3 - p1;
			float e2X = p3.x - p1X;
			float e2Y = p3.y - p1Y;
			
			//float32 D = b2Cross(e1, e2);
			float D = e1X * e2Y - e1Y * e2X;
			
			//float32 triangleArea = 0.5f * D;
			float triangleArea = 0.5f * D;
			area += triangleArea;
			
			// Area weighted centroid
			//center += triangleArea * k_inv3 * (p1 + p2 + p3);
			centerX += triangleArea * k_inv3 * (p1X + p2.x + p3.x);
			centerY += triangleArea * k_inv3 * (p1Y + p2.y + p3.y);
			
			//float32 px = p1.x, py = p1.y;
			float px = p1X;
			float py = p1Y;
			//float32 ex1 = e1.x, ey1 = e1.y;
			float ex1 = e1X;
			float ey1 = e1Y;
			//float32 ex2 = e2.x, ey2 = e2.y;
			float ex2 = e2X;
			float ey2 = e2Y;
			
			//float32 intx2 = k_inv3 * (0.25f * (ex1*ex1 + ex2*ex1 + ex2*ex2) + (px*ex1 + px*ex2)) + 0.5f*px*px;
			float intx2 = k_inv3 * (0.25f * (ex1*ex1 + ex2*ex1 + ex2*ex2) + (px*ex1 + px*ex2)) + 0.5f*px*px;
			//float32 inty2 = k_inv3 * (0.25f * (ey1*ey1 + ey2*ey1 + ey2*ey2) + (py*ey1 + py*ey2)) + 0.5f*py*py;
			float inty2 = k_inv3 * (0.25f * (ey1*ey1 + ey2*ey1 + ey2*ey2) + (py*ey1 + py*ey2)) + 0.5f*py*py;
			
			I += D * (intx2 + inty2);
		}
		
		// Total mass
		massData.mass = density * area;
		
		// Center of mass
		//b2Settings.b2Assert(area > Number.MIN_VALUE);
		//center *= 1.0f / area;
		centerX *= 1.0f / area;
		centerY *= 1.0f / area;
		//massData->center = center;
		massData.center.Set(centerX, centerY);
		
		// Inertia tensor relative to the local origin.
		massData.I = density * I;
	}

	/**
	* @inheritDoc
	*/
	public override float ComputeSubmergedArea(
			b2Vec2 normal,
			float offset,
			b2Transform xf,
			b2Vec2 c)
	{
		// Transform plane into shape co-ordinates
		b2Vec2 normalL = b2Math.MulTMV(xf.R, normal);
		float offsetL = offset - b2Math.Dot(normal, xf.position);
		
		List<float> depths = new List<float>();
		int diveCount = 0;
		int intoIndex = -1;
		int outoIndex = -1;
		
		bool lastSubmerged = false;
		int i;
		for (i = 0; i < m_vertexCount;++i)
		{
			depths[i] = b2Math.Dot(normalL, m_vertices[i]) - offsetL;
			bool isSubmerged = depths[i] < -float.MinValue;
			if (i > 0)
			{
				if (isSubmerged)
				{
					if (!lastSubmerged)
					{
						intoIndex = i - 1;
						diveCount++;
					}
				}
				else
				{
					if (lastSubmerged)
					{
						outoIndex = i - 1;
						diveCount++;
					}
				}
			}
			lastSubmerged = isSubmerged;
		}
		switch(diveCount)
		{
			case 0:
			if (lastSubmerged )
			{
				// Completely submerged
				b2MassData md = new b2MassData();
				ComputeMass(md, 1);
				c.SetV(b2Math.MulX(xf, md.center));
				return md.mass;
			}
			else
			{
				//Completely dry
				return 0;
			}
			break;
			case 1:
			if (intoIndex == -1)
			{
				intoIndex = m_vertexCount - 1;
			}
			else
			{
				outoIndex = m_vertexCount - 1;
			}
			break;
		}
		int intoIndex2 = (intoIndex + 1) % m_vertexCount;
		int outoIndex2 = (outoIndex + 1) % m_vertexCount;
		float intoLamdda = (0.0f - depths[intoIndex]) / (depths[intoIndex2] - depths[intoIndex]);
		float outoLamdda = (0.0f - depths[outoIndex]) / (depths[outoIndex2] - depths[outoIndex]);
		
		b2Vec2 intoVec = new b2Vec2(m_vertices[intoIndex].x * (1.0f - intoLamdda) + m_vertices[intoIndex2].x * intoLamdda,
										m_vertices[intoIndex].y * (1.0f - intoLamdda) + m_vertices[intoIndex2].y * intoLamdda);
		b2Vec2 outoVec = new b2Vec2(m_vertices[outoIndex].x * (1.0f - outoLamdda) + m_vertices[outoIndex2].x * outoLamdda,
										m_vertices[outoIndex].y * (1.0f - outoLamdda) + m_vertices[outoIndex2].y * outoLamdda);
										
		// Initialize accumulator
		float area = 0.0f;
		b2Vec2 center = new b2Vec2();
		b2Vec2 p2 = m_vertices[intoIndex2];
		b2Vec2 p3;
		
		// An awkward loop from intoIndex2+1 to outIndex2
		i = intoIndex2;
		while (i != outoIndex2)
		{
			i = (i + 1) % m_vertexCount;
			if(i == outoIndex2)
				p3 = outoVec;
			else
				p3 = m_vertices[i];
			
			float triangleArea = 0.5f * ( (p2.x - intoVec.x) * (p3.y - intoVec.y) - (p2.y - intoVec.y) * (p3.x - intoVec.x) );
			area += triangleArea;
			// Area weighted centroid
			center.x += triangleArea * (intoVec.x + p2.x + p3.x) / 3.0f;
			center.y += triangleArea * (intoVec.y + p2.y + p3.y) / 3.0f;
			
			p2 = p3;
		}
		
		//Normalize and transform centroid
		center.Multiply(1.0f / area);
		c.SetV(b2Math.MulX(xf, center));
		
		return area;
	}
	
	/**
	* Get the vertex count.
	*/
	public int GetVertexCount(){
		return m_vertexCount;
	}

	/**
	* Get the vertices in local coordinates.
	*/
	public List<b2Vec2> GetVertices(){
		return m_vertices;
	}
	
	/**
	* Get the edge normal vectors. There is one for each vertex.
	*/
	public List<b2Vec2> GetNormals()
	{
		return m_normals;
	}
	
	/**
	 * Get the supporting vertex index in the given direction.
	 */
	public int GetSupport(b2Vec2 d)
	{
		int bestIndex = 0;
		float bestValue = m_vertices[0].x * d.x + m_vertices[0].y * d.y;
		for (int i= 1; i < m_vertexCount; ++i)
		{
			float value = m_vertices[i].x * d.x + m_vertices[i].y * d.y;
			if (value > bestValue)
			{
				bestIndex = i;
				bestValue = value;
			}
		}
		return bestIndex;
	}
	
	public b2Vec2 GetSupportVertex(b2Vec2 d)
	{
		int bestIndex = 0;
		float bestValue = m_vertices[0].x * d.x + m_vertices[0].y * d.y;
		for (int i= 1; i < m_vertexCount; ++i)
		{
			float value = m_vertices[i].x * d.x + m_vertices[i].y * d.y;
			if (value > bestValue)
			{
				bestIndex = i;
				bestValue = value;
			}
		}
		return m_vertices[bestIndex];
	}

	// TODO: Expose this
	private bool Validate()
	{
		/*
		// Ensure the polygon is convex.
		for (int32 i = 0; i < m_vertexCount; ++i)
		{
			for (int32 j = 0; j < m_vertexCount; ++j)
			{
				// Don't check vertices on the current edge.
				if (j == i || j == (i + 1) % m_vertexCount)
				{
					continue;
				}
				
				// Your polygon is non-convex (it has an indentation).
				// Or your polygon is too skinny.
				float32 s = b2Dot(m_normals[i], m_vertices[j] - m_vertices[i]);
				b2Assert(s < -b2_linearSlop);
			}
		}
		
		// Ensure the polygon is counter-clockwise.
		for (i = 1; i < m_vertexCount; ++i)
		{
			var cross:Number = b2Math.b2CrossVV(m_normals[int(i-1)], m_normals[i]);
			
			// Keep asinf happy.
			cross = b2Math.b2Clamp(cross, -1.0, 1.0);
			
			// You have consecutive edges that are almost parallel on your polygon.
			var angle:Number = Math.asin(cross);
			//b2Assert(angle > b2_angularSlop);
			trace(angle > b2Settings.b2_angularSlop);
		}
		*/
		return false;
	}
	//--------------- Internals Below -------------------
	
	/**
	 * @private
	 */
	public b2PolygonShape(){
		
		//b2Settings.b2Assert(def.type == e_polygonShape);
		m_type = e_polygonShape;
		
		m_centroid = new b2Vec2();
		m_vertices = new List<b2Vec2>();
		m_normals = new List<b2Vec2>();
	}
	
	private void Reserve(int count)
	{
		for (int i = m_vertices.Count; i < count; i++)
		{
			m_vertices.Add(new b2Vec2());
			m_normals.Add(new b2Vec2());
		}
	}

	// Local position of the polygon centroid.
	public b2Vec2 m_centroid;

	public List<b2Vec2> m_vertices;
	public List<b2Vec2> m_normals;

	public int m_vertexCount;
	
	
	
	/**
	 * Computes the centroid of the given polygon
	 * @param	vs		vector of b2Vec specifying a polygon
	 * @param	count	length of vs
	 * @return the polygon centroid
	 */
	static public b2Vec2 ComputeCentroid(List<b2Vec2> vs, uint count)
	{
		//b2Settings.b2Assert(count >= 3);
		
		//b2Vec2 c; c.Set(0.0f, 0.0f);
		b2Vec2 c = new b2Vec2();
		float area = 0.0f;
		
		// pRef is the reference point for forming triangles.
		// It's location doesn't change the result (except for rounding error).
		//b2Vec2 pRef(0.0f, 0.0f);
		float p1X = 0.0f;
		float p1Y = 0.0f;
	/*#if 0
		// This code would put the reference point inside the polygon.
		for (int32 i = 0; i < count; ++i)
		{
			pRef += vs[i];
		}
		pRef *= 1.0f / count;
	#endif*/
		
		float inv3 = 1.0f / 3.0f;
		
		for (int i = 0; i < count; ++i)
		{
			// Triangle vertices.
			//b2Vec2 p1 = pRef;
				// 0.0, 0.0
			//b2Vec2 p2 = vs[i];
			b2Vec2 p2 = vs[i];
			//b2Vec2 p3 = i + 1 < count ? vs[i+1] : vs[0];
			b2Vec2 p3 = i + 1 < count ? vs[(int)(i+1)] : vs[0];
			
			//b2Vec2 e1 = p2 - p1;
			float e1X = p2.x - p1X;
			float e1Y = p2.y - p1Y;
			//b2Vec2 e2 = p3 - p1;
			float e2X = p3.x - p1X;
			float e2Y = p3.y - p1Y;
			
			//float32 D = b2Cross(e1, e2);
			float D = (e1X * e2Y - e1Y * e2X);
			
			//float32 triangleArea = 0.5f * D;
			float triangleArea = 0.5f * D;
			area += triangleArea;
			
			// Area weighted centroid
			//c += triangleArea * inv3 * (p1 + p2 + p3);
			c.x += triangleArea * inv3 * (p1X + p2.x + p3.x);
			c.y += triangleArea * inv3 * (p1Y + p2.y + p3.y);
		}
		
		// Centroid
		//beSettings.b2Assert(area > Number.MIN_VALUE);
		//c *= 1.0 / area;
		c.x *= 1.0f / area;
		c.y *= 1.0f / area;
		return c;
	}

	/**
	 * Computes a polygon's OBB
	 * @see http://www.geometrictools.com/Documentation/MinimumAreaRectangle.pdf
	 */
	static public void ComputeOBB(b2OBB obb, List<b2Vec2> vs, int count)
	{
		int i;
		List<b2Vec2> p = new List<b2Vec2>(count + 1);
		for (i = 0; i < count; ++i)
		{
			p[i] = vs[i];
		}
		p[count] = p[0];
		
		float minArea = float.MaxValue;
		
		for (i = 1; i <= count; ++i)
		{
			b2Vec2 root = p[(int)(i-1)];
			//b2Vec2 ux = p[i] - root;
			float uxX = p[i].x - root.x;
			float uxY = p[i].y - root.y;
			//var length:Number = ux.Normalize();
			float length = Mathf.Sqrt(uxX*uxX + uxY*uxY);
			uxX /= length;
			uxY /= length;
			//b2Settings.b2Assert(length > Number.MIN_VALUE);
			//b2Vec2 uy(-ux.y, ux.x);
			float uyX = -uxY;
			float uyY = uxX;
			//b2Vec2 lower(FLT_MAX, FLT_MAX);
			float lowerX = float.MaxValue;
			float lowerY = float.MaxValue;
			//b2Vec2 upper(-FLT_MAX, -FLT_MAX);
			float upperX = -float.MaxValue;
			float upperY = -float.MaxValue;
			
			for (int j = 0; j < count; ++j)
			{
				//b2Vec2 d = p[j] - root;
				float dX = p[j].x - root.x;
				float dY = p[j].y - root.y;
				//b2Vec2 r;
				//var rX:Number = b2Dot(ux, d);
				float rX = (uxX*dX + uxY*dY);
				//var rY:Number = b2Dot(uy, d);
				float rY = (uyX*dX + uyY*dY);
				//lower = b2Min(lower, r);
				if (rX < lowerX) lowerX = rX;
				if (rY < lowerY) lowerY = rY;
				//upper = b2Max(upper, r);
				if (rX > upperX) upperX = rX;
				if (rY > upperY) upperY = rY;
			}
			
			float area = (upperX - lowerX) * (upperY - lowerY);
			if (area < 0.95f * minArea)
			{
				minArea = area;
				//obb->R.col1 = ux;
				obb.R.col1.x = uxX;
				obb.R.col1.y = uxY;
				//obb->R.col2 = uy;
				obb.R.col2.x = uyX;
				obb.R.col2.y = uyY;
				//b2Vec2 center = 0.5f * (lower + upper);
				float centerX = 0.5f * (lowerX + upperX);
				float centerY = 0.5f * (lowerY + upperY);
				//obb->center = root + b2Mul(obb->R, center);
				b2Mat22 tMat = obb.R;
				obb.center.x = root.x + (tMat.col1.x * centerX + tMat.col2.x * centerY);
				obb.center.y = root.y + (tMat.col1.y * centerX + tMat.col2.y * centerY);
				//obb->extents = 0.5f * (upper - lower);
				obb.extents.x = 0.5f * (upperX - lowerX);
				obb.extents.y = 0.5f * (upperY - lowerY);
			}
		}
		
		//b2Settings.b2Assert(minArea < Number.MAX_VALUE);
	}
	
	
}

}
