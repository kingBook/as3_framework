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


namespace Box2D.Dynamics.Joints{



/**
* @private
*/
public class b2Jacobian
{
	public b2Vec2 linearA = new b2Vec2();
	public float angularA;
	public b2Vec2 linearB = new b2Vec2();
	public float angularB;

	public void SetZero(){
		linearA.SetZero(); angularA = 0.0f;
		linearB.SetZero(); angularB = 0.0f;
	}
	public void Set(b2Vec2 x1, float a1, b2Vec2 x2, float a2){
		linearA.SetV(x1); angularA = a1;
		linearB.SetV(x2); angularB = a2;
	}
	public float Compute(b2Vec2 x1, float a1, b2Vec2 x2, float a2){
		
		//return b2Math.b2Dot(linearA, x1) + angularA * a1 + b2Math.b2Dot(linearV, x2) + angularV * a2;
		return (linearA.x*x1.x + linearA.y*x1.y) + angularA * a1 + (linearB.x*x2.x + linearB.y*x2.y) + angularB * a2;
	}
}


}