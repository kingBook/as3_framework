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

namespace Box2D.Dynamics.Joints{
	

/**
* Revolute joint definition. This requires defining an
* anchor point where the bodies are joined. The definition
* uses local anchor points so that the initial configuration
* can violate the constraint slightly. You also need to
* specify the initial relative angle for joint limits. This
* helps when saving and loading a game.
* The local anchor points are measured from the body's origin
* rather than the center of mass because:
* 1. you might not know where the center of mass will be.
* 2. if you add/remove shapes from a body and recompute the mass,
* the joints will be broken.
* @see b2RevoluteJoint
*/

public class b2RevoluteJointDef : b2JointDef
{
	public b2RevoluteJointDef()
	{
		type = b2Joint.e_revoluteJoint;
		localAnchorA.Set(0.0f, 0.0f);
		localAnchorB.Set(0.0f, 0.0f);
		referenceAngle = 0.0f;
		lowerAngle = 0.0f;
		upperAngle = 0.0f;
		maxMotorTorque = 0.0f;
		motorSpeed = 0.0f;
		enableLimit = false;
		enableMotor = false;
	}

	/**
	* Initialize the bodies, anchors, and reference angle using the world
	* anchor.
	*/
	public void Initialize(b2Body bA, b2Body bB, b2Vec2 anchor){
		bodyA = bA;
		bodyB = bB;
		localAnchorA = bodyA.GetLocalPoint(anchor);
		localAnchorB = bodyB.GetLocalPoint(anchor);
		referenceAngle = bodyB.GetAngle() - bodyA.GetAngle();
	}

	/**
	* The local anchor point relative to bodyA's origin.
	*/
	public b2Vec2 localAnchorA = new b2Vec2();

	/**
	* The local anchor point relative to bodyB's origin.
	*/
	public b2Vec2 localAnchorB = new b2Vec2();

	/**
	* The bodyB angle minus bodyA angle in the reference state (radians).
	*/
	public float referenceAngle;

	/**
	* A flag to enable joint limits.
	*/
	public bool enableLimit;

	/**
	* The lower angle for the joint limit (radians).
	*/
	public float lowerAngle;

	/**
	* The upper angle for the joint limit (radians).
	*/
	public float upperAngle;

	/**
	* A flag to enable the joint motor.
	*/
	public bool enableMotor;

	/**
	* The desired motor speed. Usually in radians per second.
	*/
	public float motorSpeed;

	/**
	* The maximum motor torque used to achieve the desired motor speed.
	* Usually in N-m.
	*/
	public float maxMotorTorque;
	
}

}