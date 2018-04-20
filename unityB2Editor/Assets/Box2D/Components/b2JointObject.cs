using Box2D.Dynamics;
using Box2D.Dynamics.Joints;
using System.Collections;
using System.Collections.Generic;
namespace UnityEngine {
	[RequireComponent(typeof(b2BodyObject))]
	public class b2JointObject:MonoBehaviour {
		public bool enableCollision;
		[Tooltip("connected b2BodyObject")]
		public b2BodyObject connectedB2BodyObject;
		
		protected b2World _world;
		protected b2WorldObject _worldObj;
		protected b2Joint _joint;
		protected b2BodyObject _bodyObject;

		virtual protected void Start() {
			_worldObj=gameObject.GetComponentInParent<b2WorldObject>();
			_world=_worldObj.world;
			_bodyObject=GetComponent<b2BodyObject>();
		}

		virtual protected void OnDestroy() {
			
		}

#if UNITY_EDITOR
		virtual protected void onChange(){
			_joint.m_collideConnected=enableCollision;
			if(connectedB2BodyObject!=null) {
				_joint.m_bodyB = connectedB2BodyObject.body;
			}
		}

		virtual protected void onReCreate(){
			if(_joint!=null && _world!=null)_world.DestroyJoint(_joint);
		}

		virtual protected void OnDrawGizmosSelected() {

		}

		/*画"+"号，局部坐标*/
		protected Vector2 drawLocalPointPlusSign(Vector2 localPoint,Transform transform,Color color){
			Quaternion q=Quaternion.Euler(0,0,transform.eulerAngles.z);
			localPoint=q*localPoint;
			Vector2 p =transform.position;
			p.x+=localPoint.x;
			p.y+=localPoint.y;
			drawPlusSign(p,color);
			return p;
		}
		protected Vector2 drawLocalPointPlusSign(Vector2 localPoint,Transform transform) {
			return drawLocalPointPlusSign(localPoint,transform,Color.green);
		}

		protected void drawLine(Vector2 from,Vector2 to,Color color){
			Gizmos.color=color;
			Gizmos.DrawLine(from,to);
		}
		protected void drawLine(Vector2 from,Vector2 to){
			drawLine(from,to,Color.green);
		}

		/**画"+"号，世界坐标*/
		protected void drawPlusSign(Vector2 pos,Color color,float len=0.2f){
			Vector2 start,end;
			start=pos-new Vector2(len*0.5f,0);
			end=pos+new Vector2(len*0.5f,0);
			drawLine(start,end,color);

			start=pos-new Vector2(0,len*0.5f);
			end=pos+new Vector2(0,len*0.5f);
			drawLine(start,end);
		}
		protected void drawPlusSign(Vector2 pos,float len=0.2f){
			drawPlusSign(pos,Color.green,len);
		}
#endif

	}
}
