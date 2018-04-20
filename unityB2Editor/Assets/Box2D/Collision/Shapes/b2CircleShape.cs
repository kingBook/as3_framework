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
using UnityEngine;

namespace Box2D.Collision.Shapes{




/**
* A circle shape.
* @see b2CircleDef
*/
public class b2CircleShape : b2Shape
{
	override public b2Shape Copy() 
	{
		b2Shape s = new b2CircleShape();
		s.Set(this);
		return s;
	}
	
	override public void Set(b2Shape other) 
	{
		base.Set(other);
		if (other is b2CircleShape)
		{
			b2CircleShape other2 = other as b2CircleShape;
			m_p.SetV(other2.m_p);
		}
	}
	
	/**
	* @inheritDoc
	*/
	public override bool TestPoint(b2Transform transform, b2Vec2 p){
		//b2Vec2 center = transform.position + b2Mul(transform.R, m_p);
		b2Mat22 tMat = transform.R;
		float dX = transform.position.x + (tMat.col1.x * m_p.x + tMat.col2.x * m_p.y);
		float dY = transform.position.y + (tMat.col1.y * m_p.x + tMat.col2.y * m_p.y);
		//b2Vec2 d = p - center;
		dX = p.x - dX;
		dY = p.y - dY;
		//return b2Dot(d, d) <= m_radius * m_radius;
		return (dX*dX + dY*dY) <= m_radius * m_radius;
	}

	/**
	* @inheritDoc
	*/
	public override bool RayCast(b2RayCastOutput output, b2RayCastInput input, b2Transform transform)
	{
		//b2Vec2 position = transform.position + b2Mul(transform.R, m_p);
		b2Mat22 tMat = transform.R;
		float positionX = transform.position.x + (tMat.col1.x * m_p.x + tMat.col2.x * m_p.y);
		float positionY = transform.position.y + (tMat.col1.y * m_p.x + tMat.col2.y * m_p.y);
		
		//b2Vec2 s = input.p1 - position;
		float sX = input.p1.x - positionX;
		float sY = input.p1.y - positionY;
		//float32 b = b2Dot(s, s) - m_radius * m_radius;
		float b = (sX*sX + sY*sY) - m_radius * m_radius;
		
		/*// Does the segment start inside the circle?
		if (b < 0.0)
		{
			output.fraction = 0;
			output.hit = e_startsInsideCollide;
			return;
		}*/
		
		// Solve quadratic equation.
		//b2Vec2 r = input.p2 - input.p1;
		float rX = input.p2.x - input.p1.x;
		float rY = input.p2.y - input.p1.y;
		//float32 c =  b2Dot(s, r);
		float c =  (sX*rX + sY*rY);
		//float32 rr = b2Dot(r, r);
		float rr = (rX*rX + rY*rY);
		float sigma = c * c - rr * b;
		
		// Check for negative discriminant and short segment.
		if (sigma < 0.0 || rr < float.MinValue)
		{
			return false;
		}
		
		// Find the point of intersection of the line with the circle.
		float a = -(c + Mathf.Sqrt(sigma));
		
		// Is the intersection point on the segment?
		if (0.0f <= a && a <= input.maxFraction * rr)
		{
			a /= rr;
			output.fraction = a;
			// manual inline of: output.normal = s + a * r;
			output.normal.x = sX + a * rX;
			output.normal.y = sY + a * rY;
			output.normal.Normalize();
			return true;
		}
		
		return false;
	}

	/**
	* @inheritDoc
	*/
	public override void ComputeAABB(b2AABB aabb, b2Transform transform){
		//b2Vec2 p = transform.position + b2Mul(transform.R, m_p);
		b2Mat22 tMat = transform.R;
		float pX = transform.position.x + (tMat.col1.x * m_p.x + tMat.col2.x * m_p.y);
		float pY = transform.position.y + (tMat.col1.y * m_p.x + tMat.col2.y * m_p.y);
		aabb.lowerBound.Set(pX - m_radius, pY - m_radius);
		aabb.upperBound.Set(pX + m_radius, pY + m_radius);
	}

	/**
	* @inheritDoc
	*/
	public override void ComputeMass(b2MassData massData, float density){
		massData.mass = density * b2Settings.b2_pi * m_radius * m_radius;
		massData.center.SetV(m_p);
		
		// inertia about the local origin
		//massData.I = massData.mass * (0.5 * m_radius * m_radius + b2Dot(m_p, m_p));
		massData.I = massData.mass * (0.5f * m_radius * m_radius + (m_p.x*m_p.x + m_p.y*m_p.y));
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
		b2Vec2 p = b2Math.MulX(xf, m_p);
		float l = -(b2Math.Dot(normal, p) - offset);
		
		if (l < -m_radius + float.MinValue)
		{
			//Completely dry
			return 0.0f;
		}
		if (l > m_radius)
		{
			//Completely wet
			c.SetV(p);
			return Mathf.PI * m_radius * m_radius;
		}
		
		//Magic
		float r2 = m_radius * m_radius;
		float l2 = l * l;
		float area = r2 *( Mathf.Asin(l / m_radius) + Mathf.PI / 2.0f) + l * Mathf.Sqrt( r2 - l2 );
		float com = -2.0f / 3.0f * Mathf.Pow(r2 - l2, 1.5f) / area;
		
		c.x = p.x + normal.x * com;
		c.y = p.y + normal.y * com;
		
		return area;
	}

	/**
	 * Get the local position of this circle in its parent body.
	 */
	public b2Vec2 GetLocalPosition(){
		return m_p;
	}
	
	/**
	 * Set the local position of this circle in its parent body.
	 */
	public void SetLocalPosition(b2Vec2 position) {
		m_p.SetV(position);
	}
	
	/**
	 * Get the radius of the circle
	 */
	public float GetRadius()
	{
		return m_radius;
	}
	
	/**
	 * Set the radius of the circle
	 */
	public void SetRadius(float radius)
	{
		m_radius = radius;
	}

	public b2CircleShape(float radius = 0.0f):base(){
		m_type = e_circleShape;
		m_radius = radius;
	}

	// Local position in parent body
	public b2Vec2 m_p = new b2Vec2();
	
}

}
