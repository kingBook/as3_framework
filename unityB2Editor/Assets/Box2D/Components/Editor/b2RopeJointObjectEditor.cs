using Box2D.Common.Math;
using UnityEditor;
using UnityEngine;
[CanEditMultipleObjects]
[CustomEditor(typeof(b2RopeJointObject))]
public class b2RopeJointObjectEditor : b2JointObjectEditor {

	private b2RopeJointObject _ropeJointObject;

	private bool _oldAutoConfigureAnchor;
	private b2Vec2 _oldLocalAnchor1=new b2Vec2();
	private b2Vec2 _oldLocalAnchor2=new b2Vec2();
	private float _oldMaxLength;

	protected override void OnEnable() {
		base.OnEnable();
		_ropeJointObject=_jointObject as b2RopeJointObject;
		_oldAutoConfigureAnchor=_ropeJointObject.autoConfigureAnchor;
        fixAutoAnchor();
		_oldLocalAnchor1.SetV(_ropeJointObject.localAnchor1);
		_oldLocalAnchor2.SetV(_ropeJointObject.localAnchor2);
		_oldMaxLength=_ropeJointObject.maxLength;
	}

	public override void OnInspectorGUI() {
		base.OnInspectorGUI();

		if(!_ropeJointObject.enabled)return;

		bool isReCreate=false;

		if(_oldAutoConfigureAnchor!=_ropeJointObject.autoConfigureAnchor){
			isReCreate=true;
			_oldAutoConfigureAnchor=_ropeJointObject.autoConfigureAnchor;
			fixAutoAnchor();
		}
		
		if(_ropeJointObject.autoConfigureAnchor){
			_ropeJointObject.localAnchor1.SetV(_oldLocalAnchor1);
			_ropeJointObject.localAnchor2.SetV(_oldLocalAnchor2);
		}else{
			if(_oldLocalAnchor1.x!=_ropeJointObject.localAnchor1.x||_oldLocalAnchor1.y!=_ropeJointObject.localAnchor1.y){
				isReCreate=true;
				_oldLocalAnchor1.SetV(_ropeJointObject.localAnchor1);
			}
			if(_oldLocalAnchor2.x!=_ropeJointObject.localAnchor2.x||_oldLocalAnchor2.y!=_ropeJointObject.localAnchor2.y){
				isReCreate=true;
				_oldLocalAnchor2.SetV(_ropeJointObject.localAnchor2);
			}
		}
		if(_oldMaxLength!=_ropeJointObject.maxLength){
			isReCreate=true;
			_oldMaxLength=_ropeJointObject.maxLength;
		}

		if(isReCreate) sendReCreateMessage();
	}

	override protected void onChangeConnectedB2BodyObject(b2BodyObject oldConnectedB2BodyObject,b2BodyObject newConnectedB2BodyObject){
		//变更链接的刚体时，移除、添加
		if(oldConnectedB2BodyObject!=null){
           oldConnectedB2BodyObject.removeJointObject(_ropeJointObject);
        }
		if(newConnectedB2BodyObject!=null){
			newConnectedB2BodyObject.addJointObject(_ropeJointObject);
		}
		fixAutoAnchor();
    }

	private void fixAutoAnchor(){
		if(!_ropeJointObject.autoConfigureAnchor)return;
		//更新anchor
		_ropeJointObject.updateAutoAnchor();
		//记录新的anchor
		_oldLocalAnchor1.SetV(_ropeJointObject.localAnchor1);
		_oldLocalAnchor2.SetV(_ropeJointObject.localAnchor2);
	}

}
