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
using Box2D.Dynamics;
using Box2D.Common;
using UnityEngine;

namespace Box2D.Dynamics.Joints{



/**
* Pulley joint definition. This requires two ground anchors,
* two dynamic body anchor points, max lengths for each side,
* and a pulley ratio.
* @see b2PulleyJoint
*/

public class b2PulleyJointDef : b2JointDef
{
	public b2PulleyJointDef()
	{
		type = b2Joint.e_pulleyJoint;
		groundAnchorA.Set(-1.0f, 1.0f);
		groundAnchorB.Set(1.0f, 1.0f);
		localAnchorA.Set(-1.0f, 0.0f);
		localAnchorB.Set(1.0f, 0.0f);
		lengthA = 0.0f;
		maxLengthA = 0.0f;
		lengthB = 0.0f;
		maxLengthB = 0.0f;
		ratio = 1.0f;
		collideConnected = true;
	}
	
	public void Initialize(b2Body bA, b2Body bB,
				b2Vec2 gaA, b2Vec2 gaB,
				b2Vec2 anchorA, b2Vec2 anchorB,
				float r)
	{
		bodyA = bA;
		bodyB = bB;
		groundAnchorA.SetV( gaA );
		groundAnchorB.SetV( gaB );
		localAnchorA = bodyA.GetLocalPoint(anchorA);
		localAnchorB = bodyB.GetLocalPoint(anchorB);
		//b2Vec2 d1 = anchorA - gaA;
		float d1X = anchorA.x - gaA.x;
		float d1Y = anchorA.y - gaA.y;
		//length1 = d1.Length();
		lengthA = Mathf.Sqrt(d1X*d1X + d1Y*d1Y);
		
		//b2Vec2 d2 = anchor2 - ga2;
		float d2X = anchorB.x - gaB.x;
		float d2Y = anchorB.y - gaB.y;
		//length2 = d2.Length();
		lengthB = Mathf.Sqrt(d2X*d2X + d2Y*d2Y);
		
		ratio = r;
		//b2Settings.b2Assert(ratio > Number.MIN_VALUE);
		float C = lengthA + ratio * lengthB;
		maxLengthA = C - ratio * b2PulleyJoint.b2_minPulleyLength;
		maxLengthB = (C - b2PulleyJoint.b2_minPulleyLength) / ratio;
	}

	/**
	* The first ground anchor in world coordinates. This point never moves.
	*/
	public b2Vec2 groundAnchorA = new b2Vec2();
	
	/**
	* The second ground anchor in world coordinates. This point never moves.
	*/
	public b2Vec2 groundAnchorB = new b2Vec2();
	
	/**
	* The local anchor point relative to bodyA's origin.
	*/
	public b2Vec2 localAnchorA = new b2Vec2();
	
	/**
	* The local anchor point relative to bodyB's origin.
	*/
	public b2Vec2 localAnchorB = new b2Vec2();
	
	/**
	* The a reference length for the segment attached to bodyA.
	*/
	public float lengthA;
	
	/**
	* The maximum length of the segment attached to bodyA.
	*/
	public float maxLengthA;
	
	/**
	* The a reference length for the segment attached to bodyB.
	*/
	public float lengthB;
	
	/**
	* The maximum length of the segment attached to bodyB.
	*/
	public float maxLengthB;
	
	/**
	* The pulley ratio, used to simulate a block-and-tackle.
	*/
	public float ratio;
	
}

}