using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEditorInternal;
using UnityEngine;
[CustomEditor(typeof(LocalPoints))]
public class LocalPointsEditor : Editor{
    private LocalPoints _asTarget;
	private ReorderableList _reorderableList;

	private const float SnapDistance=4;
	private int _nearestID;
	private int _editID;
	private bool _isMousePress;

	private void OnEnable(){
        _asTarget=target as LocalPoints;

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
		vector2s.Add(new Vector2(-1,-1));
		vector2s.Add(new Vector2(1,1));

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
				if(stroke.Count>=2){
					if(stroke.isEdit){
						onSceneGUIEditPointsHandler(ref stroke);
					}else if(stroke.append){
						onSceneGUIAppendPointsHandler(ref stroke);
					}
				}
			}
		}
    }

    private void OnDisable() {
		
    }

	private void onSceneGUIAppendPointsHandler(ref Vector2Array points){
		HandleUtility.Repaint();
		var gameObjPos=_asTarget.gameObject.transform.position;
		//鼠标位置
		var mousePos=Event.current.mousePosition;
		mousePos=HandleUtility.GUIPointToWorldRay(mousePos).origin;
		if(Event.current.isMouse){
			EventType eventType=Event.current.type;
			if(Event.current.button==0){
				if(eventType==EventType.MouseDown){
					_isMousePress=true;
					if(_editID==-1){
						var mouseGUI=HandleUtility.WorldToGUIPoint(mousePos);
						//Debug.Log("Insert");
						Undo.RecordObject(_asTarget,"add point");
						points.Insert(points.Count,new Vector2(mousePos.x-gameObjPos.x,mousePos.y-gameObjPos.y));
						_editID=points.Count-1;
					}
				}else if(eventType==EventType.MouseUp){
					_isMousePress=false;
					_editID=-1;
				}
				if(!_isMousePress){//鼠标没有按下时
					var cpt=new Vector2(mousePos.x,mousePos.y);

					int nearestId=getNearestPointId(points,new Vector2(cpt.x-gameObjPos.x,cpt.y-gameObjPos.y));
					Vector2 nearestWorldPt=new Vector2(points[nearestId].x+gameObjPos.x,points[nearestId].y+gameObjPos.y);
					float d=Vector2.Distance(cpt,nearestWorldPt)*100;
					if(nearestId>-1 && d<=SnapDistance){
						cpt.Set(nearestWorldPt.x,nearestWorldPt.y);
						//Debug.Log("_editID:"+_editID);
						_editID=nearestId;
					}else{
						_editID=-1;
					}

					_asTarget.point.Set(cpt.x,cpt.y);
				}
			}
		}

		editPointHandler(ref points);
		//画点列表
		drawPoints(ref points,false);
	}

	private void onSceneGUIEditPointsHandler(ref Vector2Array points){
		HandleUtility.Repaint();
		var gameObjPos=_asTarget.gameObject.transform.position;
		//鼠标位置
		var mousePos=Event.current.mousePosition;
		mousePos=HandleUtility.GUIPointToWorldRay(mousePos).origin;
		var localMousePos=new Vector2(mousePos.x-gameObjPos.x,mousePos.y-gameObjPos.y);
		//寻找最近线段
		Vector2[] nearestLineSegment=new Vector2[2];
		findSetNearestLineSegment(localMousePos,ref points,ref nearestLineSegment);

		if(Event.current.isMouse) {
			EventType eventType=Event.current.type;
			if(Event.current.button==0){
				if(eventType==EventType.MouseDown){
					_isMousePress=true;
					var mouseGUI=HandleUtility.WorldToGUIPoint(mousePos);
					var nearestGUI0=HandleUtility.WorldToGUIPoint(new Vector2(nearestLineSegment[0].x+gameObjPos.x,nearestLineSegment[0].y+gameObjPos.y));
					var nearestGUI1=HandleUtility.WorldToGUIPoint(new Vector2(nearestLineSegment[1].x+gameObjPos.x,nearestLineSegment[1].y+gameObjPos.y));
					//float mouseToNearestLineSegment=HandleUtility.DistancePointToLineSegment(mouseGUI,nearestGUI0,nearestGUI1);
					float d0=Vector2.Distance(mouseGUI,nearestGUI0);
					float d1=Vector2.Distance(mouseGUI,nearestGUI1);
					if(_editID==-1){
						if(d0<=SnapDistance){
							//Debug.Log("d0<=SnapDistance");
							if(Event.current.control){
								deletePointWithIndex(ref points,_nearestID);
							}else{
								_editID=_nearestID;
							}
						}else if(d1<=SnapDistance){
							//Debug.Log("d1<=SnapDistance");
							int lineEndId=_nearestID+1<=points.Count-1?_nearestID+1:0;
							if(Event.current.control){
								deletePointWithIndex(ref points,lineEndId);
							}else{
								_editID=lineEndId;
							}
						}else{
							//Debug.Log("Insert id:"+(_nearestID+1));
							Undo.RecordObject(_asTarget,"add point");
							points.Insert(_nearestID+1,new Vector2(mousePos.x-gameObjPos.x,mousePos.y-gameObjPos.y));
							_editID=_nearestID+1;
							findSetNearestLineSegment(localMousePos,ref points,ref nearestLineSegment);
						}
					}
				}else if(eventType==EventType.MouseUp){
					_isMousePress=false;
					_editID=-1;
				}

				if(!_isMousePress){//鼠标没有按下时
					//设置控制柄到最近线段的垂线
					var perp=getPerpendicularPt(localMousePos.x,localMousePos.y,nearestLineSegment[0].x,nearestLineSegment[0].y,nearestLineSegment[1].x,nearestLineSegment[1].y);
					perp.Set(perp.x+gameObjPos.x,perp.y+gameObjPos.y);
					var perpGUI=HandleUtility.WorldToGUIPoint(perp);
					var nearestGUI0=HandleUtility.WorldToGUIPoint(new Vector2(nearestLineSegment[0].x+gameObjPos.x,nearestLineSegment[0].y+gameObjPos.y));
					var nearestGUI1=HandleUtility.WorldToGUIPoint(new Vector2(nearestLineSegment[1].x+gameObjPos.x,nearestLineSegment[1].y+gameObjPos.y));
					float perpToNearestLineSegment=HandleUtility.DistancePointToLineSegment(perpGUI,nearestGUI0,nearestGUI1);
					float d0=Vector2.Distance(perpGUI,nearestGUI0);
					float d1=Vector2.Distance(perpGUI,nearestGUI1);
					var cpt=new Vector2(mousePos.x,mousePos.y);
					//垂足不能滑出线段
					/*if(perpToNearestLineSegment>0.01f){
						if(d0<d1)perp.Set(nearestLineSegment[0].x+gameObjPos.x,nearestLineSegment[0].y+gameObjPos.y);
						else perp.Set(nearestLineSegment[1].x+gameObjPos.x,nearestLineSegment[1].y+gameObjPos.y);
					}*/
					//操作点贴紧端点
					int nearestId=getNearestPointId(points,new Vector2(cpt.x-gameObjPos.x,cpt.y-gameObjPos.y));
					Vector2 nearestWorldPt=new Vector2(points[nearestId].x+gameObjPos.x,points[nearestId].y+gameObjPos.y);
					float d=Vector2.Distance(cpt,nearestWorldPt)*100;
					if(nearestId>-1 && d<=SnapDistance){
						cpt.Set(nearestWorldPt.x,nearestWorldPt.y);
						//Debug.Log("_editID:"+_editID);
						_editID=nearestId;
					}else{
						_editID=-1;
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
		var gameObjPos=_asTarget.gameObject.transform.position;
		//Handles.Label(_asTarget.point,string.Format("({0},{1})",_asTarget.point.x,_asTarget.point.y));
		EditorGUI.BeginChangeCheck();
		float size=HandleUtility.GetHandleSize(_asTarget.point)*0.05f;
		var snap=Vector2.one*0.05f;
		var newPoint=Handles.FreeMoveHandle(_asTarget.point,Quaternion.identity,size,snap,Handles.DotHandleCap);
		if(EditorGUI.EndChangeCheck()){
			Undo.RecordObject(_asTarget,"edit point");//记录更改，实现撤消回退
			_asTarget.point=newPoint;
			//Debug.Log(_editID);
			if(_editID>-1){
				points[_editID]=new Vector2(newPoint.x-gameObjPos.x,newPoint.y-gameObjPos.y);
			}
		}
	}
	private void drawPoints(ref Vector2Array points,bool isCap=true){
		var gameObjPos=_asTarget.gameObject.transform.position;
		int count=points.Count;
		for(int i=0;i<count;i++){
			var p1=points[i];
			p1=new Vector2(p1.x+gameObjPos.x,p1.y+gameObjPos.y);
			var p2=points[(i+1<count)?i+1:0];
			p2=new Vector2(p2.x+gameObjPos.x,p2.y+gameObjPos.y);

			Handles.Label(p1,string.Format("{0}",i));
			if(!isCap){
				if(i>=count-1)break;
			}
			
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

	private int getNearestPointId(Vector2Array points,Vector2 check){
		int id=-1;
		float minDistance=float.MaxValue;
		for(int i=0;i<points.Count;i++){
			float d=Vector2.Distance(points[i],check);
			if(d<minDistance){
				minDistance=d;
				id=i;
			}
		}
		return id;
	}

	private bool onSegment(float x,float y,float x1,float y1,float x2,float y2){
		return Mathf.Min(x1,x2)<x&&x<Mathf.Max(x1,x2)&&Mathf.Min(y1,y2)<y&&y<Mathf.Max(y1,y2);
	}
}
