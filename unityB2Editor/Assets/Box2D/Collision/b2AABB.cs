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
using Box2D.Collision.Shapes;
using Box2D.Common;
using Box2D.Common.Math;

namespace Box2D.Collision{

/**
* An axis aligned bounding box.
*/
public class b2AABB
{
	/**
	* Verify that the bounds are sorted.
	*/
	public bool IsValid(){
		//b2Vec2 d = upperBound - lowerBound;;
		float dX = upperBound.x - lowerBound.x;
		float dY = upperBound.y - lowerBound.y;
		bool valid = dX >= 0.0f && dY >= 0.0f;
		valid = valid && lowerBound.IsValid() && upperBound.IsValid();
		return valid;
	}
	
	/** Get the center of the AABB. */
	public b2Vec2 GetCenter()
	{
		return new b2Vec2( (lowerBound.x + upperBound.x)*0.5f,
		                   (lowerBound.y + upperBound.y)*0.5f);
	}
	
	/** Get the extents of the AABB (half-widths). */
	public b2Vec2 GetExtents()
	{
		return new b2Vec2( (upperBound.x - lowerBound.x)*0.5f,
		                   (upperBound.y - lowerBound.y)*0.5f);
	}
	
	/**
	 * Is an AABB contained within this one.
	 */
	public bool Contains(b2AABB aabb)
	{
		bool result = true;
		if(result)result= lowerBound.x <= aabb.lowerBound.x;
		if(result)result= lowerBound.y <= aabb.lowerBound.y;
		if(result)result= aabb.upperBound.x <= upperBound.x;
		if(result)result= aabb.upperBound.y <= upperBound.y;
		return result;
	}
	
	// From Real-time Collision Detection, p179.
	/**
	 * Perform a precise raycast against the AABB.
	 */
	public bool RayCast(b2RayCastOutput output, b2RayCastInput input)
	{
		float tmin = -float.MaxValue;
		//float tmax = float.MaxValue;
		
		float pX = input.p1.x;
		float pY = input.p1.y;
		float dX = input.p2.x - input.p1.x;
		float dY = input.p2.y - input.p1.y;
		float absDX = Mathf.Abs(dX);
		float absDY = Mathf.Abs(dY);
		
		b2Vec2 normal = output.normal;
		
		float inv_d;
		float t1;
		float t2;
		float t3;
		float s;
		
		//x
			if (absDX < float.MinValue)
			{
				// Parallel.
				if (pX < lowerBound.x || upperBound.x < pX)
					return false;
			}
			else
			{
				inv_d = 1.0f / dX;
				t1 = (lowerBound.x - pX) * inv_d;
				t2 = (upperBound.x - pX) * inv_d;
				
				// Sign of the normal vector
				s = -1.0f;
				
				if (t1 > t2)
				{
					t3 = t1;
					t1 = t2;
					t2 = t3;
					s = 1.0f;
				}
				
				// Push the min up
				if (t1 > tmin)
				{
					normal.x = s;
					normal.y = 0.0f;
					tmin = t1;
				}
				
				// Pull the max down
				float tmax = Mathf.Min(float.MaxValue, t2);
				
				if (tmin > tmax)
					return false;
			}
		//y
			if (absDY < float.MinValue)
			{
				// Parallel.
				if (pY < lowerBound.y || upperBound.y < pY)
					return false;
			}
			else
			{
				inv_d = 1.0f / dY;
				t1 = (lowerBound.y - pY) * inv_d;
				t2 = (upperBound.y - pY) * inv_d;
				
				// Sign of the normal vector
				s = -1.0f;
				
				if (t1 > t2)
				{
					t3 = t1;
					t1 = t2;
					t2 = t3;
					s = 1.0f;
				}
				
				// Push the min up
				if (t1 > tmin)
				{
					normal.y = s;
					normal.x = 0.0f;
					tmin = t1;
				}
				
				// Pull the max down
				float tmax = Mathf.Min(float.MaxValue, t2);
				
				if (tmin > tmax)
					return false;
			}		
		
		output.fraction = tmin;
		return true;
	}
	
	/**
	 * Tests if another AABB overlaps this one.
	 */
	public bool TestOverlap(b2AABB other)
	{
		float d1X = other.lowerBound.x - upperBound.x;
		float d1Y = other.lowerBound.y - upperBound.y;
		float d2X = lowerBound.x - other.upperBound.x;
		float d2Y = lowerBound.y - other.upperBound.y;

		if (d1X > 0.0 || d1Y > 0.0)
			return false;

		if (d2X > 0.0 || d2Y > 0.0)
			return false;

		return true;
	}
	
	/** Combine two AABBs into one. */
	public static b2AABB CombineStatic(b2AABB aabb1, b2AABB aabb2)
	{
		b2AABB aabb = new b2AABB();
		aabb.Combine(aabb1, aabb2);
		return aabb;
	}
	
	/** Combine two AABBs into one. */
	public void Combine(b2AABB aabb1, b2AABB aabb2)
	{
		lowerBound.x = Mathf.Min(aabb1.lowerBound.x, aabb2.lowerBound.x);
		lowerBound.y = Mathf.Min(aabb1.lowerBound.y, aabb2.lowerBound.y);
		upperBound.x = Mathf.Max(aabb1.upperBound.x, aabb2.upperBound.x);
		upperBound.y = Mathf.Max(aabb1.upperBound.y, aabb2.upperBound.y);
	}
	
	//----------------add code----------------
	//2015/9/21 10:30 kingBook
	public string ToString2(float ptm_ratio=1){
		return "lowerBound:"+lowerBound.ToString2(ptm_ratio)+" upperBound:"+upperBound.ToString2(ptm_ratio);
	}
	public override string ToString(){
		return "lowerBound:"+lowerBound.ToString()+" upperBound:"+upperBound.ToString();
	}
	
	public bool ContainsV(b2Vec2 v){
		bool result=true;
		if(result)result=lowerBound.x<v.x;
		if(result)result=lowerBound.y<v.y;
		if(result)result=upperBound.x>v.x;
		if(result)result=upperBound.y>v.y;
		return result;
	}
	
	static public b2AABB Make(b2Vec2 lowerBound,b2Vec2 upperBound){
		b2AABB aabb=new b2AABB();
		aabb.lowerBound.x=lowerBound.x;
		aabb.lowerBound.y=lowerBound.y;
		aabb.upperBound.x=upperBound.x;
		aabb.upperBound.y=upperBound.y;
		return aabb;
	}
	
	static public b2AABB MakeWH(float w,float h,float centerX,float centerY){
		b2AABB aabb=new b2AABB();
		float wf=w*0.5f;
		float hf=h*0.5f;
		aabb.lowerBound.x=centerX-wf;
		aabb.lowerBound.y=centerY-hf;
		aabb.upperBound.x=centerX+wf;
		aabb.upperBound.y=centerY+hf;
		return aabb;
	}
	
	public void Offset(float tx,float ty){
		lowerBound.x += tx; lowerBound.y+=ty;
		upperBound.x += tx; upperBound.y+=ty;
	}
	
	//----------------add code end----------------

	/** The lower vertex */
	public b2Vec2 lowerBound = new b2Vec2();
	/** The upper vertex */
	public b2Vec2 upperBound = new b2Vec2();
}


}