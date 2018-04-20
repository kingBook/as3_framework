using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class testTime : MonoBehaviour {

	public GameObject prefab;
	// Use this for initialization
	void Start () {
		Debug.LogFormat("{0} , {1}",GetComponents<b2BodyObject>().Length,GetComponentsInChildren<b2BodyObject>().Length);
	}

	private void createGameObject(){
		Instantiate(prefab);
	}

	private void FixedUpdate() {
		//Debug.LogFormat("FixedUpdate {0}",gameObject.name);
	}
	// Update is called once per frame
	void Update () {
		//Debug.LogFormat("Update {0}",gameObject.name);
	}
}
