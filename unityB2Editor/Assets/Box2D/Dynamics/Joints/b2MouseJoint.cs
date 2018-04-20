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

// p = attached point, m = mouse point
// C = p - m
// Cdot = v
//      = v + cross(w, r)
// J = [I r_skew]
// Identity used:
// w k % (rx i + ry j) = w * (-ry i + rx j)

/**
* A mouse joint is used to make a point on a body track a
* specified world point. This a soft constraint with a maximum
* force. This allows the constraint to stretch and without
* applying huge forces.
* Note: this joint is not fully documented as it is intended primarily
* for the testbed. See that for more instructions.
* @see b2MouseJointDef
*/

public class b2MouseJoint : b2Joint
{
	/** @inheritDoc */
	public override b2Vec2 GetAnchorA(){
		return m_target;
	}
	/** @inheritDoc */
	public override b2Vec2 GetAnchorB(){
		return m_bodyB.GetWorldPoint(m_localAnchor);
	}
	/** @inheritDoc */
	public override b2Vec2 GetReactionForce(float inv_dt)
	{
		return new b2Vec2(inv_dt * m_impulse.x, inv_dt * m_impulse.y);
	}
	/** @inheritDoc */
	public override float GetReactionTorque(float inv_dt)
	{
		return 0.0f;
	}
	
	public b2Vec2 GetTarget()
	{
		return m_target;
	}
	
	/**
	 * Use this to update the target point.
	 */
	public void SetTarget(b2Vec2 target){
		if (m_bodyB.IsAwake() == false){
			m_bodyB.SetAwake(true);
		}
		m_target = target;
	}

	/// Get the maximum force in Newtons.
	public float GetMaxForce()
	{
		return m_maxForce;
	}
	
	/// Set the maximum force in Newtons.
	public void SetMaxForce(float maxForce)
	{
		m_maxForce = maxForce;
	}
	
	/// Get frequency in Hz
	public float GetFrequency()
	{
		return m_frequencyHz;
	}
	
	/// Set the frequency in Hz
	public void SetFrequency(float hz)
	{
		m_frequencyHz = hz;
	}
	
	/// Get damping ratio
	public float GetDampingRatio()
	{
		return m_dampingRatio;
	}
	
	/// Set damping ratio
	public void SetDampingRatio(float ratio)
	{
		m_dampingRatio = ratio;
	}
	
	//--------------- Internals Below -------------------

	/** @private */
	public b2MouseJoint(b2MouseJointDef def):base(def){
		
		//b2Settings.b2Assert(def.target.IsValid());
		//b2Settings.b2Assert(b2Math.b2IsValid(def.maxForce) && def.maxForce > 0.0);
		//b2Settings.b2Assert(b2Math.b2IsValid(def.frequencyHz) && def.frequencyHz > 0.0);
		//b2Settings.b2Assert(b2Math.b2IsValid(def.dampingRatio) && def.dampingRatio > 0.0);
		
		m_target.SetV(def.target);
		//m_localAnchor = b2MulT(m_bodyB.m_xf, m_target);
		float tX = m_target.x - m_bodyB.m_xf.position.x;
		float tY = m_target.y - m_bodyB.m_xf.position.y;
		b2Mat22 tMat = m_bodyB.m_xf.R;
		m_localAnchor.x = (tX * tMat.col1.x + tY * tMat.col1.y);
		m_localAnchor.y = (tX * tMat.col2.x + tY * tMat.col2.y);
		
		m_maxForce = def.maxForce;
		m_impulse.SetZero();
		
		m_frequencyHz = def.frequencyHz;
		m_dampingRatio = def.dampingRatio;
		
		m_beta = 0.0f;
		m_gamma = 0.0f;
	}

	// Presolve vars
	private b2Mat22 K = new b2Mat22();
	private b2Mat22 K1 = new b2Mat22();
	private b2Mat22 K2 = new b2Mat22();
	public override void InitVelocityConstraints(b2TimeStep step){
		b2Body b = m_bodyB;
		
		float mass = b.GetMass();
		
		// Frequency
		float omega = 2.0f * Mathf.PI * m_frequencyHz;
		
		// Damping co-efficient
		float d = 2.0f * mass * m_dampingRatio * omega;
		
		// Spring stiffness
		float k = mass * omega * omega;
		
		// magic formulas
		// gamma has units of inverse mass
		// beta hs units of inverse time
		//b2Settings.b2Assert(d + step.dt * k > Number.MIN_VALUE)
		m_gamma = step.dt * (d + step.dt * k);
		m_gamma = m_gamma != 0.0f ? 1.0f / m_gamma:0.0f;
		m_beta = step.dt * k * m_gamma;
		
		b2Mat22 tMat;
		
		// Compute the effective mass matrix.
		//b2Vec2 r = b2Mul(b->m_xf.R, m_localAnchor - b->GetLocalCenter());
		tMat = b.m_xf.R;
		float rX = m_localAnchor.x - b.m_sweep.localCenter.x;
		float rY = m_localAnchor.y - b.m_sweep.localCenter.y;
		float tX = (tMat.col1.x * rX + tMat.col2.x * rY);
		rY = (tMat.col1.y * rX + tMat.col2.y * rY);
		rX = tX;
		
		// K    = [(1/m1 + 1/m2) * eye(2) - skew(r1) * invI1 * skew(r1) - skew(r2) * invI2 * skew(r2)]
		//      = [1/m1+1/m2     0    ] + invI1 * [r1.y*r1.y -r1.x*r1.y] + invI2 * [r1.y*r1.y -r1.x*r1.y]
		//        [    0     1/m1+1/m2]           [-r1.x*r1.y r1.x*r1.x]           [-r1.x*r1.y r1.x*r1.x]
		float invMass = b.m_invMass;
		float invI = b.m_invI;
		
		//b2Mat22 K1;
		K1.col1.x = invMass;	K1.col2.x = 0.0f;
		K1.col1.y = 0.0f;		K1.col2.y = invMass;
		
		//b2Mat22 K2;
		K2.col1.x =  invI * rY * rY;	K2.col2.x = -invI * rX * rY;
		K2.col1.y = -invI * rX * rY;	K2.col2.y =  invI * rX * rX;
		
		//b2Mat22 K = K1 + K2;
		K.SetM(K1);
		K.AddM(K2);
		K.col1.x += m_gamma;
		K.col2.y += m_gamma;
		
		//m_ptpMass = K.GetInverse();
		K.GetInverse(m_mass);
		
		//m_C = b.m_position + r - m_target;
		m_C.x = b.m_sweep.c.x + rX - m_target.x;
		m_C.y = b.m_sweep.c.y + rY - m_target.y;
		
		// Cheat with some damping
		b.m_angularVelocity *= 0.98f;
		
		// Warm starting.
		m_impulse.x *= step.dtRatio;
		m_impulse.y *= step.dtRatio;
		//b.m_linearVelocity += invMass * m_impulse;
		b.m_linearVelocity.x += invMass * m_impulse.x;
		b.m_linearVelocity.y += invMass * m_impulse.y;
		//b.m_angularVelocity += invI * b2Cross(r, m_impulse);
		b.m_angularVelocity += invI * (rX * m_impulse.y - rY * m_impulse.x);
	}
	
	public override void SolveVelocityConstraints(b2TimeStep step){
		b2Body b = m_bodyB;
		
		b2Mat22 tMat;
		float tX;
		float tY;
		
		// Compute the effective mass matrix.
		//b2Vec2 r = b2Mul(b->m_xf.R, m_localAnchor - b->GetLocalCenter());
		tMat = b.m_xf.R;
		float rX = m_localAnchor.x - b.m_sweep.localCenter.x;
		float rY = m_localAnchor.y - b.m_sweep.localCenter.y;
		tX = (tMat.col1.x * rX + tMat.col2.x * rY);
		rY = (tMat.col1.y * rX + tMat.col2.y * rY);
		rX = tX;
		
		// Cdot = v + cross(w, r)
		//b2Vec2 Cdot = b->m_linearVelocity + b2Cross(b->m_angularVelocity, r);
		float CdotX = b.m_linearVelocity.x + (-b.m_angularVelocity * rY);
		float CdotY = b.m_linearVelocity.y + (b.m_angularVelocity * rX);
		//b2Vec2 impulse = - b2Mul(m_mass, Cdot + m_beta * m_C + m_gamma * m_impulse);
		tMat = m_mass;
		tX = CdotX + m_beta * m_C.x + m_gamma * m_impulse.x;
		tY = CdotY + m_beta * m_C.y + m_gamma * m_impulse.y;
		float impulseX = -(tMat.col1.x * tX + tMat.col2.x * tY);
		float impulseY = -(tMat.col1.y * tX + tMat.col2.y * tY);
		
		float oldImpulseX = m_impulse.x;
		float oldImpulseY = m_impulse.y;
		//m_impulse += impulse;
		m_impulse.x += impulseX;
		m_impulse.y += impulseY;
		float maxImpulse = step.dt * m_maxForce;
		if (m_impulse.LengthSquared() > maxImpulse*maxImpulse)
		{
			//m_impulse *= m_maxImpulse / m_impulse.Length();
			m_impulse.Multiply(maxImpulse / m_impulse.Length());
		}
		//impulse = m_impulse - oldImpulse;
		impulseX = m_impulse.x - oldImpulseX;
		impulseY = m_impulse.y - oldImpulseY;
		
		//b->m_linearVelocity += b->m_invMass * impulse;
		b.m_linearVelocity.x += b.m_invMass * impulseX;
		b.m_linearVelocity.y += b.m_invMass * impulseY;
		//b->m_angularVelocity += b->m_invI * b2Cross(r, P);
		b.m_angularVelocity += b.m_invI * (rX * impulseY - rY * impulseX);
	}

	public override bool SolvePositionConstraints(float baumgarte) {
		//B2_NOT_USED(baumgarte);
		return true; 
	}

	private b2Vec2 m_localAnchor = new b2Vec2();
	private b2Vec2 m_target = new b2Vec2();
	private b2Vec2 m_impulse = new b2Vec2();

	private b2Mat22 m_mass = new b2Mat22();	// effective mass for point-to-point constraint.
	private b2Vec2 m_C = new b2Vec2();			// position error
	private float m_maxForce;
	private float m_frequencyHz;
	private float m_dampingRatio;
	private float m_beta;						// bias factor
	private float m_gamma;						// softness
}

}
