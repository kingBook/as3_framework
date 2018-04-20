using UnityEditor;
using UnityEngine;

[CanEditMultipleObjects]
[CustomEditor(typeof(b2BodyObject))]
public class b2BodyObjectEditor : Editor {
	private b2BodyObject _bodyObj;

	private Transform _targetT;
	private Vector3 _oldPosition;
	private Vector3 _oldEulerAngles;
	private Vector3 _oldScale;

	void OnEnable(){
		_bodyObj = target as b2BodyObject;
		_targetT=_bodyObj.GetComponent<Transform>();

		_oldPosition=_targetT.position;
		_oldEulerAngles=_targetT.rotation.eulerAngles;
		_oldScale=_targetT.localScale;
	}

	void OnSceneGUI(){
		//Debug.Log ("OnSceneGUI");
		_bodyObj.SetIsOnUnityEditing(true);
		_bodyObj.setBodyPosWithUnityWorld();
		checkChangeTransform();
	}

	void OnDisable(){
		//Debug.Log ("OnDisable");
	}


	override public void OnInspectorGUI(){
		base.OnInspectorGUI ();
		//Debug.Log ("OnInspectorGUI");
		checkChangeTransform();
	}

	private void checkChangeTransform(){
		bool isChanged=false;
		if(_oldPosition!=_targetT.position){
			isChanged=true;
			_oldPosition=_targetT.position;
		}
		if(_oldEulerAngles!=_targetT.rotation.eulerAngles){
			isChanged=true;
			_oldEulerAngles=_targetT.rotation.eulerAngles;
		}
		if(_oldScale!=_targetT.localScale){
			isChanged=true;
			_oldScale=_targetT.localScale;
		}

		if(isChanged){
			//位置、大小、旋转发生变化时更新链接关节的数据
			_bodyObj.updateLinkJointObjectDatas();
		}
	}


    void OnDestroy(){

    }
}
