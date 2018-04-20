using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;
using UnityEditorInternal;
using Box2D.Common.Math;

[CanEditMultipleObjects]
[CustomEditor(typeof(UserData))]
public class UserDataEditor:Editor {
	private UserData _asTarget;
	private ReorderableList _list;

	private const float SnapDistance=10;
	private int _editID;
	private int _nearestID;

	private void OnEnable() {
		_asTarget = target as UserData;

		_asTarget.resetDefaultProperties();

		_list = new ReorderableList(serializedObject,serializedObject.FindProperty("list"),true,true,true,true);
		_list.drawElementCallback = drawElement;
		_list.drawHeaderCallback = drawHeader;
		_list.elementHeightCallback = getElementHeight;
		_list.onAddCallback = onAdd;
		_list.onReorderCallback = onReorder;

		_editID=-1;
		_nearestID=-1;
	}

	public override void OnInspectorGUI() {
		_asTarget.resetDefaultProperties();
		/*const float MIN_W=30.0f;

		GUILayout.BeginHorizontal();
		EditorGUILayout.LabelField("Name:",GUILayout.MinWidth(MIN_W));
		EditorGUILayout.LabelField("Type:",GUILayout.MinWidth(MIN_W));
		EditorGUILayout.LabelField("Value:",GUILayout.MinWidth(MIN_W));
		GUILayout.EndHorizontal();
		
		serializedObject.Update();
		EditorList.Show(serializedObject.FindProperty("list"),false,false);
		serializedObject.ApplyModifiedProperties();
		//创建 P、+、- 按钮
		const float MIN_W2 = 20.0f;
		EditorGUILayout.BeginHorizontal();
		EditorGUILayout.Space();
		if(GUILayout.Button("P",GUILayout.Width(MIN_W2))) {//P
			b2BodyUserData.PropertyData newData = new b2BodyUserData.PropertyData();
			newData.name = "Property" + (_asTarget.list.Count);
			newData.type = b2BodyUserData.CustomPropertyType.B2Vec2;
			newData.value = new b2BodyUserData.ValueObject();

			Transform t=_asTarget.GetComponent<Transform>();
			newData.value.b2Vec2Val=new Box2D.Common.Math.b2Vec2(t.position.x,t.position.y);

			_asTarget.list.Add(newData);
		}
		if(GUILayout.Button("✚",GUILayout.Width(MIN_W2))) {//✚
			b2BodyUserData.PropertyData newData = new b2BodyUserData.PropertyData();
			newData.name = "Property" + (_asTarget.list.Count);
			newData.type = b2BodyUserData.CustomPropertyType.String;
			newData.value = new b2BodyUserData.ValueObject();
			_asTarget.list.Add(newData);
		}
		if(GUILayout.Button("━",GUILayout.Width(MIN_W2))) {//━
			if(_asTarget.list.Count > b2BodyUserData.DefaultPropertiesCount) {
				_asTarget.list.RemoveAt(_asTarget.list.Count - 1);
			}
		}
		EditorGUILayout.EndHorizontal();*/
		serializedObject.Update();
		_list.DoLayoutList();
		serializedObject.ApplyModifiedProperties();
	}

	private void drawHeader(Rect rect) {
		float iw = rect.width / 3;
		Vector2 pos = rect.position;

		GUI.Label(new Rect(pos,new Vector2(iw,rect.height)),"   Name");

		Vector2 offsetPos = new Vector2(iw,0);
		pos += offsetPos;
		GUI.Label(new Rect(pos,new Vector2(iw,rect.height)),"Type");

		pos += offsetPos;
		GUI.Label(new Rect(pos,new Vector2(iw,rect.height)),"Value");
	}

	private void drawElement(Rect rect,int index,bool selected,bool focused) {
		SerializedProperty element = _list.serializedProperty.GetArrayElementAtIndex(index);
		rect.height = EditorGUIUtility.singleLineHeight;
		EditorGUI.PropertyField(rect,element,GUIContent.none);
	}

	private float getElementHeight(int index) {
		SerializedProperty element = _list.serializedProperty.GetArrayElementAtIndex(index);
		int type = element.FindPropertyRelative("type").intValue;
		var valueObject = element.FindPropertyRelative("value");
		if(type == (int)UserData.CustomPropertyType.ListB2Vec2) {
			var listVal = valueObject.FindPropertyRelative("listB2Vec2Val");
			int length = Mathf.Max(listVal.arraySize,1);
			return EditorGUIUtility.singleLineHeight * (length + 2) + 5 * (length + 2);
		}
		return EditorGUIUtility.singleLineHeight;
	}

	private void onAdd(ReorderableList list) {
		string name = "Property" + (_asTarget.list.Count);
		var type = UserData.CustomPropertyType.String;
		var value = new UserData.ValueObject();
		int listID = list.count;
		UserData.PropertyData newData = new UserData.PropertyData(name,type,value,listID);
		_asTarget.list.Add(newData);
		list.index = list.count;//焦点移到最后一项
	}

	private void onReorder(ReorderableList list) {
		for(int i = 0;i < _asTarget.list.Count;i++) {
			_asTarget.list[i].listID = i;
		}
	}

	private void OnSceneGUI() {
		if(!_asTarget.isActiveAndEnabled) return;
		
		for(int i=0;i<_asTarget.list.Count;i++){
			UserData.PropertyData propertyData=_asTarget.list[i];
			var type=propertyData.type;
			if(type==UserData.CustomPropertyType.ListB2Vec2){
				if(propertyData.value.listB2Vec2Val.Count>=2){
					onSceneGUIeditPointsHandler(ref propertyData.value.listB2Vec2Val,propertyData.value.editListB2Vec2Val);
				}
			}
		}
	}

	private void OnDisable() {
		for(int i=0;i<_asTarget.list.Count;i++){
			UserData.PropertyData propertyData=_asTarget.list[i];
			var type=propertyData.type;
			if(type==UserData.CustomPropertyType.ListB2Vec2){
				propertyData.value.editListB2Vec2Val=false;//取消编辑
			}
		}
	}

	private void onSceneGUIeditPointsHandler(ref List<b2Vec2> points,bool isEdit){
		if(isEdit) {
			HandleUtility.Repaint();
		
			//鼠标位置
			var mousePos=Event.current.mousePosition;
			mousePos=HandleUtility.GUIPointToWorldRay(mousePos).origin;

			//寻找最近线段
			b2Vec2[] nearestLineSegment=new b2Vec2[2];
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
							if(Event.current.control){
								deletePointWithIndex(ref points,_nearestID);
							}else{
								_editID=_nearestID;
							}
						}else if(d1<=SnapDistance){
							if(Event.current.control){
								deletePointWithIndex(ref points,_nearestID+1);
							}else{
								_editID=_nearestID+1;
							}
						}else{
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
						//垂足不能滑出线段
						if(perpToNearestLineSegment>0.01f){
							if(d0<d1)perp.Set(nearestLineSegment[0].x,nearestLineSegment[0].y);
							else perp.Set(nearestLineSegment[1].x,nearestLineSegment[1].y);
						}
						//垂足贴紧端点
						if(d0<d1){
							if(d0<=SnapDistance)perp.Set(nearestLineSegment[0].x,nearestLineSegment[0].y);
						}else{
							if(d1<=SnapDistance)perp.Set(nearestLineSegment[1].x,nearestLineSegment[1].y);
						}
						_asTarget.point.Set(perp.x,perp.y);
					}
				}
			}
			editPointHandler(ref points);
		}
		//画点列表
		drawPoints(ref points);
	}
	private void deletePointWithIndex(ref List<b2Vec2> points,int index){
		if(points.Count<3)return;
		Undo.RecordObject(_asTarget,"delete point");
		points.RemoveAt(index);
	}
	private void findSetNearestLineSegment(Vector2 refPoint,ref List<b2Vec2> points,ref b2Vec2[] nearestLineSegment){
		int count=points.Count;
		float nearestLineDistance=1e6f;
		for(int i=0;i<count;i++){
			var p1=points[i];
			var p2=points[(i+1<count)?i+1:0];
			float distance=HandleUtility.DistancePointToLine(refPoint,p1,p2);
			if(distance<nearestLineDistance){
				nearestLineDistance=distance;
				_nearestID=i;
				nearestLineSegment[0]=p1;
				nearestLineSegment[1]=p2;
			}
		}
	}
	private void editPointHandler(ref List<b2Vec2> points){
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
	private void drawPoints(ref List<b2Vec2> points){
		int count=points.Count;
		for(int i=0;i<count;i++){
			Handles.Label(points[i],string.Format("{0}",i));
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


}
