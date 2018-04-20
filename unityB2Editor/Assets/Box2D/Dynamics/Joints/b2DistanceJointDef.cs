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
using Box2D.Dynamics.Joints;
using Box2D.Dynamics;
using Box2D.Common;
using UnityEngine;

namespace Box2D.Dynamics.Joints{


/**
* Distance joint definition. This requires defining an
* anchor point on both bodies and the non-zero length of the
* distance joint. The definition uses local anchor points
* so that the initial configuration can violate the constraint
* slightly. This helps when saving and loading a game.
* @warning Do not use a zero or short length.
* @see b2DistanceJoint
*/
public class b2DistanceJointDef : b2JointDef
{
	public b2DistanceJointDef()
	{
		type = b2Joint.e_distanceJoint;
		//localAnchor1.Set(0.0, 0.0);
		//localAnchor2.Set(0.0, 0.0);
		length = 1.0f;
		frequencyHz = 0.0f;
		dampingRatio = 0.0f;
	}
	
	/**
	* Initialize the bodies, anchors, and length using the world
	* anchors.
	*/
	public void Initialize(b2Body bA, b2Body bB,
                           b2Vec2 anchorA, b2Vec2 anchorB)
	{
		bodyA = bA;
		bodyB = bB;
		localAnchorA.SetV( bodyA.GetLocalPoint(anchorA));
		localAnchorB.SetV( bodyB.GetLocalPoint(anchorB));
		float dX = anchorB.x - anchorA.x;
		float dY = anchorB.y - anchorA.y;
		length = Mathf.Sqrt(dX*dX + dY*dY);
		frequencyHz = 0.0f;
		dampingRatio = 0.0f;
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
	* The natural length between the anchor points.
	*/
	public float length;

	/**
	* The mass-spring-damper frequency in Hertz.
	*/
	public float frequencyHz;

	/**
	* The damping ratio. 0 = no damping, 1 = critical damping.
	*/
	public float dampingRatio;
}

}