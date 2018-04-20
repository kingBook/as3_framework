using UnityEditor;
using UnityEngine;

[CustomEditor(typeof(PolygonCollider2D))]
public class PolygonCollider2DEditor:Collider2DEditor{
	
	private float _oldCenterX=0;
    private float _oldCenterY=0;

    private PolygonCollider2D _polyColl;
    private Vector2[] _oldPoints;

#if UNITY_5 || UNITY_5_0 || UNITY_5_0_1 || UNITY_2017
    public PolygonCollider2DEditor() : base("PolygonCollider2DEditor") { }
#else
    public PolygonCollider2DEditor() : base("PolygonColliderEditor") { }
#endif



    override protected void OnEnable(){
        base.OnEnable();
        _polyColl = _collider as PolygonCollider2D;
		_oldCenterX=_polyColl.offset.x;
		_oldCenterY=_polyColl.offset.y;
        _oldPoints=(Vector2[])_polyColl.points.Clone();
    }

    public override void OnInspectorGUI(){
        base.OnInspectorGUI();
        changeDensityHandler();
        changeTriggerHandler();
		changeCenterHandler();
        changeShapeHandler();
    }

    override protected void changeShapeHandler(){
        if(_isEnableCustom){
            Vector2[] points=_polyColl.points;
            bool isChange=false;
            if(points.Length!=_oldPoints.Length){
                isChange=true;
            }else{
                for(int i=0;i<points.Length;i++){
                    if(_oldPoints[i].x!=points[i].x || _oldPoints[i].y!=points[i].y){
                        isChange=true;
                        break;
                    }
                }
            }
            if(isChange){
                object[] args=new object[2];
                args [0] = _collider;
                args [1] = points;
                if(Application.isPlaying){
                    _targetGameObj.SendMessage("onEditShape", args);
                }
                _oldPoints=(Vector2[])points.Clone();
            }  
        }
    }

	override protected void changeCenterHandler(){
        if(_isEnableCustom){
            if(_polyColl.offset.x!=_oldCenterX||_polyColl.offset.y!=_oldCenterY){
                object[] args=new object[5];
                args [0] = _collider;
                args [1] = _polyColl.offset.x;
                args [2] = _polyColl.offset.y;
				args [3] = _oldCenterX;
				args [4] = _oldCenterY;
                if(Application.isPlaying){
                    _targetGameObj.SendMessage("onEditShapeCenter", args);
					_oldPoints=(Vector2[])_polyColl.points.Clone();
                }
                _oldCenterX=_polyColl.offset.x;
                _oldCenterY=_polyColl.offset.y;
            }
        }
    }

}
