using UnityEngine;
using System.Collections;
using System.Collections.Generic;
using Box2D.Common.Math;
using Box2D.Common;
using Box2D.Dynamics;
using Box2D.Collision.Shapes;

public class helloWorld:BaseMain {

	public GameObject boxGameObj_prefab;
	public GameObject circleGameObj_prefab;
	public GameObject polyGameObj_prefab;

	void Start () {
		initBase (0,-10);

		b2Body body;
		BodyGameObj bodyObj;
		for(int i=0;i<20;i++){
			if((i&1)>0){ 
				body=createBox (100.0f,100.0f,Random.Range(-100.0f,100.0f),Random.Range(0.0f,100.0f));
				bodyObj=((GameObject)Instantiate(boxGameObj_prefab)).GetComponent<BodyGameObj>();
				bodyObj.body=body;
			}else{
				body=createCircle(50.0f,Random.Range(-100.0f,100.0f),Random.Range(0.0f,100.0f));
				bodyObj=((GameObject)Instantiate(circleGameObj_prefab)).GetComponent<BodyGameObj>();
				bodyObj.body=body;
			}
		}

		for (int i=0; i<10; i++) {
			b2Vec2[] vertices=new b2Vec2[4];
			vertices [0] = new b2Vec2 (-50.0f, 0.0f);
			vertices [1] = new b2Vec2 (0.0f, 50.0f);
			vertices [2] = new b2Vec2 (50.0f, 0.0f);
			vertices [3] = new b2Vec2 (0.0f, -100.0f);
			body=createPolygon(vertices,0,0);
			bodyObj=((GameObject)Instantiate(polyGameObj_prefab)).GetComponent<BodyGameObj>();
			bodyObj.body=body;
		}

	}

	void Update () {
		updateBase ();
	}
}
