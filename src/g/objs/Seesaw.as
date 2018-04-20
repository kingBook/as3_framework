package g.objs{
	import Box2D.Collision.Shapes.b2PolygonShape;
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.Contacts.b2ContactEdge;
	import Box2D.Dynamics.Joints.b2RevoluteJointDef;
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.b2BodyDef;
	import Box2D.Dynamics.b2FixtureDef;
	import flash.display.MovieClip;
	import flash.geom.Rectangle;
	import framework.game.Game;
	import framework.objs.Clip;
	import g.objs.MovableObject;
	import g.MyData;
	import Box2D.Dynamics.b2World;
	/**跷跷板*/
	public class Seesaw extends MovableObject{
		
		public function Seesaw(){
			super();
		}
		
		static public function create(childMc:MovieClip,world:b2World):void{
			var game:Game=Game.getInstance();
			
			var bodyDef:b2BodyDef=new b2BodyDef();
			bodyDef.position.Set(childMc.x/MyData.ptm_ratio,childMc.y/MyData.ptm_ratio);
			bodyDef.type=b2Body.b2_dynamicBody;
			
			var fixtureDef:b2FixtureDef=new b2FixtureDef();
			fixtureDef.shape=b2PolygonShape.AsOrientedBox(childMc.width*0.5/MyData.ptm_ratio,childMc.height*0.5/MyData.ptm_ratio,new b2Vec2());
			var body:b2Body=world.CreateBody(bodyDef);
			body.CreateFixture(fixtureDef);
			
			var r:Rectangle=childMc.getBounds(childMc.parent);
			var rcx:Number=r.x+r.width*0.5;
			var rcy:Number=r.y+r.height*0.5;
			var ov:b2Vec2=new b2Vec2(childMc.x-rcx,childMc.y-rcy);
			ov.Multiply(-1/MyData.ptm_ratio);
			
			var poly:b2PolygonShape=body.GetFixtureList().GetShape() as b2PolygonShape;
			var vertices:Vector.<b2Vec2>=poly.GetVertices();
			for each(var v:b2Vec2 in vertices)v.Add(ov);
			
			var clip:Clip=Clip.fromDefName("Seesaw_view",true,true,game.global.layerMan.items1Layer,childMc.x,childMc.y);
			clip.transform=childMc.transform;
			clip.smoothing=true;
			
			game.createGameObj(new Seesaw(),{
				body:body,
				view:clip,
				world:world
			});
		}
		
		override protected function init(info:* = null):void{
			super.init(info);
			var world:b2World=info.world;
			var jointDef:b2RevoluteJointDef=new b2RevoluteJointDef();
			jointDef.Initialize(_body,world.GetGroundBody(),_body.GetWorldCenter());
			world.CreateJoint(jointDef);
			
			_body.SetAngularDamping(15);
		}
		
		override protected function update():void{
			var isEmptyContact:Boolean=true;
			var ce:b2ContactEdge=_body.GetContactList();
			for(ce;ce;ce=ce.next){
				var b1:b2Body=ce.contact.GetFixtureA().GetBody();
				var b2:b2Body=ce.contact.GetFixtureB().GetBody();
				var ob:b2Body=b1==_body?b2:b1;
				if(!ce.contact.IsEnabled()||!ce.contact.IsTouching()||ce.contact.IsSensor())continue;
				if(ob.GetUserData().type=="Ground")continue;
				isEmptyContact=false;
				break;
			}
			if(isEmptyContact){
				var angle:Number=_body.GetAngle();
				angle*=0.9;
				_body.SetAngle(angle);
			}
			super.update();
		}
	};

}