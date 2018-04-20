using Box2D.Dynamics.Joints;
using System.Collections;
using System.Collections.Generic;
using Box2D.Common.Math;
using Box2D.Dynamics;
using UnityEditor;

namespace UnityEngine {
	[AddComponentMenu("b2Components/b2RevoluteJointObject",3)]
	public class b2RevoluteJointObject:b2JointObject {
		[Tooltip("auto configure anchor")]
		public bool autoConfigureAnchor=true;
		public b2Vec2 localAnchor1=new b2Vec2();
		public b2Vec2 localAnchor2=new b2Vec2();

		public bool enableLimit;
        [Range(0,2*Mathf.PI)]
		public float referenceAngle=0;
        [Range(-2*Mathf.PI,0)]
		public float lowerAngle=0;
        [Range(0,2*Mathf.PI)]
		public float upperAngle=0;

		public bool enableMotor;
		public float motorSpeed=0;
		public float maxMotorTorque=0;
		
		private b2RevoluteJoint _revoluteJoint;

		protected override void Start(){
			base.Start();
			
			create();
		}

		private void create(){
			b2Body bodyB;
			if(connectedB2BodyObject==null) bodyB=_world.GetGroundBody();
			else bodyB=connectedB2BodyObject.body;

			b2RevoluteJointDef jointDef=new b2RevoluteJointDef();
			jointDef.Initialize(_bodyObject.body,bodyB,new b2Vec2());
			jointDef.collideConnected=enableCollision;

			jointDef.enableLimit=enableLimit;
			jointDef.referenceAngle=referenceAngle;
			jointDef.lowerAngle=lowerAngle;
			jointDef.upperAngle=upperAngle;
			
			jointDef.enableMotor=enableMotor;
			jointDef.motorSpeed=motorSpeed;
			jointDef.maxMotorTorque=maxMotorTorque;
			
			_joint=_world.CreateJoint(jointDef);
			_revoluteJoint=_joint as b2RevoluteJoint;

			_revoluteJoint.m_localAnchor1.SetV(localAnchor1);
			_revoluteJoint.m_localAnchor2.SetV(localAnchor2);

			_revoluteJoint.GetBodyA().SetAwake(true);
			_revoluteJoint.GetBodyB().SetAwake(true);

		}

		protected override void OnDestroy() {
#if UNITY_EDITOR
			if(connectedB2BodyObject!=null)connectedB2BodyObject.removeJointObject(this);
#endif
			base.OnDestroy();
		}

#if UNITY_EDITOR
		public void updateAutoAnchor(){
			if(autoConfigureAnchor){ 
				Vector3 myPos=GetComponent<Transform>().position;
				Transform connectedT=null;
				Vector3 connectedPos=myPos;
				if(connectedB2BodyObject != null){
					connectedT=connectedB2BodyObject.GetComponent<Transform>();
					connectedPos=connectedT.position;
				}
				float localAnchor1X=0,localAnchor1Y=0;
				float localAnchor2X=myPos.x-connectedPos.x,localAnchor2Y=myPos.y-connectedPos.y;
				if(connectedT!=null) {
					Quaternion q=Quaternion.Euler(0,0,-connectedT.rotation.eulerAngles.z);
					Vector2 p=new Vector2(localAnchor2X,localAnchor2Y);
					p=q*p;
					localAnchor2X=p.x;
					localAnchor2Y=p.y;
				}
				localAnchor1.Set(localAnchor1X,localAnchor1Y);
				localAnchor2.Set(localAnchor2X,localAnchor2Y);
			}
		}

		protected override void onChange() {
			base.onChange();
			_revoluteJoint.EnableLimit(enableLimit);

			_revoluteJoint.EnableMotor(enableMotor);
			_revoluteJoint.SetMotorSpeed(motorSpeed);
			_revoluteJoint.SetMaxMotorTorque(maxMotorTorque);

			_revoluteJoint.GetBodyA().SetAwake(true);
			_revoluteJoint.GetBodyB().SetAwake(true);
		}

		protected override void onReCreate() {
			base.onReCreate();
			create();
		}

		protected override void OnDrawGizmosSelected() {
			base.OnDrawGizmosSelected();
			if(enabled){
				//local anchor1
				Vector2 p1=drawLocalPointPlusSign(localAnchor1,transform);
				//local anchor2
				if(connectedB2BodyObject!=null){
					Vector2 p2=drawLocalPointPlusSign(localAnchor2,connectedB2BodyObject.transform);
					drawLine(p1,p2);
				}
			}
		}

#endif
	}
}