﻿/*
* Copyright (c) 2006-2007 Adam Newgas
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
using Box2D.Dynamics;

namespace Box2D.Dynamics.Controllers{
	


/**
 * Applies a force every frame
 */
public class b2ConstantForceController : b2Controller
{	
	/**
	 * The force to apply
	 */
	public b2Vec2 F = new b2Vec2(0.0f,0.0f);
	
	public override void Step(b2TimeStep step){
		for(b2ControllerEdge i=m_bodyList;i!=null;i=i.nextBody){
			b2Body body = i.body;
			if(!body.IsAwake())
				continue;
			body.ApplyForce(F,body.GetWorldCenter());
		}
	}
}

}