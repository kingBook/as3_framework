package framework.utils {
	import Box2D.Collision.b2RayCastInput;
	import Box2D.Collision.b2RayCastOutput;
	import Box2D.Collision.Shapes.b2CircleShape;
	import Box2D.Collision.Shapes.b2PolygonShape;
	import Box2D.Collision.Shapes.b2Shape;
	import Box2D.Collision.b2WorldManifold;
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.b2BodyDef;
	import Box2D.Dynamics.b2FilterData;
	import Box2D.Dynamics.b2Fixture;
	import Box2D.Dynamics.b2FixtureDef;
	import Box2D.Dynamics.b2World;
	import Box2D.Dynamics.Contacts.b2ContactEdge;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import Box2D.Collision.b2AABB;
	import framework.utils.Mathk;
	public class Box2dUtil {
		
		public function Box2dUtil() {}
		private static var _worldManifold:b2WorldManifold=new b2WorldManifold();
		
		public static function setContactBodiesAwake(b:b2Body,awake:Boolean):void{
			var ce:b2ContactEdge=b.GetContactList();
			for(ce;ce;ce=ce.next){
				var b1:b2Body=ce.contact.GetFixtureA().GetBody();
				var b2:b2Body=ce.contact.GetFixtureB().GetBody();
				var ob:b2Body=b1==b?b2:b1;
				ob.SetAwake(awake);
			}
		}
		
		public static function createRoundBox(w:Number,h:Number,x:Number,y:Number,world:b2World,ptm_ratio:Number,roundRadius:Number,smooth:int=20):b2Body{
			var bodyDef:b2BodyDef = new b2BodyDef();
			bodyDef.type=b2Body.b2_dynamicBody;
			bodyDef.position.Set(x/ptm_ratio,y/ptm_ratio);
			
			var fixtureDef:b2FixtureDef = new b2FixtureDef();
			fixtureDef.shape = getRoundPolygonShape(w/ptm_ratio*0.5,h/ptm_ratio*0.5,roundRadius/ptm_ratio,smooth);
			var body:b2Body=world.CreateBody(bodyDef);
			body.CreateFixture(fixtureDef);
			return body;
		}
		
		public static function getRoundPolygonShape(hx:Number,hy:Number,roundRadius:Number,smooth:int=20):b2PolygonShape{
			var vertices:Vector.<b2Vec2>=new Vector.<b2Vec2>();
			var x:Number,y:Number;
			
			x=-hx, y=-hy;
			ComputeRoundVertices(x,y,x+roundRadius,y+roundRadius,roundRadius,smooth,vertices);
			
			x=hx, y=-hy;
			ComputeRoundVertices(x,y,x-roundRadius,y+roundRadius,roundRadius,smooth,vertices);
			
			x=hx, y=hy;
			ComputeRoundVertices(x,y,x-roundRadius,y-roundRadius,roundRadius,smooth,vertices);
			
			x=-hx, y=hy;
			ComputeRoundVertices(x,y,x+roundRadius,y-roundRadius,roundRadius,smooth,vertices);
			
			return b2PolygonShape.AsVector(vertices,vertices.length);
		}
		
		private static function ComputeRoundVertices(x:Number,y:Number,cx:Number,cy:Number,roundRadius:Number,smooth:int,outputVertices:Vector.<b2Vec2>):void{
			var cAngle:Number=Math.atan2(y-cy,x-cx);
			var angle:Number=cAngle-Math.PI/4;//-90°
			var angle1:Number;
			var interval:Number=Math.PI*0.5/smooth;//90°平均分smooth
			var x1:Number,y1:Number;
			for(var i:int=0;i<smooth;i++){
				angle1=angle+interval*i;
				x1=cx+Math.cos(angle1)*roundRadius;
				y1=cy+Math.sin(angle1)*roundRadius;
				outputVertices.push(new b2Vec2(x1,y1));
			}
		}
		
		public static function createBox(w:Number,h:Number,x:Number,y:Number,world:b2World,ptm_ratio:Number,center:b2Vec2=null):b2Body{
			var bodyDef:b2BodyDef = new b2BodyDef();
			bodyDef.type=b2Body.b2_dynamicBody;
			bodyDef.position.Set(x/ptm_ratio,y/ptm_ratio);
			
			var fixtureDef:b2FixtureDef = new b2FixtureDef();
            center||=new b2Vec2();
            center.Multiply(1/ptm_ratio);
			fixtureDef.shape = b2PolygonShape.AsOrientedBox(w/ptm_ratio*0.5,h/ptm_ratio*0.5,center);
			
			var body:b2Body=world.CreateBody(bodyDef);
			body.CreateFixture(fixtureDef);
			
			return body;
		}
		
		public static function createCircle(radius:Number,x:Number,y:Number,world:b2World,ptm_ratio:Number):b2Body{
			var bodyDef:b2BodyDef = new b2BodyDef();
			bodyDef.type=b2Body.b2_dynamicBody;
			bodyDef.position.Set(x/ptm_ratio,y/ptm_ratio);
			
			var fixtureDef:b2FixtureDef = new b2FixtureDef();
			fixtureDef.shape = new b2CircleShape(radius/ptm_ratio);
			
			var body:b2Body=world.CreateBody(bodyDef);
			body.CreateFixture(fixtureDef);
			
			return body;
		}
		
		/**创建多边形刚体*/
		public static function createPolygon(x:Number, y:Number, vertices:Vector.<b2Vec2>,world:b2World,ptm_ratio:Number):b2Body {
			var bodyDef:b2BodyDef=new b2BodyDef();
			bodyDef.type=b2Body.b2_dynamicBody;
			bodyDef.position.Set(x/ptm_ratio,y/ptm_ratio);
			
			var fixtureDef:b2FixtureDef = new b2FixtureDef();
			var v2:b2Vec2;
			var i:int=vertices.length;
			while (--i>=0){
				v2=vertices[i];
				v2.x/=ptm_ratio, v2.y/=ptm_ratio;
			}
			fixtureDef.shape = b2PolygonShape.AsVector(vertices,vertices.length);
			
			var body:b2Body=world.CreateBody(bodyDef);
			body.CreateFixture(fixtureDef);
			
			return body;
		}
		/**创建正边形刚体*/
		public static function createPolygonRegular(radius:Number,x:Number,y:Number,edges:uint,world:b2World,ptm_ratio:Number):b2Body{
			var bodyDef:b2BodyDef=new b2BodyDef();
			bodyDef.type=b2Body.b2_dynamicBody;
			bodyDef.position.Set(x/ptm_ratio,y/ptm_ratio);
			
			var fixtureDef:b2FixtureDef=new b2FixtureDef();
			fixtureDef.shape=createPolygonRegularShape(radius/ptm_ratio,edges);
			
			var body:b2Body=world.CreateBody(bodyDef);
			body.CreateFixture(fixtureDef);
			return body;
		}
		/**创建正多边形shape*/
		public static function createPolygonRegularShape(radius:Number,edges:uint):b2PolygonShape{
			var angleSize:Number = (2*Math.PI)/edges;
			var vertices:Vector.<b2Vec2>=new Vector.<b2Vec2>(edges,true);
			var angle:Number=0;
			for(var i:int=0;i<edges;i++){
				angle=i*angleSize;
				vertices[i]=new b2Vec2(Math.cos(angle)*radius,Math.sin(angle)*radius);
			}
			var polygon:b2PolygonShape=new b2PolygonShape();
			polygon.SetAsVector(vertices,edges);
			return polygon;
		}
		
		public static function createRoundBottomBody(w:Number,h:Number,x:Number,y:Number,radius:Number,bottomFriction:Number,world:b2World,ptm_ratio:Number):b2Body{
			w/=ptm_ratio, h/=ptm_ratio, x/=ptm_ratio, y/=ptm_ratio, radius/=ptm_ratio;
			var dx:Number=w*0.5-radius+0.2/ptm_ratio;
			var dy:Number=h*0.5-radius;
			
			var bodyDef:b2BodyDef=new b2BodyDef();
			bodyDef.type=b2Body.b2_dynamicBody;
			bodyDef.fixedRotation=true;
			bodyDef.position.Set(x,y);
			
			var body:b2Body=world.CreateBody(bodyDef);
			
			var fixtureDef:b2FixtureDef=new b2FixtureDef();
			var pol:b2PolygonShape=b2PolygonShape.AsOrientedBox(w*0.5,h*0.5,b2Vec2.Make(0,-radius));
			fixtureDef.friction=0;
			fixtureDef.shape = pol;
			body.CreateFixture(fixtureDef);
			
			fixtureDef=new b2FixtureDef();
			fixtureDef.friction=bottomFriction;
			var c:b2CircleShape=new b2CircleShape(radius);
			c.SetLocalPosition(b2Vec2.Make(-dx,dy));
			fixtureDef.shape=c;
			body.CreateFixture(fixtureDef);
			
			c=c.Copy() as b2CircleShape;
			c.SetLocalPosition(b2Vec2.Make(dx,dy));
			fixtureDef.shape=c;
			body.CreateFixture(fixtureDef);
			
			return body;
		}
		
		/**创建一个刚体，以一个容器所有子对象做为矩形形状*/
		public static function createBoxFromSprite(sprite:Sprite,world:b2World,ptm_ratio:Number):b2Body{
			var len:int=sprite.numChildren;
			var child:DisplayObject;
			var body:b2Body=world.CreateBody(new b2BodyDef);
			
			for(var i:int;i<len;i++){
				child=sprite.getChildAt(i);
				var fixtureDef:b2FixtureDef=new b2FixtureDef();
				var poly:b2PolygonShape=new b2PolygonShape();
				var w:Number=child.width*0.5/ptm_ratio;w*=sprite.scaleX;
				var h:Number=child.height*0.5/ptm_ratio;h*=sprite.scaleY;
				var x:Number=child.x/ptm_ratio;x*=sprite.scaleX;
				var y:Number=child.y/ptm_ratio;y*=sprite.scaleY;
				poly.SetAsOrientedBox(w,h,b2Vec2.Make(x,y));
				fixtureDef.shape=poly;
				body.CreateFixture(fixtureDef);
			}
			body.SetAngle(sprite.rotation*0.01745);
			body.SetType(b2Body.b2_kinematicBody);
			body.SetPosition(b2Vec2.Make(sprite.x/ptm_ratio,sprite.y/ptm_ratio));
			return body;
		}
		
		/*public static function fixedBody(body:b2Body, world:b2World):void{
			var jointDef:b2DistanceJointDef=new b2DistanceJointDef();
			jointDef.Initialize(world.GetGroundBody(),body,body.GetPosition(),body.GetPosition());
			//jointDef.collideConnected = true;
			world.CreateJoint(jointDef);
		}*/
		
		public static function setBodyFixture(body:b2Body,density:Number=NaN,friction:Number=NaN,restitution:Number=NaN,filter:b2FilterData=null,data:*=null):void{
			var fixture:b2Fixture=body.GetFixtureList();
			for(fixture;fixture;fixture=fixture.GetNext()){
				if(!isNaN(density))fixture.SetDensity(density);
				if(filter)fixture.SetFilterData(filter);
				if(!isNaN(friction))fixture.SetFriction(friction);
				if(!isNaN(restitution))fixture.SetRestitution(restitution);
				if(data)fixture.SetUserData(data);
			}
		}
		
		public static function createWrapWallBodies(x:Number, y:Number, w:Number, h:Number,world:b2World,ptm_ratio:Number):Vector.<b2Body> {
			var thickness:uint = 20;
			var bodies:Vector.<b2Body> = new Vector.<b2Body>(4,true);
			//顶
			bodies[0]=createBox(w, thickness, w * 0.5 + x,  y - thickness * 0.5,world,ptm_ratio);
			//底
			bodies[1]=createBox(w, thickness, w * 0.5 + x,  h + thickness * 0.5 + y,world,ptm_ratio);
			//左
			bodies[2]=createBox(thickness, h, x - thickness * 0.5, h * 0.5 + y,world,ptm_ratio);
			//右
			bodies[3]=createBox(thickness, h, x +w + thickness * 0.5, h * 0.5 + y,world,ptm_ratio);
			return bodies;
		}
		
		public static function createXmlBodies(xml:XML,world:b2World,ptm_ratio:Number):Vector.<b2Body>{
			var bodies:Vector.<b2Body>=new Vector.<b2Body>();
			var vertices:Array=getXmlVerts(xml,ptm_ratio);
			var i:int = vertices.length, j:int, bodyDef:b2BodyDef=new b2BodyDef(), b:b2Body,fixtrureDef:b2FixtureDef=new b2FixtureDef(),s:b2PolygonShape;
			bodyDef.type=b2Body.b2_staticBody;
			while (--i >= 0) {
				
				j = vertices[i].length;
				while (--j >= 0){
					b = world.CreateBody(bodyDef);
					s=b2PolygonShape.AsArray(vertices[i][j],vertices[i][j].length);
					fixtrureDef.shape=s;
					b.CreateFixture(fixtrureDef);
					bodies.push(b);
				}
			}
			return bodies;
		}
		
		public static function createXmlBody(xml:XML,world:b2World,ptm_ratio:Number):b2Body{
			var vertices:Array=getXmlVerts(xml,ptm_ratio);
			var i:int = vertices.length, j:int, bodyDef:b2BodyDef=new b2BodyDef(), b:b2Body,fixtrureDef:b2FixtureDef=new b2FixtureDef(),s:b2PolygonShape;
			bodyDef.type=b2Body.b2_staticBody;
			b = world.CreateBody(bodyDef);
			while (--i >= 0) {
				j = vertices[i].length;
				while (--j >= 0){
					s=b2PolygonShape.AsArray(vertices[i][j],vertices[i][j].length);
					fixtrureDef.shape=s;
					b.CreateFixture(fixtrureDef);
				}
			}
			return b;
		}
		
		public static function getXmlVerts(xml:XML,ptm_ratio:Number):Array{
			//[IF-SCRIPT]xml=new XML(xml);
			var vertices:Array=[];
			var numBodies:int, numPolygons:int, numVertexes:int;
			var i:int, j:int, k:int;
			numBodies=xml.bodies.body.fixture.length(); //刚体个数
			for (i = 0; i < numBodies; i++) {
				vertices[i]=[];
				numPolygons=xml.bodies.body.fixture[i].polygon.length(); //多边形个数
				for (j = 0; j < numPolygons; j++) {
					vertices[i][j]=[];
					numVertexes = xml.bodies.body.fixture[i].polygon[j].vertex.length(); //顶点个数
					for (k = 0; k < numVertexes; k++)
						vertices[i][j][k] = new b2Vec2( (Number(xml.bodies.body.fixture[i].polygon[j].vertex[k].@x))/ptm_ratio, 
														(Number(xml.bodies.body.fixture[i].polygon[j].vertex[k].@y))/ptm_ratio
													  );
				}
			}
			return vertices;
		}
		
		/**求点与线段的关系*/
		public static function pointOnSegment(p:b2Vec2,p1:b2Vec2,p2:b2Vec2):Number {
			var ax:Number = p2.x-p1.x;
			var ay:Number = p2.y-p1.y;			
			var bx:Number = p.x-p1.x;
			var by:Number = p.y-p1.y;
			return ax*by-ay*bx;
		}
		
		/**切割多个刚体*/
		public static function cutBodies(bodies:Vector.<b2Body>,rayStart:b2Vec2,rayEnd:b2Vec2,outputBodies:Vector.<b2Body>=null):Vector.<b2Body>{
			var resultBodies:Vector.<b2Body>=outputBodies?outputBodies:new Vector.<b2Body>();
			var body:b2Body;
			var i:int=bodies.length;
			while (--i>=0){
				body=bodies[i];
				cutBody(body,rayStart,rayEnd,resultBodies);
			}
			return resultBodies;
		}
		
		/**切割刚体*/
		public static function cutBody(body:b2Body,rayStart:b2Vec2,rayEnd:b2Vec2,outputBodies:Vector.<b2Body>=null):Vector.<b2Body>{
			var resultBodies:Vector.<b2Body>=outputBodies?outputBodies:new Vector.<b2Body>();
			var world:b2World=body.GetWorld();
			var rayLength:Number=b2Vec2.Distance(rayStart,rayEnd);
			var vertices2:Vector.<b2Vec2>=new Vector.<b2Vec2>();//存射线的右边点
			var vertices1:Vector.<b2Vec2>=new Vector.<b2Vec2>();//存射线的左边点
			
			var fixture:b2Fixture=body.GetFixtureList();
			var shape:b2Shape,polygon:b2PolygonShape,output:b2RayCastOutput=new b2RayCastOutput(),input:b2RayCastInput,hit1:b2Vec2,hit2:b2Vec2,rayAngle:Number;
			for(fixture;fixture;fixture=fixture.GetNext()){
				shape=fixture.GetShape();
				if(shape is b2CircleShape){//如果是圆形，则转换为正多边形
					var circle:b2CircleShape=shape as b2CircleShape;
					polygon=createPolygonRegularShape(circle.GetRadius(),15);
				}else{
					polygon=shape as b2PolygonShape;
				}
				if(!polygon)continue;
				//求正向射线碰撞点
				rayAngle=Math.atan2(rayEnd.y-rayStart.y,rayEnd.x-rayStart.x);
				input=new b2RayCastInput(rayStart,rayEnd,1);
				if(polygon.RayCast(output,input,body.GetTransform())){
					hit1=new b2Vec2(rayStart.x+Math.cos(rayAngle)*(rayLength*output.fraction), rayStart.y+Math.sin(rayAngle)*(rayLength*output.fraction));
				}
				//求反向射线碰撞点
				rayAngle=Math.atan2(rayStart.y-rayEnd.y,rayStart.x-rayEnd.x);
				input=new b2RayCastInput(rayEnd,rayStart,1);
				if(polygon.RayCast(output,input,body.GetTransform())){
					hit2=new b2Vec2(rayEnd.x+Math.cos(rayAngle)*(rayLength*output.fraction), rayEnd.y+Math.sin(rayAngle)*(rayLength*output.fraction));
				}
				
				if(hit1&&hit2){
					var rayCenter:b2Vec2=new b2Vec2((hit1.x+hit2.x)*0.5,(hit1.y+hit2.y)*0.5);
					rayAngle=Math.atan2(hit1.y-hit2.y,hit1.x-hit2.x);
					var localVertices:Vector.<b2Vec2>=polygon.GetVertices();
					var worldPoint:b2Vec2,cutAngle:Number;
					var currentPoly:int=0;
					var cutPlaced1:Boolean=false;
					var cutPlaced2:Boolean=false;
					var localV:b2Vec2;
					var i:int=localVertices.length;
					while(--i>=0){
						localV=localVertices[i];
						worldPoint=body.GetWorldPoint(localV);
						cutAngle=Math.atan2(worldPoint.y-rayCenter.y,worldPoint.x-rayCenter.x)-rayAngle;
						if(cutAngle<-Math.PI) cutAngle+=2*Math.PI;
						if(cutAngle>0&&cutAngle<=Math.PI){
							if(currentPoly==2){
								cutPlaced1=true;
								vertices1.push(hit2);
								vertices1.push(hit1);
							}
							vertices1.push(worldPoint);
							currentPoly=1;
						}else{
							if(currentPoly==1){
								cutPlaced2=true;
								vertices2.push(hit1);
								vertices2.push(hit2);
							}
							vertices2.push(worldPoint);
							currentPoly=2;
						}
					}
					if(!cutPlaced1){
						vertices1.push(hit2);
						vertices1.push(hit1);
					}
    					if(!cutPlaced2){
						vertices2.push(hit1);
						vertices2.push(hit2);
					}
					//创建
					resultBodies.push(createCutBody(vertices2,vertices2.length,world));
					resultBodies.push(createCutBody(vertices1,vertices1.length,world));
    				}
			}
			return resultBodies;
		}
		
		/**创建切割后的刚体*/
		private static function createCutBody(vertices:Vector.<b2Vec2>,len:int,world:b2World):b2Body{
			var center:b2Vec2=findCentroid(vertices,len);
			var v:b2Vec2;
			var i:int=vertices.length;
			while (--i>=0){
				v=vertices[i];
				v.Subtract(center);
			}
			var b:b2Body=world.CreateBody(new b2BodyDef());
			var fixtureDef:b2FixtureDef=new b2FixtureDef();
			fixtureDef.shape=b2PolygonShape.AsVector(vertices,len);
			b.CreateFixture(fixtureDef);
			b.SetPosition(center);
			b.SetType(b2Body.b2_dynamicBody);
			i=vertices.length;
			while (--i>=0){
				v=vertices[i];
				v.Add(center);
			}
			return b;
		}
		
		/** 寻找质心*/
		public static function findCentroid(vs:Vector.<b2Vec2>, count:uint):b2Vec2 {
			var c:b2Vec2 = new b2Vec2();
			var area:Number=0.0;
			var p1X:Number=0.0;
			var p1Y:Number=0.0;
			var inv3:Number=1.0/3.0;
			for (var i:int = 0; i < count; ++i) {
				var p2:b2Vec2=vs[i];
				var p3:b2Vec2=i+1<count?vs[int(i+1)]:vs[0];
				var e1X:Number=p2.x-p1X;
				var e1Y:Number=p2.y-p1Y;
				var e2X:Number=p3.x-p1X;
				var e2Y:Number=p3.y-p1Y;
				var D:Number = (e1X * e2Y - e1Y * e2X);
				var triangleArea:Number=0.5*D;
				area+=triangleArea;
				c.x += triangleArea * inv3 * (p1X + p2.x + p3.x);
				c.y += triangleArea * inv3 * (p1Y + p2.y + p3.y);
			}
			c.x*=1.0/area;
			c.y*=1.0/area;
			return c;
		}
		
		/**创建矩形刚体，与disObj一样的位置，大小，旋转角*/
		public static function createBoxWithDisObj(disObj:DisplayObject,world:b2World,ptm_ratio:Number):b2Body{
			var w:Number=FuncUtil.getTransformWidth(disObj);
			var h:Number=FuncUtil.getTransformHeight(disObj);
			var body:b2Body=createBox(w,h,disObj.x,disObj.y,world,ptm_ratio);
			body.SetAngle((disObj.rotation%360)*0.01745);
			return body;
		}
		
		/**创建圆角矩形刚体，与disObj一样的位置，大小，旋转角*/
		public static function createRoundBoxWithDisObj(disObj:DisplayObject,world:b2World,ptm_ratio:Number,roundRadius:Number=5,smooth:Number=10):b2Body{
			var w:Number=FuncUtil.getTransformWidth(disObj);
			var h:Number=FuncUtil.getTransformHeight(disObj);
			var body:b2Body=createRoundBox(w,h,disObj.x,disObj.y,world,ptm_ratio,roundRadius,smooth);
			body.SetAngle((disObj.rotation%360)*0.01745);
			return body;
		}
		/**替换形状为圆角多边形*/
		public static function replaceRoundBoxWithFixture(fixture:b2Fixture,ptm_ratio:Number,roundRadius:Number=5,smooth:int=10):void{
			var body:b2Body=fixture.GetBody();
			//记录角度，先设置为0后还原
			var angle:Number=body.GetAngle();
			body.SetAngle(0);

			var aabb:b2AABB=body.GetAABB();
			var poly:b2PolygonShape=fixture.GetShape() as b2PolygonShape;

			var fixtureDef:b2FixtureDef=new b2FixtureDef();
			fixtureDef.density=fixture.GetDensity();
			fixtureDef.filter=fixture.GetFilterData();
			fixtureDef.friction=fixture.GetFriction();
			fixtureDef.isSensor=fixture.IsSensor();
			fixtureDef.restitution=fixture.GetRestitution();
			fixtureDef.userData=fixture.GetUserData();
			fixtureDef.shape=getRoundPolygonShape(aabb.GetExtents().x,aabb.GetExtents().y,roundRadius/ptm_ratio,smooth);
			body.DestroyFixture(fixture);
			body.CreateFixture(fixtureDef);

			body.SetAngle(angle);//还原角度
		}
		
		/**
		 * 检测是否在地面
		 * @param	b 检测的刚体
		 * @param	normalY 检测在地面的法线向量
		 * @param	ignoreCallback function(contact:b2Contact):Boolean; 返回true将忽略当前b2Contact的检测
		 * @return
		 */
		public static function getIsOnGround(b:b2Body,normalY:Number=0.7,ignoreCallback:Function=null):Boolean{
			var isOnGround:Boolean=false;
			var ce:b2ContactEdge=b.GetContactList();
			for(ce;ce;ce=ce.next){
				if(!ce.contact.IsEnabled())continue;
				if(!ce.contact.IsTouching())continue;
				if(ce.contact.IsSensor())continue;
				if(ignoreCallback!=null && ignoreCallback(ce.contact))continue;
				ce.contact.GetWorldManifold(_worldManifold);
				var ny:Number=_worldManifold.m_normal.y;  if(ce.contact.GetFixtureA().GetBody()!=b)ny=-ny;
				if(ny>=normalY){
					isOnGround=true;
					break;
				}
			}
			return isOnGround;
		}
		
		/**
		 * 返回轨迹点
		 * @param	pos0 初始位置
		 * @param	v0 初始速度
		 * @param	n 预测step次数
		 * @param	world 
		 * @param	deltaTime
		 * @return
		 */
		public static function getTrajectoryPoint(pos0:b2Vec2,v0:b2Vec2,n:Number,world:b2World,deltaTime:Number):b2Vec2{
			var t:Number=1/deltaTime;
			var stepVX:Number=v0.x*t; 
			var stepVY:Number=v0.y*t; 
			var stepGX:Number=world.GetGravity().x*t*t;
			var stepGY:Number=world.GetGravity().y*t*t;
			
			var result:b2Vec2=new b2Vec2();
			result.x=pos0.x+n*stepVX+0.5*(n*n+n)*stepGX;
			result.y=pos0.y+n*stepVY+0.5*(n*n+n)*stepGY;
			return result;
		}
		
		/**返回抛物线的最高点y坐标*/
		public static function getMaxHeight(pos0:b2Vec2,v0:b2Vec2,world:b2World,deltaTime:Number):Number{
			if(v0.y>0)return pos0.y;
			
			var t:Number=1/deltaTime;
			//var stepVX:Number=v0.x*t; 
			var stepVY:Number=v0.y*t; 
			//var stepGX:Number=world.GetGravity().x*t*t;
			var stepGY:Number=world.GetGravity().y*t*t;
			
			var n:Number=-stepVY/stepGY-1;
			return pos0.y+n*stepVY+0.5*(n*n+n)*stepGY;
		}
		
		/**返回抛物线的最高点xy坐标*/
		public static function getMaxHeightPoint(pos0:b2Vec2,v0:b2Vec2,world:b2World,deltaTime:Number):b2Vec2{
			if(v0.y>0)return pos0;
			
			var t:Number=1/deltaTime;
			var gy:Number = world.GetGravity().y;
			var n:Number = -v0.y/t /gy;
			return getTrajectoryPoint(pos0,v0,n,world,deltaTime);
		}
		
		/**
		 * 返回需要到达抛物线最高点所需要vy
		 * @param	dy 高度一个负数
		 * @param	world
		 * @param	deltaTime
		 * @return
		 */
		public static function calculateVerticalVelocityForHeight(dy:Number,world:b2World,deltaTime:Number):Number{
			if(dy>=0)return 0;
			var t:Number=1/deltaTime;
			var stepGY:Number=world.GetGravity().y*t*t;
			
			var a:Number=0.5/stepGY;
			var b:Number=0.5;
			var c:Number=dy;
			
			var quadraticSolution1:Number=( -b - Math.sqrt( b*b - 4*a*c ) ) / (2*a);
			var quadraticSolution2:Number=( -b + Math.sqrt( b*b - 4*a*c ) ) / (2*a);
			
			var v:Number=quadraticSolution1;
			if (v>0) v=quadraticSolution2;
			return v*deltaTime;
		}
		
		/**
		 * 返回抛物线所需到达起点y平行的目标x所需vx
		 * @param	dx （目标x-当前x）
		 * @param	vy	抛物线向量y
		 * @param	world
		 * @param	deltaTime
		 * @return
		 */
		public static function calculateHorizontalVelocityForWidth(dx:Number,vy:Number,world:b2World,deltaTime:Number):Number{
			var t:Number=1/deltaTime;
			var gy:Number=world.GetGravity().y;
			var stepGX:Number=world.GetGravity().x*t*t;
			var stepGY:Number=world.GetGravity().y*t*t;
			var n:Number=-vy/t/gy;n*=2;
			var vx:Number=(dx-0.5*(n*n+n)*stepGX)/n;
			vx/=t;
			return vx;
		}
		
		public static function getVelocityForPosition(from:b2Vec2,to:b2Vec2,world:b2World,deltaTime:Number):b2Vec2{
			var dy:Number = to.y-from.y;
			var dx:Number = to.x -from.x;
			
			if ( dy >= 0 )
				return new b2Vec2();
			
			var delta:Number = 1 / deltaTime;
			var aGravity:Number = delta * delta * world.GetGravity().y; // m/s/s
			
			var a:Number = 0.5 / aGravity;
			var b:Number = 0.5;
			var c:Number = dy;
			
			var quadraticSolution1:Number = ( -b - Math.sqrt( b*b - 4*a*c ) ) / (2*a);
			var quadraticSolution2:Number = ( -b + Math.sqrt( b*b - 4*a*c ) ) / (2*a);
			
			var vy:Number = quadraticSolution1;
			if ( vy > 0  ){
				vy = quadraticSolution2;
			}

			var vx:Number = dx/(-vy/aGravity*delta);

			return new b2Vec2(vx,vy*deltaTime);
		}
		
		public static function updateBodyAngle(body:b2Body,angle:Number,dt:Number,maxAngleSpeed:Number=1):void{
			maxAngleSpeed*=0.01745;
			var nextAngle:Number=body.GetAngle()+body.GetAngularVelocity()*dt;
			var vAngle:Number=angle-nextAngle;
			if(vAngle<-Math.PI)vAngle+=2*Math.PI;
			else if(vAngle>Math.PI)vAngle-=2*Math.PI;
			vAngle=vAngle/dt;
			vAngle=Math.min(maxAngleSpeed,Math.max(-maxAngleSpeed,vAngle));
			var impulse:Number=body.GetInertia()*vAngle;
			body.ApplyAngularImpulse(impulse,true);
		}

		public static function getBodyAContactBodyB(bodyA:b2Body,bodyB:b2Body,isFilterSensor:Boolean=false):Boolean{
			var ce:b2ContactEdge=bodyA.GetContactList();
            for(ce;ce;ce=ce.next){
                if(!ce.contact.IsTouching())continue;
				if(isFilterSensor){
					if(ce.contact.IsSensor())continue;
				}
                if(ce.other==bodyB)return true;
            }
			return false;
		}

		public static function getBodyMaskSprite(body:b2Body,ptm_ratio:Number,offsetLeft:Number=0,offsetRight:Number=0,offsetTop:Number=0,offsetBottom:Number=0):Sprite{
			var angle:Number=body.GetAngle();
			body.SetAngle(0);
			var aabb:b2AABB=body.GetAABB();
			body.SetAngle(angle);

			var w:Number=aabb.GetExtents().x*2*ptm_ratio;
			var h:Number=aabb.GetExtents().y*2*ptm_ratio;
			var x:Number=-w*0.5;
			var y:Number=-h*0.5;
			w+=offsetRight-offsetLeft;
			h+=offsetBottom-offsetTop;
			x+=offsetLeft;
			y+=offsetTop;
			var sp:Sprite=new Sprite();
			sp.graphics.beginFill(0);
			sp.graphics.drawRect(x,y,w,h);
			sp.graphics.endFill();

			sp.x=body.GetPosition().x*ptm_ratio;
			sp.y=body.GetPosition().y*ptm_ratio;
			sp.rotation=angle*Mathk.Rad2Deg;
			return sp;
		}
	};

}





