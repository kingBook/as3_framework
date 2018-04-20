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
using Box2D.Common;

namespace Box2D.Collision{


/**
* @private
*/
public class b2TimeOfImpact
{
	
	private static int b2_toiCalls = 0;
	private static int b2_toiIters = 0;
	private static int b2_toiMaxIters = 0;
	private static int b2_toiRootIters = 0;
	private static int b2_toiMaxRootIters = 0;

	private static b2SimplexCache s_cache = new b2SimplexCache();
	private static b2DistanceInput s_distanceInput = new b2DistanceInput();
	private static b2Transform s_xfA = new b2Transform();
	private static b2Transform s_xfB = new b2Transform();
	private static b2SeparationFunction s_fcn = new b2SeparationFunction();
	private static b2DistanceOutput s_distanceOutput = new b2DistanceOutput();
	public static float TimeOfImpact(b2TOIInput input)
	{
		++b2_toiCalls;
		
		b2DistanceProxy proxyA = input.proxyA;
		b2DistanceProxy proxyB = input.proxyB;
		
		b2Sweep sweepA = input.sweepA;
		b2Sweep sweepB = input.sweepB;
		
		b2Settings.b2Assert(sweepA.t0 == sweepB.t0);
		b2Settings.b2Assert(1.0f - sweepA.t0 > float.MinValue);
		
		float radius = proxyA.m_radius + proxyB.m_radius;
		float tolerance = input.tolerance;
		
		float alpha = 0.0f;
		
		const int k_maxIterations = 1000; //TODO_ERIN b2Settings
		int iter = 0;
		float target = 0.0f;
		
		// Prepare input for distance query.
		s_cache.count = 0;
		s_distanceInput.useRadii = false;
		
		for (;; )
		{
			sweepA.GetTransform(s_xfA, alpha);
			sweepB.GetTransform(s_xfB, alpha);
			
			// Get the distance between shapes
			s_distanceInput.proxyA = proxyA;
			s_distanceInput.proxyB = proxyB;
			s_distanceInput.transformA = s_xfA;
			s_distanceInput.transformB = s_xfB;
			
			b2Distance.Distance(s_distanceOutput, s_cache, s_distanceInput);
			
			if (s_distanceOutput.distance <= 0.0f)
			{
				alpha = 1.0f;
				break;
			}
			
			s_fcn.Initialize(s_cache, proxyA, s_xfA, proxyB, s_xfB);
			
			float separation = s_fcn.Evaluate(s_xfA, s_xfB);
			if (separation <= 0.0f)
			{
				alpha = 1.0f;
				break;
			}
			
			if (iter == 0)
			{
				// Compute a reasonable target distance to give some breathing room
				// for conservative advancement. We take advantage of the shape radii
				// to create additional clearance
				if (separation > radius)
				{
					target = b2Math.Max(radius - tolerance, 0.75f * radius);
				}
				else
				{
					target = b2Math.Max(separation - tolerance, 0.02f * radius);
				}
			}
			
			if (separation - target < 0.5f * tolerance)
			{
				if (iter == 0)
				{
					alpha = 1.0f;
					break;
				}
				break;
			}
			
//#if 0
			// Dump the curve seen by the root finder
			//{
				//const N:int = 100;
				//var dx:Number = 1.0 / N;
				//var xs:Vector.<Number> = new Array(N + 1);
				//var fs:Vector.<Number> = new Array(N + 1);
				//
				//var x:Number = 0.0;
				//for (var i:int = 0; i <= N; i++)
				//{
					//sweepA.GetTransform(xfA, x);
					//sweepB.GetTransform(xfB, x);
					//var f:Number = fcn.Evaluate(xfA, xfB) - target;
					//
					//trace(x, f);
					//xs[i] = x;
					//fx[i] = f'
					//
					//x += dx;
				//}
			//}
//#endif
			// Compute 1D root of f(x) - target = 0
			float newAlpha = alpha;
			{
				float x1 = alpha;
				float x2 = 1.0f;
				
				float f1 = separation;
				
				sweepA.GetTransform(s_xfA, x2);
				sweepB.GetTransform(s_xfB, x2);
				
				float f2 = s_fcn.Evaluate(s_xfA, s_xfB);
				
				// If intervals don't overlap at t2, then we are done
				if (f2 >= target)
				{
					alpha = 1.0f;
					break;
				}
				
				// Determine when intervals intersect
				int rootIterCount = 0;
				for (;; )
				{
					// Use a mis of the secand rule and bisection
					float x;
					if ((rootIterCount & 1)>0)
					{
						// Secant rule to improve convergence
						x = x1 + (target - f1) * (x2 - x1) / (f2 - f1);
					}
					else
					{
						// Bisection to guarantee progress
						x = 0.5f * (x1 + x2);
					}
					
					sweepA.GetTransform(s_xfA, x);
					sweepB.GetTransform(s_xfB, x);
					
					float f = s_fcn.Evaluate(s_xfA, s_xfB);
					
					if (b2Math.Abs(f - target) < 0.025f * tolerance)
					{
						newAlpha = x;
						break;
					}
					
					// Ensure we continue to bracket the root
					if (f > target)
					{
						x1 = x;
						f1 = f;
					}
					else
					{
						x2 = x;
						f2 = f;
					}
					
					++rootIterCount;
					++b2_toiRootIters;
					if (rootIterCount == 50)
					{
						break;
					}
				}
				
				b2_toiMaxRootIters = (int)b2Math.Max((float)b2_toiMaxRootIters, (float)rootIterCount);
			}
			
			// Ensure significant advancement
			if (newAlpha < (1.0f + 100.0f * float.MinValue) * alpha)
			{
				break;
			}
			
			alpha = newAlpha;
			
			iter++;
			++b2_toiIters;
			
			if (iter == k_maxIterations)
			{
				break;
			}
		}
		
		b2_toiMaxIters = (int)b2Math.Max((float)b2_toiMaxIters, (float)iter);

		return alpha;
	}

}

}
