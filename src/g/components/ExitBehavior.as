package g.components{
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.Contacts.b2ContactEdge;
	import Box2D.Dynamics.b2Body;
	import framework.objs.Component;
	import g.MyData;
	
	/*使用方法Exit类:
		private var _exitBehavior:ExitBehavior;
		override protected function init(info:* = null):void{
			super.init(info);
			_game.addEventListener(MyEvent.CREATE_MAP_COMPLETE,createMapComplete);
			
		}
		
		private function createMapComplete(e:MyEvent):void{
			_exitBehavior=addComponent(ExitBehavior) as ExitBehavior;
			
			var playerBehaviors:Vector.<PlayerBehavior>=new Vector.<PlayerBehavior>();
			var players:Vector.<GameObject>=_game.getGameObjList(Player);
			for(var i:int=0;i<players.length;i++){
				playerBehaviors.push(Player(players[i]).playerBehavior);
			}
			_exitBehavior.initialize(_body,playerBehaviors);
		}
		
		override protected function onDestroy():void{
			_game.removeEventListener(MyEvent.CREATE_MAP_COMPLETE,createMapComplete);
			super.onDestroy();
		}
		
		public function get isAllPlayerInfo():Boolean{return _exitBehavior.isAllPlayerInto;}
	*/
	
	/**出口行为组件*/
	public class ExitBehavior extends Component{
		
		public function ExitBehavior(){
			super();
		}
		
		private const e_isAllPlayerInto:uint=0x0001;
		private var _flags:uint;
		private var _body:b2Body;
		private var _playerBehaviors:Vector.<PlayerBehavior>;
		private var _playerBodies:Vector.<b2Body>;
		
		public function initialize(body:b2Body,playerBehaviors:Vector.<PlayerBehavior>):void{
			_body=body;
			_body.SetType(b2Body.b2_staticBody);
			_body.SetSensor(true);
			_playerBehaviors=playerBehaviors;
			
			_playerBodies=new Vector.<b2Body>();
			for(var i:int=0;i<_playerBehaviors.length;i++){
				_playerBodies.push(_playerBehaviors[i].body);
			}
		}
		
		override protected function update():void{
			var touchCount:int=0;
			for(var ce:b2ContactEdge=_body.GetContactList();ce;ce=ce.next){
				if(!ce.contact.IsTouching())continue;
				if(_playerBodies.indexOf(ce.other)>-1){
					touchCount++;
				}
			}
			
			if(touchCount==_playerBehaviors.length){//所有都接触
				var isAllOnGround:Boolean=true;//所有都站在地面上
				for(var i:int=0;i<_playerBehaviors.length;i++){
					if(_playerBehaviors[i].isInAir){
						isAllOnGround=false;
						break;
					}
				}
				
				var dy:Number=Math.abs(_playerBodies[0].GetPosition().y-_playerBodies[1].GetPosition().y)*MyData.ptm_ratio;
				var isNoPile:Boolean=dy<10;//玩家没有堆叠
				
				if(isAllOnGround&&isNoPile){
					_flags|=e_isAllPlayerInto;
				}else{
					_flags&=~e_isAllPlayerInto;
				}
			}else{
				_flags&=~e_isAllPlayerInto;
			}
		}
		
		override protected function onDestroy():void{
			_body=null;
			_playerBehaviors=null;
			_playerBodies=null;
			super.onDestroy();
		}
		
		public function get isAllPlayerInto():Boolean{
			return (_flags&e_isAllPlayerInto)>0;
		}
		
	};

}