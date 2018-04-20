using UnityEngine;
using System.Collections;
using UnityEditor;

[CustomEditor(typeof(BoxCollider2D))]
public class BoxCollider2DEditor : Collider2DEditor{

    private float _oldSizeX=0;
    private float _oldSizeY=0;

    private float _oldCenterX=0;
    private float _oldCenterY=0;

    private BoxCollider2D _boxColl;

    public BoxCollider2DEditor():base("BoxCollider2DEditor"){}

    override protected void OnEnable(){
        base.OnEnable();
        _boxColl = _collider as BoxCollider2D;
		_oldCenterX=_boxColl.offset.x;
		_oldCenterY=_boxColl.offset.y;
		_oldSizeX=_boxColl.size.x;
		_oldSizeY=_boxColl.size.y;
    }

    public override void OnInspectorGUI(){
        base.OnInspectorGUI();
        changeDensityHandler();
        changeTriggerHandler();
        changeCenterHandler();
        changeShapeHandler();
    }

    override protected void changeCenterHandler(){
        if(_isEnableCustom){
            if(_boxColl.offset.x!=_oldCenterX||_boxColl.offset.y!=_oldCenterY){
                object[] args=new object[5];
                args [0] = _collider;
                args [1] = _boxColl.offset.x;
                args [2] = _boxColl.offset.y;
				args [3] = _oldCenterX;
				args [4] = _oldCenterY;
                if(Application.isPlaying){
                    _targetGameObj.SendMessage("onEditShapeCenter", args);
                }
                _oldCenterX=_boxColl.offset.x;
                _oldCenterY=_boxColl.offset.y;
            }
        }
    }
    
    override protected void changeShapeHandler(){
        if(_isEnableCustom){
            if(_boxColl.size.x!=_oldSizeX||_boxColl.size.y!=_oldSizeY){
                object[] args=new object[3];
                args [0] = _collider;
                args [1] = _boxColl.size.x;
                args [2] = _boxColl.size.y;
                if(Application.isPlaying){
                    _targetGameObj.SendMessage("onEditShape", args);
                }
                _oldSizeX=_boxColl.size.x;
                _oldSizeY=_boxColl.size.y;
            }
            
        }
    }
}

