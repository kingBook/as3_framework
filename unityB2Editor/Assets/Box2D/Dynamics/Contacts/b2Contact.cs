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

namespace Box2D.Dynamics.Contacts{


//typedef b2Contact* b2ContactCreateFcn(b2Shape* shape1, b2Shape* shape2, b2BlockAllocator* allocator);
//typedef void b2ContactDestroyFcn(b2Contact* contact, b2BlockAllocator* allocator);



/**
* The class manages contact between two shapes. A contact exists for each overlapping
* AABB in the broad-phase (except if filtered). Therefore a contact object may exist
* that has no contact points.
*/
public class b2Contact
{
	/**
	 * Get the contact manifold. Do not modify the manifold unless you understand the
	 * internals of Box2D
	 */
	public b2Manifold GetManifold()
	{
		return m_manifold;
	}
	
	/**
	 * Get the world manifold
	 */
	public void GetWorldManifold(b2WorldManifold worldManifold)
	{
		b2Body bodyA = m_fixtureA.GetBody();
		b2Body bodyB = m_fixtureB.GetBody();
		b2Shape shapeA = m_fixtureA.GetShape();
		b2Shape shapeB = m_fixtureB.GetShape();
		
		worldManifold.Initialize(m_manifold, bodyA.GetTransform(), shapeA.m_radius, bodyB.GetTransform(), shapeB.m_radius);
	}
	
	/**
	 * Is this contact touching.
	 */
	public bool IsTouching()
	{
		return (m_flags & e_touchingFlag) == e_touchingFlag; 
	}
	
	/**
	 * Does this contact generate TOI events for continuous simulation
	 */
	public bool IsContinuous()
	{
		return (m_flags & e_continuousFlag) == e_continuousFlag; 
	}
	
	/**
	 * Change this to be a sensor or-non-sensor contact.
	 */
		public void SetSensor(bool sensor){
		if (sensor)
		{
			m_flags |= e_sensorFlag;
		}
		else
		{
			m_flags &= ~e_sensorFlag;
		}
	}
	
	/**
	 * Is this contact a sensor?
	 */
	public bool IsSensor(){
		return (m_flags & e_sensorFlag) == e_sensorFlag;
	}
	
	/**
	 * Enable/disable this contact. This can be used inside the pre-solve
	 * contact listener. The contact is only disabled for the current
	 * time step (or sub-step in continuous collision).
	 */
	public void SetEnabled(bool flag){
		if (flag)
		{
			m_flags |= e_enabledFlag;
		}
		else
		{
			m_flags &= ~e_enabledFlag;
		}
	}
	
	/**
	 * Has this contact been disabled?
	 * @return
	 */
	public bool IsEnabled() {
		return (m_flags & e_enabledFlag) == e_enabledFlag;
	}
	
	/**
	* Get the next contact in the world's contact list.
	*/
	public b2Contact GetNext(){
		return m_next;
	}
	
	/**
	* Get the first fixture in this contact.
	*/
	public b2Fixture GetFixtureA()
	{
		return m_fixtureA;
	}
	
	/**
	* Get the second fixture in this contact.
	*/
	public b2Fixture GetFixtureB()
	{
		return m_fixtureB;
	}
	
	/**
	 * Flag this contact for filtering. Filtering will occur the next time step.
	 */
	public void FlagForFiltering()
	{
		m_flags |= e_filterFlag;
	}

	//--------------- Internals Below -------------------
	
	// m_flags
	// enum
	// This contact should not participate in Solve
	// The contact equivalent of sensors
	static public uint e_sensorFlag		= 0x0001;
	// Generate TOI events.
	static public uint e_continuousFlag	= 0x0002;
	// Used when crawling contact graph when forming islands.
	static public uint e_islandFlag		= 0x0004;
	// Used in SolveTOI to indicate the cached toi value is still valid.
	static public uint e_toiFlag		= 0x0008;
	// Set when shapes are touching
	static public uint e_touchingFlag	= 0x0010;
	// This contact can be disabled (by user)
	static public uint e_enabledFlag	= 0x0020;
	// This contact needs filtering because a fixture filter was changed.
	static public uint e_filterFlag		= 0x0040;

	public b2Contact()
	{
		// Real work is done in Reset
	}
	
	/** @private */
	virtual public void Reset(b2Fixture fixtureA = null, b2Fixture fixtureB = null)
	{
		m_flags = e_enabledFlag;
		
		if (fixtureA==null || fixtureB==null){
			m_fixtureA = null;
			m_fixtureB = null;
			return;
		}
		
		if (fixtureA.IsSensor() || fixtureB.IsSensor())
		{
			m_flags |= e_sensorFlag;
		}
		
		b2Body bodyA = fixtureA.GetBody();
		b2Body bodyB = fixtureB.GetBody();
		
		if (bodyA.GetType() != b2Body.b2_dynamicBody || bodyA.IsBullet() || bodyB.GetType() != b2Body.b2_dynamicBody || bodyB.IsBullet())
		{
			m_flags |= e_continuousFlag;
		}
		
		m_fixtureA = fixtureA;
		m_fixtureB = fixtureB;
		
		m_manifold.m_pointCount = 0;
		
		m_prev = null;
		m_next = null;
		
		m_nodeA.contact = null;
		m_nodeA.prev = null;
		m_nodeA.next = null;
		m_nodeA.other = null;
		
		m_nodeB.contact = null;
		m_nodeB.prev = null;
		m_nodeB.next = null;
		m_nodeB.other = null;
	}
	
	public void Update(b2ContactListener listener)
	{
		// Swap old & new manifold
		b2Manifold tManifold = m_oldManifold;
		m_oldManifold = m_manifold;
		m_manifold = tManifold;
		
		// Re-enable this contact
		m_flags |= e_enabledFlag;
		
		bool touching = false;
		bool wasTouching = (m_flags & e_touchingFlag) == e_touchingFlag;
		
		b2Body bodyA = m_fixtureA.m_body;
		b2Body bodyB = m_fixtureB.m_body;
		
		bool aabbOverlap = m_fixtureA.m_aabb.TestOverlap(m_fixtureB.m_aabb);
		
		// Is this contat a sensor?
		if ((m_flags  & e_sensorFlag)>0)
		{
			if (aabbOverlap)
			{
				b2Shape shapeA = m_fixtureA.GetShape();
				b2Shape shapeB = m_fixtureB.GetShape();
				b2Transform xfA = bodyA.GetTransform();
				b2Transform xfB = bodyB.GetTransform();
				touching = b2Shape.TestOverlap(shapeA, xfA, shapeB, xfB);
			}
			
			// Sensors don't generate manifolds
			m_manifold.m_pointCount = 0;
		}
		else
		{
			// Slow contacts don't generate TOI events.
			if (bodyA.GetType() != b2Body.b2_dynamicBody || bodyA.IsBullet() || bodyB.GetType() != b2Body.b2_dynamicBody || bodyB.IsBullet())
			{
				m_flags |= e_continuousFlag;
			}
			else
			{
				m_flags &= ~e_continuousFlag;
			}
			
			if (aabbOverlap)
			{
				Evaluate();
				
				touching = m_manifold.m_pointCount > 0;
				
				// Match old contact ids to new contact ids and copy the
				// stored impulses to warm start the solver.
				for (int i = 0; i < m_manifold.m_pointCount; ++i)
				{
					b2ManifoldPoint mp2 = m_manifold.m_points[i];
					mp2.m_normalImpulse = 0.0f;
					mp2.m_tangentImpulse = 0.0f;
					b2ContactID id2 = mp2.m_id;

					for (int j = 0; j < m_oldManifold.m_pointCount; ++j)
					{
						b2ManifoldPoint mp1 = m_oldManifold.m_points[j];

						if (mp1.m_id.key == id2.key)
						{
							mp2.m_normalImpulse = mp1.m_normalImpulse;
							mp2.m_tangentImpulse = mp1.m_tangentImpulse;
							break;
						}
					}
				}

			}
			else
			{
				m_manifold.m_pointCount = 0;
			}
			if (touching != wasTouching)
			{
				bodyA.SetAwake(true);
				bodyB.SetAwake(true);
			}
		}
				
		if (touching)
		{
			m_flags |= e_touchingFlag;
		}
		else
		{
			m_flags &= ~e_touchingFlag;
		}

		if (wasTouching == false && touching == true)
		{
			listener.BeginContact(this);
		}

		if (wasTouching == true && touching == false)
		{
			listener.EndContact(this);
		}

		if ((m_flags & e_sensorFlag) == 0)
		{
			listener.PreSolve(this, m_oldManifold);
		}
	}

	//virtual ~b2Contact() {}

	virtual public void Evaluate(){}
	
	private static b2TOIInput s_input = new b2TOIInput();
	public float ComputeTOI(b2Sweep sweepA, b2Sweep sweepB)
	{
		s_input.proxyA.Set(m_fixtureA.GetShape());
		s_input.proxyB.Set(m_fixtureB.GetShape());
		s_input.sweepA = sweepA;
		s_input.sweepB = sweepB;
		s_input.tolerance = b2Settings.b2_linearSlop;
		return b2TimeOfImpact.TimeOfImpact(s_input);
	}
	
	public uint m_flags;

	// World pool and list pointers.
	public b2Contact m_prev;
	public b2Contact m_next;

	// Nodes for connecting bodies.
	public b2ContactEdge m_nodeA = new b2ContactEdge();
	public b2ContactEdge m_nodeB = new b2ContactEdge();

	public b2Fixture m_fixtureA;
	public b2Fixture m_fixtureB;

	public b2Manifold m_manifold = new b2Manifold();
	public b2Manifold m_oldManifold = new b2Manifold();
	
	public float m_toi;
}


}
