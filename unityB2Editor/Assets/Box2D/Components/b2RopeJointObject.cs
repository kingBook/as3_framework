using Box2D.Common.Math;
using Box2D.Dynamics;
using Box2D.Dynamics.Joints;
using System.Collections;
using System.Collections.Generic;

namespace UnityEngine{
	[AddComponentMenu("b2Components/b2RopeJointObject",3)]
	public class b2RopeJointObject:b2JointObject {
		[Tooltip("auto configure anchor")]
		public bool autoConfigureAnchor=true;
		public b2Vec2 localAnchor1=new b2Vec2();
		public b2Vec2 localAnchor2=new b2Vec2();
		[Range(0.02f,1e4f)]
		public float maxLength=0.02f;

		private b2RopeJoint _ropeJoint;
		
		protected override void Start() {
			base.Start();
			
			create();
		}

		private void create(){
			b2Body bodyB;
			if(connectedB2BodyObject==null) bodyB=_world.GetGroundBody();
			else bodyB=connectedB2BodyObject.body;

			b2RopeJointDef jointDef=new b2RopeJointDef();
			b2Vec2 anchorA=_bodyObject.body.GetWorldPoint(localAnchor1);
			b2Vec2 anchorB=bodyB.GetWorldPoint(localAnchor2); 
			anchorA.x=(float)System.Math.Round(anchorA.x,2);
			anchorA.y=(float)System.Math.Round(anchorA.y,2);
			anchorB.x=(float)System.Math.Round(anchorB.x,2);
			anchorB.y=(float)System.Math.Round(anchorB.y,2);

			jointDef.Initialize(_bodyObject.body,bodyB,anchorA,anchorB,maxLength);
			jointDef.collideConnected=enableCollision;
			_joint=_world.CreateJoint(jointDef);
			_ropeJoint=_joint as b2RopeJoint;

			_ropeJoint.GetBodyA().SetAwake(true);
			_ropeJoint.GetBodyB().SetAwake(true);
		}

#if UNITY_EDITOR
		public void updateAutoAnchor(){
			if(Application.isPlaying)return;//正在运行不允许调整
			if(autoConfigureAnchor){
				//自动设置锚点，两对象位置的中间
				Transform mt=GetComponent<Transform>();
				Quaternion mq=Quaternion.Euler(0,0,-mt.rotation.eulerAngles.z);
				Vector2 m=mq*mt.position;

				Vector2 o=m;
				Transform ot=null;
				if(connectedB2BodyObject != null){
					ot=connectedB2BodyObject.GetComponent<Transform>();
					Quaternion oq=Quaternion.Euler(0,0,-ot.rotation.eulerAngles.z);
					o=oq*ot.position;
				}

				Vector2 p=(m+o)*0.5f;
				Vector2 a1=p-m;
				Vector2 a2=p-o;
				
				a1.x=(float)System.Math.Round(a1.x,2);
				a1.y=(float)System.Math.Round(a1.y,2);
				a2.x=(float)System.Math.Round(a2.x,2);
				a2.y=(float)System.Math.Round(a2.y,2);

				localAnchor1.x=a1.x;
				localAnchor1.y=a1.y;
				localAnchor2.x=a2.x;
				localAnchor2.y=a2.y;
			}
		}

		protected override void onChange() {
			base.onChange();
		}

		protected override void onReCreate() {
			base.onReCreate();
			create();
		}

		protected override void OnDrawGizmosSelected() {
			base.OnDrawGizmosSelected();
			if(enabled){
				Vector2 p1=drawLocalPointPlusSign(localAnchor1,transform);
				if(connectedB2BodyObject!=null){
					Vector2 p2=drawLocalPointPlusSign(localAnchor2,connectedB2BodyObject.transform);
					drawLine(p1,p2);
				}
			}
		}
#endif
	}
}
