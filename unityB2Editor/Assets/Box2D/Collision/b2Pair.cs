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

// The pair manager is used by the broad-phase to quickly add/remove/find pairs
// of overlapping proxies. It is based closely on code provided by Pierre Terdiman.
// http://www.codercorner.com/IncrementalSAP.txt

using Box2D.Common;

namespace Box2D.Collision{


/**
 * A Pair represents a pair of overlapping b2Proxy in the broadphse.
 * @private
 */
public class b2Pair
{
	

	public void SetBuffered()	{ status |= e_pairBuffered; }
	public void ClearBuffered()	{ status &= ~e_pairBuffered; }
	public bool IsBuffered()	{ return (status & e_pairBuffered) == e_pairBuffered; }

	public void SetRemoved()	{ status |= e_pairRemoved; }
	public void ClearRemoved()	{ status &= ~e_pairRemoved; }
	public bool IsRemoved()		{ return (status & e_pairRemoved) == e_pairRemoved; }
	
	public void SetFinal()		{ status |= e_pairFinal; }
	public bool IsFinal()		{ return (status & e_pairFinal) == e_pairFinal; }

	public object userData = null;
	public b2Proxy proxy1;
	public b2Proxy proxy2;
	public b2Pair next;
	public uint status;
	
	// STATIC
	static public uint b2_nullProxy = b2Settings.USHRT_MAX;
	
	// enum
	static public uint e_pairBuffered = 0x0001;
	static public uint e_pairRemoved = 0x0002;
	static public uint e_pairFinal = 0x0004;

}


}