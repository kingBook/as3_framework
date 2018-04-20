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

namespace Box2D.Collision {

/**
* We use contact ids to facilitate warm starting.
*/
public class Features
{
	public int _flip;
	public b2ContactID _m_id;
	/**
	* The edge that defines the outward contact normal.
	*/
	public int referenceEdge{
		get{return _referenceEdge;}
		set{
				_referenceEdge = value;
				_m_id._key = (_m_id._key & 0xffffff00) | (uint)(_referenceEdge & 0x000000ff);
			}
	}
	
	public int _referenceEdge;
	
	/**
	* The edge most anti-parallel to the reference edge.
	*/
	public int incidentEdge{
		get{return _incidentEdge;}
		set{
				_incidentEdge = value;
				_m_id._key = (_m_id._key & 0xffff00ff) | (uint)((_incidentEdge << 8) & 0x0000ff00);
			}
	}

	public int _incidentEdge;
	
	/**
	* The vertex (0 or 1) on the incident edge that was clipped.
	*/
	public int incidentVertex{
		get{return _incidentVertex;}
		set{
			_incidentVertex = value;
			_m_id._key = (_m_id._key & 0xff00ffff) | (uint)((_incidentVertex << 16) & 0x00ff0000);
		}
	}
	
	public int _incidentVertex;
	
	/**
	* A value of 1 indicates that the reference edge is on shape2.
	*/
	public int flip{
		get{return _flip;}
		set{
				_flip = value;
				_m_id._key = (_m_id._key & 0x00ffffff) | (uint)((_flip << 24) & 0xff000000);
			}
	}
	
}


}
