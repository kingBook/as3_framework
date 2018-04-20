using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
[CanEditMultipleObjects]
public class b2JointObjectEditor : Editor {
	protected b2JointObject _jointObject;
	protected GameObject _targetGameObj;

	protected bool _oldEnableCollision;
	protected b2BodyObject _oldConnectedB2BodyObject;

	virtual protected void OnEnable() {
		_jointObject = target as b2JointObject;
		_targetGameObj=_jointObject.gameObject;
		//
		_oldEnableCollision=_jointObject.enableCollision;
		_oldConnectedB2BodyObject=_jointObject.connectedB2BodyObject;
	}

	public override void OnInspectorGUI() {
		base.OnInspectorGUI();
		if(!_jointObject.enabled)return;

		bool isChanged=false;
		bool isReCreate=false;
		if(_oldEnableCollision!=_jointObject.enableCollision){
			isChanged=true;
			_oldEnableCollision=_jointObject.enableCollision;
		}
		if(_oldConnectedB2BodyObject!=_jointObject.connectedB2BodyObject){
			isReCreate=true;
			//不能设置为bodyA
			if(_jointObject.connectedB2BodyObject!=null){
				b2BodyObject bodyObjectA=_jointObject.GetComponent<b2BodyObject>();
				if(bodyObjectA==_jointObject.connectedB2BodyObject){
					_jointObject.connectedB2BodyObject=null;
					Debug.LogError("cannot be set to itself");
				}
			}
            onChangeConnectedB2BodyObject(_oldConnectedB2BodyObject,_jointObject.connectedB2BodyObject);
			_oldConnectedB2BodyObject=_jointObject.connectedB2BodyObject;
		}

		if(isReCreate){
			sendReCreateMessage();
		}else if(isChanged){
			sendChangeMessage();
		}
	}

	/**在改变链接的刚体之前*/
	virtual protected void onChangeConnectedB2BodyObject(b2BodyObject oldConnectedB2BodyObject,b2BodyObject newConnectedB2BodyObject){

    }

	protected void sendChangeMessage(){
		if(Application.isPlaying) _targetGameObj.SendMessage("onChange");
	}

	protected void sendReCreateMessage(){
		if(Application.isPlaying) _targetGameObj.SendMessage("onReCreate");
	}
	

}
