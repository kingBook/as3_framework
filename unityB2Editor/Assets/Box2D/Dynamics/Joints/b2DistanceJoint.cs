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

// 1-D constrained system
// m (v2 - v1) = lambda
// v2 + (beta/h) * x1 + gamma * lambda = 0, gamma has units of inverse mass.
// x2 = x1 + h * v2

// 1-D mass-damper-spring system
// m (v2 - v1) + h * d * v2 + h * k * 

// C = norm(p2 - p1) - L
// u = (p2 - p1) / norm(p2 - p1)
// Cdot = dot(u, v2 + cross(w2, r2) - v1 - cross(w1, r1))
// J = [-u -cross(r1, u) u cross(r2, u)]
// K = J * invM * JT
//   = invMass1 + invI1 * cross(r1, u)^2 + invMass2 + invI2 * cross(r2, u)^2

/**
* A distance joint constrains two points on two bodies
* to remain at a fixed distance from each other. You can view
* this as a massless, rigid rod.
* @see b2DistanceJointDef
*/
public class b2DistanceJoint : b2Joint
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
		//b2Vec2 F = (m_inv_dt * m_impulse) * m_u;
		//return F;
		return new b2Vec2(inv_dt * m_impulse * m_u.x, inv_dt * m_impulse * m_u.y);
	}

	/** @inheritDoc */
	public override float GetReactionTorque(float inv_dt)
	{
		//B2_NOT_USED(inv_dt);
		return 0.0f;
	}
	
	/// Set the natural length
	public float GetLength()
	{
		return m_length;
	}
	
	/// Get the natural length
	public void SetLength(float length)
	{
		m_length = length;
	}
	
	/// Get the frequency in Hz
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
	public b2DistanceJoint(b2DistanceJointDef def):base(def){
		
		b2Mat22 tMat;
		float tX;
		float tY;
		m_localAnchor1.SetV(def.localAnchorA);
		m_localAnchor2.SetV(def.localAnchorB);
		
		m_length = def.length;
		m_frequencyHz = def.frequencyHz;
		m_dampingRatio = def.dampingRatio;
		m_impulse = 0.0f;
		m_gamma = 0.0f;
		m_bias = 0.0f;
	}

	public override void InitVelocityConstraints(b2TimeStep step){
		
		b2Mat22 tMat;
		float tX;
		
		b2Body bA = m_bodyA;
		b2Body bB = m_bodyB;
		
		// Compute the effective mass matrix.
		//b2Vec2 r1 = b2Mul(bA->m_xf.R, m_localAnchor1 - bA->GetLocalCenter());
		tMat = bA.m_xf.R;
		float r1X = m_localAnchor1.x - bA.m_sweep.localCenter.x;
		float r1Y = m_localAnchor1.y - bA.m_sweep.localCenter.y;
		tX =  (tMat.col1.x * r1X + tMat.col2.x * r1Y);
		r1Y = (tMat.col1.y * r1X + tMat.col2.y * r1Y);
		r1X = tX;
		//b2Vec2 r2 = b2Mul(bB->m_xf.R, m_localAnchor2 - bB->GetLocalCenter());
		tMat = bB.m_xf.R;
		float r2X = m_localAnchor2.x - bB.m_sweep.localCenter.x;
		float r2Y = m_localAnchor2.y - bB.m_sweep.localCenter.y;
		tX =  (tMat.col1.x * r2X + tMat.col2.x * r2Y);
		r2Y = (tMat.col1.y * r2X + tMat.col2.y * r2Y);
		r2X = tX;
		
		//m_u = bB->m_sweep.c + r2 - bA->m_sweep.c - r1;
		m_u.x = bB.m_sweep.c.x + r2X - bA.m_sweep.c.x - r1X;
		m_u.y = bB.m_sweep.c.y + r2Y - bA.m_sweep.c.y - r1Y;
		
		// Handle singularity.
		//float32 length = m_u.Length();
		float length = Mathf.Sqrt(m_u.x*m_u.x + m_u.y*m_u.y);
		if (length > b2Settings.b2_linearSlop)
		{
			//m_u *= 1.0 / length;
			m_u.Multiply( 1.0f / length );
		}
		else
		{
			m_u.SetZero();
		}
		
		//float32 cr1u = b2Cross(r1, m_u);
		float cr1u = (r1X * m_u.y - r1Y * m_u.x);
		//float32 cr2u = b2Cross(r2, m_u);
		float cr2u = (r2X * m_u.y - r2Y * m_u.x);
		//m_mass = bA->m_invMass + bA->m_invI * cr1u * cr1u + bB->m_invMass + bB->m_invI * cr2u * cr2u;
		float invMass = bA.m_invMass + bA.m_invI * cr1u * cr1u + bB.m_invMass + bB.m_invI * cr2u * cr2u;
		m_mass = invMass != 0.0f ? 1.0f / invMass : 0.0f;
		
		if (m_frequencyHz > 0.0f)
		{
			float C = length - m_length;
	
			// Frequency
			float omega = 2.0f * Mathf.PI * m_frequencyHz;
	
			// Damping coefficient
			float d = 2.0f * m_mass * m_dampingRatio * omega;
	
			// Spring stiffness
			float k = m_mass * omega * omega;
	
			// magic formulas
			m_gamma = step.dt * (d + step.dt * k);
			m_gamma = m_gamma != 0.0f?1 / m_gamma:0.0f;
			m_bias = C * step.dt * k * m_gamma;
	
			m_mass = invMass + m_gamma;
			m_mass = m_mass != 0.0f ? 1.0f / m_mass : 0.0f;
		}
		
		if (step.warmStarting)
		{
			// Scale the impulse to support a variable time step
			m_impulse *= step.dtRatio;
			
			//b2Vec2 P = m_impulse * m_u;
			float PX = m_impulse * m_u.x;
			float PY = m_impulse * m_u.y;
			//bA->m_linearVelocity -= bA->m_invMass * P;
			bA.m_linearVelocity.x -= bA.m_invMass * PX;
			bA.m_linearVelocity.y -= bA.m_invMass * PY;
			//bA->m_angularVelocity -= bA->m_invI * b2Cross(r1, P);
			bA.m_angularVelocity -= bA.m_invI * (r1X * PY - r1Y * PX);
			//bB->m_linearVelocity += bB->m_invMass * P;
			bB.m_linearVelocity.x += bB.m_invMass * PX;
			bB.m_linearVelocity.y += bB.m_invMass * PY;
			//bB->m_angularVelocity += bB->m_invI * b2Cross(r2, P);
			bB.m_angularVelocity += bB.m_invI * (r2X * PY - r2Y * PX);
		}
		else
		{
			m_impulse = 0.0f;
		}
	}
	
	
	
	public override void SolveVelocityConstraints(b2TimeStep step){
		
		b2Mat22 tMat;
		
		b2Body bA = m_bodyA;
		b2Body bB = m_bodyB;
		
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
		
		// Cdot = dot(u, v + cross(w, r))
		//b2Vec2 v1 = bA->m_linearVelocity + b2Cross(bA->m_angularVelocity, r1);
		float v1X = bA.m_linearVelocity.x + (-bA.m_angularVelocity * r1Y);
		float v1Y = bA.m_linearVelocity.y + (bA.m_angularVelocity * r1X);
		//b2Vec2 v2 = bB->m_linearVelocity + b2Cross(bB->m_angularVelocity, r2);
		float v2X = bB.m_linearVelocity.x + (-bB.m_angularVelocity * r2Y);
		float v2Y = bB.m_linearVelocity.y + (bB.m_angularVelocity * r2X);
		//float32 Cdot = b2Dot(m_u, v2 - v1);
		float Cdot = (m_u.x * (v2X - v1X) + m_u.y * (v2Y - v1Y));
		
		float impulse = -m_mass * (Cdot + m_bias + m_gamma * m_impulse);
		m_impulse += impulse;
		
		//b2Vec2 P = impulse * m_u;
		float PX = impulse * m_u.x;
		float PY = impulse * m_u.y;
		//bA->m_linearVelocity -= bA->m_invMass * P;
		bA.m_linearVelocity.x -= bA.m_invMass * PX;
		bA.m_linearVelocity.y -= bA.m_invMass * PY;
		//bA->m_angularVelocity -= bA->m_invI * b2Cross(r1, P);
		bA.m_angularVelocity -= bA.m_invI * (r1X * PY - r1Y * PX);
		//bB->m_linearVelocity += bB->m_invMass * P;
		bB.m_linearVelocity.x += bB.m_invMass * PX;
		bB.m_linearVelocity.y += bB.m_invMass * PY;
		//bB->m_angularVelocity += bB->m_invI * b2Cross(r2, P);
		bB.m_angularVelocity += bB.m_invI * (r2X * PY - r2Y * PX);
	}
	
	public override bool SolvePositionConstraints(float baumgarte)
	{
		//B2_NOT_USED(baumgarte);
		
		b2Mat22 tMat;
		
		if (m_frequencyHz > 0.0f)
		{
			// There is no position correction for soft distance constraints
			return true;
		}
		
		b2Body bA = m_bodyA;
		b2Body bB = m_bodyB;
		
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
		
		//b2Vec2 d = bB->m_sweep.c + r2 - bA->m_sweep.c - r1;
		float dX = bB.m_sweep.c.x + r2X - bA.m_sweep.c.x - r1X;
		float dY = bB.m_sweep.c.y + r2Y - bA.m_sweep.c.y - r1Y;
		
		//float32 length = d.Normalize();
		float length = Mathf.Sqrt(dX*dX + dY*dY);
		dX /= length;
		dY /= length;
		//float32 C = length - m_length;
		float C = length - m_length;
		C = b2Math.Clamp(C, -b2Settings.b2_maxLinearCorrection, b2Settings.b2_maxLinearCorrection);
		
		float impulse = -m_mass * C;
		//m_u = d;
		m_u.Set(dX, dY);
		//b2Vec2 P = impulse * m_u;
		float PX = impulse * m_u.x;
		float PY = impulse * m_u.y;
		
		//bA->m_sweep.c -= bA->m_invMass * P;
		bA.m_sweep.c.x -= bA.m_invMass * PX;
		bA.m_sweep.c.y -= bA.m_invMass * PY;
		//bA->m_sweep.a -= bA->m_invI * b2Cross(r1, P);
		bA.m_sweep.a -= bA.m_invI * (r1X * PY - r1Y * PX);
		//bB->m_sweep.c += bB->m_invMass * P;
		bB.m_sweep.c.x += bB.m_invMass * PX;
		bB.m_sweep.c.y += bB.m_invMass * PY;
		//bB->m_sweep.a -= bB->m_invI * b2Cross(r2, P);
		bB.m_sweep.a += bB.m_invI * (r2X * PY - r2Y * PX);
		
		bA.SynchronizeTransform();
		bB.SynchronizeTransform();
		
		return b2Math.Abs(C) < b2Settings.b2_linearSlop;
		
	}

	private b2Vec2 m_localAnchor1 = new b2Vec2();
	private b2Vec2 m_localAnchor2 = new b2Vec2();
	private b2Vec2 m_u = new b2Vec2();
	private float m_frequencyHz;
	private float m_dampingRatio;
	private float m_gamma;
	private float m_bias;
	private float m_impulse;
	private float m_mass;	// effective mass for the constraint.
	private float m_length;
}

}
