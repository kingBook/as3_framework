package framework.fsm{
	/**demo: http://www.cnblogs.com/kingBook/p/5589925.html */
	public class Fsm{
		
		protected var _curState:State;
		protected var _callbackChangeState:Function;
		/**
		 * 状态机
		 * @param	defaultState 默认状态
		 * @param	callbackChangeState 改变状态回调函数 function(state:State):void;
		 */
		public function Fsm(defaultState:State,callbackChangeState:Function){
			_callbackChangeState=callbackChangeState;
			changeState(defaultState);
		}
		
		public function changeState(state:State):void{
			if(_curState)_curState.dispose();
			_curState=state;
			_callbackChangeState(_curState);
		}
		
		public function update():void{
			_curState.execute();
		}
		
		public function dispose():void{
			_curState=null;
			_callbackChangeState=null;
		}
		
		public function get curState():State{return _curState;}
	};
}