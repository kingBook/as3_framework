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
using UnityEngine;
namespace Box2D.Common{
	
	
	
	
/**
* This class controls Box2D global settings
*/
public class b2Settings{
    
    /**
    * The current version of Box2D
    */
	public const string VERSION = "2.1alpha";

	public const int USHRT_MAX = 0x0000ffff;

	public const float b2_pi = Mathf.PI;



	// Collision
    /**
     *   Number of manifold points in a b2Manifold. This should NEVER change.
     */
	public const int b2_maxManifoldPoints = 2;

    /*
     * The growable broadphase doesn't have upper limits,
	 * so there is no b2_maxProxies or b2_maxPairs settings.
     */
	//static public const b2_maxProxies:int = 0;
	//static public const b2_maxPairs:int = 8 * b2_maxProxies;
	
	/**
	 * This is used to fatten AABBs in the dynamic tree. This allows proxies
	 * to move by a small amount without triggering a tree adjustment.
	 * This is in meters.
	 */
	public const float b2_aabbExtension = 0.1f;
	
 	/**
 	 * This is used to fatten AABBs in the dynamic tree. This is used to predict
 	 * the future position based on the current displacement.
	 * This is a dimensionless multiplier.
	 */
	public const float b2_aabbMultiplier = 2.0f;

	/**
	 * The radius of the polygon/edge shape skin. This should not be modified. Making
	 * this smaller means polygons will have and insufficient for continuous collision.
	 * Making it larger may create artifacts for vertex collision.
	 */
	public const float b2_polygonRadius = (2.0f * b2_linearSlop);
	
	// Dynamics
	
	/**
	* A small length used as a collision and constraint tolerance. Usually it is
	* chosen to be numerically significant, but visually insignificant.
	*/
	public const float b2_linearSlop = 0.005f;	// 0.5 cm
	
	/**
	* A small angle used as a collision and constraint tolerance. Usually it is
	* chosen to be numerically significant, but visually insignificant.
	*/
	public const float b2_angularSlop = (2.0f / 180.0f * b2_pi);			// 2 degrees
	
	/**
	* Continuous collision detection (CCD) works with core, shrunken shapes. This is the
	* amount by which shapes are automatically shrunk to work with CCD. This must be
	* larger than b2_linearSlop.
    * @see b2_linearSlop
	*/
	public const float b2_toiSlop = (8.0f * b2_linearSlop);
	
	/**
	* Maximum number of contacts to be handled to solve a TOI island.
	*/
	public const int b2_maxTOIContactsPerIsland = 32;
	
	/**
	* Maximum number of joints to be handled to solve a TOI island.
	*/
	public const int b2_maxTOIJointsPerIsland = 32;
	
	/**
	* A velocity threshold for elastic collisions. Any collision with a relative linear
	* velocity below this threshold will be treated as inelastic.
	*/
	public const float b2_velocityThreshold = 1.0f;		// 1 m/s
	
	/**
	* The maximum linear position correction used when solving constraints. This helps to
	* prevent overshoot.
	*/
	public const float b2_maxLinearCorrection = 0.2f;	// 20 cm
	
	/**
	* The maximum angular position correction used when solving constraints. This helps to
	* prevent overshoot.
	*/
	public const float b2_maxAngularCorrection = (8.0f / 180.0f * b2_pi);			// 8 degrees
	
	/**
	* The maximum linear velocity of a body. This limit is very large and is used
	* to prevent numerical problems. You shouldn't need to adjust this.
	*/
	public const float b2_maxTranslation = 2.0f;
	public const float b2_maxTranslationSquared = b2_maxTranslation * b2_maxTranslation;
	
	/**
	* The maximum angular velocity of a body. This limit is very large and is used
	* to prevent numerical problems. You shouldn't need to adjust this.
	*/
	public const float b2_maxRotation = (0.5f * b2_pi);
	public const float b2_maxRotationSquared = b2_maxRotation * b2_maxRotation;
	
	/**
	* This scale factor controls how fast overlap is resolved. Ideally this would be 1 so
	* that overlap is removed in one time step. However using values close to 1 often lead
	* to overshoot.
	*/
	public const float b2_contactBaumgarte = 0.2f;
	
	/**
	 * Friction mixing law. Feel free to customize this.
	 */
	public static float b2MixFriction(float friction1, float friction2)
	{
		return Mathf.Sqrt(friction1 * friction2);
	}

	/** 
	 * Restitution mixing law. Feel free to customize this.
	 */
	public static float b2MixRestitution(float restitution1, float restitution2)
	{
		return restitution1 > restitution2 ? restitution1 : restitution2;
	}



	// Sleep
	
	/**
	* The time that a body must be still before it will go to sleep.
	*/
	public const float b2_timeToSleep = 0.5f;					// half a second
	/**
	* A body cannot sleep if its linear velocity is above this tolerance.
	*/
	public const float b2_linearSleepTolerance = 0.01f;			// 1 cm/s
	/**
	* A body cannot sleep if its angular velocity is above this tolerance.
	*/
	public const float b2_angularSleepTolerance = (2.0f / 180.0f * b2Settings.b2_pi);	// 2 degrees/s
	
	// assert
    /**
    * b2Assert is used internally to handle assertions. By default, calls are commented out to save performance,
    * so they serve more as documentation than anything else.
    */
	static public void b2Assert(bool a)
	{
		if (!a){
			//var nullVec:b2Vec2;
			//nullVec.x++;
			Debug.LogError("Assertion Failed");
		}
	}
}

}
