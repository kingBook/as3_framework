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
using Box2D.Common;

namespace Box2D.Dynamics{


/**
 * A fixture definition is used to create a fixture. This class defines an
 * abstract fixture definition. You can reuse fixture definitions safely.
 */
public class b2FixtureDef
{
	/**
	 * The constructor sets the default fixture definition values.
	 */
	public b2FixtureDef()
	{
		shape = null;
		userData = null;
		friction = 0.2f;
		restitution = 0.0f;
		density = 1.0f;//edit 2015/9/17 10:18 by kingBook
		filter.categoryBits = 0x0001;
		filter.maskBits = 0xFFFF;
		filter.groupIndex = 0;
		isSensor = false;
	}
	
	/**
	 * The shape, this must be set. The shape will be cloned, so you
	 * can create the shape on the stack.
	 */
	public b2Shape shape;

	/**
	 * Use this to store application specific fixture data.
	 */
	public object userData;

	/**
	 * The friction coefficient, usually in the range [0,1].
	 */
	public float friction;

	/**
	 * The restitution (elasticity) usually in the range [0,1].
	 */
	public float restitution;

	/**
	 * The density, usually in kg/m^2.
	 */
	public float density;

	/**
	 * A sensor shape collects contact information but never generates a collision
	 * response.
	 */
	public bool isSensor;

	/**
	 * Contact filtering data.
	 */
	public b2FilterData filter = new b2FilterData();
}



}
