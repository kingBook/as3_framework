using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
using Box2D.Common.Math;

[CustomPropertyDrawer(typeof(b2Vec2))]
public class b2Vec2Drawer:PropertyDrawer {

	public override void OnGUI(Rect position,SerializedProperty property,GUIContent label) {
		EditorGUI.BeginProperty(position,label,property);
		float totalW=position.width;
		float x=position.x;
		float spaceW;

		spaceW=totalW*0.5f;
		EditorGUIUtility.labelWidth=13;
		EditorGUI.PropertyField(new Rect(x,position.y,spaceW,position.height),property.FindPropertyRelative("x"));
		x+=spaceW;

		spaceW=totalW*0.5f;
		EditorGUIUtility.labelWidth=13;
		EditorGUI.PropertyField(new Rect(x,position.y,spaceW,position.height),property.FindPropertyRelative("y"));
		x+=spaceW;

		/*
		Rect contentPosition=EditorGUI.PrefixLabel(position, label);
		float width=position.width-contentPosition.width;
		
		EditorGUIUtility.labelWidth=13;
		contentPosition.width=width*0.5f;
		EditorGUI.PropertyField(contentPosition,property.FindPropertyRelative("x"));

		contentPosition.x += contentPosition.width;
		contentPosition.width=width*0.5f;
		EditorGUI.PropertyField(contentPosition,property.FindPropertyRelative("y"));
		*/
		EditorGUI.EndProperty();
	}
}
