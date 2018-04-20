using UnityEditor;
using UnityEngine;
[CanEditMultipleObjects]
public class Collider2DEditor:DecoratorEditor {
	protected bool _isEnableCustom;
	protected Collider2D _collider;
    protected float _density=1;
    protected float _oldDensity=1;
    protected GameObject _targetGameObj;

    protected bool _oldIsTrigger = false;

    public Collider2DEditor (string editorTypeName):base(editorTypeName){
    }

	virtual protected void OnEnable(){
		_collider = target as Collider2D;
        _targetGameObj=_collider.gameObject;
        _isEnableCustom=_collider.GetComponent<b2BodyObject>()!=null&&_targetGameObj.activeSelf&&_collider.enabled;
		_oldIsTrigger=_collider.isTrigger;

	}

    public override void OnInspectorGUI(){
        base.OnInspectorGUI();
    }

    protected void changeDensityHandler(){
        if(_isEnableCustom){
            _density=EditorGUILayout.FloatField("Density",_density);
            if(_density!=_oldDensity){
                object[] args=new object[2];
                args [0] = _collider;
                args [1] = _density;
                if(Application.isPlaying){
                    _targetGameObj.SendMessage("onEditColliderDensity", args);
                }
                _oldDensity=_density;
            }
        }
    }

    protected void changeTriggerHandler(){
        if(_isEnableCustom){
            if(_collider.isTrigger!=_oldIsTrigger){
                object[] args=new object[2];
                args [0] = _collider;
                args [1] = _collider.isTrigger;
                if(Application.isPlaying){
                    _targetGameObj.SendMessage("onEditColliderTrigger", args);
                }
                _oldIsTrigger=_collider.isTrigger;
            }
        }
    }

    virtual protected void changeCenterHandler(){
        
    }
    
    virtual protected void changeShapeHandler(){
        
    }



}
