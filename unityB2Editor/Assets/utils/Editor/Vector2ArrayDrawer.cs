using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
using UnityEditorInternal;

[CustomPropertyDrawer(typeof(Vector2Array))]
public class CharPointsArraVector2Drawer:PropertyDrawer{

    private Dictionary<int,ReorderableList> _reorderableListPool=new Dictionary<int, ReorderableList>();
	private Curve _curve;

    public override void OnGUI(Rect position,SerializedProperty property,GUIContent label){
        EditorGUI.BeginProperty(position, label, property);
        int id=property.FindPropertyRelative("listID").intValue;
        //不重复创建
        if(!_reorderableListPool.ContainsKey(id)){
            SerializedProperty list=property.FindPropertyRelative("list");//Array<T>的list属性
			SerializedProperty isEdit=property.FindPropertyRelative("isEdit");
			SerializedProperty append=property.FindPropertyRelative("append");
			SerializedProperty curveRatio=property.FindPropertyRelative("curveRatio");
            _reorderableListPool[id]=createReorderableListWithList(list,isEdit,append,curveRatio);
        }
        _reorderableListPool[id].DoList(position);
        EditorGUI.EndProperty();
        //base.OnGUI(position,property,label);
    }


    private ReorderableList createReorderableListWithList(SerializedProperty list,SerializedProperty isEdit,SerializedProperty append,SerializedProperty curveRatio){
		ReorderableList orderList=new ReorderableList(list.serializedObject,list,true,true,true,true);
		orderList.drawHeaderCallback=(Rect rect)=>{
			EditorGUILayout.BeginHorizontal();
			float x=rect.x;
			float remainW=rect.width;

			float w=50;
			EditorGUI.LabelField(new Rect(x,rect.y,w,rect.height),"Size:"+orderList.count,EditorStyles.miniLabel);
			x+=w;
			remainW-=w;

			w=15;
			isEdit.boolValue=GUI.Toggle(new Rect(x,rect.y,w,rect.height*0.8f),isEdit.boolValue,"");
			if(isEdit.boolValue)append.boolValue=false;
			x+=w;
			remainW-=w;

			w=25;
			EditorGUI.LabelField(new Rect(x,rect.y,w,rect.height),"edit",EditorStyles.miniLabel);
			x+=w;
			remainW-=w;

			w=15;
			append.boolValue=GUI.Toggle(new Rect(x,rect.y,w,rect.height*0.8f),append.boolValue,"");
			if(append.boolValue)isEdit.boolValue=false;
			x+=w;
			remainW-=w;
			
			w=40;
			EditorGUI.LabelField(new Rect(x,rect.y,w,rect.height),"append",EditorStyles.miniLabel);
			x+=w;
			remainW-=w;

			w=40;
			bool isBezier=GUI.Button(new Rect(x,rect.y,w,rect.height),"bezier",EditorStyles.miniButton);
			x+=w;
			remainW-=w;

			w=30;
			curveRatio.floatValue=EditorGUI.FloatField(new Rect(x,rect.y+2,w,rect.height),curveRatio.floatValue,EditorStyles.miniTextField);
			curveRatio.floatValue=Mathf.Max(Mathf.Min(0.5f,curveRatio.floatValue),0.01f);
			x+=w;
			remainW-=w;

			curveRatio.floatValue=GUI.HorizontalSlider(new Rect(x+3,rect.y,remainW,rect.height),curveRatio.floatValue,0.01f,0.5f);
			curveRatio.floatValue=Mathf.Floor(curveRatio.floatValue*100.0f)/100.0f;

			if(isBezier){
				bezierCurve(list,curveRatio.floatValue);
			}

		};



		orderList.drawElementCallback=(Rect rect,int index,bool isActive,bool isFocused)=>{ 
			SerializedProperty element=orderList.serializedProperty.GetArrayElementAtIndex(index);
			float x=rect.x;
			float remainW=rect.width;

			float w=35;
			EditorGUI.LabelField(new Rect(x,rect.y,w,rect.height),index+":",EditorStyles.miniLabel);
			x+=w;
			remainW-=w;

			EditorGUI.PropertyField(new Rect(x,rect.y,remainW,rect.height),element,GUIContent.none);
		};
		return orderList;
	}

	private void bezierCurve(SerializedProperty list,float curveRatio){
		var originPoints=new Vector2[list.arraySize];
		for(int i=0;i<originPoints.Length;i++){
			originPoints[i]=list.GetArrayElementAtIndex(i).vector2Value;
			//放大1000倍
			originPoints[i]*=1000.0f;
		}
		//
		if(_curve==null)_curve=new Curve();
		List<Vector2> results=_curve.createCurve(originPoints,curveRatio,false);//创建曲线
		//精简删除距离很近的点
		simplifyList(results,3);
		//设置到list
		for(int i=0;i<results.Count;i++){
			if(list.arraySize-1<i)list.InsertArrayElementAtIndex(list.arraySize-1);
			//截掉小数，缩小1000倍还原
			results[i].Set((int)(results[i].x),(int)(results[i].x));
			results[i]/=1000.0f;
			list.GetArrayElementAtIndex(i).vector2Value=results[i];
		}
		//
		list.serializedObject.ApplyModifiedProperties();
		list.serializedObject.Update();
	}

	private void simplifyList(List<Vector2> list,int stepCount=3){
		for(int f=0;f<stepCount;f++){
			int i=list.Count;
			while(--i>=0){
				if(i>0){
					Vector2 pt=list[i];
					Vector2 prev=list[i-1];
					float distance=Vector2.Distance(pt,prev);
					distance/=10.0f;
					if(f==2)Debug2.Log(i,distance);
					if(distance<=3.0f){//距离小于3个像素删除
						list.RemoveAt(i);
					}
				}
			}
		}
	}

}
