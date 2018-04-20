package g.particles{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;

	public class ParticleConfig{
		public var moveSpeed:Number=5;
		public var lifeMin:Number=1000;
		public var lifeMax:Number=2000;
		public var scaleStart:Number=1;
		public var scaleEnd:Number=0;
		public var viewDefName:String;
		public var viewParent:DisplayObjectContainer;
		public function ParticleConfig(viewDefName:String,viewParent:DisplayObjectContainer=null){
			this.viewDefName=viewDefName;
			this.viewParent=viewParent;
		}
	}
}