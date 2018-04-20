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
using Box2D.Collision;
using Box2D.Collision.Shapes;
using Box2D.Common.Math;
using Box2D.Common;
using Box2D.Dynamics.Contacts;

namespace Box2D.Dynamics{


/**
 * 定制器
 * A fixture is used to attach a shape to a body for collision detection. A fixture
 * inherits its transform from its parent. Fixtures hold additional non-geometric data
 * such as friction, collision filters, etc.
 * Fixtures are created via b2Body::CreateFixture.
 * @warning you cannot reuse fixtures.
 */
public class b2Fixture
{
	/**
	 * Get the type of the child shape. You can use this to down cast to the concrete shape.
	 * @return the shape type.
	 */
	public int GetType()
	{
		return m_shape.GetType();
	}
	
	/**
	 * Get the child shape. You can modify the child shape, however you should not change the
	 * number of vertices because this will crash some collision caching mechanisms.
	 */
	public b2Shape GetShape()
	{
		return m_shape;
	}
	
	/**
	 * Set if this fixture is a sensor.
	 */
	public void SetSensor(bool sensor)
	{
		if ( m_isSensor == sensor)
			return;
			
		m_isSensor = sensor;
		
		if (m_body == null)
			return;
			
		b2ContactEdge edge = m_body.GetContactList();
		while (edge!=null)
		{
			b2Contact contact = edge.contact;
			b2Fixture fixtureA = contact.GetFixtureA();
			b2Fixture fixtureB = contact.GetFixtureB();
			if (fixtureA == this || fixtureB == this)
				contact.SetSensor(fixtureA.IsSensor() || fixtureB.IsSensor());
			edge = edge.next;
		}
		
	}
	
	/**
	 * Is this fixture a sensor (non-solid)?
	 * @return the true if the shape is a sensor.
	 */
	public bool IsSensor()
	{
		return m_isSensor;
	}
	
	/**
	 * Set the contact filtering data. This will not update contacts until the next time
	 * step when either parent body is active and awake.
	 */
	public void SetFilterData(b2FilterData filter)
	{
		m_filter = filter.Copy();
		
		if (m_body!=null)
			return;
			
		b2ContactEdge edge = m_body.GetContactList();
		while (edge!=null)
		{
			b2Contact contact = edge.contact;
			b2Fixture fixtureA = contact.GetFixtureA();
			b2Fixture fixtureB = contact.GetFixtureB();
			if (fixtureA == this || fixtureB == this)
				contact.FlagForFiltering();
			edge = edge.next;
		}
	}
	
	/**
	 * Get the contact filtering data.
	 */
	public b2FilterData GetFilterData()
	{
		return m_filter.Copy();
	}
	
	/**
	 * Get the parent body of this fixture. This is NULL if the fixture is not attached.
	 * @return the parent body.
	 */
	public b2Body GetBody()
	{
		return m_body;
	}
	
	/**
	 * Get the next fixture in the parent body's fixture list.
	 * @return the next shape.
	 */
	public b2Fixture GetNext()
	{
		return m_next;
	}
	
	/**
	 * Get the user data that was assigned in the fixture definition. Use this to
	 * store your application specific data.
	 */
	public object GetUserData()
	{
		return m_userData;
	}
	
	/**
	 * Set the user data. Use this to store your application specific data.
	 */
	public void SetUserData(object data)
	{
		m_userData = data;
	}
	
	/**
	 * Test a point for containment in this fixture.
	 * @param xf the shape world transform.
	 * @param p a point in world coordinates.
	 */
	public bool TestPoint(b2Vec2 p)
	{
		return m_shape.TestPoint(m_body.GetTransform(), p);
	}
	
	/**
	 * Perform a ray cast against this shape.
	 * @param output the ray-cast results.
	 * @param input the ray-cast input parameters.
	 */
	public bool RayCast(b2RayCastOutput output, b2RayCastInput input)
	{
		return m_shape.RayCast(output, input, m_body.GetTransform());
	}
	
	/**
	 * Get the mass data for this fixture. The mass data is based on the density and
	 * the shape. The rotational inertia is about the shape's origin. This operation may be expensive
	 * @param massData - this is a reference to a valid massData, if it is null a new b2MassData is allocated and then returned
	 * @note if the input is null then you must get the return value.
	 */
	public b2MassData GetMassData(b2MassData massData = null)
	{
		if ( massData == null )
		{
			massData = new b2MassData();
		}
		m_shape.ComputeMass(massData, m_density);
		return massData;
	}
	
	/**
	 * Set the density of this fixture. This will _not_ automatically adjust the mass
	 * of the body. You must call b2Body::ResetMassData to update the body's mass.
	 * @param	density
	 */
	public void SetDensity(float density) {
		//b2Settings.b2Assert(b2Math.b2IsValid(density) && density >= 0.0);
		m_density = density;
	}
	
	/**
	 * Get the density of this fixture.
	 * @return density
	 */
	public float GetDensity() {
		return m_density;
	}
	
	/**
	 * Get the coefficient of friction.
	 */
	public float GetFriction()
	{
		return m_friction;
	}
	
	/**
	 * Set the coefficient of friction.
	 */
	public void SetFriction(float friction)
	{
		m_friction = friction;
	}
	
	/**
	 * Get the coefficient of restitution.
	 */
	public float GetRestitution()
	{
		return m_restitution;
	}
	
	/**
	 * Get the coefficient of restitution.
	 */
	public void SetRestitution(float restitution)
	{
		m_restitution = restitution;
	}
	
	/**
	 * Get the fixture's AABB. This AABB may be enlarge and/or stale.
	 * If you need a more accurate AABB, compute it using the shape and
	 * the body transform.
	 * @return
	 */
	public b2AABB GetAABB() {
		return m_aabb;
	}
	
	/**
	 * @private
	 */
	public b2Fixture()
	{
		m_aabb = new b2AABB();
		m_userData = null;
		m_body = null;
		m_next = null;
		//m_proxyId = b2BroadPhase.e_nullProxy;
		m_shape = null;
		m_density = 0.0f;
		
		m_friction = 0.0f;
		m_restitution = 0.0f;
	}
	
	/**
	 * the destructor cannot access the allocator (no destructor arguments allowed by C++).
	 *  We need separation create/destroy functions from the constructor/destructor because
	 */
	public void Create(b2Body body, b2Transform xf, b2FixtureDef def)
	{
		m_userData = def.userData;
		m_friction = def.friction;
		m_restitution = def.restitution;
		
		m_body = body;
		m_next = null;
		
		m_filter = def.filter.Copy();
		
		m_isSensor = def.isSensor;
		
		m_shape = def.shape.Copy();
		
		m_density = def.density;
	}
	
	/**
	 * the destructor cannot access the allocator (no destructor arguments allowed by C++).
	 *  We need separation create/destroy functions from the constructor/destructor because
	 */
	public void Destroy()
	{
		// The proxy must be destroyed before calling this.
		//b2Assert(m_proxyId == b2BroadPhase::e_nullProxy);
		
		// Free the child shape
		m_shape = null;
	}
	
	/**
	 * This supports body activation/deactivation.
	 */ 
	public void CreateProxy(IBroadPhase broadPhase, b2Transform xf){
		//b2Assert(m_proxyId == b2BroadPhase::e_nullProxy);
		
		// Create proxy in the broad-phase.
		m_shape.ComputeAABB(m_aabb, xf);
		m_proxy = broadPhase.CreateProxy(m_aabb, this);
	}
	
	/**
	 * This supports body activation/deactivation.
	 */
	public void DestroyProxy(IBroadPhase broadPhase) {
		if (m_proxy == null)
		{
			return;
		}
		
		// Destroy proxy in the broad-phase.
		broadPhase.DestroyProxy(m_proxy);
		m_proxy = null;
	}
	
	public void Synchronize(IBroadPhase broadPhase, b2Transform transform1, b2Transform transform2)
	{
		if (m_proxy==null)
			return;
			
		// Compute an AABB that ocvers the swept shape (may miss some rotation effect)
		b2AABB aabb1 = new b2AABB();
		b2AABB aabb2 = new b2AABB();
		m_shape.ComputeAABB(aabb1, transform1);
		m_shape.ComputeAABB(aabb2, transform2);
		
		m_aabb.Combine(aabb1, aabb2);
		b2Vec2 displacement = b2Math.SubtractVV(transform2.position, transform1.position);
		broadPhase.MoveProxy(m_proxy, m_aabb, displacement);
	}
	
	private b2MassData m_massData;
	
	public b2AABB m_aabb;
	public float m_density;
	public b2Fixture m_next;
	public b2Body m_body;
	public b2Shape m_shape;
	
	public float m_friction;
	public float m_restitution;
	
	public object m_proxy;
	public b2FilterData m_filter = new b2FilterData();
	
	public bool m_isSensor;
	
	public object m_userData;
}



}
