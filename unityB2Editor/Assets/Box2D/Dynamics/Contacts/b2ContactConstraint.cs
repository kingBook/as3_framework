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
using Box2D.Dynamics;
using System.Collections.Generic;

namespace Box2D.Dynamics.Contacts{


/**
* @private
*/
public class b2ContactConstraint
{
	public b2ContactConstraint(){
		points = new List<b2ContactConstraintPoint>(b2Settings.b2_maxManifoldPoints);
		for (int i = 0; i < b2Settings.b2_maxManifoldPoints; i++){
			points.Add(new b2ContactConstraintPoint());
		}
		
		
	}
	public List<b2ContactConstraintPoint> points;
	public b2Vec2 localPlaneNormal = new b2Vec2();
	public b2Vec2 localPoint = new b2Vec2();
	public b2Vec2 normal = new b2Vec2();
	public b2Mat22 normalMass = new b2Mat22();
	public b2Mat22 K = new b2Mat22();
	public b2Body bodyA;
	public b2Body bodyB;
	public int type;//b2Manifold::Type
	public float radius;
	public float friction;
	public float restitution;
	public int pointCount;
	public b2Manifold manifold;
}


}