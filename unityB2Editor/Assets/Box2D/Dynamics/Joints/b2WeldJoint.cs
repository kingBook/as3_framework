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
using Box2D.Dynamics;
using UnityEngine;

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
 * A weld joint essentially glues two bodies together. A weld joint may
 * distort somewhat because the island constraint solver is approximate.
 */
public class b2WeldJoint : b2Joint
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
		return new b2Vec2(inv_dt * m_impulse.x, inv_dt * m_impulse.y);
	}

	/** @inheritDoc */
	public override float GetReactionTorque(float inv_dt)
	{
		return inv_dt * m_impulse.z;
	}
	
	//--------------- Internals Below -------------------

	/** @private */
	public b2WeldJoint(b2WeldJointDef def):base(def){
		
		m_localAnchorA.SetV(def.localAnchorA);
		m_localAnchorB.SetV(def.localAnchorB);
		m_referenceAngle = def.referenceAngle;

		m_impulse.SetZero();
		m_mass = new b2Mat33();
	}

	public override void InitVelocityConstraints(b2TimeStep step){
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
		
		m_mass.col1.x = mA + mB + rAY * rAY * iA + rBY * rBY * iB;
		m_mass.col2.x = -rAY * rAX * iA - rBY * rBX * iB;
		m_mass.col3.x = -rAY * iA - rBY * iB;
		m_mass.col1.y = m_mass.col2.x;
		m_mass.col2.y = mA + mB + rAX * rAX * iA + rBX * rBX * iB;
		m_mass.col3.y = rAX * iA + rBX * iB;
		m_mass.col1.z = m_mass.col3.x;
		m_mass.col2.z = m_mass.col3.y;
		m_mass.col3.z = iA + iB;
		
		if (step.warmStarting)
		{
			// Scale impulses to support a variable time step.
			m_impulse.x *= step.dtRatio;
			m_impulse.y *= step.dtRatio;
			m_impulse.z *= step.dtRatio;

			bA.m_linearVelocity.x -= mA * m_impulse.x;
			bA.m_linearVelocity.y -= mA * m_impulse.y;
			bA.m_angularVelocity -= iA * (rAX * m_impulse.y - rAY * m_impulse.x + m_impulse.z);

			bB.m_linearVelocity.x += mB * m_impulse.x;
			bB.m_linearVelocity.y += mB * m_impulse.y;
			bB.m_angularVelocity += iB * (rBX * m_impulse.y - rBY * m_impulse.x + m_impulse.z);
		}
		else
		{
			m_impulse.SetZero();
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

		
		// Solve point-to-point constraint
		float Cdot1X = vB.x - wB * rBY - vA.x + wA * rAY;
		float Cdot1Y = vB.y + wB * rBX - vA.y - wA * rAX;
		float Cdot2 = wB - wA;
		b2Vec3 impulse = new b2Vec3();
		m_mass.Solve33(impulse, -Cdot1X, -Cdot1Y, -Cdot2);
		
		m_impulse.Add(impulse);
		
		vA.x -= mA * impulse.x;
		vA.y -= mA * impulse.y;
		wA -= iA * (rAX * impulse.y - rAY * impulse.x + impulse.z);

		vB.x += mB * impulse.x;
		vB.y += mB * impulse.y;
		wB += iB * (rBX * impulse.y - rBY * impulse.x + impulse.z);

		// References has made some sets unnecessary
		//bA->m_linearVelocity = vA;
		bA.m_angularVelocity = wA;
		//bB->m_linearVelocity = vB;
		bB.m_angularVelocity = wB;

	}
	
	public override bool SolvePositionConstraints(float baumgarte)
	{
		//B2_NOT_USED(baumgarte);
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
		
		//b2Vec2 C1 =  bB->m_sweep.c + rB - bA->m_sweep.c - rA;
		float C1X =  bB.m_sweep.c.x + rBX - bA.m_sweep.c.x - rAX;
		float C1Y =  bB.m_sweep.c.y + rBY - bA.m_sweep.c.y - rAY;
		float C2 = bB.m_sweep.a - bA.m_sweep.a - m_referenceAngle;

		// Handle large detachment.
		float k_allowedStretch = 10.0f * b2Settings.b2_linearSlop;
		float positionError = Mathf.Sqrt(C1X * C1X + C1Y * C1Y);
		float angularError = b2Math.Abs(C2);
		if (positionError > k_allowedStretch)
		{
			iA *= 1.0f;
			iB *= 1.0f;
		}
		
		m_mass.col1.x = mA + mB + rAY * rAY * iA + rBY * rBY * iB;
		m_mass.col2.x = -rAY * rAX * iA - rBY * rBX * iB;
		m_mass.col3.x = -rAY * iA - rBY * iB;
		m_mass.col1.y = m_mass.col2.x;
		m_mass.col2.y = mA + mB + rAX * rAX * iA + rBX * rBX * iB;
		m_mass.col3.y = rAX * iA + rBX * iB;
		m_mass.col1.z = m_mass.col3.x;
		m_mass.col2.z = m_mass.col3.y;
		m_mass.col3.z = iA + iB;
		
		b2Vec3 impulse = new b2Vec3();
		m_mass.Solve33(impulse, -C1X, -C1Y, -C2);
		

		bA.m_sweep.c.x -= mA * impulse.x;
		bA.m_sweep.c.y -= mA * impulse.y;
		bA.m_sweep.a -= iA * (rAX * impulse.y - rAY * impulse.x + impulse.z);

		bB.m_sweep.c.x += mB * impulse.x;
		bB.m_sweep.c.y += mB * impulse.y;
		bB.m_sweep.a += iB * (rBX * impulse.y - rBY * impulse.x + impulse.z);

		bA.SynchronizeTransform();
		bB.SynchronizeTransform();

		return positionError <= b2Settings.b2_linearSlop && angularError <= b2Settings.b2_angularSlop;

	}

	private b2Vec2 m_localAnchorA = new b2Vec2();
	private b2Vec2 m_localAnchorB = new b2Vec2();
	private float m_referenceAngle;
	public float GetReferenceAngle() {
		return m_referenceAngle;
	}
	
	private b2Vec3 m_impulse = new b2Vec3();
	private b2Mat33 m_mass = new b2Mat33();
}

}
