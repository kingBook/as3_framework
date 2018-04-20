using UnityEngine;
using System.Collections;
using UnityEditor;

[CustomEditor(typeof(CircleCollider2D))]
public class CircleCollider2DEditor:Collider2DEditor {

    private float _oldCenterX=0;
    private float _oldCenterY=0;

    private float _oldRadius=0;
    
    private CircleCollider2D _circleColl;

    public CircleCollider2DEditor():base("CircleCollider2DEditor"){}

    override protected void OnEnable(){
        base.OnEnable();
        _circleColl = _collider as CircleCollider2D;
		_oldCenterX=_circleColl.offset.x;
		_oldCenterY=_circleColl.offset.y;
		_oldRadius=_circleColl.radius;
    }

    public override void OnInspectorGUI(){
        base.OnInspectorGUI();
        changeDensityHandler();
        changeTriggerHandler();
        changeCenterHandler();
        changeShapeHandler();
    }

    protected override void changeCenterHandler(){
        if(_isEnableCustom){
            if(_circleColl.offset.x!=_oldCenterX||_circleColl.offset.y!=_oldCenterY){
                object[] args=new object[5];
                args [0] = _collider;
                args [1] = _circleColl.offset.x;
                args [2] = _circleColl.offset.y;
				args [3] = _oldCenterX;
				args [4] = _oldCenterY;
                if(Application.isPlaying){
                    _targetGameObj.SendMessage("onEditShapeCenter", args);
                }
                _oldCenterX=_circleColl.offset.x;
                _oldCenterY=_circleColl.offset.y;
            }
        }
    }

    override protected void changeShapeHandler(){
        if(_isEnableCustom){
            if(_circleColl.radius!=_oldRadius){
                object[] args=new object[4];
                args [0] = _collider;
                args [1] = _circleColl.radius;
				args [2] = _circleColl.offset.x;
                args [3] = _circleColl.offset.y;
                if(Application.isPlaying){
                    _targetGameObj.SendMessage("onEditShape", args);
                }
                _oldRadius=_circleColl.radius;
            }
        }
    }
}
