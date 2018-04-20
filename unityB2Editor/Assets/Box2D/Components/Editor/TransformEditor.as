using UnityEngine;
using System.Collections;
using UnityEditor;
using System.Reflection;



[CustomEditor(typeof(Transform))]
public class TransformEditor :Editor {
	
	private Editor editor;
	private Transform transform;
	private Vector3 startPostion =Vector3.zero;
	private Vector3 startRotation =Vector3.zero;
	private Vector3 startScale =Vector3.zero;
	void OnEnable()
	{
		//Debug.Log ("OnEnable");
		transform = target as Transform;
		editor = Editor.CreateEditor(target, Assembly.GetAssembly(typeof(Editor)).GetType("UnityEditor.TransformInspector",true));
		startPostion = transform.localPosition;
		startRotation = transform.localRotation.eulerAngles;
		startScale = transform.localScale;
	}

	void OnSceneGUI( )
	{
		//Debug.Log ("OnSceneGUI");
	}
	
	public override void OnInspectorGUI (){
		editor.OnInspectorGUI();
		//GUILayout.Label ("friction:");
		//Debug.Log ("TransformEditor.OnInspectorGUI();");
		/*if(GUI.changed){
			
			if(startPostion != transform.localPosition)
			{
				Debug.Log(string.Format("transform = {0}  positon = {1}",transform.name,transform.localPosition));
			}
			
			if(startRotation !=  transform.localRotation.eulerAngles)
			{
				Debug.Log(string.Format("transform = {0}   rotation = {1}",transform.name,transform.localRotation.eulerAngles));
			}
			
			if(startScale !=  transform.localScale)
			{
				Debug.Log(string.Format("transform = {0}   scale = {1}",transform.name,transform.localScale));
			}
			startPostion = transform.localPosition;
			startRotation = transform.localRotation.eulerAngles;
			startScale = transform.localScale;
		}*/
	}
	
	
}