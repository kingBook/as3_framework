package framework.system{
	import Box2D.Collision.b2Manifold;
	import Box2D.Dynamics.b2ContactImpulse;
	import Box2D.Dynamics.b2ContactListener;
	import Box2D.Dynamics.b2ContactListener;
	import Box2D.Dynamics.Contacts.b2Contact;
	import Box2D.Dynamics.b2Body;
	
	public class Box2dContactListener extends b2ContactListener{
		
		public function Box2dContactListener(){super();}
		
		override public function BeginContact(contact:b2Contact):void{
			var b1:b2Body = contact.GetFixtureA().GetBody();
			var b2:b2Body = contact.GetFixtureB().GetBody();
			b1.RunContactBeginCallback(contact,b2);
			b2.RunContactBeginCallback(contact,b1);
		}


		override public function EndContact(contact:b2Contact):void{
			var b1:b2Body = contact.GetFixtureA().GetBody();
			var b2:b2Body = contact.GetFixtureB().GetBody();
			b1.RunContactEndCallback(contact,b2);
			b2.RunContactEndCallback(contact,b1);
		}
		
		override public function PreSolve(contact:b2Contact, oldManifold:b2Manifold):void{
			var b1:b2Body = contact.GetFixtureA().GetBody();
			var b2:b2Body = contact.GetFixtureB().GetBody();
			b1.RunPreSolveCallback(contact,oldManifold,b2);
			b2.RunPreSolveCallback(contact,oldManifold,b1);
		}
		
		override public function PostSolve(contact:b2Contact, impulse:b2ContactImpulse):void{
			var b1:b2Body = contact.GetFixtureA().GetBody();
			var b2:b2Body = contact.GetFixtureB().GetBody();
			b1.RunPostSolveCallback(contact,impulse,b2);
			b2.RunPostSolveCallback(contact,impulse,b1);
		}
	}

}