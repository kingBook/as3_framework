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

using Box2D.Collision.Shapes;
using Box2D.Collision;
using Box2D.Common.Math;
using Box2D.Common;
using Box2D.Dynamics;
using System.Collections.Generic;
using UnityEngine;

namespace Box2D.Dynamics.Contacts{



/**
* @private
*/
public class b2ContactSolver
{
	public b2ContactSolver()
	{
	}
	
	private static b2WorldManifold s_worldManifold = new b2WorldManifold();
	public void Initialize(b2TimeStep step, List<b2Contact> contacts, int contactCount, object allocator)
	{
		b2Contact contact;
		
		m_step.Set (step);
		
		m_allocator = allocator;
		
		int i;
		b2Vec2 tVec;
		b2Mat22 tMat;
		
		m_constraintCount = contactCount;

		// fill vector to hold enough constraints
		while (m_constraints.Count < m_constraintCount)
		{
			m_constraints.Add(new b2ContactConstraint());
		}
		
		for (i = 0; i < contactCount; ++i)
		{
			contact = contacts[i];
			b2Fixture fixtureA = contact.m_fixtureA;
			b2Fixture fixtureB = contact.m_fixtureB;
			b2Shape shapeA = fixtureA.m_shape;
			b2Shape shapeB = fixtureB.m_shape;
			float radiusA = shapeA.m_radius;
			float radiusB = shapeB.m_radius;
			b2Body bodyA = fixtureA.m_body;
			b2Body bodyB = fixtureB.m_body;
			b2Manifold manifold = contact.GetManifold();
			float friction = b2Settings.b2MixFriction(fixtureA.GetFriction(), fixtureB.GetFriction());;
			float restitution = b2Settings.b2MixRestitution(fixtureA.GetRestitution(), fixtureB.GetRestitution());
			
			//var vA:b2Vec2 = bodyA.m_linearVelocity.Copy();
			float vAX = bodyA.m_linearVelocity.x;
			float vAY = bodyA.m_linearVelocity.y;
			//var vB:b2Vec2 = bodyB.m_linearVelocity.Copy();
			float vBX = bodyB.m_linearVelocity.x;
			float vBY = bodyB.m_linearVelocity.y;
			float wA = bodyA.m_angularVelocity;
			float wB = bodyB.m_angularVelocity;
			
			b2Settings.b2Assert(manifold.m_pointCount > 0);
			
			s_worldManifold.Initialize(manifold, bodyA.m_xf, radiusA, bodyB.m_xf, radiusB);
			
			float normalX = s_worldManifold.m_normal.x;
			float normalY = s_worldManifold.m_normal.y;
			
			b2ContactConstraint cc = m_constraints[ i ];
			cc.bodyA = bodyA; //p
			cc.bodyB = bodyB; //p
			cc.manifold = manifold; //p
			//c.normal = normal;
			cc.normal.x = normalX;
			cc.normal.y = normalY;
			cc.pointCount = manifold.m_pointCount;
			cc.friction = friction;
			//-----------------------------修改 2015/12/10 13:07 by kingBook------------------
			float bevel=10.0f;
			float planeAngle;
			int vx;
			if(!bodyA.m_allowBevelSlither||bodyA.m_uphillZeroFriction){
				planeAngle=Mathf.Atan2(normalY,normalX)*57.3f+90.0f;
				vx=(int)(bodyA.m_linearVelocity.x);
				if(planeAngle<0.0f)planeAngle+=360.0f;
				if((planeAngle>bevel&&planeAngle<90.0f-bevel) || (planeAngle>180.0f+bevel&&planeAngle<270.0f-bevel)){//斜面 左上角-右下角
					if(!bodyA.m_allowBevelSlither){
						if(vx>=0.0f)cc.friction=1.0f;
					}
					if(bodyA.m_uphillZeroFriction){
						if(vx<0.0f)cc.friction=0.0f;
					}
				}else if((planeAngle>90.0f&&planeAngle<180.0f-bevel) || (planeAngle>270.0f+bevel&&planeAngle<360.0f-bevel)){//斜面 左下角-右上角
					if(!bodyA.m_allowBevelSlither){
						if(vx<=0.0f)cc.friction=1.0f;
					}
					if(bodyA.m_uphillZeroFriction){
						if(vx>0.0f)cc.friction=0.0f;
					}
				}
			}else if(!bodyB.m_allowBevelSlither||bodyB.m_uphillZeroFriction){
				planeAngle=Mathf.Atan2(-normalY,-normalX)*57.3f+90.0f;
				vx=(int)(bodyB.m_linearVelocity.x);
				if(planeAngle<0.0f)planeAngle+=360.0f;
				if((planeAngle>bevel&&planeAngle<90.0f-bevel) || (planeAngle>180.0f+bevel&&planeAngle<270.0f-bevel)){//斜面 左上角-右下角
					if(!bodyB.m_allowBevelSlither){
						if(vx>=0.0f)cc.friction=1.0f;
					}
					if(bodyB.m_uphillZeroFriction){
						if(vx<0.0f)cc.friction=0.0f;
					}
				}else if((planeAngle>90.0f&&planeAngle<180.0f-bevel) || (planeAngle>270.0f+bevel&&planeAngle<360.0f-bevel)){//斜面 左下角-右上角
					if(!bodyB.m_allowBevelSlither){
						if(vx<=0.0f)cc.friction=1.0f;
					}
					if(bodyB.m_uphillZeroFriction){
						if(vx>0)cc.friction=0.0f;
					}
				}
			}
			
			if(bodyA.m_isIgnoreFrictionX || bodyB.m_isIgnoreFrictionX){
				if(Mathf.Abs(normalY)>0.9f)cc.friction = 0.0f;
			}else if(bodyA.m_isIgnoreFrictionY || bodyB.m_isIgnoreFrictionY){
				if(Mathf.Abs(normalX)>0.9f)cc.friction = 0.0f;
			}
			//-----------------------------修改结束------------------
			cc.restitution = restitution;
			
			cc.localPlaneNormal.x = manifold.m_localPlaneNormal.x;
			cc.localPlaneNormal.y = manifold.m_localPlaneNormal.y;
			cc.localPoint.x = manifold.m_localPoint.x;
			cc.localPoint.y = manifold.m_localPoint.y;
			cc.radius = radiusA + radiusB;
			cc.type = manifold.m_type;
			
			for (int k = 0; k < cc.pointCount; ++k)
			{
				b2ManifoldPoint cp = manifold.m_points[ k ];
				b2ContactConstraintPoint ccp = cc.points[ k ];
				
				ccp.normalImpulse = cp.m_normalImpulse;
				ccp.tangentImpulse = cp.m_tangentImpulse;
				
				ccp.localPoint.SetV(cp.m_localPoint);
				
				float rAX = ccp.rA.x = s_worldManifold.m_points[k].x - bodyA.m_sweep.c.x;
				float rAY = ccp.rA.y = s_worldManifold.m_points[k].y - bodyA.m_sweep.c.y;
				float rBX = ccp.rB.x = s_worldManifold.m_points[k].x - bodyB.m_sweep.c.x;
				float rBY = ccp.rB.y = s_worldManifold.m_points[k].y - bodyB.m_sweep.c.y;
			
				float rnA = rAX * normalY - rAY * normalX;//b2Math.b2Cross(r1, normal);
				float rnB = rBX * normalY - rBY * normalX;//b2Math.b2Cross(r2, normal);
				
				rnA *= rnA;
				rnB *= rnB;
				
				float kNormal = bodyA.m_invMass + bodyB.m_invMass + bodyA.m_invI * rnA + bodyB.m_invI * rnB;
				//b2Settings.b2Assert(kNormal > Number.MIN_VALUE);
				ccp.normalMass = 1.0f / kNormal;
				
				float kEqualized = bodyA.m_mass * bodyA.m_invMass + bodyB.m_mass * bodyB.m_invMass;
				kEqualized += bodyA.m_mass * bodyA.m_invI * rnA + bodyB.m_mass * bodyB.m_invI * rnB;
				//b2Assert(kEqualized > Number.MIN_VALUE);
				ccp.equalizedMass = 1.0f / kEqualized;
				
				//var tangent:b2Vec2 = b2Math.b2CrossVF(normal, 1.0);
				float tangentX = normalY;
				float tangentY = -normalX;
				
				//var rtA:Number = b2Math.b2Cross(rA, tangent);
				float rtA = rAX*tangentY - rAY*tangentX;
				//var rtB:Number = b2Math.b2Cross(rB, tangent);
				float rtB = rBX*tangentY - rBY*tangentX;
				
				rtA *= rtA;
				rtB *= rtB;
				
				float kTangent = bodyA.m_invMass + bodyB.m_invMass + bodyA.m_invI * rtA + bodyB.m_invI * rtB;
				//b2Settings.b2Assert(kTangent > Number.MIN_VALUE);
				ccp.tangentMass = 1.0f /  kTangent;
				
				// Setup a velocity bias for restitution.
				ccp.velocityBias = 0.0f;
				//b2Dot(c.normal, vB + b2Cross(wB, rB) - vA - b2Cross(wA, rA));
				float tX = vBX + (-wB*rBY) - vAX - (-wA*rAY);
				float tY = vBY + (wB*rBX) - vAY - (wA*rAX);
				//var vRel:Number = b2Dot(cc.normal, t);
				float vRel = cc.normal.x*tX + cc.normal.y*tY;
				if (vRel < -b2Settings.b2_velocityThreshold)
				{
					ccp.velocityBias += -cc.restitution * vRel;
				}
			}
			
			// If we have two points, then prepare the block solver.
			if (cc.pointCount == 2)
			{
				b2ContactConstraintPoint ccp1 = cc.points[0];
				b2ContactConstraintPoint ccp2 = cc.points[1];
				
				float invMassA = bodyA.m_invMass;
				float invIA = bodyA.m_invI;
				float invMassB = bodyB.m_invMass;
				float invIB = bodyB.m_invI;
				
				//var rn1A:Number = b2Cross(ccp1.rA, normal);
				//var rn1B:Number = b2Cross(ccp1.rB, normal);
				//var rn2A:Number = b2Cross(ccp2.rA, normal);
				//var rn2B:Number = b2Cross(ccp2.rB, normal);
				float rn1A = ccp1.rA.x * normalY - ccp1.rA.y * normalX;
				float rn1B = ccp1.rB.x * normalY - ccp1.rB.y * normalX;
				float rn2A = ccp2.rA.x * normalY - ccp2.rA.y * normalX;
				float rn2B = ccp2.rB.x * normalY - ccp2.rB.y * normalX;
				
				float k11 = invMassA + invMassB + invIA * rn1A * rn1A + invIB * rn1B * rn1B;
				float k22 = invMassA + invMassB + invIA * rn2A * rn2A + invIB * rn2B * rn2B;
				float k12 = invMassA + invMassB + invIA * rn1A * rn2A + invIB * rn1B * rn2B;
				
				// Ensure a reasonable condition number.
				float k_maxConditionNumber = 100.0f;
				if ( k11 * k11 < k_maxConditionNumber * (k11 * k22 - k12 * k12))
				{
					// K is safe to invert.
					cc.K.col1.Set(k11, k12);
					cc.K.col2.Set(k12, k22);
					cc.K.GetInverse(cc.normalMass);
				}
				else
				{
					// The constraints are redundant, just use one.
					// TODO_ERIN use deepest?
					cc.pointCount = 1;
				}
			}
		}
		
		//b2Settings.b2Assert(count == m_constraintCount);
	}
	//~b2ContactSolver();

	public void InitVelocityConstraints(b2TimeStep step){
		b2Vec2 tVec;
		b2Vec2 tVec2;
		b2Mat22 tMat;
		
		// Warm start.
		for (int i = 0; i < m_constraintCount; ++i)
		{
			b2ContactConstraint c = m_constraints[ i ];
			
			b2Body bodyA = c.bodyA;
			b2Body bodyB = c.bodyB;
			float invMassA = bodyA.m_invMass;
			float invIA = bodyA.m_invI;
			float invMassB = bodyB.m_invMass;
			float invIB = bodyB.m_invI;
			//var normal:b2Vec2 = new b2Vec2(c.normal.x, c.normal.y);
			float normalX = c.normal.x;
			float normalY = c.normal.y;
			//var tangent:b2Vec2 = b2Math.b2CrossVF(normal, 1.0);
			float tangentX = normalY;
			float tangentY = -normalX;
			
			float tX;
			
			int j;
			int tCount;
			if (step.warmStarting)
			{
				tCount = c.pointCount;
				for (j = 0; j < tCount; ++j)
				{
					b2ContactConstraintPoint ccp = c.points[ j ];
					ccp.normalImpulse *= step.dtRatio;
					ccp.tangentImpulse *= step.dtRatio;
					//b2Vec2 P = ccp->normalImpulse * normal + ccp->tangentImpulse * tangent;
					float PX = ccp.normalImpulse * normalX + ccp.tangentImpulse * tangentX;
					float PY = ccp.normalImpulse * normalY + ccp.tangentImpulse * tangentY;
					
					//bodyA.m_angularVelocity -= invIA * b2Math.b2CrossVV(rA, P);
					bodyA.m_angularVelocity -= invIA * (ccp.rA.x * PY - ccp.rA.y * PX);
					//bodyA.m_linearVelocity.Subtract( b2Math.MulFV(invMassA, P) );
					bodyA.m_linearVelocity.x -= invMassA * PX;
					bodyA.m_linearVelocity.y -= invMassA * PY;
					
					//bodyB.m_angularVelocity += invIB * b2Math.b2CrossVV(rB, P);
					bodyB.m_angularVelocity += invIB * (ccp.rB.x * PY - ccp.rB.y * PX);
					//bodyB.m_linearVelocity.Add( b2Math.MulFV(invMassB, P) );
					bodyB.m_linearVelocity.x += invMassB * PX;
					bodyB.m_linearVelocity.y += invMassB * PY;
					//--------------------修改start kingBook--------------------
					if(!bodyA.m_allowMovement){
						bodyA.m_linearVelocity.x=0.0f;
						bodyA.m_linearVelocity.y=0.0f;
					}
					if(!bodyB.m_allowMovement){
						bodyB.m_linearVelocity.x=0.0f;
						bodyB.m_linearVelocity.y=0.0f;
					}
					//--------------------修改end--------------------
				}
			}
			else
			{
				tCount = c.pointCount;
				for (j = 0; j < tCount; ++j)
				{
					b2ContactConstraintPoint ccp2 = c.points[ j ];
					ccp2.normalImpulse = 0.0f;
					ccp2.tangentImpulse = 0.0f;
				}
			}
		}
	}
	public void SolveVelocityConstraints(){
		int j;
		b2ContactConstraintPoint ccp;
		float rAX;
		float rAY;
		float rBX;
		float rBY;
		float dvX;
		float dvY;
		float vn;
		float vt;
		float lambda;
		float maxFriction;
		float newImpulse;
		float PX;
		float PY;
		float dX;
		float dY;
		float P1X;
		float P1Y;
		float P2X;
		float P2Y;
		
		b2Mat22 tMat;
		b2Vec2 tVec;
		
		for (int i = 0; i < m_constraintCount; ++i)
		{
			b2ContactConstraint c = m_constraints[ i ];
			b2Body bodyA = c.bodyA;
			b2Body bodyB = c.bodyB;
			float wA = bodyA.m_angularVelocity;
			float wB = bodyB.m_angularVelocity;
			b2Vec2 vA = bodyA.m_linearVelocity;
			b2Vec2 vB = bodyB.m_linearVelocity;
			
			float invMassA = bodyA.m_invMass;
			float invIA = bodyA.m_invI;
			float invMassB = bodyB.m_invMass;
			float invIB = bodyB.m_invI;
			//var normal:b2Vec2 = new b2Vec2(c.normal.x, c.normal.y);
			float normalX = c.normal.x;
			float normalY = c.normal.y;
			//var tangent:b2Vec2 = b2Math.b2CrossVF(normal, 1.0);
			float tangentX = normalY;
			float tangentY = -normalX;
			float friction = c.friction;
			
			float tX;
			
			//b2Settings.b2Assert(c.pointCount == 1 || c.pointCount == 2);
			// Solve the tangent constraints
			for (j = 0; j < c.pointCount; j++)
			{
				ccp = c.points[j];
				
				// Relative velocity at contact
				//b2Vec2 dv = vB + b2Cross(wB, ccp->rB) - vA - b2Cross(wA, ccp->rA);
				dvX = vB.x - wB * ccp.rB.y - vA.x + wA * ccp.rA.y;
				dvY = vB.y + wB * ccp.rB.x - vA.y - wA * ccp.rA.x;
				
				// Compute tangent force
				vt = dvX * tangentX + dvY * tangentY;
				lambda = ccp.tangentMass * -vt;
				
				// b2Clamp the accumulated force
				maxFriction = friction * ccp.normalImpulse;
				newImpulse = b2Math.Clamp(ccp.tangentImpulse + lambda, -maxFriction, maxFriction);
				lambda = newImpulse-ccp.tangentImpulse;
				
				// Apply contact impulse
				PX = lambda * tangentX;
				PY = lambda * tangentY;
				
				vA.x -= invMassA * PX;
				vA.y -= invMassA * PY;
				wA -= invIA * (ccp.rA.x * PY - ccp.rA.y * PX);
				
				vB.x += invMassB * PX;
				vB.y += invMassB * PY;
				wB += invIB * (ccp.rB.x * PY - ccp.rB.y * PX);
				
				ccp.tangentImpulse = newImpulse;
			}
			
			// Solve the normal constraints
			int tCount = c.pointCount;
			if (c.pointCount == 1)
			{
				ccp = c.points[ 0 ];
				
				// Relative velocity at contact
				//b2Vec2 dv = vB + b2Cross(wB, ccp->rB) - vA - b2Cross(wA, ccp->rA);
				dvX = vB.x + (-wB * ccp.rB.y) - vA.x - (-wA * ccp.rA.y);
				dvY = vB.y + (wB * ccp.rB.x) - vA.y - (wA * ccp.rA.x);
				
				// Compute normal impulse
				//var vn:Number = b2Math.b2Dot(dv, normal);
				vn = dvX * normalX + dvY * normalY;
				lambda = -ccp.normalMass * (vn - ccp.velocityBias);
				
				// b2Clamp the accumulated impulse
				//newImpulse = b2Math.b2Max(ccp.normalImpulse + lambda, 0.0);
				newImpulse = ccp.normalImpulse + lambda;
				newImpulse = newImpulse > 0 ? newImpulse : 0.0f;
				lambda = newImpulse - ccp.normalImpulse;
				
				// Apply contact impulse
				//b2Vec2 P = lambda * normal;
				PX = lambda * normalX;
				PY = lambda * normalY;
				
				//vA.Subtract( b2Math.MulFV( invMassA, P ) );
				vA.x -= invMassA * PX;
				vA.y -= invMassA * PY;
				wA -= invIA * (ccp.rA.x * PY - ccp.rA.y * PX);//invIA * b2Math.b2CrossVV(ccp.rA, P);
				
				//vB.Add( b2Math.MulFV( invMass2, P ) );
				vB.x += invMassB * PX;
				vB.y += invMassB * PY;
				wB += invIB * (ccp.rB.x * PY - ccp.rB.y * PX);//invIB * b2Math.b2CrossVV(ccp.rB, P);
				
				ccp.normalImpulse = newImpulse;
			}
			else
			{
				// Block solver developed in collaboration with Dirk Gregorius (back in 01/07 on Box2D_Lite).
				// Build the mini LCP for this contact patch
				//
				// vn = A * x + b, vn >= 0, , vn >= 0, x >= 0 and vn_i * x_i = 0 with i = 1..2
				//
				// A = J * W * JT and J = ( -n, -r1 x n, n, r2 x n )
				// b = vn_0 - velocityBias
				//
				// The system is solved using the "Total enumeration method" (s. Murty). The complementary constraint vn_i * x_i
				// implies that we must have in any solution either vn_i = 0 or x_i = 0. So for the 2D contact problem the cases
				// vn1 = 0 and vn2 = 0, x1 = 0 and x2 = 0, x1 = 0 and vn2 = 0, x2 = 0 and vn1 = 0 need to be tested. The first valid
				// solution that satisfies the problem is chosen.
				//
				// In order to account of the accumulated impulse 'a' (because of the iterative nature of the solver which only requires
				// that the accumulated impulse is clamped and not the incremental impulse) we change the impulse variable (x_i).
				//
				// Substitute:
				//
				// x = x' - a
				//
				// Plug into above equation:
				//
				// vn = A * x + b
				//    = A * (x' - a) + b
				//    = A * x' + b - A * a
				//    = A * x' + b'
				// b' = b - A * a;
				
				b2ContactConstraintPoint cp1 = c.points[ 0 ];
				b2ContactConstraintPoint cp2 = c.points[ 1 ];
				
				float aX = cp1.normalImpulse;
				float aY = cp2.normalImpulse;
				//b2Settings.b2Assert( aX >= 0.0f && aY >= 0.0f );
				
				// Relative velocity at contact
				//var dv1:b2Vec2 = vB + b2Cross(wB, cp1.rB) - vA - b2Cross(wA, cp1.rA);
				float dv1X = vB.x - wB * cp1.rB.y - vA.x + wA * cp1.rA.y;
				float dv1Y = vB.y + wB * cp1.rB.x - vA.y - wA * cp1.rA.x;
				//var dv2:b2Vec2 = vB + b2Cross(wB, cpB.r2) - vA - b2Cross(wA, cp2.rA);
				float dv2X = vB.x - wB * cp2.rB.y - vA.x + wA * cp2.rA.y;
				float dv2Y = vB.y + wB * cp2.rB.x - vA.y - wA * cp2.rA.x;
				
				// Compute normal velocity
				//var vn1:Number = b2Dot(dv1, normal);
				float vn1 = dv1X * normalX + dv1Y * normalY;
				//var vn2:Number = b2Dot(dv2, normal);
				float vn2 = dv2X * normalX + dv2Y * normalY;
				
				float bX = vn1 - cp1.velocityBias;
				float bY = vn2 - cp2.velocityBias;
				
				//b -= b2Mul(c.K,a);
				tMat = c.K;
				bX -= tMat.col1.x * aX + tMat.col2.x * aY;
				bY -= tMat.col1.y * aX + tMat.col2.y * aY;
				
				float k_errorTol  = 0.001f;
				while(true)
				{
					//
					// Case 1: vn = 0
					//
					// 0 = A * x' + b'
					//
					// Solve for x':
					//
					// x' = -inv(A) * b'
					//
					
					//var x:b2Vec2 = - b2Mul(c->normalMass, b);
					tMat = c.normalMass;
					float xX = - (tMat.col1.x * bX + tMat.col2.x * bY);
					float xY = - (tMat.col1.y * bX + tMat.col2.y * bY);
					
					if (xX >= 0.0f && xY >= 0.0f) {
						// Resubstitute for the incremental impulse
						//d = x - a;
						dX = xX - aX;
						dY = xY - aY;
						
						//Aply incremental impulse
						//P1 = d.x * normal;
						P1X = dX * normalX;
						P1Y = dX * normalY;
						//P2 = d.y * normal;
						P2X = dY * normalX;
						P2Y = dY * normalY;
						
						//vA -= invMass1 * (P1 + P2)
						vA.x -= invMassA * (P1X + P2X);
						vA.y -= invMassA * (P1Y + P2Y);
						//wA -= invIA * (b2Cross(cp1.rA, P1) + b2Cross(cp2.rA, P2));
						wA -= invIA * ( cp1.rA.x * P1Y - cp1.rA.y * P1X + cp2.rA.x * P2Y - cp2.rA.y * P2X);
						
						//vB += invMassB * (P1 + P2)
						vB.x += invMassB * (P1X + P2X);
						vB.y += invMassB * (P1Y + P2Y);
						//wB += invIB * (b2Cross(cp1.rB, P1) + b2Cross(cp2.rB, P2));
						wB   += invIB * ( cp1.rB.x * P1Y - cp1.rB.y * P1X + cp2.rB.x * P2Y - cp2.rB.y * P2X);
						
						// Accumulate
						cp1.normalImpulse = xX;
						cp2.normalImpulse = xY;
						
	//#if B2_DEBUG_SOLVER == 1
	//					// Post conditions
	//					//dv1 = vB + b2Cross(wB, cp1.rB) - vA - b2Cross(wA, cp1.rA);
	//					dv1X = vB.x - wB * cp1.rB.y - vA.x + wA * cp1.rA.y;
	//					dv1Y = vB.y + wB * cp1.rB.x - vA.y - wA * cp1.rA.x;
	//					//dv2 = vB + b2Cross(wB, cp2.rB) - vA - b2Cross(wA, cp2.rA);
	//					dv1X = vB.x - wB * cp2.rB.y - vA.x + wA * cp2.rA.y;
	//					dv1Y = vB.y + wB * cp2.rB.x - vA.y - wA * cp2.rA.x;
	//					// Compute normal velocity
	//					//vn1 = b2Dot(dv1, normal);
	//					vn1 = dv1X * normalX + dv1Y * normalY;
	//					//vn2 = b2Dot(dv2, normal);
	//					vn2 = dv2X * normalX + dv2Y * normalY;
	//
	//					//b2Settings.b2Assert(b2Abs(vn1 - cp1.velocityBias) < k_errorTol);
	//					//b2Settings.b2Assert(b2Abs(vn2 - cp2.velocityBias) < k_errorTol);
	//#endif
						break;
					}
					
					//
					// Case 2: vn1 = 0  and x2 = 0
					//
					//   0 = a11 * x1' + a12 * 0 + b1'
					// vn2 = a21 * x1' + a22 * 0 + b2'
					//
					
					xX = - cp1.normalMass * bX;
					xY = 0.0f;
					vn1 = 0.0f;
					vn2 = c.K.col1.y * xX + bY;
					
					if (xX >= 0.0f && vn2 >= 0.0f)
					{
						// Resubstitute for the incremental impulse
						//d = x - a;
						dX = xX - aX;
						dY = xY - aY;
						
						//Aply incremental impulse
						//P1 = d.x * normal;
						P1X = dX * normalX;
						P1Y = dX * normalY;
						//P2 = d.y * normal;
						P2X = dY * normalX;
						P2Y = dY * normalY;
						
						//vA -= invMassA * (P1 + P2)
						vA.x -= invMassA * (P1X + P2X);
						vA.y -= invMassA * (P1Y + P2Y);
						//wA -= invIA * (b2Cross(cp1.rA, P1) + b2Cross(cp2.rA, P2));
						wA -= invIA * ( cp1.rA.x * P1Y - cp1.rA.y * P1X + cp2.rA.x * P2Y - cp2.rA.y * P2X);
						
						//vB += invMassB * (P1 + P2)
						vB.x += invMassB * (P1X + P2X);
						vB.y += invMassB * (P1Y + P2Y);
						//wB += invIB * (b2Cross(cp1.rB, P1) + b2Cross(cp2.rB, P2));
						wB   += invIB * ( cp1.rB.x * P1Y - cp1.rB.y * P1X + cp2.rB.x * P2Y - cp2.rB.y * P2X);
						
						// Accumulate
						cp1.normalImpulse = xX;
						cp2.normalImpulse = xY;
						
	//#if B2_DEBUG_SOLVER == 1
	//					// Post conditions
	//					//dv1 = vB + b2Cross(wB, cp1.rB) - vA - b2Cross(wA, cp1.rA);
	//					dv1X = vB.x - wB * cp1.rB.y - vA.x + wA * cp1.rA.y;
	//					dv1Y = vB.y + wB * cp1.rB.x - vA.y - wA * cp1.rA.x;
	//					//dv2 = vB + b2Cross(wB, cp2.rB) - vA - b2Cross(wA, cp2.rA);
	//					dv1X = vB.x - wB * cp2.rB.y - vA.x + wA * cp2.rA.y;
	//					dv1Y = vB.y + wB * cp2.rB.x - vA.y - wA * cp2.rA.x;
	//					// Compute normal velocity
	//					//vn1 = b2Dot(dv1, normal);
	//					vn1 = dv1X * normalX + dv1Y * normalY;
	//					//vn2 = b2Dot(dv2, normal);
	//					vn2 = dv2X * normalX + dv2Y * normalY;
	//
	//					//b2Settings.b2Assert(b2Abs(vn1 - cp1.velocityBias) < k_errorTol);
	//					//b2Settings.b2Assert(b2Abs(vn2 - cp2.velocityBias) < k_errorTol);
	//#endif
						break;
					}
					
					//
					// Case 3: wB = 0 and x1 = 0
					//
					// vn1 = a11 * 0 + a12 * x2' + b1'
					//   0 = a21 * 0 + a22 * x2' + b2'
					//
					
					xX = 0.0f;
					xY = -cp2.normalMass * bY;
					vn1 = c.K.col2.x * xY + bX;
					vn2 = 0.0f;
					if (xY >= 0.0f && vn1 >= 0.0f)
					{
						// Resubstitute for the incremental impulse
						//d = x - a;
						dX = xX - aX;
						dY = xY - aY;
						
						//Aply incremental impulse
						//P1 = d.x * normal;
						P1X = dX * normalX;
						P1Y = dX * normalY;
						//P2 = d.y * normal;
						P2X = dY * normalX;
						P2Y = dY * normalY;
						
						//vA -= invMassA * (P1 + P2)
						vA.x -= invMassA * (P1X + P2X);
						vA.y -= invMassA * (P1Y + P2Y);
						//wA -= invIA * (b2Cross(cp1.rA, P1) + b2Cross(cp2.rA, P2));
						wA -= invIA * ( cp1.rA.x * P1Y - cp1.rA.y * P1X + cp2.rA.x * P2Y - cp2.rA.y * P2X);
						
						//vB += invMassB * (P1 + P2)
						vB.x += invMassB * (P1X + P2X);
						vB.y += invMassB * (P1Y + P2Y);
						//wB += invIB * (b2Cross(cp1.rB, P1) + b2Cross(cp2.rB, P2));
						wB   += invIB * ( cp1.rB.x * P1Y - cp1.rB.y * P1X + cp2.rB.x * P2Y - cp2.rB.y * P2X);
						
						// Accumulate
						cp1.normalImpulse = xX;
						cp2.normalImpulse = xY;
						
	//#if B2_DEBUG_SOLVER == 1
	//					// Post conditions
	//					//dv1 = vB + b2Cross(wB, cp1.rB) - vA - b2Cross(wA, cp1.rA);
	//					dv1X = vB.x - wB * cp1.rB.y - vA.x + wA * cp1.rA.y;
	//					dv1Y = vB.y + wB * cp1.rB.x - vA.y - wA * cp1.rA.x;
	//					//dv2 = vB + b2Cross(wB, cp2.rB) - vA - b2Cross(wA, cp2.rA);
	//					dv1X = vB.x - wB * cp2.rB.y - vA.x + wA * cp2.rA.y;
	//					dv1Y = vB.y + wB * cp2.rB.x - vA.y - wA * cp2.rA.x;
	//					// Compute normal velocity
	//					//vn1 = b2Dot(dv1, normal);
	//					vn1 = dv1X * normalX + dv1Y * normalY;
	//					//vn2 = b2Dot(dv2, normal);
	//					vn2 = dv2X * normalX + dv2Y * normalY;
	//
	//					//b2Settings.b2Assert(b2Abs(vn1 - cp1.velocityBias) < k_errorTol);
	//					//b2Settings.b2Assert(b2Abs(vn2 - cp2.velocityBias) < k_errorTol);
	//#endif
						break;
					}
					
					//
					// Case 4: x1 = 0 and x2 = 0
					//
					// vn1 = b1
					// vn2 = b2
					
					xX = 0.0f;
					xY = 0.0f;
					vn1 = bX;
					vn2 = bY;
					
					if (vn1 >= 0.0f && vn2 >= 0.0f ) {
						// Resubstitute for the incremental impulse
						//d = x - a;
						dX = xX - aX;
						dY = xY - aY;
						
						//Aply incremental impulse
						//P1 = d.x * normal;
						P1X = dX * normalX;
						P1Y = dX * normalY;
						//P2 = d.y * normal;
						P2X = dY * normalX;
						P2Y = dY * normalY;
						
						//vA -= invMassA * (P1 + P2)
						vA.x -= invMassA * (P1X + P2X);
						vA.y -= invMassA * (P1Y + P2Y);
						//wA -= invIA * (b2Cross(cp1.rA, P1) + b2Cross(cp2.rA, P2));
						wA -= invIA * ( cp1.rA.x * P1Y - cp1.rA.y * P1X + cp2.rA.x * P2Y - cp2.rA.y * P2X);
						
						//vB += invMassB * (P1 + P2)
						vB.x += invMassB * (P1X + P2X);
						vB.y += invMassB * (P1Y + P2Y);
						//wB += invIB * (b2Cross(cp1.rB, P1) + b2Cross(cp2.rB, P2));
						wB   += invIB * ( cp1.rB.x * P1Y - cp1.rB.y * P1X + cp2.rB.x * P2Y - cp2.rB.y * P2X);
						
						// Accumulate
						cp1.normalImpulse = xX;
						cp2.normalImpulse = xY;
						
	//#if B2_DEBUG_SOLVER == 1
	//					// Post conditions
	//					//dv1 = vB + b2Cross(wB, cp1.rB) - vA - b2Cross(wA, cp1.rA);
	//					dv1X = vB.x - wB * cp1.rB.y - vA.x + wA * cp1.rA.y;
	//					dv1Y = vB.y + wB * cp1.rB.x - vA.y - wA * cp1.rA.x;
	//					//dv2 = vB + b2Cross(wB, cp2.rB) - vA - b2Cross(wA, cp2.rA);
	//					dv1X = vB.x - wB * cp2.rB.y - vA.x + wA * cp2.rA.y;
	//					dv1Y = vB.y + wB * cp2.rB.x - vA.y - wA * cp2.rA.x;
	//					// Compute normal velocity
	//					//vn1 = b2Dot(dv1, normal);
	//					vn1 = dv1X * normalX + dv1Y * normalY;
	//					//vn2 = b2Dot(dv2, normal);
	//					vn2 = dv2X * normalX + dv2Y * normalY;
	//
	//					//b2Settings.b2Assert(b2Abs(vn1 - cp1.velocityBias) < k_errorTol);
	//					//b2Settings.b2Assert(b2Abs(vn2 - cp2.velocityBias) < k_errorTol);
	//#endif
						break;
					}
					
					// No solution, give up. This is hit sometimes, but it doesn't seem to matter.
					break;
				}
			}
			
			
			// b2Vec2s in AS3 are copied by reference. The originals are 
			// references to the same things here and there is no need to 
			// copy them back, unlike in C++ land where b2Vec2s are 
			// copied by value.
			/*bodyA->m_linearVelocity = vA;
			bodyB->m_linearVelocity = vB;*/
			bodyA.m_angularVelocity = wA;
			bodyB.m_angularVelocity = wB;
			//--------------------修改start kingBook--------------------
			if(!bodyA.m_allowMovement){
				bodyA.m_linearVelocity.x=0.0f;
				bodyA.m_linearVelocity.y=0.0f;
			}
			if(!bodyB.m_allowMovement){
				bodyB.m_linearVelocity.x=0.0f;
				bodyB.m_linearVelocity.y=0.0f;
			}
			//--------------------修改end--------------------
		}
	}
	
	public void FinalizeVelocityConstraints()
	{
		for (int i = 0; i < m_constraintCount; ++i)
		{
			b2ContactConstraint c = m_constraints[ i ];
			b2Manifold m = c.manifold;
			
			for (int j = 0; j < c.pointCount; ++j)
			{
				b2ManifoldPoint point1 = m.m_points[j];
				b2ContactConstraintPoint point2 = c.points[j];
				point1.m_normalImpulse = point2.normalImpulse;
				point1.m_tangentImpulse = point2.tangentImpulse;
			}
		}
	}
	
//#if 1
// Sequential solver
//	public function SolvePositionConstraints(baumgarte:Number):Boolean{
//		var minSeparation:Number = 0.0;
//		
//		var tMat:b2Mat22;
//		var tVec:b2Vec2;
//		
//		for (var i:int = 0; i < m_constraintCount; ++i)
//		{
//			var c:b2ContactConstraint = m_constraints[ i ];
//			var bodyA:b2Body = c.bodyA;
//			var bodyB:b2Body = c.bodyB;
//			var bA_sweep_c:b2Vec2 = bodyA.m_sweep.c;
//			var bA_sweep_a:Number = bodyA.m_sweep.a;
//			var bB_sweep_c:b2Vec2 = bodyB.m_sweep.c;
//			var bB_sweep_a:Number = bodyB.m_sweep.a;
//			
//			var invMassa:Number = bodyA.m_mass * bodyA.m_invMass;
//			var invIa:Number = bodyA.m_mass * bodyA.m_invI;
//			var invMassb:Number = bodyB.m_mass * bodyB.m_invMass;
//			var invIb:Number = bodyB.m_mass * bodyB.m_invI;
//			//var normal:b2Vec2 = new b2Vec2(c.normal.x, c.normal.y);
//			var normalX:Number = c.normal.x;
//			var normalY:Number = c.normal.y;
//			
//			// Solver normal constraints
//			var tCount:int = c.pointCount;
//			for (var j:int = 0; j < tCount; ++j)
//			{
//				var ccp:b2ContactConstraintPoint = c.points[ j ];
//				
//				//r1 = b2Mul(bodyA->m_xf.R, ccp->localAnchor1 - bodyA->GetLocalCenter());
//				tMat = bodyA.m_xf.R;
//				tVec = bodyA.m_sweep.localCenter;
//				var r1X:Number = ccp.localAnchor1.x - tVec.x;
//				var r1Y:Number = ccp.localAnchor1.y - tVec.y;
//				tX =  (tMat.col1.x * r1X + tMat.col2.x * r1Y);
//				r1Y = (tMat.col1.y * r1X + tMat.col2.y * r1Y);
//				r1X = tX;
//				
//				//r2 = b2Mul(bodyB->m_xf.R, ccp->localAnchor2 - bodyB->GetLocalCenter());
//				tMat = bodyB.m_xf.R;
//				tVec = bodyB.m_sweep.localCenter;
//				var r2X:Number = ccp.localAnchor2.x - tVec.x;
//				var r2Y:Number = ccp.localAnchor2.y - tVec.y;
//				var tX:Number =  (tMat.col1.x * r2X + tMat.col2.x * r2Y);
//				r2Y = 			 (tMat.col1.y * r2X + tMat.col2.y * r2Y);
//				r2X = tX;
//				
//				//b2Vec2 p1 = bodyA->m_sweep.c + r1;
//				var p1X:Number = b1_sweep_c.x + r1X;
//				var p1Y:Number = b1_sweep_c.y + r1Y;
//				
//				//b2Vec2 p2 = bodyB->m_sweep.c + r2;
//				var p2X:Number = b2_sweep_c.x + r2X;
//				var p2Y:Number = b2_sweep_c.y + r2Y;
//				
//				//var dp:b2Vec2 = b2Math.SubtractVV(p2, p1);
//				var dpX:Number = p2X - p1X;
//				var dpY:Number = p2Y - p1Y;
//				
//				// Approximate the current separation.
//				//var separation:Number = b2Math.b2Dot(dp, normal) + ccp.separation;
//				var separation:Number = (dpX*normalX + dpY*normalY) + ccp.separation;
//				
//				// Track max constraint error.
//				minSeparation = b2Math.b2Min(minSeparation, separation);
//				
//				// Prevent large corrections and allow slop.
//				var C:Number =  b2Math.b2Clamp(baumgarte * (separation + b2Settings.b2_linearSlop), -b2Settings.b2_maxLinearCorrection, 0.0);
//				
//				// Compute normal impulse
//				var dImpulse:Number = -ccp.equalizedMass * C;
//				
//				//var P:b2Vec2 = b2Math.MulFV( dImpulse, normal );
//				var PX:Number = dImpulse * normalX;
//				var PY:Number = dImpulse * normalY;
//				
//				//bodyA.m_position.Subtract( b2Math.MulFV( invMass1, impulse ) );
//				b1_sweep_c.x -= invMass1 * PX;
//				b1_sweep_c.y -= invMass1 * PY;
//				b1_sweep_a -= invI1 * (r1X * PY - r1Y * PX);//b2Math.b2CrossVV(r1, P);
//				bodyA.m_sweep.a = b1_sweep_a;
//				bodyA.SynchronizeTransform();
//				
//				//bodyB.m_position.Add( b2Math.MulFV( invMass2, P ) );
//				b2_sweep_c.x += invMass2 * PX;
//				b2_sweep_c.y += invMass2 * PY;
//				b2_sweep_a += invI2 * (r2X * PY - r2Y * PX);//b2Math.b2CrossVV(r2, P);
//				bodyB.m_sweep.a = b2_sweep_a;
//				bodyB.SynchronizeTransform();
//			}
//			// Update body rotations
//			//bodyA.m_sweep.a = b1_sweep_a;
//			//bodyB.m_sweep.a = b2_sweep_a;
//		}
//		
//		// We can't expect minSpeparation >= -b2_linearSlop because we don't
//		// push the separation above -b2_linearSlop.
//		return minSeparation >= -1.5 * b2Settings.b2_linearSlop;
//	}
//#else
	// Sequential solver.
	private static b2PositionSolverManifold s_psm = new b2PositionSolverManifold();
	public bool SolvePositionConstraints(float baumgarte)
	{
		float minSeparation = 0.0f;
		
		for (int i = 0; i < m_constraintCount; i++)
		{
			b2ContactConstraint c = m_constraints[i];
			b2Body bodyA = c.bodyA;
			b2Body bodyB = c.bodyB;
			
			float invMassA = bodyA.m_mass * bodyA.m_invMass;
			float invIA = bodyA.m_mass * bodyA.m_invI;
			float invMassB = bodyB.m_mass * bodyB.m_invMass;
			float invIB = bodyB.m_mass * bodyB.m_invI;
			
			
			s_psm.Initialize(c);
			b2Vec2 normal = s_psm.m_normal;
			
			// Solve normal constraints
			for (int j = 0; j < c.pointCount; j++)
			{
				b2ContactConstraintPoint ccp = c.points[j];
				
				b2Vec2 point = s_psm.m_points[j];
				float separation = s_psm.m_separations[j];
				
				float rAX = point.x - bodyA.m_sweep.c.x;
				float rAY = point.y - bodyA.m_sweep.c.y;
				float rBX = point.x - bodyB.m_sweep.c.x;
				float rBY = point.y - bodyB.m_sweep.c.y;
				
				// Track max constraint error.
				minSeparation = minSeparation < separation?minSeparation:separation;
				
				// Prevent large corrections and allow slop.
				float C = b2Math.Clamp(baumgarte * (separation + b2Settings.b2_linearSlop), -b2Settings.b2_maxLinearCorrection, 0.0f);
				
				// Compute normal impulse
				float impulse = -ccp.equalizedMass * C;
				
				float PX = impulse * normal.x;
				float PY = impulse * normal.y;
				
				//bodyA.m_sweep.c -= invMassA * P;
				if(bodyA.m_allowMovement){
					bodyA.m_sweep.c.x -= invMassA * PX;
					bodyA.m_sweep.c.y -= invMassA * PY;
				}
				//bodyA.m_sweep.a -= invIA * b2Cross(rA, P);
				bodyA.m_sweep.a -= invIA * (rAX * PY - rAY * PX);
				bodyA.SynchronizeTransform();
				
				//bodyB.m_sweep.c += invMassB * P;
				
				//--------------------修改start kingBook------------
				if(bodyB.m_allowMovement){
					bodyB.m_sweep.c.x += invMassB * PX;
					bodyB.m_sweep.c.y += invMassB * PY;
				}
				//--------------------修改end kingBook------------
				
				//bodyB.m_sweep.a += invIB * b2Cross(rB, P);
				bodyB.m_sweep.a += invIB * (rBX * PY - rBY * PX);
				bodyB.SynchronizeTransform();
			}
		}
		
		// We can't expect minSpeparation >= -b2_linearSlop because we don't
		// push the separation above -b2_linearSlop.
		return minSeparation > -1.5f * b2Settings.b2_linearSlop;
	}
	
//#endif
	private b2TimeStep m_step = new b2TimeStep();
	private object m_allocator;
	public List<b2ContactConstraint> m_constraints = new List<b2ContactConstraint> ();
	private int m_constraintCount;
}

}