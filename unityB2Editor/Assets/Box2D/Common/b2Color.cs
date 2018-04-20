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
using UnityEngine;

namespace Box2D.Common{




/**
* Color for debug drawing. Each value has the range [0,1].
*/

public class b2Color
{

	public b2Color(float rr, float gg, float bb){
		_r = (uint)(255.0f * b2Math.Clamp(rr, 0.0f, 1.0f));
		_g = (uint)(255.0f * b2Math.Clamp(gg, 0.0f, 1.0f));
		_b = (uint)(255.0f * b2Math.Clamp(bb, 0.0f, 1.0f));
	}
	
	public void Set(float rr, float gg, float bb){
		_r = (uint)(255.0f * b2Math.Clamp(rr, 0.0f, 1.0f));
		_g = (uint)(255.0f * b2Math.Clamp(gg, 0.0f, 1.0f));
		_b = (uint)(255.0f * b2Math.Clamp(bb, 0.0f, 1.0f));
	}
	
	// R
	public uint r{
		set{_r = (uint)(255.0f * b2Math.Clamp(value, 0.0f, 1.0f));}
		get{return _r;}
	}
	// G
	public uint g{
		set{_g = (uint)(255.0f * b2Math.Clamp(value, 0.0f, 1.0f));}
		get{return _g;}
	}
	// B
	public uint b{
		set{_b = (uint)(255.0f * b2Math.Clamp(value, 0.0f, 1.0f));}
		get{return _b;}
	}
	
	// Color
	public uint color{
		get{return (_r << 16) | (_g << 8) | (_b);}
	}

	public Color unityColor{
		get
		{
			float r = (float)_r / 255.0f;
			float g = (float)_g / 255.0f;
			float b = (float)_b / 255.0f;
			return new Color(r,g,b);
		}
	}
	
	private uint _r = 0;
	private uint _g = 0;
	private uint _b = 0;

}

}