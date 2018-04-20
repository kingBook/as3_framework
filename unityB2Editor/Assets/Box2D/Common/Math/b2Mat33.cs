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

namespace Box2D.Common.Math{
	
	
/**
* A 3-by-3 matrix. Stored in column-major order.
*/
public class b2Mat33
{
	public b2Mat33(b2Vec3 c1=null, b2Vec3 c2=null, b2Vec3 c3=null)
	{
		if (c1==null && c2==null && c3==null)
		{
			col1.SetZero();
			col2.SetZero();
			col3.SetZero();
		}
		else
		{
			col1.SetV(c1);
			col2.SetV(c2);
			col3.SetV(c3);
		}
	}
	
	public void SetVVV(b2Vec3 c1, b2Vec3 c2, b2Vec3 c3)
	{
		col1.SetV(c1);
		col2.SetV(c2);
		col3.SetV(c3);
	}
	
	public b2Mat33 Copy(){
		return new b2Mat33(col1, col2, col3);
	}
	
	public void SetM(b2Mat33 m)
	{
		col1.SetV(m.col1);
		col2.SetV(m.col2);
		col3.SetV(m.col3);
	}
	
	public void AddM(b2Mat33 m)
	{
		col1.x += m.col1.x;
		col1.y += m.col1.y;
		col1.z += m.col1.z;
		col2.x += m.col2.x;
		col2.y += m.col2.y;
		col2.z += m.col2.z;
		col3.x += m.col3.x;
		col3.y += m.col3.y;
		col3.z += m.col3.z;
	}
	
	public void SetIdentity()
	{
		col1.x = 1.0f; col2.x = 0.0f; col3.x = 0.0f;
		col1.y = 0.0f; col2.y = 1.0f; col3.y = 0.0f;
		col1.z = 0.0f; col2.z = 0.0f; col3.z = 1.0f;
	}

	public void SetZero()
	{
		col1.x = 0.0f; col2.x = 0.0f; col3.x = 0.0f;
		col1.y = 0.0f; col2.y = 0.0f; col3.y = 0.0f;
		col1.z = 0.0f; col2.z = 0.0f; col3.z = 0.0f;
	}
	
	// Solve A * x = b
	public b2Vec2 Solve22(b2Vec2 outV, float bX, float bY)
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
	
	// Solve A * x = b
	public b2Vec3 Solve33(b2Vec3 outV, float bX, float bY, float bZ)
	{
		float a11 = col1.x;
		float a21 = col1.y;
		float a31 = col1.z;
		float a12 = col2.x;
		float a22 = col2.y;
		float a32 = col2.z;
		float a13 = col3.x;
		float a23 = col3.y;
		float a33 = col3.z;
		//float32 det = b2Dot(col1, b2Cross(col2, col3));
		float det = 	a11 * (a22 * a33 - a32 * a23) +
							a21 * (a32 * a13 - a12 * a33) +
							a31 * (a12 * a23 - a22 * a13);
		if (det != 0.0f)
		{
			det = 1.0f / det;
		}
		//out.x = det * b2Dot(b, b2Cross(col2, col3));
		outV.x = det * (	bX * (a22 * a33 - a32 * a23) +
						bY * (a32 * a13 - a12 * a33) +
						bZ * (a12 * a23 - a22 * a13) );
		//out.y = det * b2Dot(col1, b2Cross(b, col3));
		outV.y = det * (	a11 * (bY * a33 - bZ * a23) +
						a21 * (bZ * a13 - bX * a33) +
						a31 * (bX * a23 - bY * a13));
		//out.z = det * b2Dot(col1, b2Cross(col2, b));
		outV.z = det * (	a11 * (a22 * bZ - a32 * bY) +
						a21 * (a32 * bX - a12 * bZ) +
						a31 * (a12 * bY - a22 * bX));
		return outV;
	}

	public b2Vec3 col1 = new b2Vec3();
	public b2Vec3 col2 = new b2Vec3();
	public b2Vec3 col3 = new b2Vec3();
};

}