/*
* Copyright (c) 2006-2007 Erin Catto http://www.gphysics.com
*
* This software is provided 'as-is', without any express or implied
* warranty.  In no event will the authors be held liable for any damages
* arising from the use of this software.
* Permission is granted to anyone to use this software for any purpose,
* including commercial applications, and to alter it and redistribute it
* freely, subject to the following restrictions:
* 1. The origin of this software must not be misrepresented; you must not
* claim that you wrote the original software. If you use this software
* in a product, an acknowledgment in the product documentation would be
* appreciated but is not required.
* 2. Altered source versions must be plainly marked as such, and must not be
* misrepresented as being the original software.
* 3. This notice may not be removed or altered from any source distribution.
*/
using Box2D.Common.Math;
using Box2D.Common;
using System.Collections.Generic;
using UnityEngine;

namespace Box2D.Dynamics{
	
/**
* Implement and register this class with a b2World to provide debug drawing of physics
* entities in your game.
*/
public class b2DebugDraw
{

	public b2DebugDraw(){
		m_drawFlags = 0;
	}

	//virtual ~b2DebugDraw() {}

	//enum
	//{
	/** Draw shapes */
	static public uint e_shapeBit 			= 0x0001;
	/** Draw joint connections */
	static public uint e_jointBit			= 0x0002;
	/** Draw axis aligned bounding boxes */
	static public uint e_aabbBit			= 0x0004;
	/** Draw broad-phase pairs */
	static public uint e_pairBit			= 0x0008;
	/** Draw center of mass frame */
	static public uint e_centerOfMassBit	= 0x0010;
	/** Draw controllers */
	static public uint e_controllerBit		= 0x0020;
	//};

	/**
	* Set the drawing flags.
	*/
	public void SetFlags(uint flags){
		m_drawFlags = flags;
	}

	/**
	* Get the drawing flags.
	*/
	public uint GetFlags(){
		return m_drawFlags;
	}
	
	/**
	* Append flags to the current flags.
	*/
	public void AppendFlags(uint flags){
		m_drawFlags |= flags;
	}

	/**
	* Clear flags from the current flags.
	*/
	public void ClearFlags(uint flags){
		m_drawFlags &= ~flags;
	}

	/**
	* Set the sprite
	*/
	/*public void SetSprite(Sprite sprite){
		m_sprite = sprite; 
	}*/
	
	/**
	* Get the sprite
	*/
	/*public Sprite GetSprite()
		return m_sprite;
	}*/
	
	/**
	* Set the draw scale
	*/
	public void SetDrawScale(float drawScale){
		m_drawScale = drawScale; 
	}
	
	/**
	* Get the draw
	*/
	public float GetDrawScale(){
		return m_drawScale;
	}
	
	/**
	* Set the line thickness
	*/
	public void SetLineThickness(float lineThickness){
		m_lineThickness = lineThickness; 
	}
	
	/**
	* Get the line thickness
	*/
	public float GetLineThickness(){
		return m_lineThickness;
	}
	
	/**
	* Set the alpha value used for lines
	*/
	public void SetAlpha(float alpha){
		m_alpha = alpha; 
	}
	
	/**
	* Get the alpha value used for lines
	*/
	public float GetAlpha(){
		return m_alpha;
	}
	
	/**
	* Set the alpha value used for fills
	*/
	public void SetFillAlpha(float alpha){
		m_fillAlpha = alpha; 
	}
	
	/**
	* Get the alpha value used for fills
	*/
	public float GetFillAlpha() {
		return m_fillAlpha;
	}
	
	/**
	* Set the scale used for drawing XForms
	*/
	public void SetXFormScale(float xformScale){
		m_xformScale = xformScale; 
	}
	
	/**
	* Get the scale used for drawing XForms
	*/
	public float GetXFormScale(){
		return m_xformScale;
	}
	
	/**
	* Draw a closed polygon provided in CCW order.
	*/
	public void DrawPolygon(b2Vec2[] vertices, int vertexCount, b2Color color){
		for (int i=0; i<vertexCount; i++) {
			if(i+1<vertexCount){
				Debug.DrawLine(new Vector3(vertices[i].x * m_drawScale,vertices[i].y * m_drawScale),
				               new Vector3(vertices[i+1].x * m_drawScale,vertices[i+1].y * m_drawScale),
				               color.unityColor);
			}else{
				Debug.DrawLine(new Vector3(vertices[i].x * m_drawScale,vertices[i].y * m_drawScale),
				               new Vector3(vertices[0].x * m_drawScale,vertices[0].y * m_drawScale),
				               color.unityColor);
			}
		}		
	}

	/**
	* Draw a solid closed polygon provided in CCW order.
	*/
	public void DrawSolidPolygon(b2Vec2[] vertices, int vertexCount, b2Color color){
		for (int i=0; i<vertexCount; i++) {
			if(i+1<vertexCount){
				Debug.DrawLine(new Vector3(vertices[i].x * m_drawScale,vertices[i].y * m_drawScale),
				               new Vector3(vertices[i+1].x * m_drawScale,vertices[i+1].y * m_drawScale),
				               color.unityColor);
			}else{
				Debug.DrawLine(new Vector3(vertices[i].x * m_drawScale,vertices[i].y * m_drawScale),
				               new Vector3(vertices[0].x * m_drawScale,vertices[0].y * m_drawScale),
				               color.unityColor);
			}
		}
	}

	/**
	* Draw a circle.
	*/
	public void DrawCircle(b2Vec2 center, float radius, b2Color color){
		for (float i=0; i<360.0f; i++) {
			if(i+1.0f<360.0f){
				Debug.DrawLine(new Vector3((center.x+Mathf.Cos(i*0.01745f)*radius)*m_drawScale, (center.y+Mathf.Sin(i*0.01745f)*radius)*m_drawScale),
				               new Vector3((center.x+Mathf.Cos((i+1.0f)*0.01745f)*radius)*m_drawScale, (center.y+Mathf.Sin((i+1.0f)*0.01745f)*radius)*m_drawScale),
				               color.unityColor);
			}else{
				Debug.DrawLine(new Vector3((center.x+Mathf.Cos(i*0.01745f)*radius)*m_drawScale, (center.y+Mathf.Sin(i*0.01745f)*radius)*m_drawScale),
				               new Vector3((center.x+Mathf.Cos(0.0f)*radius)*m_drawScale, (center.y+Mathf.Sin(0.0f)*radius)*m_drawScale),
				               color.unityColor);
			}
		}
	}
	
	/**
	* Draw a solid circle.
	*/
	public void DrawSolidCircle(b2Vec2 center, float radius, b2Vec2 axis, b2Color color){
		for (float i=0; i<360.0f; i++) {
			if(i+1.0f<360.0f){
				Debug.DrawLine(new Vector3((center.x+Mathf.Cos(i*0.01745f)*radius)*m_drawScale, (center.y+Mathf.Sin(i*0.01745f)*radius)*m_drawScale),
				               new Vector3((center.x+Mathf.Cos((i+1.0f)*0.01745f)*radius)*m_drawScale, (center.y+Mathf.Sin((i+1.0f)*0.01745f)*radius)*m_drawScale),
			               	   color.unityColor);
			}else{
				Debug.DrawLine(new Vector3((center.x+Mathf.Cos(i*0.01745f)*radius)*m_drawScale, (center.y+Mathf.Sin(i*0.01745f)*radius)*m_drawScale),
					           new Vector3((center.x+Mathf.Cos(0.0f)*radius)*m_drawScale, (center.y+Mathf.Sin(0.0f)*radius)*m_drawScale),
				               color.unityColor);
			}
		}
		Debug.DrawLine (new Vector3(center.x * m_drawScale, center.y * m_drawScale),
		                new Vector3((center.x + axis.x*radius) * m_drawScale, (center.y + axis.y*radius) * m_drawScale),
		                color.unityColor);
	}

	
	/**
	* Draw a line segment.
	*/
	public void DrawSegment(b2Vec2 p1, b2Vec2 p2, b2Color color){
		Debug.DrawLine (new Vector3(p1.x*m_drawScale,p1.y*m_drawScale,0), new Vector3(p2.x*m_drawScale,p2.y*m_drawScale,0),color.unityColor);
	}

	/**
	* Draw a transform. Choose your own length scale.
	* @param xf a transform.
	*/
	public void DrawTransform(b2Transform xf){
		Debug.DrawLine (new Vector3(xf.position.x * m_drawScale, xf.position.y * m_drawScale),
		                new Vector3((xf.position.x + m_xformScale*xf.R.col1.x) * m_drawScale, (xf.position.y + m_xformScale*xf.R.col1.y) * m_drawScale),
		                Color.white);
		Debug.DrawLine (new Vector3(xf.position.x * m_drawScale, xf.position.y * m_drawScale),
		                new Vector3((xf.position.x + m_xformScale*xf.R.col2.x) * m_drawScale, (xf.position.y + m_xformScale*xf.R.col2.y) * m_drawScale),
		                Color.green);
	}
	
	
	
	private uint m_drawFlags;
	//public Sprite m_sprite;
	private float m_drawScale = 1.0f;
	
	private float m_lineThickness = 1.0f;
	private float m_alpha = 1.0f;
	private float m_fillAlpha = 1.0f;
	private float m_xformScale = 1.0f;
	
}

}
