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

//import Box2D.Common.b2Settings;
//import Box2D.Collision.b2AABB;

/**
* @private
*/
public class b2Math{

	/**
	* This function is used to ensure that a floating point number is
	* not a NaN or infinity.
	*/
	static public bool IsValid(float x)
	{
		return x!=Mathf.Infinity && x!=Mathf.NegativeInfinity;
	}
	
	/*static public function b2InvSqrt(x:Number):Number{
		union
		{
			float32 x;
			int32 i;
		} convert;
		
		convert.x = x;
		float32 xhalf = 0.5f * x;
		convert.i = 0x5f3759df - (convert.i >> 1);
		x = convert.x;
		x = x * (1.5f - xhalf * x * x);
		return x;
	}*/

	static public float Dot(b2Vec2 a, b2Vec2 b)
	{
		return a.x * b.x + a.y * b.y;
	}

	static public float CrossVV(b2Vec2 a, b2Vec2 b)
	{
		return a.x * b.y - a.y * b.x;
	}

	static public b2Vec2 CrossVF(b2Vec2 a, float s)
	{
		b2Vec2 v = new b2Vec2(s * a.y, -s * a.x);
		return v;
	}

	static public b2Vec2 CrossFV(float s, b2Vec2 a)
	{
		b2Vec2 v = new b2Vec2(-s * a.y, s * a.x);
		return v;
	}

	static public b2Vec2 MulMV(b2Mat22 A, b2Vec2 v)
	{
		// (tMat.col1.x * tVec.x + tMat.col2.x * tVec.y)
		// (tMat.col1.y * tVec.x + tMat.col2.y * tVec.y)
		b2Vec2 u = new b2Vec2(A.col1.x * v.x + A.col2.x * v.y, A.col1.y * v.x + A.col2.y * v.y);
		return u;
	}

	static public b2Vec2 MulTMV(b2Mat22 A, b2Vec2 v)
	{
		// (tVec.x * tMat.col1.x + tVec.y * tMat.col1.y)
		// (tVec.x * tMat.col2.x + tVec.y * tMat.col2.y)
		b2Vec2 u = new b2Vec2(Dot(v, A.col1), Dot(v, A.col2));
		return u;
	}
	
	static public b2Vec2 MulX(b2Transform T, b2Vec2 v)
	{
		b2Vec2 a = MulMV(T.R, v);
		a.x += T.position.x;
		a.y += T.position.y;
		//return T.position + b2Mul(T.R, v);
		return a;
	}

	static public b2Vec2 MulXT(b2Transform T, b2Vec2 v)
	{
		b2Vec2 a = SubtractVV(v, T.position);
		//return b2MulT(T.R, v - T.position);
		float tX = (a.x * T.R.col1.x + a.y * T.R.col1.y );
		a.y = (a.x * T.R.col2.x + a.y * T.R.col2.y );
		a.x = tX;
		return a;
	}

	static public b2Vec2 AddVV(b2Vec2 a, b2Vec2 b)
	{
		b2Vec2 v = new b2Vec2(a.x + b.x, a.y + b.y);
		return v;
	}

	static public b2Vec2 SubtractVV(b2Vec2 a, b2Vec2 b)
	{
		b2Vec2 v = new b2Vec2(a.x - b.x, a.y - b.y);
		return v;
	}
	
	static public float Distance(b2Vec2 a, b2Vec2 b){
		float cX = a.x-b.x;
		float cY = a.y-b.y;
		return Mathf.Sqrt(cX*cX + cY*cY);
	}
	
	static public float DistanceSquared(b2Vec2 a, b2Vec2 b){
		float cX = a.x-b.x;
		float cY = a.y-b.y;
		return (cX*cX + cY*cY);
	}

	static public b2Vec2 MulFV(float s, b2Vec2 a)
	{
		b2Vec2 v = new b2Vec2(s * a.x, s * a.y);
		return v;
	}

	static public b2Mat22 AddMM(b2Mat22 A, b2Mat22 B)
	{
		b2Mat22 C = b2Mat22.FromVV(AddVV(A.col1, B.col1), AddVV(A.col2, B.col2));
		return C;
	}

	// A * B
	static public b2Mat22 MulMM(b2Mat22 A, b2Mat22 B)
	{
		b2Mat22 C = b2Mat22.FromVV(MulMV(A, B.col1), MulMV(A, B.col2));
		return C;
	}

	// A^T * B
	static public b2Mat22 MulTMM(b2Mat22 A, b2Mat22 B)
	{
		b2Vec2 c1 = new b2Vec2(Dot(A.col1, B.col1), Dot(A.col2, B.col1));
		b2Vec2 c2 = new b2Vec2(Dot(A.col1, B.col2), Dot(A.col2, B.col2));
		b2Mat22 C = b2Mat22.FromVV(c1, c2);
		return C;
	}

	static public float Abs(float a)
	{
		return a > 0.0f ? a : -a;
	}

	static public b2Vec2 AbsV(b2Vec2 a)
	{
		b2Vec2 b = new b2Vec2(Abs(a.x), Abs(a.y));
		return b;
	}

	static public b2Mat22 AbsM(b2Mat22 A)
	{
		b2Mat22 B = b2Mat22.FromVV(AbsV(A.col1), AbsV(A.col2));
		return B;
	}

	static public float Min(float a, float b)
	{
		return a < b ? a : b;
	}

	static public b2Vec2 MinV(b2Vec2 a, b2Vec2 b)
	{
		b2Vec2 c = new b2Vec2(Min(a.x, b.x), Min(a.y, b.y));
		return c;
	}

	static public float Max(float a, float b)
	{
		return a > b ? a : b;
	}

	static public b2Vec2 MaxV(b2Vec2 a, b2Vec2 b)
	{
		b2Vec2 c = new b2Vec2(Max(a.x, b.x), Max(a.y, b.y));
		return c;
	}

	static public float Clamp(float a, float low, float high)
	{
		return a < low ? low : a > high ? high : a;
	}

	static public b2Vec2 ClampV(b2Vec2 a, b2Vec2 low, b2Vec2 high)
	{
		return MaxV(low, MinV(a, high));
	}
	//kingBook
	/*static public void Swap(a:Array, b:Array)
	{
		var tmp:* = a[0];
		a[0] = b[0];
		b[0] = tmp;
	}*/

	// b2Random number in range [-1,1]
	static public float Random()
	{
		return  UnityEngine.Random.value* 2 - 1;
	}

	static public float RandomRange(float lo, float hi)
	{
		float r = UnityEngine.Random.value;
		r = (hi - lo) * r + lo;
		return r;
	}

	// "Next Largest Power of 2
	// Given a binary integer value x, the next largest power of 2 can be computed by a SWAR algorithm
	// that recursively "folds" the upper bits into the lower bits. This process yields a bit vector with
	// the same most significant 1 as x, but all 1's below it. Adding 1 to that value yields the next
	// largest power of 2. For a 32-bit value:"
	static public uint NextPowerOfTwo(uint x)
	{
		x |= (x >> 1) & 0x7FFFFFFF;
		x |= (x >> 2) & 0x3FFFFFFF;
		x |= (x >> 4) & 0x0FFFFFFF;
		x |= (x >> 8) & 0x00FFFFFF;
		x |= (x >> 16)& 0x0000FFFF;
		return x + 1;
	}

	static public bool IsPowerOfTwo(uint x)
	{
		bool result = x > 0 && (x & (x - 1)) == 0;
		return result;
	}
	
	
	// Temp vector functions to reduce calls to 'new'
	/*static public var tempVec:b2Vec2 = new b2Vec2();
	static public var tempVec2:b2Vec2 = new b2Vec2();
	static public var tempVec3:b2Vec2 = new b2Vec2();
	static public var tempVec4:b2Vec2 = new b2Vec2();
	static public var tempVec5:b2Vec2 = new b2Vec2();
	
	static public var tempMat:b2Mat22 = new b2Mat22();	
	
	static public var tempAABB:b2AABB = new b2AABB();	*/
	
	public static b2Vec2 b2Vec2_zero = new b2Vec2(0.0f, 0.0f);
	public static b2Mat22 b2Mat22_identity = b2Mat22.FromVV(new b2Vec2(1.0f, 0.0f), new b2Vec2(0.0f, 1.0f));
	public static b2Transform b2Transform_identity = new b2Transform(b2Vec2_zero, b2Mat22_identity);
	

}
}
