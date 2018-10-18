package g {
	import Box2D.Common.Math.b2Vec2;
	/**
	 * 2014-10-09 14:54
	 */
	public class MyData {
		public static var ptm_ratio:Number = 100;
		public static var designW:int=800;
		public static var designH:int=600;
		public static var frameRate:uint = 50;
		public static var fixedTimestep:Number=0.02;
		public static var isTesting:Boolean=true;
		public static var isDebugDraw:Boolean = true;
		public static var isVisibleFPS:Boolean= false;
		public static var useMouseJoint:Boolean = true;
		public static var unlock:Boolean = true;
		public static var clearLocalData:Boolean = false;
		public static var mute:Boolean = true;
        public static var isEndContinueBackgroupMusic:Boolean=false;//胜利/失败时是否继续播放背景音乐
		public static var isDisableControllBar:Boolean=false;
		public static var linkHomePageFunc:Function = null;
		
		public static var isAIR:Boolean=false;
		public static var languageVersion:String="cn";// cn | en | auto
		public static var language:String;//程序中判断的变量
		
		public function MyData() {
			
		}
		
	}

}