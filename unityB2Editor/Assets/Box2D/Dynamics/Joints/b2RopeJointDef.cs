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

//Ported to AS3 by Allan Bishop http://allanbishop.com

using Box2D.Common.Math;
using Box2D.Dynamics.Joints;
using Box2D.Dynamics;
using Box2D.Common;
using UnityEngine;

namespace Box2D.Dynamics.Joints{


/// Rope joint definition. This requires two body anchor points and
/// a maximum lengths.
/// Note: by default the connected objects will not collide.
/// see collideConnected in b2JointDef.

public class b2RopeJointDef : b2JointDef
{
	
	public b2RopeJointDef()
	{
		type = b2Joint.e_ropeJoint;
		localAnchorA.Set(-1.0f, 0.0f);
		localAnchorB.Set(1.0f, 0.0f);
		maxLength = 0.0f;
	}
	
	/**
	* Initialize the bodies, anchors, and length using the world
	* anchors.
	*/
	public void Initialize(b2Body bA, b2Body bB,b2Vec2 anchorA, b2Vec2 anchorB,float maxLength)
	{
		bodyA = bA;
		bodyB = bB;
		localAnchorA.SetV( bodyA.GetLocalPoint(anchorA));
		localAnchorB.SetV( bodyB.GetLocalPoint(anchorB));
		localAnchorA.x=(float)System.Math.Round(localAnchorA.x,2);
		localAnchorA.y=(float)System.Math.Round(localAnchorA.y,2);
		localAnchorB.x=(float)System.Math.Round(localAnchorB.x,2);
		localAnchorB.y=(float)System.Math.Round(localAnchorB.y,2);
		float dX = anchorB.x - anchorA.x;
		float dY = anchorB.y - anchorA.y;
		length = Mathf.Sqrt(dX*dX + dY*dY);
		this.maxLength = maxLength;
	}

	/**
	* The local anchor point relative to body1's origin.
	*/
	public b2Vec2 localAnchorA = new b2Vec2();

	/**
	* The local anchor point relative to body2's origin.
	*/
	public b2Vec2 localAnchorB = new b2Vec2();

	/**
	* The max length between the anchor points.
	*/
	public float maxLength;
	
	private float length;


}

}