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
namespace Box2D.Common.Math{

	

	
	
/**
* A 2-by-2 matrix. Stored in column-major order.
*/
public class b2Mat22
{
	public b2Mat22()
	{
		col1.x = col2.y = 1.0f;
	}
	
	public static b2Mat22 FromAngle(float angle)
	{
		b2Mat22 mat = new b2Mat22();
		mat.Set(angle);
		return mat;
	}
	
	public static b2Mat22 FromVV(b2Vec2 c1, b2Vec2 c2)
	{
		b2Mat22 mat = new b2Mat22();
		mat.SetVV(c1, c2);
		return mat;
	}

	public void Set(float angle)
	{
		float c = Mathf.Cos(angle);
		float s = Mathf.Sin(angle);
		col1.x = c; col2.x = -s;
		col1.y = s; col2.y = c;
	}
	
	public void SetVV(b2Vec2 c1, b2Vec2 c2)
	{
		col1.SetV(c1);
		col2.SetV(c2);
	}
	
	public b2Mat22 Copy(){
		b2Mat22 mat = new b2Mat22();
		mat.SetM(this);
		return mat;
	}
	
	public void SetM(b2Mat22 m)
	{
		col1.SetV(m.col1);
		col2.SetV(m.col2);
	}
	
	public void AddM(b2Mat22 m)
	{
		col1.x += m.col1.x;
		col1.y += m.col1.y;
		col2.x += m.col2.x;
		col2.y += m.col2.y;
	}
	
	public void SetIdentity()
	{
		col1.x = 1.0f; col2.x = 0.0f;
		col1.y = 0.0f; col2.y = 1.0f;
	}

	public void SetZero()
	{
		col1.x = 0.0f; col2.x = 0.0f;
		col1.y = 0.0f; col2.y = 0.0f;
	}
	
	public float GetAngle()
	{
		return Mathf.Atan2(col1.y, col1.x);
	}

	/**
	 * Compute the inverse of this matrix, such that inv(A) * A = identity.
	 */
	public b2Mat22 GetInverse(b2Mat22 outM)
	{
		float a = col1.x; 
		float b = col2.x; 
		float c = col1.y; 
		float d = col2.y;
		//b2Mat22 B = new b2Mat22();
		float det = a * d - b * c;
		if (det != 0.0f)
		{
			det = 1.0f / det;
		}
		outM.col1.x =  det * d;	outM.col2.x = -det * b;
		outM.col1.y = -det * c;	outM.col2.y =  det * a;
		return outM;
	}
	
	// Solve A * x = b
	public b2Vec2 Solve(b2Vec2 outV, float bX, float bY)
	{
		//float32 a11 = col1.x, a12 = col2.x, a21 = col1.y, a22 = col2.y;
		float a11 = col1.x;
		float a12 = col2.x;
		float a21 = col1.y;
		float a22 = col2.y;
		//float32 det = a11 * a22 - a12 * a21;
		float det = a11 * a22 - a12 * a21;
		if (det != 0.0f)
		{
			det = 1.0f / det;
		}
		outV.x = det * (a22 * bX - a12 * bY);
		outV.y = det * (a11 * bY - a21 * bX);
		
		return outV;
	}
	
	public void Abs()
	{
		col1.Abs();
		col2.Abs();
	}

	public b2Vec2 col1 = new b2Vec2();
	public b2Vec2 col2 = new b2Vec2();
}

}