using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
using UnityEngine.SceneManagement;

public class SetSpriteToWorldTopLeft : Editor {
	[MenuItem("B2Editor/SetSpriteToWorldTopLeft %t")]
	public static void SetPositionToWorldTopLeft() {
		Scene scene=SceneManager.GetActiveScene();
		GameObject[] objs=Selection.GetFiltered<GameObject>(SelectionMode.TopLevel);
		if(objs!=null&&objs.Length>0){
			GameObject obj=objs[0];
			SpriteRenderer render=obj.GetComponent<SpriteRenderer>();
			if(render!=null){
				Vector2 size=render.sprite.bounds.size;
				obj.transform.position=new Vector2(size.x*0.5f,-size.y*0.5f);
			}
		}
	}
	
}
