using UnityEngine;
using System.Collections;
using System.Collections.Generic;
using Box2D.Common.Math;
using Box2D.Common;
using Box2D.Dynamics;
using Box2D.Collision.Shapes;
using Box2D.Dynamics.Joints;
using System;
using Box2D.Delegates;


public class BaseMain : MonoBehaviour {

	protected const float ptm_ratio = 100;
	protected b2Vec2 _gravity = new b2Vec2 (0,-10);
	protected b2World _world;
	protected b2DebugDraw _debugDraw;
	protected b2MouseJoint _mj=null;

	//Start()函数调用
	protected void initBase(float gravityX=0,float gravityY=-10){
		_gravity.x = gravityX;
		_gravity.y = gravityY;
		_world = new b2World (_gravity,true);
		createDebugDraw();

		Rect r = Camera.main.pixelRect;
		Vector3 lowerPoint = Camera.main.ScreenToWorldPoint (new Vector3(r.xMin,r.yMin));
		Vector3 upperPoint = Camera.main.ScreenToWorldPoint (new Vector3(r.xMax,r.yMax));
		createWrapWallBodies (lowerPoint.x*ptm_ratio,lowerPoint.y*ptm_ratio,upperPoint.x*2*ptm_ratio,upperPoint.y*2*ptm_ratio);
	}
	//Update()函数调用
	protected void updateBase () {
		if(Input.GetMouseButtonDown(0)) mouseDownHandler();
		if (Input.GetMouseButton (0)) mouseMoveHandler ();
		if(Input.GetMouseButtonUp(0))stopDragBody();

		_world.Step (1.0f/ptm_ratio,8,8);
		_world.ClearForces ();
		_world.DrawDebugData ();
	}

	protected void mouseDownHandler(){
		Vector3 pos = Camera.main.ScreenToWorldPoint (Input.mousePosition);//屏幕坐标转世界坐标
		b2Body b=getPosBody(pos.x,pos.y);
		startDragBody(b,pos.x,pos.y);
	}

	protected void mouseMoveHandler(){
		if (_mj!=null) {
			Vector3 pos = Camera.main.ScreenToWorldPoint (Input.mousePosition);//屏幕坐标转世界坐标
			_mj.SetTarget (new b2Vec2 (pos.x, pos.y));
		}
	}

	/** 开始拖动刚体*/
	private void startDragBody(b2Body b, float x, float y){
		if (b==null || b.GetType()!=b2Body.b2_dynamicBody) return;
		if(_mj!=null)_world.DestroyJoint(_mj);
		b2MouseJointDef jointDef=new b2MouseJointDef();
		jointDef.bodyA = _world.GetGroundBody();
		jointDef.bodyB = b;
		jointDef.target.Set(x,y);
		jointDef.maxForce=1e6f;
		_mj = _world.CreateJoint(jointDef) as b2MouseJoint;
	}

	protected void stopDragBody(){
		if(_mj!=null)_world.DestroyJoint(_mj);
	}

	protected void createDebugDraw(){
		_debugDraw = new b2DebugDraw ();
		_debugDraw.SetFlags(b2DebugDraw.e_shapeBit|b2DebugDraw.e_jointBit);
		_world.SetDebugDraw(_debugDraw);
	}

	protected b2Body createBox(float w,float h,float x,float y){
		b2BodyDef bodyDef = new b2BodyDef();
		bodyDef.type = b2Body.b2_dynamicBody;
		bodyDef.position.Set (x/ptm_ratio,y/ptm_ratio);
		b2Body body=_world.CreateBody(bodyDef);
		
		b2PolygonShape s = new b2PolygonShape();
		s.SetAsBox(w/ptm_ratio*0.5f,h/ptm_ratio*0.5f);
		b2FixtureDef fixtrureDef = new b2FixtureDef();
		fixtrureDef.shape = s;
		body.CreateFixture(fixtrureDef);

		return body;
	}

	protected b2Body createCircle(float radius,float x,float y){
		b2BodyDef bodyDef = new b2BodyDef();
		bodyDef.type = b2Body.b2_dynamicBody;
		bodyDef.position.Set (x/ptm_ratio,y/ptm_ratio);
		b2Body body=_world.CreateBody(bodyDef);

		b2CircleShape s = new b2CircleShape (radius/ptm_ratio);
		b2FixtureDef fixtrureDef = new b2FixtureDef();
		fixtrureDef.shape = s;
		body.CreateFixture(fixtrureDef);

		return body;
	}

	protected b2Body createPolygon(b2Vec2[] vertices,float x,float y){
		for (int i=0; i<vertices.Length; i++) vertices [i].Multiply (1/ptm_ratio);

		b2BodyDef bodyDef = new b2BodyDef();
		bodyDef.type = b2Body.b2_dynamicBody;
		bodyDef.position.Set (x/ptm_ratio,y/ptm_ratio);
		b2Body body=_world.CreateBody(bodyDef);

		b2PolygonShape s = b2PolygonShape.AsArray(vertices,vertices.Length);
		b2FixtureDef fixtrureDef = new b2FixtureDef();
		fixtrureDef.shape = s;
		body.CreateFixture(fixtrureDef);

		return body;
	}

	private void createWrapWallBodies(float x,float y,float w,float h){
		b2Body[] bodies=getWrapWallBodies(x,y,w,h);
		int i=bodies.Length;
		b2Body b;
		while(--i>=0){
			b=bodies[i];
			b.SetType(b2Body.b2_staticBody);
		}
	}
	//屏幕坐标为单位:左下->右上
	private b2Body[] getWrapWallBodies(float x,float y,float w,float h){
		uint thickness = 20;
		b2Body[] bodies = new b2Body[4];
		//顶
		bodies[1]=createBox(w, thickness, w * 0.5f + x,  h + thickness * 0.5f + y);
		//底
		bodies[0]=createBox(w, thickness, w * 0.5f + x,  y - thickness * 0.5f);
		//左
		bodies[2]=createBox(thickness, h, x - thickness * 0.5f, h * 0.5f + y);
		//右
		bodies[3]=createBox(thickness, h, x +w + thickness * 0.5f, h * 0.5f + y);
		return bodies;
	}

	/**返回位置下的刚体*/
	private b2Body getPosBody(float x,float y) {
		b2Body b=null;

		b2WorldQueryCallback cb = delegate(b2Fixture fixture) {
			b = fixture.GetBody ();
			return false;
		};
		_world.QueryPoint (cb, new b2Vec2(x,y));
		return b;
	}

}
