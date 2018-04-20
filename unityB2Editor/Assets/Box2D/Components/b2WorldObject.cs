using UnityEngine;
using System.Collections;
using Box2D.Dynamics;
using Box2D.Common.Math;

namespace UnityEngine{
    [DisallowMultipleComponent]
	[AddComponentMenu("b2Components/b2WorldObject",0)]
	public class b2WorldObject : MonoBehaviour {

		public Vector2 gravity=new Vector2(0,-9.81f);
		public bool allowSleep=true;

		public float dt=0.01f;
		public int velocityIterations=8;
		public int positionIterations=8;

		private b2World _world;
		private b2DebugDraw _debugDraw;

		private bool _pause=false;

		void Awake(){
			_world = new b2World (new b2Vec2(gravity.x,gravity.y),allowSleep);
#if UNITY_EDITOR
			_debugDraw=new b2DebugDraw();
			_debugDraw.SetFlags(b2DebugDraw.e_shapeBit|b2DebugDraw.e_jointBit);
			_world.SetDebugDraw(_debugDraw);
#endif
			gameObject.BroadcastMessage("onWorldInitialized",this);
		}

		void Start() {
			
		}

		void FixedUpdate () {
			if (_pause)return;
			_world.Step (dt,velocityIterations,positionIterations);
			_world.ClearForces ();
#if UNITY_EDITOR
			_world.DrawDebugData();
#endif
		}

		public b2World world{
			get{ return _world;}
		}

		public void setPause(bool value){
			_pause = value;
		}

#if UNITY_EDITOR
		void Reset(){
			gravity.x = 0;
			gravity.y = -9.81f;
			allowSleep = true;
			dt = 0.01f;
			velocityIterations = 8;
			positionIterations = 8;

			apply ();
		}

		void OnValidate(){
			apply ();
		}

		private void apply(){
			if (_world != null) {
				_world.SetGravity(new b2Vec2(gravity.x,gravity.y));
				_world.SetAllowSleep(allowSleep);
			}
		}
#endif
	}
}
