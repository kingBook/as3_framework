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

//Added support for b2RopeJoint - Allan Bishop @ http://allanbishop.com

using Box2D.Common.Math;
using Box2D.Common;
using Box2D.Dynamics;

namespace Box2D.Dynamics.Joints{
	

/**
* The base joint class. Joints are used to constraint two bodies together in
* various fashions. Some joints also feature limits and motors.
* @see b2JointDef
*/
public class b2Joint
{
	/**
	* Get the type of the concrete joint.
	*/
	public int GetType(){
		return m_type;
	}
	
	/**
	* Get the anchor point on bodyA in world coordinates.
	*/
	public virtual b2Vec2 GetAnchorA(){return null;}
	/**
	* Get the anchor point on bodyB in world coordinates.
	*/
	public virtual b2Vec2 GetAnchorB(){return null;}
	
	/**
	* Get the reaction force on body2 at the joint anchor in Newtons.
	*/
	public virtual b2Vec2 GetReactionForce(float inv_dt) {return null;}
	/**
	* Get the reaction torque on body2 in N*m.
	*/
	public virtual float GetReactionTorque(float inv_dt) {return 0.0f;}
	
	/**
	* Get the first body attached to this joint.
	*/
	public b2Body GetBodyA()
	{
		return m_bodyA;
	}
	
	/**
	* Get the second body attached to this joint.
	*/
	public b2Body GetBodyB()
	{
		return m_bodyB;
	}

	/**
	* Get the next joint the world joint list.
	*/
	public b2Joint GetNext(){
		return m_next;
	}

	/**
	* Get the user data pointer.
	*/
	public object GetUserData(){
		return m_userData;
	}

	/**
	* Set the user data pointer.
	*/
	public void SetUserData(object data){
		m_userData = data;
	}

	/**
	 * Short-cut function to determine if either body is inactive.
	 * @return
	 */
	public bool IsActive() {
		return m_bodyA.IsActive() && m_bodyB.IsActive();
	}
	
	//--------------- Internals Below -------------------

	static public b2Joint Create(b2JointDef def, object allocator){
		b2Joint joint = null;
		
		if(def.type==e_distanceJoint)
		{
			//void* mem = allocator->Allocate(sizeof(b2DistanceJoint));
			joint = new b2DistanceJoint(def as b2DistanceJointDef);
		}
		else if(def.type==e_mouseJoint)
		{
			//void* mem = allocator->Allocate(sizeof(b2MouseJoint));
			joint = new b2MouseJoint(def as b2MouseJointDef);
		}
		else if(def.type==e_prismaticJoint)
		{
			//void* mem = allocator->Allocate(sizeof(b2PrismaticJoint));
			joint = new b2PrismaticJoint(def as b2PrismaticJointDef);
		}
		else if(def.type==e_revoluteJoint)
		{
			//void* mem = allocator->Allocate(sizeof(b2RevoluteJoint));
			joint = new b2RevoluteJoint(def as b2RevoluteJointDef);
		}
		else if(def.type==e_pulleyJoint)
		{
			//void* mem = allocator->Allocate(sizeof(b2PulleyJoint));
			joint = new b2PulleyJoint(def as b2PulleyJointDef);
		}
		else if(def.type==e_gearJoint)
		{
			//void* mem = allocator->Allocate(sizeof(b2GearJoint));
			joint = new b2GearJoint(def as b2GearJointDef);
		}
		else if(def.type==e_lineJoint)
		{
			//void* mem = allocator->Allocate(sizeof(b2LineJoint));
			joint = new b2LineJoint(def as b2LineJointDef);
		}
		else if(def.type==e_weldJoint)
		{
			//void* mem = allocator->Allocate(sizeof(b2WeldJoint));
			joint = new b2WeldJoint(def as b2WeldJointDef);
		}
		else if(def.type==e_frictionJoint)
		{
			//void* mem = allocator->Allocate(sizeof(b2FrictionJoint));
			joint = new b2FrictionJoint(def as b2FrictionJointDef);
		}
		else if(def.type==e_ropeJoint)
		{
			joint = new b2RopeJoint(def as b2RopeJointDef);
		}
		else
		{
			//b2Settings.b2Assert(false);
		}		
		return joint;
	}
	
	static public void Destroy(b2Joint joint, object allocator){
		/*joint->~b2Joint();
		switch (joint.m_type)
		{
		case e_distanceJoint:
			allocator->Free(joint, sizeof(b2DistanceJoint));
			break;
		
		case e_mouseJoint:
			allocator->Free(joint, sizeof(b2MouseJoint));
			break;
		
		case e_prismaticJoint:
			allocator->Free(joint, sizeof(b2PrismaticJoint));
			break;
		
		case e_revoluteJoint:
			allocator->Free(joint, sizeof(b2RevoluteJoint));
			break;
		
		case e_pulleyJoint:
			allocator->Free(joint, sizeof(b2PulleyJoint));
			break;
		
		case e_gearJoint:
			allocator->Free(joint, sizeof(b2GearJoint));
			break;
		
		case e_lineJoint:
			allocator->Free(joint, sizeof(b2LineJoint));
			break;
			
		case e_weldJoint:
			allocator->Free(joint, sizeof(b2WeldJoint));
			break;
			
		case e_frictionJoint:
			allocator->Free(joint, sizeof(b2FrictionJoint));
			break;
		
		default:
			b2Assert(false);
			break;
		}*/
	}

	/** @private */
	public b2Joint(b2JointDef def) {
		b2Settings.b2Assert(def.bodyA != def.bodyB);
		m_type = def.type;
		m_prev = null;
		m_next = null;
		m_bodyA = def.bodyA;
		m_bodyB = def.bodyB;
		m_collideConnected = def.collideConnected;
		m_islandFlag = false;
		m_userData = def.userData;
	}
	//virtual ~b2Joint() {}

	public virtual void InitVelocityConstraints(b2TimeStep step){}
	public virtual void SolveVelocityConstraints(b2TimeStep step){ }
	public virtual void FinalizeVelocityConstraints(){}

	// This returns true if the position errors are within tolerance.
	public virtual bool SolvePositionConstraints(float baumgarte) { return false; }

	public int m_type;
	public b2Joint m_prev;
	public b2Joint m_next;
	public b2JointEdge m_edgeA = new b2JointEdge();
	public b2JointEdge m_edgeB = new b2JointEdge();
	public b2Body m_bodyA;
	public b2Body m_bodyB;

	public bool m_islandFlag;
	public bool m_collideConnected;

	private object m_userData;
	
	// Cache here per time step to reduce cache misses.
	public b2Vec2 m_localCenterA = new b2Vec2();
	public b2Vec2 m_localCenterB = new b2Vec2();
	public float m_invMassA;
	public float m_invMassB;
	public float m_invIA;
	public float m_invIB;
	
	// ENUMS
	
	// enum b2JointType
	public const int e_unknownJoint = 0;
	public const int e_revoluteJoint = 1;
	public const int e_prismaticJoint = 2;
	public const int e_distanceJoint = 3;
	public const int e_pulleyJoint = 4;
	public const int e_mouseJoint = 5;
	public const int e_gearJoint = 6;
	public const int e_lineJoint = 7;
	public const int e_weldJoint = 8;
	public const int e_frictionJoint = 9;
	public const int e_ropeJoint =10;

	// enum b2LimitState
	public const int e_inactiveLimit = 0;
	public const int e_atLowerLimit = 1;
	public const int e_atUpperLimit = 2;
	public const int e_equalLimits = 3;
	
}



}
