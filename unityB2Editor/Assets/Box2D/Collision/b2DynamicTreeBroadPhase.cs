using Box2D.Common.Math;
using System.Collections.Generic;
using System;
using Box2D.Delegates;

namespace Box2D.Collision 
{
	
/**
 * The broad-phase is used for computing pairs and performing volume queries and ray casts.
 * This broad-phase does not persist pairs. Instead, this reports potentially new pairs.
 * It is up to the client to consume the new pairs and to track subsequent overlap.
 */
public class b2DynamicTreeBroadPhase : IBroadPhase
{
	
	/**
	 * Create a proxy with an initial AABB. Pairs are not reported until
	 * UpdatePairs is called.
	 */
	public object CreateProxy(b2AABB aabb, object userData)
	{
		b2DynamicTreeNode proxy = m_tree.CreateProxy(aabb, userData);
		++m_proxyCount;
		BufferMove(proxy);
		return proxy;
	}
	
	/**
	 * Destroy a proxy. It is up to the client to remove any pairs.
	 */
	public void DestroyProxy(object proxy)
	{
		UnBufferMove((b2DynamicTreeNode)proxy);
		--m_proxyCount;
		m_tree.DestroyProxy((b2DynamicTreeNode)proxy);
	}
	
	/**
	 * Call MoveProxy as many times as you like, then when you are done
	 * call UpdatePairs to finalized the proxy pairs (for your time step).
	 */
	public void MoveProxy(object proxy, b2AABB aabb, b2Vec2 displacement)
	{
		bool buffer = m_tree.MoveProxy((b2DynamicTreeNode)proxy, aabb, displacement);
		if (buffer)
		{
			BufferMove((b2DynamicTreeNode)proxy);
		}
	}
	
	public bool TestOverlap(object proxyA, object proxyB)
	{
		b2AABB aabbA = m_tree.GetFatAABB((b2DynamicTreeNode)proxyA);
		b2AABB aabbB = m_tree.GetFatAABB((b2DynamicTreeNode)proxyB);
		return aabbA.TestOverlap(aabbB);
	}
	
	/**
	 * Get user data from a proxy. Returns null if the proxy is invalid.
	 */
	public object GetUserData(object proxy)
	{
		return m_tree.GetUserData((b2DynamicTreeNode)proxy);
	}
	
	/**
	 * Get the AABB for a proxy.
	 */
	public b2AABB GetFatAABB(object proxy)
	{
		return m_tree.GetFatAABB((b2DynamicTreeNode)proxy);
	}
	
	/**
	 * Get the number of proxies.
	 */
	public int GetProxyCount()
	{
		return m_proxyCount;
	}
	
	/**
	 * Update the pairs. This results in pair callbacks. This can only add pairs.
	 */
	public void UpdatePairs(Action<object,object> callback)
	{
		m_pairCount = 0;
		// Perform tree queries for all moving queries
		foreach(b2DynamicTreeNode queryProxy in m_moveBuffer)
		{
			/*bool QueryCallback(b2DynamicTreeNode proxy)
			{
				// A proxy cannot form a pair with itself.
				if (proxy == queryProxy)
					return true;
					
				// Grow the pair buffer as needed
				if (m_pairCount == m_pairBuffer.Count)
				{
					m_pairBuffer[m_pairCount] = new b2DynamicTreePair();
				}
				
				b2DynamicTreePair pair = m_pairBuffer[m_pairCount];
				pair.proxyA = proxy < queryProxy?proxy:queryProxy;
				pair.proxyB = proxy >= queryProxy?proxy:queryProxy;
				++m_pairCount;
				
				return true;
			}*/
			BroadPhaseQueryCallback QueryCallback=delegate(object proxy){
				// A proxy cannot form a pair with itself.
				if (proxy == queryProxy)
					return true;
				
				// Grow the pair buffer as needed
				if (m_pairCount == m_pairBuffer.Count)
				{
					m_pairBuffer.Add(new b2DynamicTreePair());
				}
				
				b2DynamicTreePair pair = m_pairBuffer[m_pairCount];
				//pair.proxyA = proxy < queryProxy?proxy:queryProxy;
				//pair.proxyB = proxy >= queryProxy?proxy:queryProxy;
				//改
				pair.proxyA = queryProxy;
				pair.proxyB = (b2DynamicTreeNode)proxy;

				++m_pairCount;
				
				return true;
			};
			// We have to query the tree with the fat AABB so that
			// we don't fail to create a pair that may touch later.
			b2AABB fatAABB = m_tree.GetFatAABB(queryProxy);
			m_tree.Query(QueryCallback, fatAABB);
		}
		
		// Reset move buffer
		//m_moveBuffer.length = 0;
		m_moveBuffer.RemoveRange(0,m_moveBuffer.Count);
		
		// Sort the pair buffer to expose duplicates.
		// TODO: Something more sensible
		//m_pairBuffer.sort(ComparePairs);
		
		// Send the pair buffer
		for (int i = 0; i < m_pairCount; )
		{
			b2DynamicTreePair primaryPair = m_pairBuffer[i];
			object userDataA = m_tree.GetUserData(primaryPair.proxyA);
			object userDataB = m_tree.GetUserData(primaryPair.proxyB);
			callback(userDataA, userDataB);
			++i;
			
			// Skip any duplicate pairs
			while (i < m_pairCount)
			{
				b2DynamicTreePair pair = m_pairBuffer[i];
				if (pair.proxyA != primaryPair.proxyA || pair.proxyB != primaryPair.proxyB)
				{
					break;
				}
				++i;
			}
		}
	}
	
	/**
	 * @inheritDoc
	 */
	public void Query(BroadPhaseQueryCallback callback, b2AABB aabb)
	{
		m_tree.Query(callback, aabb);
	}
	
	/**
	 * @inheritDoc
	 */
	public void RayCast(BroadPhaseRayCastCallback callback, b2RayCastInput input)
	{
		m_tree.RayCast(callback, input);
	}
	
	
	public void Validate()
	{
		//TODO_BORIS
	}
	
	public void Rebalance(int iterations)
	{
		m_tree.Rebalance(iterations);
	}
	
	
	// Private ///////////////
	
	private void BufferMove(b2DynamicTreeNode proxy)
	{
		m_moveBuffer.Add(proxy);
	}
	
	private void UnBufferMove(b2DynamicTreeNode proxy)
	{
		m_moveBuffer.Remove (proxy);
	}
	
	private int ComparePairs(b2DynamicTreePair pair1, b2DynamicTreePair pair2)
	{
		//TODO_BORIS:
		// We cannot consistently sort objects easily in AS3
		// The caller of this needs replacing with a different method.
		return 0;
	}
	private b2DynamicTree m_tree = new b2DynamicTree();
	private int m_proxyCount;
	private List<b2DynamicTreeNode> m_moveBuffer = new List<b2DynamicTreeNode>();
	
	private List<b2DynamicTreePair> m_pairBuffer = new List<b2DynamicTreePair>();
	private int m_pairCount = 0;
	
}
	
}