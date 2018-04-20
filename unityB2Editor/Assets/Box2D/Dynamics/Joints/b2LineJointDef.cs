﻿/*
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
 * Line joint definition. This requires defining a line of
 * motion using an axis and an anchor point. The definition uses local
 * anchor points and a local axis so that the initial configuration
 * can violate the constraint slightly. The joint translation is zero
 * when the local anchor points coincide in world space. Using local
 * anchors and a local axis helps when saving and loading a game.
 * @see b2LineJoint
 */
public class b2LineJointDef : b2JointDef
{
	public b2LineJointDef()
	{
		type = b2Joint.e_lineJoint;
		//localAnchor1.SetZero();
		//localAnchor2.SetZero();
		localAxisA.Set(1.0f, 0.0f);
		enableLimit = false;
		lowerTranslation = 0.0f;
		upperTranslation = 0.0f;
		enableMotor = false;
		maxMotorForce = 0.0f;
		motorSpeed = 0.0f;
	}
	
	public void Initialize(b2Body bA, b2Body bB, b2Vec2 anchor, b2Vec2 axis)
	{
		bodyA = bA;
		bodyB = bB;
		localAnchorA = bodyA.GetLocalPoint(anchor);
		localAnchorB = bodyB.GetLocalPoint(anchor);
		localAxisA = bodyA.GetLocalVector(axis);
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
	* The local translation axis in bodyA.
	*/
	public b2Vec2 localAxisA = new b2Vec2();

	/**
	* Enable/disable the joint limit.
	*/
	public bool enableLimit;

	/**
	* The lower translation limit, usually in meters.
	*/
	public float lowerTranslation;

	/**
	* The upper translation limit, usually in meters.
	*/
	public float upperTranslation;

	/**
	* Enable/disable the joint motor.
	*/
	public bool enableMotor;

	/**
	* The maximum motor torque, usually in N-m.
	*/
	public float maxMotorForce;

	/**
	* The desired motor speed in radians per second.
	*/
	public float motorSpeed;

	
}
	
}