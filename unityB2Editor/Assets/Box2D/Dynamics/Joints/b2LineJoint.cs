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
using Box2D.Common;
using Box2D.Common.Math;
using Box2D.Dynamics;

namespace Box2D.Dynamics.Joints{

// Linear constraint (point-to-line)
// d = p2 - p1 = x2 + r2 - x1 - r1
// C = dot(perp, d)
// Cdot = dot(d, cross(w1, perp)) + dot(perp, v2 + cross(w2, r2) - v1 - cross(w1, r1))
//      = -dot(perp, v1) - dot(cross(d + r1, perp), w1) + dot(perp, v2) + dot(cross(r2, perp), v2)
// J = [-perp, -cross(d + r1, perp), perp, cross(r2,perp)]
//
// K = J * invM * JT
//
// J = [-a -s1 a s2]
// a = perp
// s1 = cross(d + r1, a) = cross(p2 - x1, a)
// s2 = cross(r2, a) = cross(p2 - x2, a)


// Motor/Limit linear constraint
// C = dot(ax1, d)
// Cdot = = -dot(ax1, v1) - dot(cross(d + r1, ax1), w1) + dot(ax1, v2) + dot(cross(r2, ax1), v2)
// J = [-ax1 -cross(d+r1,ax1) ax1 cross(r2,ax1)]

// Block Solver
// We develop a block solver that includes the joint limit. This makes the limit stiff (inelastic) even
// when the mass has poor distribution (leading to large torques about the joint anchor points).
//
// The Jacobian has 3 rows:
// J = [-uT -s1 uT s2] // linear
//     [-vT -a1 vT a2] // limit
//
// u = perp
// v = axis
// s1 = cross(d + r1, u), s2 = cross(r2, u)
// a1 = cross(d + r1, v), a2 = cross(r2, v)

// M * (v2 - v1) = JT * df
// J * v2 = bias
//
// v2 = v1 + invM * JT * df
// J * (v1 + invM * JT * df) = bias
// K * df = bias - J * v1 = -Cdot
// K = J * invM * JT
// Cdot = J * v1 - bias
//
// Now solve for f2.
// df = f2 - f1
// K * (f2 - f1) = -Cdot
// f2 = invK * (-Cdot) + f1
//
// Clamp accumulated limit impulse.
// lower: f2(2) = max(f2(2), 0)
// upper: f2(2) = min(f2(2), 0)
//
// Solve for correct f2(1)
// K(1,1) * f2(1) = -Cdot(1) - K(1,2) * f2(2) + K(1,1:2) * f1
//                = -Cdot(1) - K(1,2) * f2(2) + K(1,1) * f1(1) + K(1,2) * f1(2)
// K(1,1) * f2(1) = -Cdot(1) - K(1,2) * (f2(2) - f1(2)) + K(1,1) * f1(1)
// f2(1) = invK(1,1) * (-Cdot(1) - K(1,2) * (f2(2) - f1(2))) + f1(1)
//
// Now compute impulse to be applied:
// df = f2 - f1

/**
 * A line joint. This joint provides one degree of freedom: translation
 * along an axis fixed in body1. You can use a joint limit to restrict
 * the range of motion and a joint motor to drive the motion or to
 * model joint friction.
 * @see b2LineJointDef
 */
public class b2LineJoint : b2Joint
{
	/** @inheritDoc */
	public override b2Vec2 GetAnchorA(){
		return m_bodyA.GetWorldPoint(m_localAnchor1);
	}
	/** @inheritDoc */
	public override b2Vec2 GetAnchorB(){
		return m_bodyB.GetWorldPoint(m_localAnchor2);
	}
	/** @inheritDoc */
	public override b2Vec2 GetReactionForce(float inv_dt)
	{
		//return inv_dt * (m_impulse.x * m_perp + (m_motorImpulse + m_impulse.y) * m_axis);
		return new b2Vec2(inv_dt * (m_impulse.x * m_perp.x + (m_motorImpulse + m_impulse.y) * m_axis.x),
						  inv_dt * (m_impulse.x * m_perp.y + (m_motorImpulse + m_impulse.y) * m_axis.y));
	}

	/** @inheritDoc */
	public override float GetReactionTorque(float inv_dt)
	{
		return inv_dt * m_impulse.y;
	}
	
	/**
	* Get the current joint translation, usually in meters.
	*/
	public float GetJointTranslation(){
		b2Body bA = m_bodyA;
		b2Body bB = m_bodyB;
		
		b2Mat22 tMat;
		
		b2Vec2 p1 = bA.GetWorldPoint(m_localAnchor1);
		b2Vec2 p2 = bB.GetWorldPoint(m_localAnchor2);
		//var d:b2Vec2 = b2Math.SubtractVV(p2, p1);
		float dX = p2.x - p1.x;
		float dY = p2.y - p1.y;
		//b2Vec2 axis = bA->GetWorldVector(m_localXAxis1);
		b2Vec2 axis = bA.GetWorldVector(m_localXAxis1);
		
		//float32 translation = b2Dot(d, axis);
		float translation = axis.x*dX + axis.y*dY;
		return translation;
	}
	
	/**
	* Get the current joint translation speed, usually in meters per second.
	*/
	public float GetJointSpeed(){
		b2Body bA = m_bodyA;
		b2Body bB = m_bodyB;
		
		b2Mat22 tMat;
		
		//b2Vec2 r1 = b2Mul(bA->m_xf.R, m_localAnchor1 - bA->GetLocalCenter());
		tMat = bA.m_xf.R;
		float r1X = m_localAnchor1.x - bA.m_sweep.localCenter.x;
		float r1Y = m_localAnchor1.y - bA.m_sweep.localCenter.y;
		float tX =  (tMat.col1.x * r1X + tMat.col2.x * r1Y);
		r1Y = (tMat.col1.y * r1X + tMat.col2.y * r1Y);
		r1X = tX;
		//b2Vec2 r2 = b2Mul(bB->m_xf.R, m_localAnchor2 - bB->GetLocalCenter());
		tMat = bB.m_xf.R;
		float r2X = m_localAnchor2.x - bB.m_sweep.localCenter.x;
		float r2Y = m_localAnchor2.y - bB.m_sweep.localCenter.y;
		tX =  (tMat.col1.x * r2X + tMat.col2.x * r2Y);
		r2Y = (tMat.col1.y * r2X + tMat.col2.y * r2Y);
		r2X = tX;
		
		//b2Vec2 p1 = bA->m_sweep.c + r1;
		float p1X = bA.m_sweep.c.x + r1X;
		float p1Y = bA.m_sweep.c.y + r1Y;
		//b2Vec2 p2 = bB->m_sweep.c + r2;
		float p2X = bB.m_sweep.c.x + r2X;
		float p2Y = bB.m_sweep.c.y + r2Y;
		//var d:b2Vec2 = b2Math.SubtractVV(p2, p1);
		float dX = p2X - p1X;
		float dY = p2Y - p1Y;
		//b2Vec2 axis = bA->GetWorldVector(m_localXAxis1);
		b2Vec2 axis = bA.GetWorldVector(m_localXAxis1);
		
		b2Vec2 v1 = bA.m_linearVelocity;
		b2Vec2 v2 = bB.m_linearVelocity;
		float w1 = bA.m_angularVelocity;
		float w2 = bB.m_angularVelocity;
		
		//var speed:Number = b2Math.b2Dot(d, b2Math.b2CrossFV(w1, ax1)) + b2Math.b2Dot(ax1, b2Math.SubtractVV( b2Math.SubtractVV( b2Math.AddVV( v2 , b2Math.b2CrossFV(w2, r2)) , v1) , b2Math.b2CrossFV(w1, r1)));
		//var b2D:Number = (dX*(-w1 * ax1Y) + dY*(w1 * ax1X));
		//var b2D2:Number = (ax1X * ((( v2.x + (-w2 * r2Y)) - v1.x) - (-w1 * r1Y)) + ax1Y * ((( v2.y + (w2 * r2X)) - v1.y) - (w1 * r1X)));
		float speed = (dX*(-w1 * axis.y) + dY*(w1 * axis.x)) + (axis.x * ((( v2.x + (-w2 * r2Y)) - v1.x) - (-w1 * r1Y)) + axis.y * ((( v2.y + (w2 * r2X)) - v1.y) - (w1 * r1X)));
		
		return speed;
	}
	
	/**
	* Is the joint limit enabled?
	*/
	public bool IsLimitEnabled()
	{
		return m_enableLimit;
	}
	/**
	* Enable/disable the joint limit.
	*/
	public void EnableLimit(bool flag)
	{
		m_bodyA.SetAwake(true);
		m_bodyB.SetAwake(true);
		m_enableLimit = flag;
	}
	/**
	* Get the lower joint limit, usually in meters.
	*/
	public float GetLowerLimit()
	{
		return m_lowerTranslation;
	}
	/**
	* Get the upper joint limit, usually in meters.
	*/
	public float GetUpperLimit()
	{
		return m_upperTranslation;
	}
	/**
	* Set the joint limits, usually in meters.
	*/
	public void SetLimits(float lower, float upper)
	{
		//b2Settings.b2Assert(lower <= upper);
		m_bodyA.SetAwake(true);
		m_bodyB.SetAwake(true);
		m_lowerTranslation = lower;
		m_upperTranslation = upper;
	}
	/**
	* Is the joint motor enabled?
	*/
	public bool IsMotorEnabled()
	{
		return m_enableMotor;
	}
	/**
	* Enable/disable the joint motor.
	*/
	public void EnableMotor(bool flag)
	{
		m_bodyA.SetAwake(true);
		m_bodyB.SetAwake(true);
		m_enableMotor = flag;
	}
	/**
	* Set the motor speed, usually in meters per second.
	*/
	public void SetMotorSpeed(float speed)
	{
		m_bodyA.SetAwake(true);
		m_bodyB.SetAwake(true);
		m_motorSpeed = speed;
	}
	/**
	* Get the motor speed, usually in meters per second.
	*/
	public float GetMotorSpeed()
	{
		return m_motorSpeed;
	}
	
	/**
	 * Set the maximum motor force, usually in N.
	 */
	public void SetMaxMotorForce(float force)
	{
		m_bodyA.SetAwake(true);
		m_bodyB.SetAwake(true);
		m_maxMotorForce = force;
	}
	
	/**
	 * Get the maximum motor force, usually in N.
	 */
	public float GetMaxMotorForce()
	{
		return m_maxMotorForce;
	}
	
	/**
	* Get the current motor force, usually in N.
	*/
	public float GetMotorForce() 
	{
		return m_motorImpulse;
	}
	

	//--------------- Internals Below -------------------

	/** @private */
	public b2LineJoint(b2LineJointDef def):base(def){
		
		b2Mat22 tMat;
		float tX;
		float tY;
		
		m_localAnchor1.SetV(def.localAnchorA);
		m_localAnchor2.SetV(def.localAnchorB);
		m_localXAxis1.SetV(def.localAxisA);
		
		//m_localYAxis1 = b2Cross(1.0f, m_localXAxis1);
		m_localYAxis1.x = -m_localXAxis1.y;
		m_localYAxis1.y = m_localXAxis1.x;
		
		m_impulse.SetZero();
		m_motorMass = 0.0f;
		m_motorImpulse = 0.0f;
		
		m_lowerTranslation = def.lowerTranslation;
		m_upperTranslation = def.upperTranslation;
		m_maxMotorForce = def.maxMotorForce;
		m_motorSpeed = def.motorSpeed;
		m_enableLimit = def.enableLimit;
		m_enableMotor = def.enableMotor;
		m_limitState = e_inactiveLimit;
		
		m_axis.SetZero();
		m_perp.SetZero();
	}

	public override void InitVelocityConstraints(b2TimeStep step){
		b2Body bA = m_bodyA;
		b2Body bB = m_bodyB;
		
		b2Mat22 tMat;
		float tX;
		
		m_localCenterA.SetV(bA.GetLocalCenter());
		m_localCenterB.SetV(bB.GetLocalCenter());
		
		b2Transform xf1 = bA.GetTransform();
		b2Transform xf2 = bB.GetTransform();
		
		// Compute the effective masses.
		//b2Vec2 r1 = b2Mul(bA->m_xf.R, m_localAnchor1 - bA->GetLocalCenter());
		tMat = bA.m_xf.R;
		float r1X = m_localAnchor1.x - m_localCenterA.x;
		float r1Y = m_localAnchor1.y - m_localCenterA.y;
		tX =  (tMat.col1.x * r1X + tMat.col2.x * r1Y);
		r1Y = (tMat.col1.y * r1X + tMat.col2.y * r1Y);
		r1X = tX;
		//b2Vec2 r2 = b2Mul(bB->m_xf.R, m_localAnchor2 - bB->GetLocalCenter());
		tMat = bB.m_xf.R;
		float r2X = m_localAnchor2.x - m_localCenterB.x;
		float r2Y = m_localAnchor2.y - m_localCenterB.y;
		tX =  (tMat.col1.x * r2X + tMat.col2.x * r2Y);
		r2Y = (tMat.col1.y * r2X + tMat.col2.y * r2Y);
		r2X = tX;
		
		//b2Vec2 d = bB->m_sweep.c + r2 - bA->m_sweep.c - r1;
		float dX = bB.m_sweep.c.x + r2X - bA.m_sweep.c.x - r1X;
		float dY = bB.m_sweep.c.y + r2Y - bA.m_sweep.c.y - r1Y;
		
		m_invMassA = bA.m_invMass;
		m_invMassB = bB.m_invMass;
		m_invIA = bA.m_invI;
		m_invIB = bB.m_invI;
		
		// Compute motor Jacobian and effective mass.
		{
			m_axis.SetV(b2Math.MulMV(xf1.R, m_localXAxis1));
			//m_a1 = b2Math.b2Cross(d + r1, m_axis);
			m_a1 = (dX + r1X) * m_axis.y - (dY + r1Y) * m_axis.x;
			//m_a2 = b2Math.b2Cross(r2, m_axis);
			m_a2 = r2X * m_axis.y - r2Y * m_axis.x;
			
			m_motorMass = m_invMassA + m_invMassB + m_invIA * m_a1 * m_a1 + m_invIB * m_a2 * m_a2; 
			m_motorMass = m_motorMass > float.MinValue?1.0f / m_motorMass:0.0f;
		}
		
		// Prismatic constraint.
		{
			m_perp.SetV(b2Math.MulMV(xf1.R, m_localYAxis1));
			//m_s1 = b2Math.b2Cross(d + r1, m_perp);
			m_s1 = (dX + r1X) * m_perp.y - (dY + r1Y) * m_perp.x;
			//m_s2 = b2Math.b2Cross(r2, m_perp);
			m_s2 = r2X * m_perp.y - r2Y * m_perp.x;
			
			float m1 = m_invMassA;
			float m2 = m_invMassB;
			float i1 = m_invIA;
			float i2 = m_invIB;
			
			m_K.col1.x = m1 + m2 + i1 * m_s1 * m_s1 + i2 * m_s2 * m_s2;
 	  	  	m_K.col1.y = i1 * m_s1 * m_a1 + i2 * m_s2 * m_a2;
			m_K.col2.x = m_K.col1.y;
 	  	  	m_K.col2.y = m1 + m2 + i1 * m_a1 * m_a1 + i2 * m_a2 * m_a2; 
		}
		
		// Compute motor and limit terms
		if (m_enableLimit)
		{
			//float32 jointTranslation = b2Dot(m_axis, d); 
			float jointTransition = m_axis.x * dX + m_axis.y * dY;
			if (b2Math.Abs(m_upperTranslation - m_lowerTranslation) < 2.0f * b2Settings.b2_linearSlop)
			{
				m_limitState = e_equalLimits;
			}
			else if (jointTransition <= m_lowerTranslation)
			{
				if (m_limitState != e_atLowerLimit)
				{
					m_limitState = e_atLowerLimit;
					m_impulse.y = 0.0f;
				}
			}
			else if (jointTransition >= m_upperTranslation)
			{
				if (m_limitState != e_atUpperLimit)
				{
					m_limitState = e_atUpperLimit;
					m_impulse.y = 0.0f;
				}
			}
			else
			{
				m_limitState = e_inactiveLimit;
				m_impulse.y = 0.0f;
			}
		}
		else
		{
			m_limitState = e_inactiveLimit;
		}
		
		if (m_enableMotor == false)
		{
			m_motorImpulse = 0.0f;
		}
		
		if (step.warmStarting)
		{
			// Account for variable time step.
			m_impulse.x *= step.dtRatio;
			m_impulse.y *= step.dtRatio;
			m_motorImpulse *= step.dtRatio; 
			
			//b2Vec2 P = m_impulse.x * m_perp + (m_motorImpulse + m_impulse.z) * m_axis;
			float PX = m_impulse.x * m_perp.x + (m_motorImpulse + m_impulse.y) * m_axis.x;
			float PY = m_impulse.x * m_perp.y + (m_motorImpulse + m_impulse.y) * m_axis.y;
			float L1 = m_impulse.x * m_s1     + (m_motorImpulse + m_impulse.y) * m_a1;
			float L2 = m_impulse.x * m_s2     + (m_motorImpulse + m_impulse.y) * m_a2; 

			//bA->m_linearVelocity -= m_invMassA * P;
			bA.m_linearVelocity.x -= m_invMassA * PX;
			bA.m_linearVelocity.y -= m_invMassA * PY;
			//bA->m_angularVelocity -= m_invIA * L1;
			bA.m_angularVelocity -= m_invIA * L1;
			
			//bB->m_linearVelocity += m_invMassB * P;
			bB.m_linearVelocity.x += m_invMassB * PX;
			bB.m_linearVelocity.y += m_invMassB * PY;
			//bB->m_angularVelocity += m_invIB * L2;
			bB.m_angularVelocity += m_invIB * L2;
		}
		else
		{
			m_impulse.SetZero();
			m_motorImpulse = 0.0f;
		}
	}
	
	public override void SolveVelocityConstraints(b2TimeStep step){
		b2Body bA = m_bodyA;
		b2Body bB = m_bodyB;
		
		b2Vec2 v1 = bA.m_linearVelocity;
		float w1 = bA.m_angularVelocity;
		b2Vec2 v2 = bB.m_linearVelocity;
		float w2 = bB.m_angularVelocity;
		
		float PX;
		float PY;
		float L1;
		float L2;
		
		// Solve linear motor constraint
		if (m_enableMotor && m_limitState != e_equalLimits)
		{
			//float32 Cdot = b2Dot(m_axis, v2 - v1) + m_a2 * w2 - m_a1 * w1; 
			float Cdot = m_axis.x * (v2.x -v1.x) + m_axis.y * (v2.y - v1.y) + m_a2 * w2 - m_a1 * w1;
			float impulse = m_motorMass * (m_motorSpeed - Cdot);
			float oldImpulse = m_motorImpulse;
			float maxImpulse = step.dt * m_maxMotorForce;
			m_motorImpulse = b2Math.Clamp(m_motorImpulse + impulse, -maxImpulse, maxImpulse);
			impulse = m_motorImpulse - oldImpulse;
			
			PX = impulse * m_axis.x;
			PY = impulse * m_axis.y;
			L1 = impulse * m_a1;
			L2 = impulse * m_a2;
			
			v1.x -= m_invMassA * PX;
			v1.y -= m_invMassA * PY;
			w1 -= m_invIA * L1;
			
			v2.x += m_invMassB * PX;
			v2.y += m_invMassB * PY;
			w2 += m_invIB * L2;
		}
		
		//Cdot1 = b2Dot(m_perp, v2 - v1) + m_s2 * w2 - m_s1 * w1; 
		float Cdot1 = m_perp.x * (v2.x - v1.x) + m_perp.y * (v2.y - v1.y) + m_s2 * w2 - m_s1 * w1; 
		
		if (m_enableLimit && m_limitState != e_inactiveLimit)
		{
			// Solve prismatic and limit constraint in block form
			//Cdot2 = b2Dot(m_axis, v2 - v1) + m_a2 * w2 - m_a1 * w1; 
			float Cdot2 = m_axis.x * (v2.x - v1.x) + m_axis.y * (v2.y - v1.y) + m_a2 * w2 - m_a1 * w1; 
			
			b2Vec2 f1 = m_impulse.Copy();
			b2Vec2 df = m_K.Solve(new b2Vec2(), -Cdot1, -Cdot2);
			
			m_impulse.Add(df);
			
			if (m_limitState == e_atLowerLimit)
			{
				m_impulse.y = b2Math.Max(m_impulse.y, 0.0f);
			}
			else if (m_limitState == e_atUpperLimit)
			{
				m_impulse.y = b2Math.Min(m_impulse.y, 0.0f);
			}
			
			// f2(1) = invK(1,1) * (-Cdot(1) - K(1,3) * (f2(2) - f1(2))) + f1(1) 
			float b = -Cdot1 - (m_impulse.y - f1.y) * m_K.col2.x;
			float f2r;
			if (m_K.col1.x != 0.0f)
			{
				f2r = b / m_K.col1.x + f1.x;
			}else {
				f2r = f1.x;
			}
			m_impulse.x = f2r;
			
			df.x = m_impulse.x - f1.x;
			df.y = m_impulse.y - f1.y;
			
			PX = df.x * m_perp.x + df.y * m_axis.x;
			PY = df.x * m_perp.y + df.y * m_axis.y;
			L1 = df.x * m_s1 + df.y * m_a1;
			L2 = df.x * m_s2 + df.y * m_a2;
			
			v1.x -= m_invMassA * PX;
			v1.y -= m_invMassA * PY;
			w1 -= m_invIA * L1;
			
			v2.x += m_invMassB * PX;
			v2.y += m_invMassB * PY;
			w2 += m_invIB * L2;
		}
		else
		{
			// Limit is inactive, just solve the prismatic constraint in block form. 
			float df2;
			if (m_K.col1.x != 0.0f)
			{
				df2 = ( -Cdot1) / m_K.col1.x;
			}else {
				df2 = 0.0f;
			}
			m_impulse.x += df2;
			
			PX = df2 * m_perp.x;
			PY = df2 * m_perp.y;
			L1 = df2 * m_s1;
			L2 = df2 * m_s2;
			
			v1.x -= m_invMassA * PX;
			v1.y -= m_invMassA * PY;
			w1 -= m_invIA * L1;
			
			v2.x += m_invMassB * PX;
			v2.y += m_invMassB * PY;
			w2 += m_invIB * L2;
		}
		
		bA.m_linearVelocity.SetV(v1);
		bA.m_angularVelocity = w1;
		bB.m_linearVelocity.SetV(v2);
		bB.m_angularVelocity = w2;
	}
	
	public override bool SolvePositionConstraints(float baumgarte )
	{
		//B2_NOT_USED(baumgarte);
		
		
		float limitC;
		float oldLimitImpulse;
		
		b2Body bA = m_bodyA;
		b2Body bB = m_bodyB;
		
		b2Vec2 c1 = bA.m_sweep.c;
		float a1 = bA.m_sweep.a;
		
		b2Vec2 c2 = bB.m_sweep.c;
		float a2 = bB.m_sweep.a;
		
		b2Mat22 tMat;
		float tX;
		
		float m1;
		float m2;
		float i1;
		float i2;
		
		// Solve linear limit constraint
		float linearError = 0.0f;
		float angularError = 0.0f;
		bool active = false;
		float C2 = 0.0f;
		
		b2Mat22 R1 = b2Mat22.FromAngle(a1);
		b2Mat22 R2 = b2Mat22.FromAngle(a2);
		
		//b2Vec2 r1 = b2Mul(R1, m_localAnchor1 - m_localCenter1);
		tMat = R1;
		float r1X = m_localAnchor1.x - m_localCenterA.x;
		float r1Y = m_localAnchor1.y - m_localCenterA.y;
		tX =  (tMat.col1.x * r1X + tMat.col2.x * r1Y);
		r1Y = (tMat.col1.y * r1X + tMat.col2.y * r1Y);
		r1X = tX;
		//b2Vec2 r2 = b2Mul(R2, m_localAnchor2 - m_localCenter2);
		tMat = R2;
		float r2X = m_localAnchor2.x - m_localCenterB.x;
		float r2Y = m_localAnchor2.y - m_localCenterB.y;
		tX =  (tMat.col1.x * r2X + tMat.col2.x * r2Y);
		r2Y = (tMat.col1.y * r2X + tMat.col2.y * r2Y);
		r2X = tX;
		
		float dX = c2.x + r2X - c1.x - r1X;
		float dY = c2.y + r2Y - c1.y - r1Y;
		
		if (m_enableLimit)
		{
			m_axis = b2Math.MulMV(R1, m_localXAxis1);
			
			//m_a1 = b2Math.b2Cross(d + r1, m_axis);
			m_a1 = (dX + r1X) * m_axis.y - (dY + r1Y) * m_axis.x;
			//m_a2 = b2Math.b2Cross(r2, m_axis);
			m_a2 = r2X * m_axis.y - r2Y * m_axis.x;
			
			float translation = m_axis.x * dX + m_axis.y * dY;
			if (b2Math.Abs(m_upperTranslation - m_lowerTranslation) < 2.0f * b2Settings.b2_linearSlop)
			{
				// Prevent large angular corrections.
				C2 = b2Math.Clamp(translation, -b2Settings.b2_maxLinearCorrection, b2Settings.b2_maxLinearCorrection);
				linearError = b2Math.Abs(translation);
				active = true;
			}
			else if (translation <= m_lowerTranslation)
			{
				// Prevent large angular corrections and allow some slop.
				C2 = b2Math.Clamp(translation - m_lowerTranslation + b2Settings.b2_linearSlop, -b2Settings.b2_maxLinearCorrection, 0.0f);
				linearError = m_lowerTranslation - translation;
				active = true;
			}
			else if (translation >= m_upperTranslation)
			{
				// Prevent large angular corrections and allow some slop.
				C2 = b2Math.Clamp(translation - m_upperTranslation + b2Settings.b2_linearSlop, 0.0f, b2Settings.b2_maxLinearCorrection);
				linearError = translation - m_upperTranslation;
				active = true;
			}
		}
		
		m_perp = b2Math.MulMV(R1, m_localYAxis1);
		
		//m_s1 = b2Cross(d + r1, m_perp); 
		m_s1 = (dX + r1X) * m_perp.y - (dY + r1Y) * m_perp.x;
		//m_s2 = b2Cross(r2, m_perp); 
		m_s2 = r2X * m_perp.y - r2Y * m_perp.x;
		
		b2Vec2 impulse = new b2Vec2();
		float C1 = m_perp.x * dX + m_perp.y * dY;
		
		linearError = b2Math.Max(linearError, b2Math.Abs(C1));
		angularError = 0.0f;
		
		if (active)
		{
			m1 = m_invMassA;
			m2 = m_invMassB;
			i1 = m_invIA;
			i2 = m_invIB;
			
			m_K.col1.x = m1 + m2 + i1 * m_s1 * m_s1 + i2 * m_s2 * m_s2;
 	  	  	m_K.col1.y = i1 * m_s1 * m_a1 + i2 * m_s2 * m_a2;
			m_K.col2.x = m_K.col1.y;
 	  	  	m_K.col2.y = m1 + m2 + i1 * m_a1 * m_a1 + i2 * m_a2 * m_a2;
			
			m_K.Solve(impulse, -C1, -C2);
		}
		else
		{
			m1 = m_invMassA;
			m2 = m_invMassB;
			i1 = m_invIA;
			i2 = m_invIB;
			
			float k11  = m1 + m2 + i1 * m_s1 * m_s1 + i2 * m_s2 * m_s2;
			
			float impulse1;
			if (k11 != 0.0f)
			{
				impulse1 = ( -C1) / k11;
			}else {
				impulse1 = 0.0f;
			}
			impulse.x = impulse1;
			impulse.y = 0.0f;
		}
		
		float PX = impulse.x * m_perp.x + impulse.y * m_axis.x;
		float PY = impulse.x * m_perp.y + impulse.y * m_axis.y;
		float L1 = impulse.x * m_s1 + impulse.y * m_a1;
		float L2 = impulse.x * m_s2 + impulse.y * m_a2;
		
		c1.x -= m_invMassA * PX;
		c1.y -= m_invMassA * PY;
		a1 -= m_invIA * L1;
		
		c2.x += m_invMassB * PX;
		c2.y += m_invMassB * PY;
		a2 += m_invIB * L2;
		
		// TODO_ERIN remove need for this
		//bA.m_sweep.c = c1;	//Already done by reference
		bA.m_sweep.a = a1;
		//bB.m_sweep.c = c2;	//Already done by reference
		bB.m_sweep.a = a2;
		bA.SynchronizeTransform();
		bB.SynchronizeTransform(); 
		
		return linearError <= b2Settings.b2_linearSlop && angularError <= b2Settings.b2_angularSlop;
		
	}

	public b2Vec2 m_localAnchor1 = new b2Vec2();
	public b2Vec2 m_localAnchor2 = new b2Vec2();
	public b2Vec2 m_localXAxis1 = new b2Vec2();
	private b2Vec2 m_localYAxis1 = new b2Vec2();

	private b2Vec2 m_axis = new b2Vec2();
	private b2Vec2 m_perp = new b2Vec2();
	private float m_s1;
	private float m_s2;
	private float m_a1;
	private float m_a2;
	
	private b2Mat22 m_K = new b2Mat22();
	private b2Vec2 m_impulse = new b2Vec2();

	private float m_motorMass;			// effective mass for motor/limit translational constraint.
	private float m_motorImpulse;

	private float m_lowerTranslation;
	private float m_upperTranslation;
	private float m_maxMotorForce;
	private float m_motorSpeed;
	
	private bool m_enableLimit;
	private bool m_enableMotor;
	private int m_limitState;
}

}
