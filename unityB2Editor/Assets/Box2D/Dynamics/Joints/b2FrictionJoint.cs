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
using Box2D.Common;
using Box2D.Dynamics;


namespace Box2D.Dynamics.Joints{

// Point-to-point constraint
// Cdot = v2 - v1
//      = v2 + cross(w2, r2) - v1 - cross(w1, r1)
// J = [-I -r1_skew I r2_skew ]
// Identity used:
// w k % (rx i + ry j) = w * (-ry i + rx j)

// Angle constraint
// Cdot = w2 - w1
// J = [0 0 -1 0 0 1]
// K = invI1 + invI2

/**
 * Friction joint. This is used for top-down friction.
 * It provides 2D translational friction and angular friction.
 * @see b2FrictionJointDef
 */
public class b2FrictionJoint : b2Joint
{
	/** @inheritDoc */
	public override b2Vec2 GetAnchorA(){
		return m_bodyA.GetWorldPoint(m_localAnchorA);
	}
	/** @inheritDoc */
	public override b2Vec2 GetAnchorB(){
		return m_bodyB.GetWorldPoint(m_localAnchorB);
	}
	
	/** @inheritDoc */
	public override b2Vec2 GetReactionForce(float inv_dt)
	{
		return new b2Vec2(inv_dt * m_linearImpulse.x, inv_dt * m_linearImpulse.y);
	}

	/** @inheritDoc */
	public override float GetReactionTorque(float inv_dt)
	{
		//B2_NOT_USED(inv_dt);
		return inv_dt * m_angularImpulse;
	}
	
	public void SetMaxForce(float force)
	{
		m_maxForce = force;
	}
	
	public float GetMaxForce()
	{
		return m_maxForce;
	}
	
	public void SetMaxTorque(float torque)
	{
		m_maxTorque = torque;
	}
	
	public float GetMaxTorque()
	{
		return m_maxTorque;
	}
	
	//--------------- Internals Below -------------------

	/** @private */
	public b2FrictionJoint(b2FrictionJointDef def):base(def){
		
		m_localAnchorA.SetV(def.localAnchorA);
		m_localAnchorB.SetV(def.localAnchorB);
		
		m_linearMass.SetZero();
		m_angularMass = 0.0f;
		
		m_linearImpulse.SetZero();
		m_angularImpulse = 0.0f;
		
		m_maxForce = def.maxForce;
		m_maxTorque = def.maxTorque;
	}

	public override void InitVelocityConstraints(b2TimeStep step) {
		b2Mat22 tMat;
		float tX;
		
		b2Body bA = m_bodyA;
		b2Body bB= m_bodyB;

		// Compute the effective mass matrix.
		//b2Vec2 rA = b2Mul(bA->m_xf.R, m_localAnchorA - bA->GetLocalCenter());
		tMat = bA.m_xf.R;
		float rAX = m_localAnchorA.x - bA.m_sweep.localCenter.x;
		float rAY = m_localAnchorA.y - bA.m_sweep.localCenter.y;
		tX =  (tMat.col1.x * rAX + tMat.col2.x * rAY);
		rAY = (tMat.col1.y * rAX + tMat.col2.y * rAY);
		rAX = tX;
		//b2Vec2 rB = b2Mul(bB->m_xf.R, m_localAnchorB - bB->GetLocalCenter());
		tMat = bB.m_xf.R;
		float rBX = m_localAnchorB.x - bB.m_sweep.localCenter.x;
		float rBY = m_localAnchorB.y - bB.m_sweep.localCenter.y;
		tX =  (tMat.col1.x * rBX + tMat.col2.x * rBY);
		rBY = (tMat.col1.y * rBX + tMat.col2.y * rBY);
		rBX = tX;

		// J = [-I -r1_skew I r2_skew]
		//     [ 0       -1 0       1]
		// r_skew = [-ry; rx]

		// Matlab
		// K = [ mA+r1y^2*iA+mB+r2y^2*iB,  -r1y*iA*r1x-r2y*iB*r2x,          -r1y*iA-r2y*iB]
		//     [  -r1y*iA*r1x-r2y*iB*r2x, mA+r1x^2*iA+mB+r2x^2*iB,           r1x*iA+r2x*iB]
		//     [          -r1y*iA-r2y*iB,           r1x*iA+r2x*iB,                   iA+iB]

		float mA = bA.m_invMass;
		float mB = bB.m_invMass;
		float iA = bA.m_invI;
		float iB = bB.m_invI;

		b2Mat22 K = new b2Mat22();
		K.col1.x = mA + mB;	K.col2.x = 0.0f;
		K.col1.y = 0.0f;	K.col2.y = mA + mB;

		K.col1.x+=  iA * rAY * rAY;	K.col2.x+= -iA * rAX * rAY;
		K.col1.y+= -iA * rAX * rAY;	K.col2.y+=  iA * rAX * rAX;

		K.col1.x+=  iB * rBY * rBY;	K.col2.x+= -iB * rBX * rBY;
		K.col1.y+= -iB * rBX * rBY;	K.col2.y+=  iB * rBX * rBX;

		K.GetInverse(m_linearMass);

		m_angularMass = iA + iB;
		if (m_angularMass > 0.0f)
		{
			m_angularMass = 1.0f / m_angularMass;
		}

		if (step.warmStarting)
		{
			// Scale impulses to support a variable time step.
			m_linearImpulse.x *= step.dtRatio;
			m_linearImpulse.y *= step.dtRatio;
			m_angularImpulse *= step.dtRatio;

			b2Vec2 P = m_linearImpulse;

			bA.m_linearVelocity.x -= mA * P.x;
			bA.m_linearVelocity.y -= mA * P.y;
			bA.m_angularVelocity -= iA * (rAX * P.y - rAY * P.x + m_angularImpulse);

			bB.m_linearVelocity.x += mB * P.x;
			bB.m_linearVelocity.y += mB * P.y;
			bB.m_angularVelocity += iB * (rBX * P.y - rBY * P.x + m_angularImpulse);
		}
		else
		{
			m_linearImpulse.SetZero();
			m_angularImpulse = 0.0f;
		}

	}
	
	
	
	public override void SolveVelocityConstraints(b2TimeStep step){
		//B2_NOT_USED(step);
		b2Mat22 tMat;
		float tX;

		b2Body bA = m_bodyA;
		b2Body bB= m_bodyB;

		b2Vec2 vA = bA.m_linearVelocity;
		float wA = bA.m_angularVelocity;
		b2Vec2 vB = bB.m_linearVelocity;
		float wB = bB.m_angularVelocity;

		float mA = bA.m_invMass;
		float mB = bB.m_invMass;
		float iA = bA.m_invI;
		float iB = bB.m_invI;

		//b2Vec2 rA = b2Mul(bA->m_xf.R, m_localAnchorA - bA->GetLocalCenter());
		tMat = bA.m_xf.R;
		float rAX = m_localAnchorA.x - bA.m_sweep.localCenter.x;
		float rAY = m_localAnchorA.y - bA.m_sweep.localCenter.y;
		tX =  (tMat.col1.x * rAX + tMat.col2.x * rAY);
		rAY = (tMat.col1.y * rAX + tMat.col2.y * rAY);
		rAX = tX;
		//b2Vec2 rB = b2Mul(bB->m_xf.R, m_localAnchorB - bB->GetLocalCenter());
		tMat = bB.m_xf.R;
		float rBX = m_localAnchorB.x - bB.m_sweep.localCenter.x;
		float rBY = m_localAnchorB.y - bB.m_sweep.localCenter.y;
		tX =  (tMat.col1.x * rBX + tMat.col2.x * rBY);
		rBY = (tMat.col1.y * rBX + tMat.col2.y * rBY);
		rBX = tX;
		
		float maxImpulse;

		// Solve angular friction
		{
			float Cdot = wB - wA;
			float impulse = -m_angularMass * Cdot;

			float oldImpulse = m_angularImpulse;
			maxImpulse = step.dt * m_maxTorque;
			m_angularImpulse = b2Math.Clamp(m_angularImpulse + impulse, -maxImpulse, maxImpulse);
			impulse = m_angularImpulse - oldImpulse;

			wA -= iA * impulse;
			wB += iB * impulse;
		}

		// Solve linear friction
		{
			//b2Vec2 Cdot = vB + b2Cross(wB, rB) - vA - b2Cross(wA, rA);
			float CdotX = vB.x - wB * rBY - vA.x + wA * rAY;
			float CdotY = vB.y + wB * rBX - vA.y - wA * rAX;

			b2Vec2 impulseV = b2Math.MulMV(m_linearMass, new b2Vec2(-CdotX, -CdotY));
			b2Vec2 oldImpulseV = m_linearImpulse.Copy();
			
			m_linearImpulse.Add(impulseV);

			maxImpulse = step.dt * m_maxForce;

			if (m_linearImpulse.LengthSquared() > maxImpulse * maxImpulse)
			{
				m_linearImpulse.Normalize();
				m_linearImpulse.Multiply(maxImpulse);
			}

			impulseV = b2Math.SubtractVV(m_linearImpulse, oldImpulseV);

			vA.x -= mA * impulseV.x;
			vA.y -= mA * impulseV.y;
			wA -= iA * (rAX * impulseV.y - rAY * impulseV.x);

			vB.x += mB * impulseV.x;
			vB.y += mB * impulseV.y;
			wB += iB * (rBX * impulseV.y - rBY * impulseV.x);
		}

		// References has made some sets unnecessary
		//bA->m_linearVelocity = vA;
		bA.m_angularVelocity = wA;
		//bB->m_linearVelocity = vB;
		bB.m_angularVelocity = wB;

	}
	
	public override bool SolvePositionConstraints(float baumgarte)
	{
		//B2_NOT_USED(baumgarte);
		
		return true;
		
	}

	private b2Vec2 m_localAnchorA = new b2Vec2();
	private b2Vec2 m_localAnchorB = new b2Vec2();
	
	public b2Mat22 m_linearMass = new b2Mat22();
	public float m_angularMass;
	
	private b2Vec2 m_linearImpulse = new b2Vec2();
	private float m_angularImpulse;
	
	private float m_maxForce;
	private float m_maxTorque;
};

}
