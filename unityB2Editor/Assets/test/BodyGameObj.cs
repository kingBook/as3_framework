using UnityEngine;
using System.Collections;
using Box2D.Dynamics;

public class BodyGameObj : MonoBehaviour {
	public b2Body body;

	void Start () {
	
	}

	void Update () {
		Vector3 pos = transform.localPosition;
		pos.x = body.GetPosition ().x;
		pos.y = body.GetPosition ().y;
		transform.localPosition = pos;
		transform.localRotation = Quaternion.Euler(0, 0, body.GetAngle () * 57.3f);
	}
}
