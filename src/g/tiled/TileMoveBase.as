package g.tiled{
	import flash.geom.Point;
	
	public class TileMoveBase extends TileBase{
		protected var _moveSpeed:Number=2;
		protected var _moveDirV:Point=new Point();
        private var _velocity:Point=new Point();
		private var _isGotoAtStopTimeCellCentering:Boolean;
		private var _nextCell:Point=new Point();
        private var _curCellPos:Point=new Point();
		private var _cellCenterPos:Point=new Point();
		private var _cellCenterPosInt:Point=new Point();
		private var _tmpPoint:Point=new Point();
		
		public function TileMoveBase(){
			super();
		}
		
		override protected function update():void{
			super.update();
			//moveToTargetCellStopAI(targetCell:Point);
			//moveToObsStopAI();
		}
		
		/**
		 * 根据移动方向一直移动到目标格子的中心则停止的AI
		 */
		final protected function moveToTargetCellStopAI(targetCell:Point):Boolean{
			var isStop:Boolean=false;
			if(_moveDirV.x!=0||_moveDirV.y!=0){
				if(_isGotoAtStopTimeCellCentering){
					isStop=moveToAtStopTimeCellCenter();
				}else if(posInt.equals(targetCell)){
					_cellCenterPosInt.setTo(posInt.x,posInt.y);
					getPosWithPosInt(_cellCenterPosInt,_cellCenterPos);
					if(pos.equals(_cellCenterPos))isStop=true;
					else _isGotoAtStopTimeCellCentering=true;
				}else{
					moveWithV(_moveDirV);
				}
			}else{
				isStop=true;
				onStopMove();
			}
			return isStop;
		}
		
		/**
		 * 根据移动方向一直移动到障碍格子前停止的AI
		 * @return 是否走到目标点停止
		 */
		final protected function moveToObsStopAI():Boolean{
			var isStop:Boolean=false;
			if(_moveDirV.x!=0||_moveDirV.y!=0){
				if(_isGotoAtStopTimeCellCentering){
					isStop=moveToAtStopTimeCellCenter();
				}else{
					moveWithV(_moveDirV);
				}
			}else{
				isStop=true;
				onStopMove();
			}
			return isStop;
		}
		
		/**
		 * 根据当前移动方向计算下一个格子能否通过，
		 * 1.能通过则移动. 2.不能通过移动到当前或下一格子的中心
		 * 需要每一帧都调用
		 * @param	moveDirV 移动方向Point
		 */
		private function moveWithV(moveDirV:Point):void{
			getNextCell(moveDirV,_nextCell);
			if(isCanPassWithPosInt(_nextCell)){
				_velocity.setTo(moveDirV.x*_moveSpeed,moveDirV.y*_moveSpeed);
				movePos(_velocity.x,_velocity.y);
			}else if(getMoveOutCurrentCellCenterWithMoveDirV(moveDirV)/*行走超过当前格子的中心*/){
				//调头
				moveDirV.setTo(-moveDirV.x,-moveDirV.y);
				_velocity.setTo(moveDirV.x*_moveSpeed,moveDirV.y*_moveSpeed);
				movePos(_velocity.x,_velocity.y);
				onOutCurrentCellCenterTurnAround(moveDirV);
			}else if(pos.equals(getPosWithPosInt(posInt))/*正好走到当前格子的中心*/){
				moveDirV.setTo(0,0);
				onStopMove();
			}else{/*行走没超过当前格子的中心*/
				_cellCenterPosInt.setTo(posInt.x,posInt.y);
				getPosWithPosInt(_cellCenterPosInt,_cellCenterPos);
				_isGotoAtStopTimeCellCentering=true;
			}
		}
		
		/**在超过当前格子中心调头时运行,如果脸的方向不一样在子类重写该函数进行设置*/
		virtual protected function onOutCurrentCellCenterTurnAround(moveDirV:Point):void{  }
		final protected function getMoveOutCurrentCellCenterWithMoveDirV(moveDirV:Point):Boolean{
			var result:Boolean=false;
			getPosWithPosInt(posInt,_curCellPos);//update current cell position
			if(moveDirV.x<0){
				if(pos.x<_curCellPos.x)result=true;
			}else if(moveDirV.x>0){
				if(pos.x>_curCellPos.x)result=true;
			}else if(moveDirV.y<0){
				if(pos.y<_curCellPos.y)result=true;
			}else if(moveDirV.y>0){
				if(pos.y>_curCellPos.y)result=true;
			}
			return result;
		}
		
		/**根据移动方向判断移动是否超过指定格子的中心*/
		final protected function getOutCellCenter(moveDirV:Point,posInt:Point):Boolean{
			var result:Boolean=false;
			getPosWithPosInt(posInt,_tmpPoint);
			if(moveDirV.x<0){
				if(pos.x<_tmpPoint.x)result=true;
			}else if(moveDirV.x>0){
				if(pos.x>_tmpPoint.x)result=true;
			}else if(moveDirV.y<0){
				if(pos.y<_tmpPoint.y)result=true;
			}else if(moveDirV.y>0){
				if(pos.y>_tmpPoint.y)result=true;
			}
			return result;
		}
		
		private function moveToAtStopTimeCellCenter():Boolean{
			if(gotoPos(_moveDirV,_cellCenterPos)){
				_moveDirV.setTo(0,0);
				_isGotoAtStopTimeCellCentering=false;
				onGotoStopTimeCellCenter();
				onStopMove();
				return true;
			}
			return false;
		}
		
		/**
		 * 走到停止时的格子中心
		 */
		virtual protected function onGotoStopTimeCellCenter():void{ }
		
		/**
		 * 在_moveV.setTo(0,0)的时候运行
		 */
		virtual protected function onStopMove():void{ }
		
		private function gotoPos(moveDirV:Point,target:Point):Boolean{
			_velocity.setTo(moveDirV.x*_moveSpeed,moveDirV.y*_moveSpeed);
			var d:Number=Point.distance(pos,target);
			if(d>_velocity.length){
				movePos(_velocity.x,_velocity.y);
			}else{
				movePos(target.x-pos.x,target.y-pos.y);
				return true;
			}
			return false;
		}
		
		/**
		 * 根据不为0的移动方向Point，计算出下一格子的位置
		 * @param	moveV
		 * @param	out 整数Point
		 * @return
		 */
		protected function getNextCell(moveV:Point,out:Point=null):Point{
			out||=new Point();
			out.setTo(posInt.x+moveV.x,posInt.y+moveV.y);
            return out;
        }
		
		/**判断某格子位置是否有障碍能否通过*/
		virtual protected function isCanPassWithPosInt(posInt:Point):Boolean{
			return true;
		}
		
		override protected function onDestroy():void{
			_velocity=null;
			_moveDirV=null;
			_nextCell=null;
			_curCellPos=null;
			_cellCenterPos=null;
			_cellCenterPosInt=null;
			super.onDestroy();
		}
		
	};

}