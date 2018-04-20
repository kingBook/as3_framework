using Box2D.Dynamics;
namespace Box2D.Dynamics.Controllers 
{
public class b2ControllerEdge 
{
	/** provides quick access to other end of this edge */
	public b2Controller controller;
	/** the body */
	public b2Body body;
	/** the previous controller edge in the controllers's body list */
	public b2ControllerEdge prevBody;
	/** the next controller edge in the controllers's body list */
	public b2ControllerEdge nextBody;
	/** the previous controller edge in the body's controller list */
	public b2ControllerEdge prevController;
	/** the next controller edge in the body's controller list */
	public b2ControllerEdge nextController;
}
}