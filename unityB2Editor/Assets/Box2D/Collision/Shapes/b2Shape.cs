﻿/*
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
using Box2D.Common;
using Box2D.Common.Math;

namespace Box2D.Collision.Shapes{




/**
* A shape is used for collision detection. Shapes are created in b2Body.
* You can use shape for collision detection before they are attached to the world.
* @warning you cannot reuse shapes.
*/
public class b2Shape
{
	
	/**
	 * Clone the shape
	 */
	virtual public b2Shape Copy()
	{
		//var s:b2Shape = new b2Shape();
		//s.Set(this);
		//return s;
		return null; // Abstract type
	}
	
	/**
	 * Assign the properties of anther shape to this
	 */
	virtual public void Set(b2Shape other)
	{
		//Don't copy m_type?
		//m_type = other.m_type;
		m_radius = other.m_radius;
	}
	
	/**
	* Get the type of this shape. You can use this to down cast to the concrete shape.
	* @return the shape type.
	*/
	public int GetType()
	{
		return m_type;
	}

	/**
	* Test a point for containment in this shape. This only works for convex shapes.
	* @param xf the shape world transform.
	* @param p a point in world coordinates.
	*/
	virtual public bool TestPoint(b2Transform xf, b2Vec2 p) {return false;}

	/**
	 * Cast a ray against this shape.
	 * @param output the ray-cast results.
	 * @param input the ray-cast input parameters.
	 * @param transform the transform to be applied to the shape.
	 */
	virtual public bool RayCast(b2RayCastOutput output, b2RayCastInput input, b2Transform transform)
	{
		return false;
	}

	/**
	* Given a transform, compute the associated axis aligned bounding box for this shape.
	* @param aabb returns the axis aligned box.
	* @param xf the world transform of the shape.
	*/
	virtual public void ComputeAABB(b2AABB aabb, b2Transform xf) {}

	/**
	* Compute the mass properties of this shape using its dimensions and density.
	* The inertia tensor is computed about the local origin, not the centroid.
	* @param massData returns the mass data for this shape.
	*/
	virtual public void ComputeMass(b2MassData massData, float density) { }
	
	/**
	 * Compute the volume and centroid of this shape intersected with a half plane
	 * @param normal the surface normal
	 * @param offset the surface offset along normal
	 * @param xf the shape transform
	 * @param c returns the centroid
	 * @return the total volume less than offset along normal
	 */
	virtual public float ComputeSubmergedArea(
			b2Vec2 normal,
			float offset,
			b2Transform xf,
			b2Vec2 c) { return 0.0f; }
				
	public static bool TestOverlap(b2Shape shape1, b2Transform transform1, b2Shape shape2, b2Transform transform2)
	{
		b2DistanceInput input = new b2DistanceInput();
		input.proxyA = new b2DistanceProxy();
		input.proxyA.Set(shape1);
		input.proxyB = new b2DistanceProxy();
		input.proxyB.Set(shape2);
		input.transformA = transform1;
		input.transformB = transform2;
		input.useRadii = true;
		b2SimplexCache simplexCache = new b2SimplexCache();
		simplexCache.count = 0;
		b2DistanceOutput output = new b2DistanceOutput();
		b2Distance.Distance(output, simplexCache, input);
		
		//return output.distance  < 10.0f * float.MinValue;
		//改
		return output.distance < 1e-10f;
	}
	
	//--------------- Internals Below -------------------
	/**
	 * @private
	 */
	public b2Shape()
	{
		m_type = e_unknownShape;
		m_radius = b2Settings.b2_linearSlop;
	}
	
	//~b2Shape();
	
	public int m_type;
	public float m_radius;
	
	/**
	* The various collision shape types supported by Box2D.
	*/
	//enum b2ShapeType
	//{
		public const int e_unknownShape =  -1;
		public const int e_circleShape = 	0;
		public const int e_polygonShape = 	1;
		public const int e_edgeShape =      2;
		public const int e_shapeTypeCount = 3;
	//};
	
	/**
	 * Possible return values for TestSegment
	 */
		/** Return value for TestSegment indicating a hit. */
		public const int e_hitCollide = 1;
		/** Return value for TestSegment indicating a miss. */
		public const int e_missCollide = 0;
		/** Return value for TestSegment indicating that the segment starting point, p1, is already inside the shape. */
		public const int e_startsInsideCollide = -1;
}

	
}
