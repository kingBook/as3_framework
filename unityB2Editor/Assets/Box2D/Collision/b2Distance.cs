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

using Box2D.Common.Math;
using Box2D.Common;
using System.Collections.Generic;

namespace Box2D.Collision{	

/**
* @private
*/
public class b2Distance
{

// GJK using Voronoi regions (Christer Ericson) and Barycentric coordinates.

private static int b2_gjkCalls;
private static int b2_gjkIters;
private static int b2_gjkMaxIters;

private static b2Simplex s_simplex = new b2Simplex();
private static int[] s_saveA = new int[3];
private static int[] s_saveB = new int[3];
public static void Distance(b2DistanceOutput output, b2SimplexCache cache, b2DistanceInput input)
{
	++b2_gjkCalls;
	
	b2DistanceProxy proxyA = input.proxyA;
	b2DistanceProxy proxyB = input.proxyB;
	
	b2Transform transformA = input.transformA;
	b2Transform transformB = input.transformB;
	
	// Initialize the simplex
	b2Simplex simplex = s_simplex;
	simplex.ReadCache(cache, proxyA, transformA, proxyB, transformB);
	
	// Get simplex vertices as an vector.
	b2SimplexVertex[] vertices = simplex.m_vertices;
	const int k_maxIters = 20;
	
	// These store the vertices of the last simplex so that we
	// can check for duplicates and preven cycling
	int[] saveA = s_saveA;
	int[] saveB = s_saveB;
	int saveCount = 0;
	
	b2Vec2 closestPoint = simplex.GetClosestPoint();
	float distanceSqr1 = closestPoint.LengthSquared();
	float distanceSqr2 = distanceSqr1;
	
	int i;
	b2Vec2 p;
	
	// Main iteration loop
	int iter = 0;
	while (iter < k_maxIters)
	{
		// Copy the simplex so that we can identify duplicates
		saveCount = simplex.m_count;
		for (i = 0; i < saveCount; i++)
		{
			saveA[i] = vertices[i].indexA;
			saveB[i] = vertices[i].indexB;
		}
		
		/*switch(simplex.m_count)
		{
			case 1:
				break;
			case 2:
				simplex.Solve2();
				break;
			case 3:
				simplex.Solve3();
				break;
			default:
				b2Settings.b2Assert(false);
		}*/
		if(simplex.m_count==1){
			
		}else if(simplex.m_count==2){
			simplex.Solve2();
		}else if(simplex.m_count==3){
			simplex.Solve3();	
		}else{
			b2Settings.b2Assert(false);
		}
		
		// If we have 3 points, then the origin is in the corresponding triangle.
		if (simplex.m_count == 3)
		{
			break;
		}
		
		// Compute the closest point.
		p = simplex.GetClosestPoint();
		distanceSqr2 = p.LengthSquared();
		
		// Ensure progress
		if (distanceSqr2 > distanceSqr1)
		{
			//break;
		}
		distanceSqr1 = distanceSqr2;
		
		// Get search direction.
		b2Vec2 d = simplex.GetSearchDirection();
		
		// Ensure the search direction is numerically fit.
		if (d.LengthSquared() < 0.0f/*Number.MinValue * Number.MinValue*/)
		{
			// THe origin is probably contained by a line segment or triangle.
			// Thus the shapes are overlapped.
			
			// We can't return zero here even though there may be overlap.
			// In case the simplex is a point, segment or triangle it is very difficult
			// to determine if the origin is contained in the CSO or very close to it
			break;
		}
		
		// Compute a tentative new simplex vertex using support points
		b2SimplexVertex vertex = vertices[simplex.m_count];
		vertex.indexA = (int)proxyA.GetSupport(b2Math.MulTMV(transformA.R, d.GetNegative()));
		vertex.wA = b2Math.MulX(transformA, proxyA.GetVertex(vertex.indexA));
		vertex.indexB = (int)proxyB.GetSupport(b2Math.MulTMV(transformB.R, d));
		vertex.wB = b2Math.MulX(transformB, proxyB.GetVertex(vertex.indexB));
		vertex.w = b2Math.SubtractVV(vertex.wB, vertex.wA);
		
		// Iteration count is equated to the number of support point calls.
		++iter;
		++b2_gjkIters;
		
		// Check for duplicate support points. This is the main termination criteria.
		bool duplicate = false;
		for (i = 0; i < saveCount; i++)
		{
			if (vertex.indexA == saveA[i] && vertex.indexB == saveB[i])
			{
				duplicate = true;
				break;
			}
		}
		
		// If we found a duplicate support point we must exist to avoid cycling
		if (duplicate)
		{
			break;
		}
		
		// New vertex is ok and needed.
		++simplex.m_count;
	}
	
	b2_gjkMaxIters = (int)b2Math.Max(b2_gjkMaxIters, iter);
	
	// Prepare output
	simplex.GetWitnessPoints(output.pointA, output.pointB);
	output.distance = b2Math.SubtractVV(output.pointA, output.pointB).Length();
	output.iterations = iter;
	
	// Cache the simplex
	simplex.WriteCache(cache);
	
	// Apply radii if requested.
	if (input.useRadii)
	{
		float rA = proxyA.m_radius;
		float rB = proxyB.m_radius;
		
		if (output.distance > rA + rB && output.distance > float.MinValue)
		{
			// Shapes are still not overlapped.
			// Move the witness points to the outer surface.
			output.distance -= rA + rB;
			b2Vec2 normal = b2Math.SubtractVV(output.pointB, output.pointA);
			normal.Normalize();
			output.pointA.x += rA * normal.x;
			output.pointA.y += rA * normal.y;
			output.pointB.x -= rB * normal.x;
			output.pointB.y -= rB * normal.y;
		}
		else
		{
			// Shapes are overlapped when radii are considered.
			// Move the witness points to the middle.
			p = new b2Vec2();
			p.x = 0.5f * (output.pointA.x + output.pointB.x);
			p.y = 0.5f * (output.pointA.y + output.pointB.y);
			output.pointA.x = output.pointB.x = p.x;
			output.pointA.y = output.pointB.y = p.y;
			output.distance = 0.0f;
		}
	}
}

}


}