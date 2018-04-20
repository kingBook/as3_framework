/*
* Copyright (c) 2009 Erin Catto http://www.gphysics.com
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
using UnityEngine;
using System;
using Box2D.Delegates;

namespace Box2D.Collision 
{
	
	// A dynamic AABB tree broad-phase, inspired by Nathanael Presson's btDbvt.
	
	/**
	 * A dynamic tree arranges data in a binary tree to accelerate
	 * queries such as volume queries and ray casts. Leafs are proxies
	 * with an AABB. In the tree we expand the proxy AABB by b2_fatAABBFactor
	 * so that the proxy AABB is bigger than the client object. This allows the client
	 * object to move by small amounts without triggering a tree update.
	 * 
	 * Nodes are pooled.
	 */
	public class b2DynamicTree 
	{
		/**
		 * Constructing the tree initializes the node pool.
		 */
		public b2DynamicTree() 
		{
			m_root = null;
			
			// TODO: Maybe allocate some free nodes?
			m_freeList = null;
			m_path = 0;
			
			m_insertionCount = 0;
		}
		/*
		public function Dump(node:b2DynamicTreeNode=null, depth:int=0):void
		{
			if (!node)
			{
				node = m_root;
			}
			if (!node) return;
			for (var i:int = 0; i < depth; i++) s += " ";
			if (node.userData)
			{
				var ud:* = (node.userData as b2Fixture).GetBody().GetUserData();
				trace(s + ud);
			}else {
				trace(s + "-");
			}
			if (node.child1)
				Dump(node.child1, depth + 1);
			if (node.child2)
				Dump(node.child2, depth + 1);
		}
		*/
		
		/**
		 * Create a proxy. Provide a tight fitting AABB and a userData.
		 */
		public b2DynamicTreeNode CreateProxy(b2AABB aabb, object userData)
		{
			b2DynamicTreeNode node = AllocateNode();
			
			// Fatten the aabb.
			float extendX = b2Settings.b2_aabbExtension;
			float extendY = b2Settings.b2_aabbExtension;
			node.aabb.lowerBound.x = aabb.lowerBound.x - extendX;
			node.aabb.lowerBound.y = aabb.lowerBound.y - extendY;
			node.aabb.upperBound.x = aabb.upperBound.x + extendX;
			node.aabb.upperBound.y = aabb.upperBound.y + extendY;
			
			node.userData = userData;
			
			InsertLeaf(node);
			return node;
		}
		
		/**
		 * Destroy a proxy. This asserts if the id is invalid.
		 */
		public void DestroyProxy(b2DynamicTreeNode proxy)
		{
			//b2Settings.b2Assert(proxy.IsLeaf());
			RemoveLeaf(proxy);
			FreeNode(proxy);
		}
		
		/**
		 * Move a proxy with a swept AABB. If the proxy has moved outside of its fattened AABB,
		 * then the proxy is removed from the tree and re-inserted. Otherwise
		 * the function returns immediately.
		 */
		public bool MoveProxy(b2DynamicTreeNode proxy, b2AABB aabb, b2Vec2 displacement)
		{
			b2Settings.b2Assert(proxy.IsLeaf());
			
			if (proxy.aabb.Contains(aabb))
			{
				return false;
			}
			
			RemoveLeaf(proxy);
			
			// Extend AABB
			float extendX = b2Settings.b2_aabbExtension + b2Settings.b2_aabbMultiplier * (displacement.x > 0?displacement.x: -displacement.x);
			float extendY = b2Settings.b2_aabbExtension + b2Settings.b2_aabbMultiplier * (displacement.y > 0?displacement.y: -displacement.y);
			proxy.aabb.lowerBound.x = aabb.lowerBound.x - extendX;
			proxy.aabb.lowerBound.y = aabb.lowerBound.y - extendY;
			proxy.aabb.upperBound.x = aabb.upperBound.x + extendX;
			proxy.aabb.upperBound.y = aabb.upperBound.y + extendY;
			
			InsertLeaf(proxy);
			return true;
		}
		
		/**
		 * Perform some iterations to re-balance the tree.
		 */
		public void Rebalance(int iterations)
		{
			if (m_root == null)
				return;
				
			for (int i = 0; i < iterations; i++)
			{
				b2DynamicTreeNode node = m_root;
				uint bit = 0;
				while (node.IsLeaf() == false)
				{
					node = (((int)m_path >> (int)bit) & 1)>0 ? node.child2 : node.child1;
					bit = (bit + 1) & 31; // 0-31 bits in a uint
				}
				++m_path;
				
				RemoveLeaf(node);
				InsertLeaf(node);
			}
		}
		
		public b2AABB GetFatAABB(b2DynamicTreeNode proxy)
		{
			return proxy.aabb;
		}

		/**
		 * Get user data from a proxy. Returns null if the proxy is invalid.
		 */
		public object GetUserData(b2DynamicTreeNode proxy)
		{
			return proxy.userData;
		}
		
		/**
		 * Query an AABB for overlapping proxies. The callback
		 * is called for each proxy that overlaps the supplied AABB.
		 * The callback should match function signature
		 * <code>fuction callback(proxy:b2DynamicTreeNode):Boolean</code>
		 * and should return false to trigger premature termination.
		 */
		public void Query(BroadPhaseQueryCallback callback, b2AABB aabb)
		{
			if (m_root == null)
				return;
				
			Dictionary<int,b2DynamicTreeNode> stack = new Dictionary<int,b2DynamicTreeNode>();

			int count = 0;
			stack.Add(count++,m_root);

			while (count > 0)
			{
				b2DynamicTreeNode node = stack[--count];
				
				if (node.aabb.TestOverlap(aabb))
				{
					if (node.IsLeaf())
					{
						bool proceed = callback(node);
						if (!proceed)
							return;
					}
					else
					{
						// No stack limit, so no assert
						int key;

						key=count++;
						if(stack.ContainsKey(key))stack.Remove (key);
						stack.Add(key,node.child1);

						key=count++;
						if(stack.ContainsKey(key))stack.Remove (key);
						stack.Add(key,node.child2);
					}
				}
			}
		}
	
		/**
		 * Ray-cast against the proxies in the tree. This relies on the callback
		 * to perform a exact ray-cast in the case were the proxy contains a shape.
		 * The callback also performs the any collision filtering. This has performance
		 * roughly equal to k * log(n), where k is the number of collisions and n is the
		 * number of proxies in the tree.
		 * @param input the ray-cast input data. The ray extends from p1 to p1 + maxFraction * (p2 - p1).
		 * @param callback a callback class that is called for each proxy that is hit by the ray.
		 * It should be of signature:
		 * ----- <code>function callback(input:b2RayCastInput, proxy:*):void</code>
		 * <code>function callback(input:b2RayCastInput, proxy:*):Number</code>
		 */
		public void RayCast(BroadPhaseRayCastCallback callback, b2RayCastInput input)
		{
			if (m_root == null)
				return;
				
			b2Vec2 p1 = input.p1;
			b2Vec2 p2 = input.p2;
			b2Vec2 r = b2Math.SubtractVV(p1, p2);
			//b2Settings.b2Assert(r.LengthSquared() > 0.0);
			r.Normalize();
			
			// v is perpendicular to the segment
			b2Vec2 v = b2Math.CrossFV(1.0f, r);
			b2Vec2 abs_v = b2Math.AbsV(v);
			
			float maxFraction = input.maxFraction;
			
			// Build a bounding box for the segment
			b2AABB segmentAABB = new b2AABB();
			float tX;
			float tY;
			{
				tX = p1.x + maxFraction * (p2.x - p1.x);
				tY = p1.y + maxFraction * (p2.y - p1.y);
				segmentAABB.lowerBound.x = Mathf.Min(p1.x, tX);
				segmentAABB.lowerBound.y = Mathf.Min(p1.y, tY);
				segmentAABB.upperBound.x = Mathf.Max(p1.x, tX);
				segmentAABB.upperBound.y = Mathf.Max(p1.y, tY);
			}
			
			Dictionary<int,b2DynamicTreeNode> stack = new Dictionary<int,b2DynamicTreeNode>();
			
			int count = 0;
			stack[count++] = m_root;
			
			while (count > 0)
			{
				b2DynamicTreeNode node = stack[--count];
				
				if (node.aabb.TestOverlap(segmentAABB) == false)
				{
					continue;
				}
				
				// Separating axis for segment (Gino, p80)
				// |dot(v, p1 - c)| > dot(|v|,h)
				
				b2Vec2 c = node.aabb.GetCenter();
				b2Vec2 h = node.aabb.GetExtents();
				float separation = Mathf.Abs(v.x * (p1.x - c.x) + v.y * (p1.y - c.y))
										- abs_v.x * h.x - abs_v.y * h.y;
				if (separation > 0.0f)
					continue;
				
				if (node.IsLeaf())
				{
					b2RayCastInput subInput = new b2RayCastInput();
					subInput.p1 = input.p1;
					subInput.p2 = input.p2;
					//*************by kingBook 2015/10/22 16:17*************
					subInput.maxFraction=maxFraction;
					float value=callback(subInput, node);
					if(value==0)return;
					if(value>0)
					{
						//Update the segment bounding box
						maxFraction=value;
					//******************************************************
						tX = p1.x + maxFraction * (p2.x - p1.x);
						tY = p1.y + maxFraction * (p2.y - p1.y);
						segmentAABB.lowerBound.x = Mathf.Min(p1.x, tX);
						segmentAABB.lowerBound.y = Mathf.Min(p1.y, tY);
						segmentAABB.upperBound.x = Mathf.Max(p1.x, tX);
						segmentAABB.upperBound.y = Mathf.Max(p1.y, tY);
					}
				}
				else
				{
					// No stack limit, so no assert
					stack[count++] = node.child1;
					stack[count++] = node.child2;
				}
			}
		}
		
		
		private b2DynamicTreeNode AllocateNode()
		{
			// Peel a node off the free list
			if (m_freeList!=null)
			{
				b2DynamicTreeNode node = m_freeList;
				m_freeList = node.parent;
				node.parent = null;
				node.child1 = null;
				node.child2 = null;
				return node;
			}
			
			// Ignore length pool expansion and relocation found in the C++
			// As we are using heap allocation
			return new b2DynamicTreeNode();
		}
		
		private void FreeNode(b2DynamicTreeNode node)
		{
			node.parent = m_freeList;
			m_freeList = node;
		}
		
		private void InsertLeaf(b2DynamicTreeNode leaf)
		{
			++m_insertionCount;
			
			if (m_root == null)
			{
				m_root = leaf;
				m_root.parent = null;
				return;
			}
			
			b2Vec2 center = leaf.aabb.GetCenter();
			b2DynamicTreeNode sibling = m_root;
			if (sibling.IsLeaf() == false)
			{
				do
				{
					b2DynamicTreeNode child1 = sibling.child1;
					b2DynamicTreeNode child2 = sibling.child2;
					
					//b2Vec2 delta1 = b2Abs(m_nodes[child1].aabb.GetCenter() - center);
					//b2Vec2 delta2 = b2Abs(m_nodes[child2].aabb.GetCenter() - center);
					//float32 norm1 = delta1.x + delta1.y;
					//float32 norm2 = delta2.x + delta2.y;
					
					float norm1 = Mathf.Abs((child1.aabb.lowerBound.x + child1.aabb.upperBound.x) / 2.0f - center.x)
							    + Mathf.Abs((child1.aabb.lowerBound.y + child1.aabb.upperBound.y) / 2.0f - center.y);
					float norm2 = Mathf.Abs((child2.aabb.lowerBound.x + child2.aabb.upperBound.x) / 2.0f - center.x)
							    + Mathf.Abs((child2.aabb.lowerBound.y + child2.aabb.upperBound.y) / 2.0f - center.y);
									 
					if (norm1 < norm2)
					{
						sibling = child1;
					}else {
						sibling = child2;
					}
				}
				while (sibling.IsLeaf() == false);
			}
			
			// Create a parent for the siblings
			b2DynamicTreeNode node1 = sibling.parent;
			b2DynamicTreeNode node2 = AllocateNode();
			node2.parent = node1;
			node2.userData = null;
			node2.aabb.Combine(leaf.aabb, sibling.aabb);
			if (node1!=null)
			{
				if (sibling.parent.child1 == sibling)
				{
					node1.child1 = node2;
				}
				else
				{
					node1.child2 = node2;
				}
				
				node2.child1 = sibling;
				node2.child2 = leaf;
				sibling.parent = node2;
				leaf.parent = node2;
				do
				{
					if (node1.aabb.Contains(node2.aabb))
						break;
					
					node1.aabb.Combine(node1.child1.aabb, node1.child2.aabb);
					node2 = node1;
					node1 = node1.parent;
				}
				while (node1!=null);
			}
			else
			{
				node2.child1 = sibling;
				node2.child2 = leaf;
				sibling.parent = node2;
				leaf.parent = node2;
				m_root = node2;
			}
			
		}
		
		private void RemoveLeaf(b2DynamicTreeNode leaf)
		{
			if ( leaf == m_root)
			{
				m_root = null;
				return;
			}
			
			b2DynamicTreeNode node2 = leaf.parent;
			b2DynamicTreeNode node1 = node2.parent;
			b2DynamicTreeNode sibling;
			if (node2.child1 == leaf)
			{
				sibling = node2.child2;
			}
			else
			{
				sibling = node2.child1;
			}
			
			if (node1!=null)
			{
				// Destroy node2 and connect node1 to sibling
				if (node1.child1 == node2)
				{
					node1.child1 = sibling;
				}
				else
				{
					node1.child2 = sibling;
				}
				sibling.parent = node1;
				FreeNode(node2);
				
				// Adjust the ancestor bounds
				while (node1!=null)
				{
					b2AABB oldAABB = node1.aabb;
					node1.aabb = b2AABB.CombineStatic(node1.child1.aabb, node1.child2.aabb);
					
					if (oldAABB.Contains(node1.aabb))
						break;
						
					node1 = node1.parent;
				}
			}
			else
			{
				m_root = sibling;
				sibling.parent = null;
				FreeNode(node2);
			}
		}
		
		private b2DynamicTreeNode m_root;
		private b2DynamicTreeNode m_freeList;
		
		/** This is used for incrementally traverse the tree for rebalancing */
		private uint m_path;
		
		private int m_insertionCount;
	}
	
}