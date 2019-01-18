using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEditorInternal;
using UnityEngine;
[CustomEditor(typeof(CharPoints))]
public class CharPointsEditor:Editor{
    private CharPoints _asTarget;
    private ReorderableList _reorderableList;

	private const float SnapDistance=10;
	private int _nearestID;
	private int _editID;

    private void OnEnable() {
        _asTarget=target as CharPoints;
        
        _reorderableList=new ReorderableList(serializedObject,serializedObject.FindProperty("_paths"),true,true,true,true);
        _reorderableList.drawHeaderCallback=drawHeader;
        _reorderableList.drawElementCallback=drawElement;
        _reorderableList.elementHeightCallback=getElementHeight;
		_reorderableList.onAddCallback=onAdd;
		_reorderableList.onReorderCallback=onReorder;
    }

    private void drawHeader(Rect rect){
        EditorGUI.LabelField(rect,"paths");
    }

    private void drawElement(Rect rect,int index,bool selected,bool focused){
        SerializedProperty element = _reorderableList.serializedProperty.GetArrayElementAtIndex(index);
		rect.height = EditorGUIUtility.singleLineHeight;
		EditorGUI.PropertyField(rect,element,GUIContent.none);
    }

    private float getElementHeight(int index) {
        //计算子列表所占高度
		SerializedProperty element = _reorderableList.serializedProperty.GetArrayElementAtIndex(index);
        var list=element.FindPropertyRelative("list");
        int length=Mathf.Max(list.arraySize,1);
		return EditorGUIUtility.singleLineHeight * (length + 2) + 5 * (length + 2);
	}

    private void onAdd(ReorderableList list) {
		int listID = list.count;

		var gameObjPos=_asTarget.gameObject.transform.position;
        Vector2Array vector2s=new Vector2Array();
		vector2s.Add(new Vector2(-1+gameObjPos.x,-1+gameObjPos.y));
		vector2s.Add(new Vector2(1+gameObjPos.x,1+gameObjPos.y));

        vector2s.listID=listID;//记录Drawer中使用的id
		_asTarget.paths.Add(vector2s);
		list.index = list.count;//焦点移到最后一项
	}

	private void onReorder(ReorderableList list) {
		
	}

    public override void OnInspectorGUI() {
        _reorderableList.DoLayoutList();
        serializedObject.ApplyModifiedProperties();
		serializedObject.Update();
        //base.OnInspectorGUI();
    }

    private void OnSceneGUI() {
        if(_asTarget.isActiveAndEnabled){
			for(int i=0;i<_asTarget.paths.Count;i++){
				Vector2Array stroke=_asTarget.paths[i];
				if(stroke.isEdit){
					if(stroke.Count>=2){
						onSceneGUIeditPointsHandler(ref stroke);
					}
				}
			}
		}
    }

    private void OnDisable() {
		
    }

	private void onSceneGUIeditPointsHandler(ref Vector2Array points){
		HandleUtility.Repaint();
		
		//鼠标位置
		var mousePos=Event.current.mousePosition;
		mousePos=HandleUtility.GUIPointToWorldRay(mousePos).origin;

		//寻找最近线段
		Vector2[] nearestLineSegment=new Vector2[2];
		findSetNearestLineSegment(mousePos,ref points,ref nearestLineSegment);

		if(Event.current.isMouse) {
			EventType eventType=Event.current.type;
			bool isMousePress=false;
			if(Event.current.button==0){
				if(eventType==EventType.MouseDown){
					isMousePress=true;
					var mouseGUI=HandleUtility.WorldToGUIPoint(mousePos);
					var nearestGUI0=HandleUtility.WorldToGUIPoint(nearestLineSegment[0]);
					var nearestGUI1=HandleUtility.WorldToGUIPoint(nearestLineSegment[1]);
					//float mouseToNearestLineSegment=HandleUtility.DistancePointToLineSegment(mouseGUI,nearestGUI0,nearestGUI1);
					float d0=Vector2.Distance(mouseGUI,nearestGUI0);
					float d1=Vector2.Distance(mouseGUI,nearestGUI1);
					if(d0<=SnapDistance){
						Debug.Log("d0<=SnapDistance");
						if(Event.current.control){
							deletePointWithIndex(ref points,_nearestID);
						}else{
							_editID=_nearestID;
						}
					}else if(d1<=SnapDistance){
						Debug.Log("d1<=SnapDistance");
						int lineEndId=_nearestID+1<=points.Count-1?_nearestID+1:0;
						if(Event.current.control){
							deletePointWithIndex(ref points,lineEndId);
						}else{
							_editID=lineEndId;
						}
					}else{
						Debug.Log("Insert");
						Undo.RecordObject(_asTarget,"add point");
						points.Insert(_nearestID+1,new Vector2(mousePos.x,mousePos.y));
						findSetNearestLineSegment(mousePos,ref points,ref nearestLineSegment);
						_editID=_nearestID+1;
					}
				}else if(eventType==EventType.MouseUp){
					isMousePress=false;
					_editID=-1;
				}

				if(!isMousePress){//鼠标没有按下时
					//设置控制柄到最近线段的垂线
					var perp=getPerpendicularPt(mousePos.x,mousePos.y,nearestLineSegment[0].x,nearestLineSegment[0].y,nearestLineSegment[1].x,nearestLineSegment[1].y);
					var perpGUI=HandleUtility.WorldToGUIPoint(perp);
					var nearestGUI0=HandleUtility.WorldToGUIPoint(nearestLineSegment[0]);
					var nearestGUI1=HandleUtility.WorldToGUIPoint(nearestLineSegment[1]);
					float perpToNearestLineSegment=HandleUtility.DistancePointToLineSegment(perpGUI,nearestGUI0,nearestGUI1);
					float d0=Vector2.Distance(perpGUI,nearestGUI0);
					float d1=Vector2.Distance(perpGUI,nearestGUI1);
					var cpt=new Vector2(mousePos.x,mousePos.y);
					//垂足不能滑出线段
					/*if(perpToNearestLineSegment>0.01f){
						if(d0<d1)perp.Set(nearestLineSegment[0].x,nearestLineSegment[0].y);
						else perp.Set(nearestLineSegment[1].x,nearestLineSegment[1].y);
					}*/
					//操作点贴紧端点
					if(d0<d1){
						if(d0<=SnapDistance)cpt.Set(nearestLineSegment[0].x,nearestLineSegment[0].y);
					}else{
						if(d1<=SnapDistance)cpt.Set(nearestLineSegment[1].x,nearestLineSegment[1].y);
					}
					_asTarget.point.Set(cpt.x,cpt.y);
				}
			}
		}
		editPointHandler(ref points);
		//画点列表
		drawPoints(ref points,false);
	}
    private void deletePointWithIndex(ref Vector2Array points,int index){
		if(points.Count<3)return;
		Undo.RecordObject(_asTarget,"delete point");
		points.RemoveAt(index);
	}
	private void findSetNearestLineSegment(Vector2 refPoint,ref Vector2Array points,ref Vector2[] nearestLineSegment){
		int count=points.Count;
		float nearestLineDistance=1e6f;
		for(int i=0;i<count;i++){
			var p1=points[i];
			var p2=points[(i+1<count)?i+1:0];

			var perp=getPerpendicularPt(refPoint.x,refPoint.y,p1.x,p1.y,p2.x,p2.y);
			if(onSegment(perp.x,perp.y,p1.x,p1.y,p2.x,p2.y)){
				float distance=HandleUtility.DistancePointToLine(refPoint,p1,p2);
				if(distance<nearestLineDistance){
					nearestLineDistance=distance;
					_nearestID=i;
					nearestLineSegment[0]=p1;
					nearestLineSegment[1]=p2;
				}
			}
		}
	}
	private void editPointHandler(ref Vector2Array points){
		//Handles.Label(_asTarget.point,string.Format("({0},{1})",_asTarget.point.x,_asTarget.point.y));
		EditorGUI.BeginChangeCheck();
		float size=HandleUtility.GetHandleSize(_asTarget.point)*0.05f;
		var snap=Vector2.one*0.05f;
		var newPoint=Handles.FreeMoveHandle(_asTarget.point,Quaternion.identity,size,snap,Handles.DotHandleCap);
		if(EditorGUI.EndChangeCheck()){
			Undo.RecordObject(_asTarget,"edit point");//记录更改，实现撤消回退
			_asTarget.point=newPoint;
			if(_editID>-1){
				points[_editID]=newPoint;
			}
		}
	}
	private void drawPoints(ref Vector2Array points,bool isCap=true){
		int count=points.Count;
		for(int i=0;i<count;i++){ 
			Handles.Label(points[i],string.Format("{0}",i));
			if(!isCap){
				if(i>=count-1)break;
			}
			var p1=points[i];
			var p2=points[(i+1<count)?i+1:0];
			if(i==_nearestID){
				Handles.color=new Color(0,1,0);
			}else{
				Handles.color=new Color(0.5f,1,0.5f);
			}
			Handles.DrawLine(p1,p2);
		}
	}
	private Vector2 getPerpendicularPt(float x,float y,float x1,float y1,float x2,float y2){
		//以x1,y1为坐标原点得到向量a，b
		var ax=x-x1;
		var ay=y-y1;
		var bx=x2-x1;
		var by=y2-y1;
		//求向量a,b的点积
		var dot=ax*bx+ay*by;
		//向量b模的平方
		//var bl=Math.sqrt(bx*bx+by*by);
		//var sq=bl*bl;
		//简化
		var sq=bx*bx+by*by;
		//垂点
		var l=dot/sq;
		var ppx=l*bx;
		var ppy=l*by;
		ppx+=x1;
		ppy+=y1;
		//
		return new Vector2(ppx,ppy);
	}

	/**点在线段上的关系最好以0.1小数误差判断*/
	private float getPointOnLine(float x,float y,float x1,float y1,float x2,float y2){
		float ax = x2-x1;
		float ay = y2-y1;
			
		float bx = x-x1;
		float by = y-y1;
		return ax*by-ay*bx;
	}

	private bool onSegment(float x,float y,float x1,float y1,float x2,float y2){
		return Mathf.Min(x1,x2)<x&&x<Mathf.Max(x1,x2)&&Mathf.Min(y1,y2)<y&&y<Mathf.Max(y1,y2);
	}

}
