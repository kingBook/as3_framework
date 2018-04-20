using UnityEngine;
using System.Collections;
using System.Collections.Generic;
using Box2D.Common.Math;
using Box2D.Common;
using Box2D.Dynamics;
using Box2D.Collision.Shapes;
using Box2D.Delegates;

public class testRay : BaseMain {
	

	void Start () {
		initBase (0,0);
		
		b2Body body;
		BodyGameObj bodyObj;
		for(int i=0;i<20;i++){
			if((i&1)>0){ 
				body=createBox (100.0f,100.0f,Random.Range(-100.0f,100.0f),Random.Range(0.0f,100.0f));
				//bodyObj=((GameObject)Instantiate(boxGameObj_prefab)).GetComponent<BodyGameObj>();
				//bodyObj.body=body;
			}else{
				body=createCircle(50.0f,Random.Range(-100.0f,100.0f),Random.Range(0.0f,100.0f));
				//bodyObj=((GameObject)Instantiate(circleGameObj_prefab)).GetComponent<BodyGameObj>();
				//bodyObj.body=body;
			}
		}
		
		for (int i=0; i<10; i++) {
			b2Vec2[] vertices=new b2Vec2[4];
			vertices [0] = new b2Vec2 (-50.0f, 0.0f);
			vertices [1] = new b2Vec2 (0.0f, 50.0f);
			vertices [2] = new b2Vec2 (50.0f, 0.0f);
			vertices [3] = new b2Vec2 (0.0f, -100.0f);
			body=createPolygon(vertices,0,0);
			//bodyObj=((GameObject)Instantiate(polyGameObj_prefab)).GetComponent<BodyGameObj>();
			//bodyObj.body=body;
		}


	}
	
	void Update () {
		updateBase ();

		//
		b2WorldRayCastCallback cb = delegate(b2Fixture fixture, b2Vec2 point, b2Vec2 normal, float fraction) {
			Debug.DrawLine(Vector3.zero,new Vector3(point.x,point.y),Color.red);
			return fraction;
		};
		Vector3 mousePos=Camera.main.ScreenToWorldPoint (Input.mousePosition);
		_world.RayCast (cb, new b2Vec2 (0, 0), new b2Vec2 (mousePos.x,mousePos.y));
	}
}
