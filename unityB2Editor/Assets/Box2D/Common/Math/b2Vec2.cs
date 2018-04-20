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
* A 2D column vector.
*/
[System.Serializable]
public class b2Vec2
{
	public b2Vec2(float x_=0.0f, float y_=0.0f){x=x_; y=y_;}

	public void SetZero(){ x = 0.0f; y = 0.0f; }
	public void Set(float x_=0f, float y_=0f){x=x_; y=y_;}
	public void SetV(b2Vec2 v){x=v.x; y=v.y;}

	public b2Vec2 GetNegative(){ return new b2Vec2(-x, -y); }
	public void NegativeSelf() { x = -x; y = -y; }
	
	static public b2Vec2 Make(float x_, float y_)
	{
		return new b2Vec2(x_, y_);
	}
	//----------start-----
	//2015/9/21 10:01 kingBook
	private static b2Vec2 _onceV=new b2Vec2();
	static public b2Vec2 MakeOnce(float x_, float y_){
		_onceV.x=x_;
		_onceV.y=y_;
		return _onceV;
	}
	static public b2Vec2 MakeFromAngle(float angle,float length,bool isOnce=false){
		b2Vec2 v=isOnce?_onceV:new b2Vec2(0,0);
		v.x=Mathf.Cos(angle)*length;
		v.y=Mathf.Sin(angle)*length;
		return v;
	}
	static public float Distance(b2Vec2 v1,b2Vec2 v2){		
		//float dx=Mathf.Abs(v1.x-v2.x);
		//float dy=Mathf.Abs(v1.y-v2.y);
		float dx=v1.x-v2.x;
		float dy=v1.y-v2.y;
		return Mathf.Sqrt(dx*dx+dy*dy);
	}
	//----------end------
	
	public b2Vec2 Copy(){
		return new b2Vec2(x,y);
	}
	
	public void Add(b2Vec2 v)
	{
		x += v.x; y += v.y;
	}
	
	public void Subtract(b2Vec2 v)
	{
		x -= v.x; y -= v.y;
	}

	public void Multiply(float a)
	{
		x *= a; y *= a;
	}
	
	public void MulM(b2Mat22 A)
	{
		float tX = x;
		x = A.col1.x * tX + A.col2.x * y;
		y = A.col1.y * tX + A.col2.y * y;
	}
	
	public void MulTM(b2Mat22 A)
	{
		float tX = b2Math.Dot(this, A.col1);
		y = b2Math.Dot(this, A.col2);
		x = tX;
	}
	
	public void CrossVF(float s)
	{
		float tX = x;
		x = s * y;
		y = -s * tX;
	}
	
	public void CrossFV(float s)
	{
		float tX = x;
		x = -s * y;
		y = s * tX;
	}
	
	public void MinV(b2Vec2 b)
	{
		x = x < b.x ? x : b.x;
		y = y < b.y ? y : b.y;
	}
	
	public void MaxV(b2Vec2 b)
	{
		x = x > b.x ? x : b.x;
		y = y > b.y ? y : b.y;
	}
	
	public void Abs()
	{
		if (x < 0f) x = -x;
		if (y < 0f) y = -y;
	}

	public float Length()
	{
		return Mathf.Sqrt(x * x + y * y);
	}
	
	public float LengthSquared()
	{
		return (x * x + y * y);
	}

	public float Normalize()
	{
		float length = Mathf.Sqrt(x * x + y * y);
		if (length < float.MinValue)
		{
			return 0.0f;
		}
		float invLength = 1.0f / length;
		x *= invLength;
		y *= invLength;
		
		return length;
	}

	public bool IsValid()
	{
		return b2Math.IsValid(x) && b2Math.IsValid(y);
	}
	

	//2015/9/16 16:05 --> by kingBook
	public string ToString2(float ptm_ratio=1){
		return "{x:"+x*ptm_ratio+",y:"+y*ptm_ratio+"}";
	}
	public override string ToString (){
		return "{x:"+x+",y:"+y+"}";
	}
	//2017/6/16 10:14 --> by kingBook
	public static implicit operator b2Vec2(Vector2 v){
		return new b2Vec2(v.x,v.y);
	}
	public static implicit operator b2Vec2(Vector3 v){
		return new b2Vec2(v.x,v.y);
	}
	public static implicit operator Vector2(b2Vec2 v){
		return new Vector2(v.x,v.y);
	}
	public static implicit operator Vector3(b2Vec2 v){
		return new Vector3(v.x,v.y,0);
	}


	public float x;
	public float y;
}

}