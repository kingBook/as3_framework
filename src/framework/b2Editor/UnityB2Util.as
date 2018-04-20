package framework.b2Editor{
	import Box2D.Collision.Shapes.b2Shape;
	import Box2D.Collision.Shapes.b2PolygonShape;
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Collision.Shapes.b2CircleShape;

	public class UnityB2Util{
		public static function scaleShapeWithTransformData(shape:b2Shape,transformData:TransformData):void{
			if(shape is b2PolygonShape){
				var poly:b2PolygonShape=shape as b2PolygonShape;
				var vertices:Vector.<b2Vec2>=poly.GetVertices();
				for(var i:int=0;i<vertices.length;i++){
					vertices[i].x*=transformData.lossyScale.x;
					vertices[i].y*=transformData.lossyScale.y;
				}
			}else if(shape is b2CircleShape){
				var circle:b2CircleShape=shape as b2CircleShape;
				var scale:Number=Math.max(transformData.lossyScale.x,transformData.lossyScale.y);
				circle.SetRadius(circle.GetRadius()*scale);
				var offset:b2Vec2=circle.GetLocalPosition();
				offset.x*=transformData.lossyScale.x;
				offset.y*=transformData.lossyScale.y;
				circle.SetLocalPosition(offset);
			}
		}
	}
}