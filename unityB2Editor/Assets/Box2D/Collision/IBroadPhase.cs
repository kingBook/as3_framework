using Box2D.Common.Math;
using System;
using Box2D.Delegates;

namespace Box2D.Collision 
{

	/**
	 * Interface for objects tracking overlap of many AABBs.
	 */
	public interface IBroadPhase 
	{
		/**
		 * Create a proxy with an initial AABB. Pairs are not reported until
		 * UpdatePairs is called.
		 */
		object CreateProxy(b2AABB aabb, object userData);
		
		/**
		 * Destroy a proxy. It is up to the client to remove any pairs.
		 */
		void DestroyProxy(object proxy);
		
		/**
		 * Call MoveProxy as many times as you like, then when you are done
		 * call UpdatePairs to finalized the proxy pairs (for your time step).
		 */
		void MoveProxy(object proxy, b2AABB aabb, b2Vec2 displacement);
		
		bool TestOverlap(object proxyA, object proxyB);
		
		/**
		 * Get user data from a proxy. Returns null if the proxy is invalid.
		 */
		object GetUserData(object proxy);
		
		/**
		 * Get the fat AABB for a proxy.
		 */
		b2AABB GetFatAABB(object proxy);
		
		/**
		 * Get the number of proxies.
		 */
		int GetProxyCount();
		
		/**
		 * Update the pairs. This results in pair callbacks. This can only add pairs.
		 */
		void UpdatePairs(Action<object,object> callback);
		
		/**
		 * Query an AABB for overlapping proxies. The callback class
		 * is called with each proxy that overlaps 
		 * the supplied AABB, and return a Boolean indicating if 
		 * the broaphase should proceed to the next match.
		 * @param callback This function should be a function matching signature
		 * <code>function Callback(proxy:*):Boolean</code>
		 */
		void Query(BroadPhaseQueryCallback callback, b2AABB aabb);
		
		/**
		 * Ray-cast  agains the proxies in the tree. This relies on the callback
		 * to perform exact ray-cast in the case where the proxy contains a shape
		 * The callback also performs any collision filtering
		 * @param callback This function should be a function matching signature
		 * <code>function Callback(subInput:b2RayCastInput, proxy:*):Number</code>
		 * Where the returned number is the new value for maxFraction
		 */
		void RayCast(BroadPhaseRayCastCallback callback, b2RayCastInput input);
		
		/**
		 * For debugging, throws in invariants have been broken
		 */
		void Validate();
		
		/**
		 * Give the broadphase a chance for structural optimizations
		 */
		void Rebalance(int iterations);
	}
	
}