using Box2D.Common.Math;
using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;
[CustomEditor(typeof(b2RevoluteJointObject))]
public class b2RevoluteJointObjectEditor : b2JointObjectEditor {
    
	private bool _oldAutoConfigureAnchor;
	
	private b2Vec2 _oldLocalAnchor1=new b2Vec2();
	private b2Vec2 _oldLocalAnchor2=new b2Vec2();

	private bool _oldEnableLimit;
	private float _oldReferenceAngle;
	private float _oldLowerAngle;
	private float _oldUpperAngle;

	private bool _oldEnableMotor;
	private float _oldMotorSpeed;
	private float _oldMaxMotorTorque;

	private b2RevoluteJointObject _revoluteJointObject;
	
	protected override void OnEnable() {
		base.OnEnable();
		_revoluteJointObject=_jointObject as b2RevoluteJointObject;

		_oldAutoConfigureAnchor=_revoluteJointObject.autoConfigureAnchor;
        fixAutoAnchor();

		_oldLocalAnchor1.SetV(_revoluteJointObject.localAnchor1);
		_oldLocalAnchor2.SetV(_revoluteJointObject.localAnchor2);

		_oldEnableLimit=_revoluteJointObject.enableLimit;
		_oldReferenceAngle=_revoluteJointObject.referenceAngle;
		_oldLowerAngle=_revoluteJointObject.lowerAngle;
		_oldUpperAngle=_revoluteJointObject.upperAngle;

		_oldEnableMotor=_revoluteJointObject.enableMotor;
		_oldMotorSpeed=_revoluteJointObject.motorSpeed;
		_oldMaxMotorTorque=_revoluteJointObject.maxMotorTorque;

        //添加到链接的bodyObject关节列表
        if(_revoluteJointObject.connectedB2BodyObject!=null)_revoluteJointObject.connectedB2BodyObject.addJointObject(_revoluteJointObject);
	}

	public override void OnInspectorGUI() {
		base.OnInspectorGUI();
		if(!_revoluteJointObject.enabled)return;

		bool isChanged=false;
		bool isReCreate=false;
		
		if(_oldAutoConfigureAnchor!=_revoluteJointObject.autoConfigureAnchor){
			isChanged=true;
			_oldAutoConfigureAnchor=_revoluteJointObject.autoConfigureAnchor;
			fixAutoAnchor();
		}
        //不允许编辑anchor
		if(_revoluteJointObject.autoConfigureAnchor){
            if(_oldLocalAnchor1.x!=_revoluteJointObject.localAnchor1.x||_oldLocalAnchor1.y!=_revoluteJointObject.localAnchor1.y){
                _revoluteJointObject.localAnchor1.SetV(_oldLocalAnchor1);
			}
            if(_oldLocalAnchor2.x!=_revoluteJointObject.localAnchor2.x||_oldLocalAnchor2.y!=_revoluteJointObject.localAnchor2.y){
                _revoluteJointObject.localAnchor2.SetV(_oldLocalAnchor2);
			}
		}else{
			if(_oldLocalAnchor1.x!=_revoluteJointObject.localAnchor1.x||_oldLocalAnchor1.y!=_revoluteJointObject.localAnchor1.y){
				isReCreate=true;
				_oldLocalAnchor1.SetV(_revoluteJointObject.localAnchor1);
			}
			if(_oldLocalAnchor2.x!=_revoluteJointObject.localAnchor2.x||_oldLocalAnchor2.y!=_revoluteJointObject.localAnchor2.y){
				isReCreate=true;
				_oldLocalAnchor2.SetV(_revoluteJointObject.localAnchor2);
			}
		}

		if(_oldEnableLimit!=_revoluteJointObject.enableLimit){
			isChanged=true;
			_oldEnableLimit=_revoluteJointObject.enableLimit;
		}
		if(_oldReferenceAngle!=_revoluteJointObject.referenceAngle){
			isReCreate=true;
			_oldReferenceAngle=_revoluteJointObject.referenceAngle;
		}
		if(_oldLowerAngle!=_revoluteJointObject.lowerAngle){
			isReCreate=true;
			_oldLowerAngle=_revoluteJointObject.lowerAngle;
		}
		if(_oldUpperAngle!=_revoluteJointObject.upperAngle){
			isReCreate=true;
			_oldUpperAngle=_revoluteJointObject.upperAngle;
		}


		if(_oldEnableMotor!=_revoluteJointObject.enableMotor){
			isChanged=true;
			_oldEnableMotor=_revoluteJointObject.enableMotor;
		}
		if(_oldMotorSpeed!=_revoluteJointObject.motorSpeed){
			isChanged=true;
			_oldMotorSpeed=_revoluteJointObject.motorSpeed;
		}
		if(_oldMaxMotorTorque!=_revoluteJointObject.maxMotorTorque){
			isChanged=true;
			_oldMaxMotorTorque=_revoluteJointObject.maxMotorTorque;
		}

		if(isReCreate) {
			sendReCreateMessage();
		}else if(isChanged){
			sendChangeMessage();
		}

		
	}

	override protected void onChangeConnectedB2BodyObject(b2BodyObject oldConnectedB2BodyObject,b2BodyObject newConnectedB2BodyObject){
		//变更链接的刚体时，移除、添加
		if(oldConnectedB2BodyObject!=null){
           oldConnectedB2BodyObject.removeJointObject(_revoluteJointObject);
        }
		if(newConnectedB2BodyObject!=null){
			newConnectedB2BodyObject.addJointObject(_revoluteJointObject);
		}
		fixAutoAnchor();
    }

	private void fixAutoAnchor(){
		if(!_revoluteJointObject.autoConfigureAnchor)return;
		//更新anchor
		_revoluteJointObject.updateAutoAnchor();
		//记录新的anchor
		_oldLocalAnchor1.SetV(_revoluteJointObject.localAnchor1);
		_oldLocalAnchor2.SetV(_revoluteJointObject.localAnchor2);
	}
}
