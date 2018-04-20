using UnityEngine;
using System.Collections;
using System.Collections.Generic;
using Box2D.Common.Math;
using Box2D.Common;
using Box2D.Dynamics;
using Box2D.Collision.Shapes;
using Box2D.Delegates;
using Box2D.Collision;

public class testQuery : BaseMain {

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

			body.SetLinearDamping(10.0f);
			body.SetAngularDamping(10.0f);
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

			body.SetLinearDamping(10.0f);
			body.SetAngularDamping(10.0f);
		}
		
		
	}
	
	void Update () {
		updateBase ();
		
		//testQueryAABB ();
		//testQueryShape_poly ();
		testQueryShape_circle ();
	}

	private void testQueryAABB(){
		Vector3 mousePos=Camera.main.ScreenToWorldPoint (Input.mousePosition);
		b2WorldQueryCallback cb = delegate(b2Fixture fixture) {
			b2Body body=fixture.GetBody ();
			body.SetAwake(true);
			return true;
		};

		float w = 200 / ptm_ratio;
		float h = 200 / ptm_ratio;
		b2AABB aabb = b2AABB.MakeWH (w,h,mousePos.x,mousePos.y);
		_world.QueryAABB (cb, aabb);
		
		b2Vec2[] vertices=new b2Vec2[]{
			new b2Vec2(aabb.lowerBound.x,aabb.lowerBound.y),
			new b2Vec2(aabb.upperBound.x,aabb.lowerBound.y),
			new b2Vec2(aabb.upperBound.x,aabb.upperBound.y),
			new b2Vec2(aabb.lowerBound.x,aabb.upperBound.y)};
		b2Color color = new b2Color (1.0f,0.0f,0.0f);
		_debugDraw.DrawPolygon(vertices,vertices.Length,color);
	}

	private void testQueryShape_poly(){
		Vector3 mousePos=Camera.main.ScreenToWorldPoint (Input.mousePosition);
		b2WorldQueryCallback cb = delegate(b2Fixture fixture) {
			b2Body body=fixture.GetBody ();
			body.SetAwake(true);
			return true;
		};
		
		b2Vec2[] vertices=new b2Vec2[4];
		vertices [0] = new b2Vec2 (-100.0f/ptm_ratio, 0.0f/ptm_ratio);
		vertices [1] = new b2Vec2 (0.0f/ptm_ratio,   100.0f/ptm_ratio);
		vertices [2] = new b2Vec2 (100.0f/ptm_ratio,  0.0f/ptm_ratio);
		vertices [3] = new b2Vec2 (0.0f/ptm_ratio,   -200.0f/ptm_ratio);
		b2PolygonShape shape = b2PolygonShape.AsArray(vertices,vertices.Length);

		b2Transform transform = new b2Transform (new b2Vec2(mousePos.x,mousePos.y),b2Mat22.FromAngle(0));

		_world.QueryShape (cb, shape,transform);

		for (int i=0; i<vertices.Length; i++) {
			vertices[i].x+=mousePos.x;
			vertices[i].y+=mousePos.y;
		}
		b2Color color = new b2Color (1.0f,0.0f,0.0f);
		_debugDraw.DrawPolygon(vertices,vertices.Length,color);

	}

	private void testQueryShape_circle(){
		Vector3 mousePos=Camera.main.ScreenToWorldPoint (Input.mousePosition);
		b2WorldQueryCallback cb = delegate(b2Fixture fixture) {
			b2Body body=fixture.GetBody ();
			body.SetAwake(true);
			return true;
		};

		b2CircleShape shape = new b2CircleShape (200.0f/ptm_ratio);
		
		b2Transform transform = new b2Transform (new b2Vec2(mousePos.x,mousePos.y),b2Mat22.FromAngle(0));
		
		_world.QueryShape (cb, shape,transform);

		b2Color color = new b2Color (1.0f,0.0f,0.0f);
		_debugDraw.DrawCircle(new b2Vec2(mousePos.x,mousePos.y),200.0f/ptm_ratio,color);
		
	}
}
