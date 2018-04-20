package g.objs{
	import g.objs.MyObj;
	import Box2D.Dynamics.b2Body;
	import g.objs.BodyObject;
	import Box2D.Dynamics.Contacts.b2Contact;
	import Box2D.Collision.b2Manifold;
	import Box2D.Dynamics.b2ContactImpulse;

	public class BodyObject extends MyObj{
		protected var _body:b2Body;
		public function BodyObject():void{
			super();
		}

		override protected function init(info:*=null):void{
			super.init(info);
			_body=info.body;
			if(_body){
				var userData:*=_body.GetUserData();
				userData.type=getClassName();
				userData.thisObj=this;
				_body.SetUserData(userData);

				_body.SetPreSolveCallback(preSolve);
				_body.SetContactBeginCallback(contactBegin);
				_body.SetPostSolveCallback(postSolve);
				_body.SetContactEndCallback(contactEnd);
			}
		}

		virtual protected function preSolve(contact:b2Contact, oldManifold:b2Manifold, other:b2Body):void{}
		virtual protected function contactBegin(contact:b2Contact, other:b2Body):void{}
		virtual protected function postSolve(contact:b2Contact, impulse:b2ContactImpulse, other:b2Body):void{}
		virtual protected function contactEnd(contact:b2Contact, other:b2Body):void{}

		override protected function onDestroy():void{
			if(_body){
				_body.SetPreSolveCallback(null);
				_body.SetContactBeginCallback(null);
				_body.SetPostSolveCallback(null);
				_body.SetContactEndCallback(null);
				_body.Destroy();
				_body=null;
			}
			super.onDestroy();
		}
	}
	
	
}