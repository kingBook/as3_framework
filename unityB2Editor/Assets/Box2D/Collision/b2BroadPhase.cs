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
using System.Collections.Generic;
using System;
using Box2D.Delegates;

namespace Box2D.Collision{


/*
This broad phase uses the Sweep and Prune algorithm as described in:
Collision Detection in Interactive 3D Environments by Gino van den Bergen
Also, some ideas, such as using integral values for fast compares comes from
Bullet (http:/www.bulletphysics.com).
*/


// Notes:
// - we use bound arrays instead of linked lists for cache coherence.
// - we use quantized integral values for fast compares.
// - we use short indices rather than pointers to save memory.
// - we use a stabbing count for fast overlap queries (less than order N).
// - we also use a time stamp on each proxy to speed up the registration of
//   overlap query results.
// - where possible, we compare bound indices instead of values to reduce
//   cache misses (TODO_ERIN).
// - no broadphase is perfect and neither is this one: it is not great for huge
//   worlds (use a multi-SAP instead), it is not great for large objects.

/**
* @private
*/
public class b2BroadPhase : IBroadPhase
{
//public:
		public b2BroadPhase(b2AABB worldAABB){
		//b2Settings.b2Assert(worldAABB.IsValid());
		int i=0;
		
		m_pairManager.Initialize(this);
		
		m_worldAABB = worldAABB;
		
		m_proxyCount = 0;
		
		// bounds array
		m_bounds = new List<List<b2Bound> >();
		for (i = 0; i < 2; i++){
			m_bounds.Add(new List<b2Bound>());
		}
		
		//b2Vec2 d = worldAABB.upperBound - worldAABB.lowerBound;
		float dX = worldAABB.upperBound.x - worldAABB.lowerBound.x;;
		float dY = worldAABB.upperBound.y - worldAABB.lowerBound.y;
		
		m_quantizationFactor.x = b2Settings.USHRT_MAX / dX;
		m_quantizationFactor.y = b2Settings.USHRT_MAX / dY;
		
		m_timeStamp = 1;
		m_queryResultCount = 0;
	}
	//~b2BroadPhase();
	
	// Use this to see if your proxy is in range. If it is not in range,
	// it should be destroyed. Otherwise you may get O(m^2) pairs, where m
	// is the number of proxies that are out of range.
	public bool InRange(b2AABB aabb){
		//b2Vec2 d = b2Max(aabb.lowerBound - m_worldAABB.upperBound, m_worldAABB.lowerBound - aabb.upperBound);
		float dX;
		float dY;
		float d2X;
		float d2Y;
		
		dX = aabb.lowerBound.x;
		dY = aabb.lowerBound.y;
		dX -= m_worldAABB.upperBound.x;
		dY -= m_worldAABB.upperBound.y;
		
		d2X = m_worldAABB.lowerBound.x;
		d2Y = m_worldAABB.lowerBound.y;
		d2X -= aabb.upperBound.x;
		d2Y -= aabb.upperBound.y;
		
		dX = b2Math.Max(dX, d2X);
		dY = b2Math.Max(dY, d2Y);
		
		return b2Math.Max(dX, dY) < 0.0f;
	}

	// Create and destroy proxies. These call Flush first.
	public object CreateProxy(b2AABB aabb, object userData){
		uint index;
		b2Proxy proxy;
		int i;
		int j;
		
		//b2Settings.b2Assert(m_proxyCount < b2_maxProxies);
		//b2Settings.b2Assert(m_freeProxy != b2Pair.b2_nullProxy);
		
		if (m_freeProxy==null)
		{
			// As all proxies are allocated, m_proxyCount == m_proxyPool.length
			m_freeProxy = m_proxyPool[m_proxyCount] = new b2Proxy();
			m_freeProxy.next = null;
			m_freeProxy.timeStamp = 0;
			m_freeProxy.overlapCount = b2_invalid;
			m_freeProxy.userData = null;
			
			for (i = 0; i < 2; i++)
			{
				j = m_proxyCount * 2;
				m_bounds[i][j++] = new b2Bound();
				m_bounds[i][j] = new b2Bound();
			}
			
		}
		
		proxy = m_freeProxy;
		m_freeProxy = proxy.next;
		
		proxy.overlapCount = 0;
		proxy.userData = userData;
		
		uint boundCount = (uint)(2 * m_proxyCount);
		
			List<float> lowerValues = new List<float>();
			List<float> upperValues = new List<float>();
		ComputeBounds(lowerValues, upperValues, aabb);
		
		for (int axis = 0; axis < 2; ++axis)
		{
			List<b2Bound> bounds = m_bounds[axis];
			uint lowerIndex=0;
			uint upperIndex=0;
			List<uint> lowerIndexOut = new List<uint>();
			lowerIndexOut.Add(lowerIndex);
			List<uint> upperIndexOut = new List<uint>();
			upperIndexOut.Add(upperIndex);
			QueryAxis(lowerIndexOut, upperIndexOut, (uint)lowerValues[axis], (uint)upperValues[axis], bounds, boundCount, axis);
			lowerIndex = lowerIndexOut[0];
			upperIndex = upperIndexOut[0];
			
			//bounds.splice(upperIndex, 0, bounds[bounds.length - 1]);
			//bounds.length--;
			//bounds.splice(lowerIndex, 0, bounds[bounds.length - 1]);
			//bounds.length--;
			bounds.Insert((int)upperIndex,bounds[bounds.Count - 1]);
			bounds.RemoveAt(bounds.Count-1);
			bounds.Insert((int)lowerIndex,bounds[bounds.Count - 1]);
			bounds.RemoveAt(bounds.Count-1);
			
			// The upper index has increased because of the lower bound insertion.
			++upperIndex;
			
			// Copy in the new bounds.
			b2Bound tBound1 = bounds[(int)lowerIndex];
			b2Bound tBound2 = bounds[(int)upperIndex];
			tBound1.value = (uint)lowerValues[axis];
			tBound1.proxy = proxy;
			tBound2.value = (uint)upperValues[axis];
			tBound2.proxy = proxy;
			
			b2Bound tBoundAS3 = bounds[(int)(lowerIndex-1)];
			tBound1.stabbingCount = lowerIndex == 0 ? 0 : tBoundAS3.stabbingCount;
			tBoundAS3 = bounds[(int)(upperIndex-1)];
			tBound2.stabbingCount = tBoundAS3.stabbingCount;
			
			// Adjust the stabbing count between the new bounds.
			for (index = lowerIndex; index < upperIndex; ++index)
			{
				tBoundAS3 = bounds[(int)index];
				tBoundAS3.stabbingCount++;
			}
			
			// Adjust the all the affected bound indices.
			for (index = lowerIndex; index < boundCount + 2; ++index)
			{
				tBound1 = bounds[(int)index];
				b2Proxy proxy2 = tBound1.proxy;
				if (tBound1.IsLower())
				{
					proxy2.lowerBounds[axis] = index;
				}
				else
				{
					proxy2.upperBounds[axis] = index;
				}
			}
		}
		
		++m_proxyCount;
		
		//b2Settings.b2Assert(m_queryResultCount < b2Settings.b2_maxProxies);
		
		for (i = 0; i < m_queryResultCount; ++i)
		{
			//b2Settings.b2Assert(m_queryResults[i] < b2_maxProxies);
			//b2Settings.b2Assert(m_proxyPool[m_queryResults[i]].IsValid());
			
			m_pairManager.AddBufferedPair(proxy, (b2Proxy)m_queryResults[i]);
		}
		
		// Prepare for next query.
		m_queryResultCount = 0;
		IncrementTimeStamp();
		
		return proxy;
	}
	
	public void DestroyProxy(object proxy_) {
		b2Proxy proxy = proxy_ as b2Proxy;
		b2Bound tBound1;
		b2Bound tBound2;
		
		//b2Settings.b2Assert(proxy.IsValid());
		
		int boundCount = 2 * m_proxyCount;
		
		for (int axis = 0; axis < 2; ++axis)
		{
			List<b2Bound> bounds = m_bounds[axis];
			
			uint lowerIndex = proxy.lowerBounds[axis];
			uint upperIndex = proxy.upperBounds[axis];
			tBound1 = bounds[(int)lowerIndex];
			uint lowerValue = tBound1.value;
			tBound2 = bounds[(int)upperIndex];
			uint upperValue = tBound2.value;
			
			bounds.RemoveRange((int)upperIndex, 1);
			bounds.RemoveRange((int)lowerIndex, 1);
			bounds.Add(tBound1);
			bounds.Add(tBound2);
			
			
			// Fix bound indices.
			int tEnd = boundCount - 2;
			for (uint index = lowerIndex; index < tEnd; ++index)
			{
				tBound1 = bounds[(int)index];
				b2Proxy proxy2 = tBound1.proxy;
				if (tBound1.IsLower())
				{
					proxy2.lowerBounds[axis] = index;
				}
				else
				{
					proxy2.upperBounds[axis] = index;
				}
			}
			
			// Fix stabbing count.
			tEnd = (int)upperIndex - 1;
			for (int index2 = (int)lowerIndex; index2 < tEnd; ++index2)
			{
				tBound1 = bounds[index2];
				tBound1.stabbingCount--;
			}
			
			// Query for pairs to be removed. lowerIndex and upperIndex are not needed.
			// make lowerIndex and upper output using an array and do this for others if compiler doesn't pick them up
			List<uint> ignore = new List<uint>();
			QueryAxis(ignore, ignore, lowerValue, upperValue, bounds, (uint)(boundCount - 2), axis);
		}
		
		//b2Settings.b2Assert(m_queryResultCount < b2Settings.b2_maxProxies);
		
		for (int i = 0; i < m_queryResultCount; ++i)
		{
			//b2Settings.b2Assert(m_proxyPool[m_queryResults[i]].IsValid());
			
			m_pairManager.RemoveBufferedPair(proxy, (b2Proxy)m_queryResults[i]);
		}
		
		// Prepare for next query.
		m_queryResultCount = 0;
		IncrementTimeStamp();
		
		// Return the proxy to the pool.
		proxy.userData = null;
		proxy.overlapCount = b2_invalid;
		proxy.lowerBounds[0] = b2_invalid;
		proxy.lowerBounds[1] = b2_invalid;
		proxy.upperBounds[0] = b2_invalid;
		proxy.upperBounds[1] = b2_invalid;
		
		proxy.next = m_freeProxy;
		m_freeProxy = proxy;
		--m_proxyCount;
	}


	// Call MoveProxy as many times as you like, then when you are done
	// call Commit to finalized the proxy pairs (for your time step).
	public void MoveProxy(object proxy_, b2AABB aabb, b2Vec2 displacement) {
		b2Proxy proxy = proxy_ as b2Proxy;
		
		List<uint> as3arr;
		int as3int;
		
		int axis;
		uint index;
		b2Bound bound;
		b2Bound prevBound;
		b2Bound nextBound;
		uint nextProxyId;
		b2Proxy nextProxy;
		
		if (proxy == null)
		{
			//b2Settings.b2Assert(false);
			return;
		}
		
		if (aabb.IsValid() == false)
		{
			//b2Settings.b2Assert(false);
			return;
		}
		
		uint boundCount = (uint)(2 * m_proxyCount);
		
		// Get new bound values
		b2BoundValues newValues = new b2BoundValues();
		ComputeBounds(newValues.lowerValues, newValues.upperValues, aabb);
		
		// Get old bound values
		b2BoundValues oldValues = new b2BoundValues();
		for (axis = 0; axis < 2; ++axis)
		{
			bound = m_bounds[axis][(int)proxy.lowerBounds[axis]];
			oldValues.lowerValues[axis] = bound.value;
			bound = m_bounds[axis][(int)proxy.upperBounds[axis]];
			oldValues.upperValues[axis] = bound.value;
		}
		
		for (axis = 0; axis < 2; ++axis)
		{
			List<b2Bound> bounds = m_bounds[axis];
			
			uint lowerIndex = proxy.lowerBounds[axis];
			uint upperIndex = proxy.upperBounds[axis];
		
			uint lowerValue = (uint)newValues.lowerValues[axis];
			uint upperValue = (uint)newValues.upperValues[axis];
			
			bound = bounds[(int)lowerIndex];
			int deltaLower = (int)(lowerValue - bound.value);
			bound.value = lowerValue;
			
			bound = bounds[(int)upperIndex];
			int deltaUpper = (int)(upperValue - bound.value);
			bound.value = upperValue;
			
			//
			// Expanding adds overlaps
			//
			
			// Should we move the lower bound down?
			if (deltaLower < 0)
			{
				index = lowerIndex;
				while (index > 0 && lowerValue < (bounds[(int)(index-1)] as b2Bound).value)
				{
					bound = bounds[(int)index];
					prevBound = bounds[(int)(index - 1)];
					
					b2Proxy prevProxy = prevBound.proxy;
					
					prevBound.stabbingCount++;
					
					if (prevBound.IsUpper() == true)
					{
						if (TestOverlapBound(newValues, prevProxy))
						{
							m_pairManager.AddBufferedPair(proxy, prevProxy);
						}
						
						//prevProxy.upperBounds[axis]++;
						as3arr = prevProxy.upperBounds;
						as3int = (int)as3arr[axis];
						as3int++;
						as3arr[axis] = (uint)as3int;
						
						bound.stabbingCount++;
					}
					else
					{
						//prevProxy.lowerBounds[axis]++;
						as3arr = prevProxy.lowerBounds;
						as3int = (int)as3arr[axis];
						as3int++;
						as3arr[axis] = (uint)as3int;
						
						bound.stabbingCount--;
					}
					
					//proxy.lowerBounds[axis]--;
					as3arr = proxy.lowerBounds;
					as3int = (int)as3arr[axis];
					as3int--;
					as3arr[axis] = (uint)as3int;
					
					// swap
					//var temp:b2Bound = bound;
					//bound = prevEdge;
					//prevEdge = temp;
					bound.Swap(prevBound);
					//b2Math.Swap(bound, prevEdge);
					--index;
				}
			}
			
			// Should we move the upper bound up?
			if (deltaUpper > 0)
			{
				index = upperIndex;
				while (index < boundCount-1 && (bounds[(int)(index+1)] as b2Bound).value <= upperValue)
				{
					bound = bounds[ (int)index ];
					nextBound = bounds[ (int)(index + 1) ];
					nextProxy = nextBound.proxy;
					
					nextBound.stabbingCount++;
					
					if (nextBound.IsLower() == true)
					{
						if (TestOverlapBound(newValues, nextProxy))
						{
							m_pairManager.AddBufferedPair(proxy, nextProxy);
						}
						
						//nextProxy.lowerBounds[axis]--;
						as3arr = nextProxy.lowerBounds;
						as3int = (int)as3arr[axis];
						as3int--;
						as3arr[axis] = (uint)as3int;
						
						bound.stabbingCount++;
					}
					else
					{
						//nextProxy.upperBounds[axis]--;
						as3arr = nextProxy.upperBounds;
						as3int = (int)as3arr[axis];
						as3int--;
						as3arr[axis] = (uint)as3int;
						
						bound.stabbingCount--;
					}
					
					//proxy.upperBounds[axis]++;
					as3arr = proxy.upperBounds;
					as3int = (int)as3arr[axis];
					as3int++;
					as3arr[axis] = (uint)as3int;
					
					// swap
					//var temp:b2Bound = bound;
					//bound = nextEdge;
					//nextEdge = temp;
					bound.Swap(nextBound);
					//b2Math.Swap(bound, nextEdge);
					index++;
				}
			}
			
			//
			// Shrinking removes overlaps
			//
			
			// Should we move the lower bound up?
			if (deltaLower > 0)
			{
				index = lowerIndex;
				while (index < boundCount-1 && (bounds[(int)(index+1)] as b2Bound).value <= lowerValue)
				{
					bound = bounds[ (int)index ];
					nextBound = bounds[ (int)(index + 1) ];
					
					nextProxy = nextBound.proxy;
					
					nextBound.stabbingCount--;
					
					if (nextBound.IsUpper())
					{
						if (TestOverlapBound(oldValues, nextProxy))
						{
							m_pairManager.RemoveBufferedPair(proxy, nextProxy);
						}
						
						//nextProxy.upperBounds[axis]--;
						as3arr = nextProxy.upperBounds;
						as3int = (int)as3arr[axis];
						as3int--;
						as3arr[axis] = (uint)as3int;
						
						bound.stabbingCount--;
					}
					else
					{
						//nextProxy.lowerBounds[axis]--;
						as3arr = nextProxy.lowerBounds;
						as3int = (int)as3arr[axis];
						as3int--;
						as3arr[axis] = (uint)as3int;
						
						bound.stabbingCount++;
					}
					
					//proxy.lowerBounds[axis]++;
					as3arr = proxy.lowerBounds;
					as3int = (int)as3arr[axis];
					as3int++;
					as3arr[axis] = (uint)as3int;
					
					// swap
					//var temp:b2Bound = bound;
					//bound = nextEdge;
					//nextEdge = temp;
					bound.Swap(nextBound);
					//b2Math.Swap(bound, nextEdge);
					index++;
				}
			}
			
			// Should we move the upper bound down?
			if (deltaUpper < 0)
			{
				index = upperIndex;
				while (index > 0 && upperValue < (bounds[(int)(index-1)] as b2Bound).value)
				{
					bound = bounds[(int)index];
					prevBound = bounds[(int)(index - 1)];
					
					b2Proxy prevProxy = prevBound.proxy;
					
					prevBound.stabbingCount--;
					
					if (prevBound.IsLower() == true)
					{
						if (TestOverlapBound(oldValues, prevProxy))
						{
							m_pairManager.RemoveBufferedPair(proxy, prevProxy);
						}
						
						//prevProxy.lowerBounds[axis]++;
						as3arr = prevProxy.lowerBounds;
						as3int = (int)as3arr[axis];
						as3int++;
						as3arr[axis] = (uint)as3int;
						
						bound.stabbingCount--;
					}
					else
					{
						//prevProxy.upperBounds[axis]++;
						as3arr = prevProxy.upperBounds;
						as3int = (int)as3arr[axis];
						as3int++;
						as3arr[axis] = (uint)as3int;
						
						bound.stabbingCount++;
					}
					
					//proxy.upperBounds[axis]--;
					as3arr = proxy.upperBounds;
					as3int = (int)as3arr[axis];
					as3int--;
					as3arr[axis] = (uint)as3int;
					
					// swap
					//var temp:b2Bound = bound;
					//bound = prevEdge;
					//prevEdge = temp;
					bound.Swap(prevBound);
					//b2Math.Swap(bound, prevEdge);
					index--;
				}
			}
		}
	}
	
	public void UpdatePairs(Action<object,object> callback){
		m_pairManager.Commit(callback);
	}

	public bool TestOverlap(object proxyA, object proxyB)
	{
		b2Proxy proxyA_ = proxyA as b2Proxy;
		b2Proxy proxyB_ = proxyB as b2Proxy;
		if ( proxyA_.lowerBounds[0] > proxyB_.upperBounds[0]) return false;
		if ( proxyB_.lowerBounds[0] > proxyA_.upperBounds[0]) return false;
		if ( proxyA_.lowerBounds[1] > proxyB_.upperBounds[1]) return false;
		if ( proxyB_.lowerBounds[1] > proxyA_.upperBounds[1]) return false;
		return true;
	}
	
	/**
	 * Get user data from a proxy. Returns null if the proxy is invalid.
	 */
	public object GetUserData(object proxy)
	{
		return (proxy as b2Proxy).userData;
	}
	
	/**
	 * Get the AABB for a proxy.
	 */
	public b2AABB GetFatAABB(object proxy_)
	{
		b2AABB aabb = new b2AABB();
		b2Proxy proxy = proxy_ as b2Proxy;
		aabb.lowerBound.x = m_worldAABB.lowerBound.x +  m_bounds[0][(int)proxy.lowerBounds[0]].value  / m_quantizationFactor.x;
		aabb.lowerBound.y = m_worldAABB.lowerBound.y +  m_bounds[1][(int)proxy.lowerBounds[1]].value  / m_quantizationFactor.y;
		aabb.upperBound.x = m_worldAABB.lowerBound.x +  m_bounds[0][(int)proxy.upperBounds[0]].value  / m_quantizationFactor.x;
		aabb.upperBound.y = m_worldAABB.lowerBound.y +  m_bounds[1][(int)proxy.upperBounds[1]].value  / m_quantizationFactor.y;
		return aabb;
	}
	
	/**
	 * Get the number of proxies.
	 */
	public int GetProxyCount()
	{
		return m_proxyCount;
	}
		
	
	/**
	 * Query an AABB for overlapping proxies. The callback class
	 * is called for each proxy that overlaps the supplied AABB.
	 */
	public void Query(BroadPhaseQueryCallback callback, b2AABB aabb)
	{
		List<float> lowerValues = new List<float>();
		List<float> upperValues = new List<float>();
		ComputeBounds(lowerValues, upperValues, aabb);
		
		uint lowerIndex=0;
		uint upperIndex=0;
		List<uint> lowerIndexOut = new List<uint>();
		lowerIndexOut.Add(lowerIndex);
		List<uint> upperIndexOut = new List<uint>();
		upperIndexOut.Add(upperIndex);
		QueryAxis(lowerIndexOut, upperIndexOut, (uint)lowerValues[0], (uint)upperValues[0], m_bounds[0], (uint)(2*m_proxyCount), 0);
		QueryAxis(lowerIndexOut, upperIndexOut, (uint)lowerValues[1], (uint)upperValues[1], m_bounds[1], (uint)(2*m_proxyCount), 1);
		
		//b2Settings.b2Assert(m_queryResultCount < b2Settings.b2_maxProxies);
		
		// TODO: Don't be lazy, transform QueryAxis to directly call callback
		for (int i = 0; i < m_queryResultCount; ++i)
		{
			b2Proxy proxy =  (b2Proxy)m_queryResults[i];
			//b2Settings.b2Assert(proxy.IsValid());
			if (!callback(proxy))
			{
				break;
			}
		}
		
		// Prepare for next query.
		m_queryResultCount = 0;
		IncrementTimeStamp();
	}

	public void Validate(){
		b2Pair pair;
		b2Proxy proxy1;
		b2Proxy proxy2;
		bool overlap;
		
		for (int axis = 0; axis < 2; ++axis)
		{
			List<b2Bound> bounds = m_bounds[axis];
			
			uint boundCount = (uint)(2 * m_proxyCount);
			uint stabbingCount = 0;
			
			for (uint i = 0; i < boundCount; ++i)
			{
				b2Bound bound = bounds[(int)i];
				//b2Settings.b2Assert(i == 0 || bounds[i-1].value <= bound->value);
				//b2Settings.b2Assert(bound->proxyId != b2_nullProxy);
				//b2Settings.b2Assert(m_proxyPool[bound->proxyId].IsValid());
				
				if (bound.IsLower() == true)
				{
					//b2Settings.b2Assert(m_proxyPool[bound.proxyId].lowerBounds[axis] == i);
					stabbingCount++;
				}
				else
				{
					//b2Settings.b2Assert(m_proxyPool[bound.proxyId].upperBounds[axis] == i);
					stabbingCount--;
				}
				
				//b2Settings.b2Assert(bound.stabbingCount == stabbingCount);
			}
		}
		
	}

	public void Rebalance(int iterations)
	{
		// Do nothing
	}

	
	/**
	 * @inheritDoc
	 */
	public void RayCast(BroadPhaseRayCastCallback callback, b2RayCastInput input)
	{
		b2RayCastInput subInput = new  b2RayCastInput();
		subInput.p1.SetV(input.p1);
		subInput.p2.SetV(input.p2);
		subInput.maxFraction = input.maxFraction;
		
		
		float dx = (input.p2.x-input.p1.x)*m_quantizationFactor.x;
		float dy = (input.p2.y-input.p1.y)*m_quantizationFactor.y;
		
		int sx = dx<-float.MinValue ? -1 : (dx>float.MinValue ? 1 : 0);
		int sy = dy<-float.MinValue ? -1 : (dy>float.MinValue ? 1 : 0);
		
		//b2Settings.b2Assert(sx!=0||sy!=0);
		
		float p1x = m_quantizationFactor.x * (input.p1.x - m_worldAABB.lowerBound.x);
		float p1y = m_quantizationFactor.y * (input.p1.y - m_worldAABB.lowerBound.y);
		
		List<uint> startValues = new List<uint>();
		List<uint> startValues2 = new List<uint>();
		startValues[0]=(uint)(p1x) & (b2Settings.USHRT_MAX - 1);
		startValues[1]=(uint)(p1y) & (b2Settings.USHRT_MAX - 1);
		startValues2[0]=startValues[0]+1;
		startValues2[1]=startValues[1]+1;
		
		List<uint> startIndices = new List<uint> ();
		
		int xIndex;
		int yIndex;
		
		b2Proxy proxy;
		
		
		//First deal with all the proxies that contain segment.p1
		uint lowerIndex=0;
		uint upperIndex=0;
		List<uint> lowerIndexOut = new List<uint>(); 
		lowerIndexOut.Add(lowerIndex);
		List<uint> upperIndexOut = new List<uint>();
		upperIndexOut.Add(upperIndex);
		QueryAxis(lowerIndexOut, upperIndexOut, startValues[0], startValues2[0], m_bounds[0], (uint)(2*m_proxyCount), 0);
		if(sx>=0)	xIndex = (int)(upperIndexOut[0]-1);
		else		xIndex = (int)(lowerIndexOut[0]);
		QueryAxis(lowerIndexOut, upperIndexOut, startValues[1], startValues2[1], m_bounds[1], (uint)(2*m_proxyCount), 1);
		if(sy>=0)	yIndex = (int)(upperIndexOut[0]-1);
		else		yIndex = (int)lowerIndexOut[0];
			
		// Callback for starting proxies:
		for (int i = 0; i < m_queryResultCount; i++) {
			//subInput.maxFraction = callback(m_queryResults[i], subInput);
			subInput.maxFraction = callback(subInput,m_queryResults[i]);
		}
		
		//Now work through the rest of the segment
		for (;; )
		{
			float xProgress = 0;
			float yProgress = 0;
			//Move on to next bound
			xIndex += sx >= 0?1: -1;
			if(xIndex<0||xIndex>=m_proxyCount*2)
				break;
			if(sx!=0){
				xProgress = (m_bounds[0][xIndex].value - p1x) / dx;
			}
			//Move on to next bound
			yIndex += sy >= 0?1: -1;
			if(yIndex<0||yIndex>=m_proxyCount*2)
				break;
			if(sy!=0){
				yProgress = (m_bounds[1][yIndex].value - p1y) / dy;	
			}
			for (;; )
			{	
				if(sy==0||(sx!=0&&xProgress<yProgress)){
					if(xProgress>subInput.maxFraction)
						break;
					
					//Check that we are entering a proxy, not leaving
					if(sx>0?m_bounds[0][xIndex].IsLower():m_bounds[0][xIndex].IsUpper()){
						//Check the other axis of the proxy
						proxy = m_bounds[0][xIndex].proxy;
						if(sy>=0){
							if(proxy.lowerBounds[1]<=yIndex-1&&proxy.upperBounds[1]>=yIndex){
								//Add the proxy
								//subInput.maxFraction = callback(proxy, subInput);
								subInput.maxFraction = callback(subInput,proxy);
							}
						}else{
							if(proxy.lowerBounds[1]<=yIndex&&proxy.upperBounds[1]>=yIndex+1){
								//Add the proxy
								//subInput.maxFraction = callback(proxy, subInput);
								subInput.maxFraction = callback(subInput, proxy);
							}
						}
					}
					
					//Early out
					if(subInput.maxFraction==0)
						break;
					
					//Move on to the next bound
					if(sx>0){
						xIndex++;
						if(xIndex==m_proxyCount*2)
							break;
					}else{
						xIndex--;
						if(xIndex<0)
							break;
					}
					xProgress = (m_bounds[0][xIndex].value - p1x) / dx;
				}else{
					if(yProgress>subInput.maxFraction)
						break;
					
					//Check that we are entering a proxy, not leaving
					if(sy>0?m_bounds[1][yIndex].IsLower():m_bounds[1][yIndex].IsUpper()){
						//Check the other axis of the proxy
						proxy = m_bounds[1][yIndex].proxy;
						if(sx>=0){
							if(proxy.lowerBounds[0]<=xIndex-1&&proxy.upperBounds[0]>=xIndex){
								//Add the proxy
								//subInput.maxFraction = callback(proxy, subInput);
								subInput.maxFraction = callback(subInput, proxy);
							}
						}else{
							if(proxy.lowerBounds[0]<=xIndex&&proxy.upperBounds[0]>=xIndex+1){
								//Add the proxy
								//subInput.maxFraction = callback(proxy, subInput);
								subInput.maxFraction = callback(subInput, proxy);
							}
						}
					}
					
					//Early out
					if(subInput.maxFraction==0)
						break;
					
					//Move on to the next bound
					if(sy>0){
						yIndex++;
						if(yIndex==m_proxyCount*2)
							break;
					}else{
						yIndex--;
						if(yIndex<0)
							break;
					}
					yProgress = (m_bounds[1][yIndex].value - p1y) / dy;
				}
			}
			break;
		}
		
		// Prepare for next query.
		m_queryResultCount = 0;
		IncrementTimeStamp();
		
		return;
	}
	
//private:
	private void ComputeBounds(List<float> lowerValues, List<float> upperValues, b2AABB aabb)
	{
		//b2Settings.b2Assert(aabb.upperBound.x >= aabb.lowerBound.x);
		//b2Settings.b2Assert(aabb.upperBound.y >= aabb.lowerBound.y);
		
		//var minVertex:b2Vec2 = b2Math.ClampV(aabb.minVertex, m_worldAABB.minVertex, m_worldAABB.maxVertex);
		float minVertexX = aabb.lowerBound.x;
		float minVertexY = aabb.lowerBound.y;
		minVertexX = b2Math.Min(minVertexX, m_worldAABB.upperBound.x);
		minVertexY = b2Math.Min(minVertexY, m_worldAABB.upperBound.y);
		minVertexX = b2Math.Max(minVertexX, m_worldAABB.lowerBound.x);
		minVertexY = b2Math.Max(minVertexY, m_worldAABB.lowerBound.y);
		
		//var maxVertex:b2Vec2 = b2Math.ClampV(aabb.maxVertex, m_worldAABB.minVertex, m_worldAABB.maxVertex);
		float maxVertexX = aabb.upperBound.x;
		float maxVertexY = aabb.upperBound.y;
		maxVertexX = b2Math.Min(maxVertexX, m_worldAABB.upperBound.x);
		maxVertexY = b2Math.Min(maxVertexY, m_worldAABB.upperBound.y);
		maxVertexX = b2Math.Max(maxVertexX, m_worldAABB.lowerBound.x);
		maxVertexY = b2Math.Max(maxVertexY, m_worldAABB.lowerBound.y);
		
		// Bump lower bounds downs and upper bounds up. This ensures correct sorting of
		// lower/upper bounds that would have equal values.
		// TODO_ERIN implement fast float to uint16 conversion.
		lowerValues[0] = (uint)(m_quantizationFactor.x * (minVertexX - m_worldAABB.lowerBound.x)) & (b2Settings.USHRT_MAX - 1);
		upperValues[0] = ((uint)(m_quantizationFactor.x * (maxVertexX - m_worldAABB.lowerBound.x))& 0x0000ffff) | 1;
		
		lowerValues[1] = (uint)(m_quantizationFactor.y * (minVertexY - m_worldAABB.lowerBound.y)) & (b2Settings.USHRT_MAX - 1);
		upperValues[1] = ((uint)(m_quantizationFactor.y * (maxVertexY - m_worldAABB.lowerBound.y))& 0x0000ffff) | 1;
	}

	// This one is only used for validation.
	private bool TestOverlapValidate(b2Proxy p1, b2Proxy p2){
		
		for (int axis = 0; axis < 2; ++axis)
		{
			List<b2Bound> bounds = m_bounds[axis];
			
			//b2Settings.b2Assert(p1.lowerBounds[axis] < 2 * m_proxyCount);
			//b2Settings.b2Assert(p1.upperBounds[axis] < 2 * m_proxyCount);
			//b2Settings.b2Assert(p2.lowerBounds[axis] < 2 * m_proxyCount);
			//b2Settings.b2Assert(p2.upperBounds[axis] < 2 * m_proxyCount);
			
			b2Bound bound1 = bounds[(int)p1.lowerBounds[axis]];
			b2Bound bound2 = bounds[(int)p2.upperBounds[axis]];
			if (bound1.value > bound2.value)
				return false;
			
			bound1 = bounds[(int)p1.upperBounds[axis]];
			bound2 = bounds[(int)p2.lowerBounds[axis]];
			if (bound1.value < bound2.value)
				return false;
		}
		
		return true;
	}
	
	public bool TestOverlapBound(b2BoundValues b, b2Proxy p)
	{
		for (int axis = 0; axis < 2; ++axis)
		{
			List<b2Bound> bounds = m_bounds[axis];
			
			//b2Settings.b2Assert(p.lowerBounds[axis] < 2 * m_proxyCount);
			//b2Settings.b2Assert(p.upperBounds[axis] < 2 * m_proxyCount);
			
			b2Bound bound = bounds[(int)p.upperBounds[axis]];
			if (b.lowerValues[axis] > bound.value)
				return false;
			
			bound = bounds[(int)p.lowerBounds[axis]];
			if (b.upperValues[axis] < bound.value)
				return false;
		}
		
		return true;
	}


		
	private void QueryAxis(List<uint> lowerQueryOut, List<uint> upperQueryOut, uint lowerValue, uint upperValue, List<b2Bound> bounds, uint boundCount, int axis){
		uint lowerQuery = BinarySearch(bounds, (int)boundCount, lowerValue);
		uint upperQuery = BinarySearch(bounds, (int)boundCount, upperValue);
		b2Bound bound;
		
		// Easy case: lowerQuery <= lowerIndex(i) < upperQuery
		// Solution: search query range for min bounds.
		for (uint j = lowerQuery; j < upperQuery; ++j)
		{
			bound = bounds[(int)j];
			if (bound.IsLower())
			{
				IncrementOverlapCount(bound.proxy);
			}
		}
		
		// Hard case: lowerIndex(i) < lowerQuery < upperIndex(i)
		// Solution: use the stabbing count to search down the bound array.
		if (lowerQuery > 0)
		{
			int i = (int)(lowerQuery - 1);
			bound = bounds[i];
			int s = (int)bound.stabbingCount;
			
			// Find the s overlaps.
			while (s!=0)
			{
				//b2Settings.b2Assert(i >= 0);
				bound = bounds[i];
				if (bound.IsLower())
				{
					b2Proxy proxy = bound.proxy;
					if (lowerQuery <= proxy.upperBounds[axis])
					{
						IncrementOverlapCount(bound.proxy);
						--s;
					}
				}
				--i;
			}
		}
		
		lowerQueryOut[0] = lowerQuery;
		upperQueryOut[0] = upperQuery;
	}

	private void IncrementOverlapCount(b2Proxy proxy){
		if (proxy.timeStamp < m_timeStamp)
		{
			proxy.timeStamp = m_timeStamp;
			proxy.overlapCount = 1;
		}
		else
		{
			proxy.overlapCount = 2;
			//b2Settings.b2Assert(m_queryResultCount < b2Settings.b2_maxProxies);
			m_queryResults[m_queryResultCount] = proxy;
			++m_queryResultCount;
		}
	}
	private void IncrementTimeStamp(){
		if (m_timeStamp == b2Settings.USHRT_MAX)
		{
			for (uint i = 0; i < m_proxyPool.Count; ++i)
			{
				(m_proxyPool[(int)i] as b2Proxy).timeStamp = 0;
			}
			m_timeStamp = 1;
		}
		else
		{
			++m_timeStamp;
		}
	}
	
	public b2PairManager m_pairManager = new b2PairManager();

	public List<b2Proxy> m_proxyPool = new List<b2Proxy>();
	private b2Proxy m_freeProxy;

	public List<List<b2Bound>> m_bounds ;

	private List<object> m_querySortKeys = new List<object>();
	private List<object> m_queryResults = new List<object>();
	private int m_queryResultCount;
	
	public b2AABB m_worldAABB;
	public b2Vec2 m_quantizationFactor = new b2Vec2();
	public int m_proxyCount;
	private uint m_timeStamp;

	static public bool s_validate = false;
	
	public const uint b2_invalid = b2Settings.USHRT_MAX;
	public const uint b2_nullEdge = b2Settings.USHRT_MAX;


	static public uint BinarySearch(List<b2Bound> bounds, int count, uint value)
	{
		int low = 0;
		int high = count - 1;
		while (low <= high)
		{
			int mid = ((low + high) / 2);
			b2Bound bound = bounds[mid];
			if (bound.value > value)
			{
				high = mid - 1;
			}
			else if (bound.value < value)
			{
				low = mid + 1;
			}
			else
			{
				return (uint)(mid);
			}
		}
		
		return (uint)(low);
	}
	
	
}
}
