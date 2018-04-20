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
* A 2D column vector with 3 elements.
*/

public class b2Vec3
{
	/**
	 * Construct using co-ordinates
	 */
	public b2Vec3(float x = 0.0f, float y = 0.0f, float z = 0.0f)
	{
		this.x = x;
		this.y = y;
		this.z = z;
	}
	
	/**
	 * Sets this vector to all zeros
	 */
	public void SetZero()
	{
		x = y = z = 0.0f;
	}
	
	/**
	 * Set this vector to some specified coordinates.
	 */
		public void Set(float x, float y, float z)
	{
		this.x = x;
		this.y = y;
		this.z = z;
	}
	
	public void SetV(b2Vec3 v)
	{
		x = v.x;
		y = v.y;
		z = v.z;
	}
	
	/**
	 * Negate this vector
	 */
	public b2Vec3 GetNegative() { return new b2Vec3( -x, -y, -z); }
	
	public void NegativeSelf() { x = -x; y = -y; z = -z; }
	
	public b2Vec3 Copy(){
		return new b2Vec3(x,y,z);
	}
	
	public void Add(b2Vec3 v)
	{
		x += v.x; y += v.y; z += v.z;
	}
	
	public void Subtract(b2Vec3 v)
	{
		x -= v.x; y -= v.y; z -= v.z;
	}

	public void Multiply(float a)
	{
		x *= a; y *= a; z *= a;
	}
	
	public float x;
	public float y;
	public float z;
	
}
}