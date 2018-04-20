using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEditorInternal;
using UnityEngine;
[CustomPropertyDrawer(typeof(UserData.PropertyData))]  
public class UserDataPropertyDataDrawer:PropertyDrawer {
	private Dictionary<string,ValueList> _valuelistDict=new Dictionary<string,ValueList>();
	
	public override void OnGUI(Rect position,SerializedProperty property,GUIContent label){
		EditorGUI.BeginProperty(position, label, property);
		string propertyName=property.FindPropertyRelative("name").stringValue;
		int listID=property.FindPropertyRelative("listID").intValue;

		float totalW=position.width;
		float x=position.x;
		float spaceW;
		
		spaceW=totalW/4;
		EditorGUI.PropertyField(new Rect(position.x,position.y,spaceW,position.height), property.FindPropertyRelative("name"),GUIContent.none);
		x+=spaceW;
		
		spaceW=Mathf.Min(totalW/4,60);
		SerializedProperty typeProp=property.FindPropertyRelative("type");
		EditorGUI.PropertyField(new Rect(x,position.y,spaceW,position.height),typeProp,GUIContent.none);
		x+=spaceW;

		SerializedProperty valueProp=property.FindPropertyRelative("value");
		
		switch(typeProp.enumValueIndex){
			case (int)UserData.CustomPropertyType.String:
				spaceW=totalW/2;
				EditorGUI.PropertyField(new Rect(x,position.y,spaceW,position.height),valueProp.FindPropertyRelative("stringVal"),GUIContent.none);
				x+=spaceW;
				break;
			case (int)UserData.CustomPropertyType.Int:
				spaceW=totalW/2;
				EditorGUI.PropertyField(new Rect(x,position.y,spaceW,position.height),valueProp.FindPropertyRelative("intVal"),GUIContent.none);
				x+=spaceW;
				break;
			case (int)UserData.CustomPropertyType.Float:
				spaceW=totalW/2;
				EditorGUI.PropertyField(new Rect(x,position.y,spaceW,position.height),valueProp.FindPropertyRelative("floatVal"),GUIContent.none);
				x+=spaceW;
				break;
			case (int)UserData.CustomPropertyType.Bool:
				spaceW=totalW/2;
				EditorGUI.PropertyField(new Rect(x,position.y,spaceW,position.height),valueProp.FindPropertyRelative("boolVal"),GUIContent.none);
				x+=spaceW;
				break;
			case (int)UserData.CustomPropertyType.B2BodyObject:
				spaceW=totalW/2;
				EditorGUI.PropertyField(new Rect(x,position.y,spaceW,position.height),valueProp.FindPropertyRelative("b2BodyObjectVal"),GUIContent.none);
				x+=spaceW;
				break;
			case (int)UserData.CustomPropertyType.B2Vec2:
				spaceW=totalW/2;
				EditorGUI.PropertyField(new Rect(x,position.y,spaceW,position.height),valueProp.FindPropertyRelative("b2Vec2Val"),GUIContent.none);
				x+=spaceW;
				break;
			case (int)UserData.CustomPropertyType.ListB2Vec2:
				spaceW=totalW/2;
				SerializedProperty list=valueProp.FindPropertyRelative("listB2Vec2Val");
				if(_valuelistDict.ContainsKey(propertyName)){
					if(listID!=_valuelistDict[propertyName].listID){
						_valuelistDict[propertyName]=new ValueList(createReorderableListWithList(valueProp.FindPropertyRelative("editListB2Vec2Val"),list),listID,propertyName);
					}
				}else{
					_valuelistDict.Add(propertyName,new ValueList(createReorderableListWithList(valueProp.FindPropertyRelative("editListB2Vec2Val"),list),listID,propertyName));
				}
				Rect r=new Rect(x,position.y,spaceW,position.height);
				_valuelistDict[propertyName].orderList.DoList(r);
				x+=spaceW;
				break;
			case (int)UserData.CustomPropertyType.GameObject:
				spaceW=totalW/2;
				EditorGUI.PropertyField(new Rect(x,position.y,spaceW,position.height),valueProp.FindPropertyRelative("gameObjectVal"),GUIContent.none);
				x+=spaceW;
				break;
		}
		EditorGUI.EndProperty();
	}
	private ReorderableList createReorderableListWithList(SerializedProperty edit,SerializedProperty list){
		ReorderableList orderList=new ReorderableList(list.serializedObject,list,true,true,true,true);
		orderList.drawHeaderCallback=(Rect rect)=>{
			float x=rect.x;
			float remainW=rect.width;

			float w=45;
			edit.boolValue=GUI.Toggle(new Rect(x,rect.y,w,rect.height),edit.boolValue,"edit");
			x+=w;
			remainW-=w;

			w=35;
			if(GUI.Button(new Rect(x,rect.y,w,rect.height),"re")){
				int i=list.arraySize;
				while(--i>=0){
					Debug.LogFormat("{0},{1}",i,(list.arraySize-1)-i);
					list.MoveArrayElement(i,(list.arraySize-1)-i);
				}
			}
			x+=w;
			remainW-=w;
			//EditorGUI.LabelField(rect,"Size:"+orderList.count);
		};
		orderList.drawElementCallback=(Rect rect,int index,bool isActive,bool isFocused)=>{ 
			SerializedProperty element=orderList.serializedProperty.GetArrayElementAtIndex(index);
			rect.height=EditorGUIUtility.singleLineHeight;
			EditorGUI.PropertyField(rect,element,GUIContent.none);
		};
		return orderList;
	}

	public class ValueList{
		public ReorderableList orderList;
		public int listID;
		public string propertyName;
		public ValueList(ReorderableList orderList,int listID,string propertyName):base(){
			this.orderList=orderList;
			this.listID=listID;
			this.propertyName=propertyName;
		} 
	}


}
