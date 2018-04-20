using Box2D.Common.Math;
using Box2D.Delegates;
using Box2D.Dynamics;
using Box2D.Dynamics.Joints;

namespace UnityEngine {
	[DisallowMultipleComponent]
	[AddComponentMenu("b2Components/b2DebugDrag",2)]
	public class b2DebugDrag:MonoBehaviour {
		private b2World _world;
		private b2MouseJoint _mj = null;
		void Start() {
			b2WorldObject worldObj = GetComponent<b2WorldObject>();
			_world = worldObj.world;
		}

		void Update() {
			if(Input.GetMouseButtonDown(0)) mouseDownHandler();
			if(Input.GetMouseButton(0)) mouseMoveHandler();
			if(Input.GetMouseButtonUp(0)) stopDragBody();
		}

		void OnDestroy() {
			if(_mj != null) _world.DestroyJoint(_mj);
			_mj = null;
		}

		protected void mouseDownHandler() {
			Vector3 pos = Camera.main.ScreenToWorldPoint(Input.mousePosition);//屏幕坐标转世界坐标
			b2Body b = getPosBody(pos.x,pos.y);
			startDragBody(b,pos.x,pos.y);
		}

		protected void mouseMoveHandler() {
			if(_mj != null) {
				Vector3 pos = Camera.main.ScreenToWorldPoint(Input.mousePosition);//屏幕坐标转世界坐标
				_mj.SetTarget(new b2Vec2(pos.x,pos.y));
			}
		}

		/** 开始拖动刚体*/
		private void startDragBody(b2Body b,float x,float y) {
			if(b == null || b.GetType() != b2Body.b2_dynamicBody) return;
			if(_mj != null) _world.DestroyJoint(_mj);
			b2MouseJointDef jointDef = new b2MouseJointDef();
			jointDef.bodyA = _world.GetGroundBody();
			jointDef.bodyB = b;
			jointDef.target.Set(x,y);
			jointDef.maxForce = 1e6f;
			_mj = _world.CreateJoint(jointDef) as b2MouseJoint;
		}

		protected void stopDragBody() {
			if(_mj != null) _world.DestroyJoint(_mj);
		}

		/**返回位置下的刚体*/
		private b2Body getPosBody(float x,float y) {
			b2Body b = null;

			b2WorldQueryCallback cb = delegate (b2Fixture fixture) {
				b = fixture.GetBody();
				return false;
			};
			_world.QueryPoint(cb,new b2Vec2(x,y));
			return b;
		}
	}
}

