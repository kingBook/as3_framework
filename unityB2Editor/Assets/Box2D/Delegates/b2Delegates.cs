using Box2D.Collision;
using Box2D.Dynamics;
using Box2D.Common.Math;

namespace Box2D.Delegates
{
	///public delegate void IBroadPhase_UpdatePairs_Callback(object data1,object data2);
	public delegate bool BroadPhaseQueryCallback(object proxy);
	public delegate float BroadPhaseRayCastCallback(b2RayCastInput input, object proxy);
	
	public delegate float b2WorldRayCastCallback(b2Fixture fixture,b2Vec2 point,b2Vec2 normal,float fraction);
	public delegate bool b2WorldQueryCallback(b2Fixture fixture);

}