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
using Box2D.Common.Math;
using Box2D.Common;

namespace Box2D.Collision{

/**
* This structure is used to report contact points.
*/
public class b2ContactPoint
{
	/** The first shape */
	public b2Shape shape1;
	/** The second shape */
	public b2Shape shape2;
	/** Position in world coordinates */
	public b2Vec2 position = new b2Vec2();
	/** Velocity of point on body2 relative to point on body1 (pre-solver) */
	public b2Vec2 velocity = new b2Vec2();
	/** Points from shape1 to shape2 */
	public b2Vec2 normal = new b2Vec2();
	/** The separation is negative when shapes are touching */
	public float separation;
	/** The combined friction coefficient */
	public float frictio;
	/** The combined restitution coefficient */
	public float restitution;
	/** The contact id identifies the features in contact */
	public b2ContactID id = new b2ContactID();
}


}