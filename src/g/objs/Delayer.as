package g.objs{
	import framework.game.Game;
	import framework.objs.GameObject;
	import g.events.MyEvent;
	import g.objs.MyObj;
	import g.objs.Delayer;
	public class Delayer extends MyObj{
		public static const EXECUTE:String = "delayerExecute";
		/**
		 * 创建延时器
		 * @param isAuto true/自动开始延时,false必须手动调用startDelayer()开始延时
		 * linkGameObject是否派发EXECUTE事件,由odd和even决定
		 * odd==true, even==true 延时完成都派发EXECUTE事件
		 * odd==true, even==false 奇数次派发EXECUTE事件
		 * odd==false,even==true 偶数次派发EXECUTE事件
		 * 
		 * 监听EXECUTE事件使用linkGameObject.addEventListener(Delayer.EXECUTE,executeHandler);
		 * function executeHandler(e:MyEvent):void;
		 */
		public static function create(linkGameObject:GameObject,delay:Number=1,isAuto:Boolean=true,odd:Boolean=true,even:Boolean=true):Delayer{
			var game:Game=Game.getInstance();
			var info:*={};
			info.isAuto=isAuto;
			info.delay=delay;
			info.odd=odd;
			info.even=even;
			var delayer:Delayer=game.createGameObj(new Delayer(),info) as Delayer;
			if(odd&&even){
				delayer.addGameObject(linkGameObject);
			}else{
				if(odd)delayer.addOddGameObject(linkGameObject);
				else if(even)delayer.addEvenGameObject(linkGameObject);
			}
			return delayer;
		}
		
		
		//{ 1:delayer1, 1.5:delayer2, ... }
		private static var gList:*={};//存储不同时间间隔的Auto Delayer在onDestroyAll时清空
		/**
		 * 返回一个同步执行的延时器
		 * @param isAuto true/自动开始延时,false必须手动调用startDelayer()开始延时
		 * 
		 * 如果gList列表中存在相同的时间间隔的延时器，则直接取出
		 * 否则新建一个延时器，以时间间隔作为key存储到gList里面
		 * (如果希望一直存在列表中，请不要销毁实例GameObject.destroy(delayer))
		 * 
		 * linkGameObject是否派发EXECUTE事件,由odd和even决定
		 * odd==true, even==true 延时完成都派发EXECUTE事件
		 * odd==true, even==false 奇数次派发EXECUTE事件
		 * odd==false,even==true 偶数次派发EXECUTE事件
		 * 
		 * 监听EXECUTE事件使用linkGameObject.addEventListener(Delayer.EXECUTE,executeHandler);
		 * function executeHandler(e:MyEvent):void;
		 */
		public static function createWithList(linkGameObject:GameObject,delay:Number=1,isAuto:Boolean=true,odd:Boolean=true,even:Boolean=true):Delayer{
			var delayer:Delayer=gList[delay];
			if(delayer){
				if(odd&&even){
					delayer.addGameObject(linkGameObject);
				}else{
					if(odd)delayer.addOddGameObject(linkGameObject);
					else if(even)delayer.addEvenGameObject(linkGameObject);
				}
			}else{
				delayer=create(linkGameObject,delay,isAuto,odd,even);
				gList[delay]=delayer;
			}
			return delayer;
		}
		
		public function Delayer() {
			super();
		}
		
		private var _oddLinkGameObjects:Array=[];//奇数次运行列表
		private var _evenLinkGameObjects:Array=[];//偶数次运行列表
		private var _linkGameObjects:Array=[];
		private var _delay:Number;
		private var _isAuto:Boolean;
		private var _isDelaying:Boolean;
		private var _isEvenDelayed:Boolean;//奇偶数次延时结束
		private var _odd:Boolean;
		private var _even:Boolean;
		private var _executeEvent:MyEvent=new MyEvent(EXECUTE);
		
		override protected function init(info:*=null):void{
			_isAuto=info.isAuto;
			_delay=info.delay;
			_odd=info.odd;
			_even=info.even;
			if(_isAuto){
				addDelay();
			}
		}
		
		private function addDelay():void {
			scheduleOnce(delayed,_delay);
		}
		
		private function delayed():void {
			_isDelaying=false;
			var isEvenDestroy:Boolean,isOddDestroy:Boolean,isDoDestroy:Boolean;
			
			if(_isEvenDelayed){//偶数次派发EXECUTE事件
				isEvenDestroy=dispatchGameObjs(_evenLinkGameObjects);
			}else{//奇数次派发EXECUTE事件
				isOddDestroy=dispatchGameObjs(_oddLinkGameObjects);
			}

			//非自动时，奇次完成时却标记奇次不运行则重新开始计时，偶次完成时却标记偶次不运行则重新开始计时。
			if(!_isAuto){
				if(_isEvenDelayed){
					if(!_even)startDelayer();
				}else{
					if(!_odd)startDelayer();
				}
			}

			_isEvenDelayed=!_isEvenDelayed;
			
			isDoDestroy=dispatchGameObjs(_linkGameObjects);//派发EXECUTE事件
			
			if(isEvenDestroy&&isOddDestroy&&isDoDestroy){//当各列表中的对象都销毁了，或没有游戏对象时，则销毁延时器
				destroy(this);
			}else{
				if(_isAuto)addDelay();
			}
		}
		
		/**
		 * 向一个列表的所有游戏对象派发EXECUTE事件
		 * 列表中的所有对象被销毁，则返回true
		 */
		private function dispatchGameObjs(gameObjs:Array):Boolean{
			var isDoDestroy:Boolean=true;
			var i:int=gameObjs.length, go:GameObject;
			while(--i>=0){
				go=gameObjs[i];
				if(go.isDestroyed){//移除已销毁的游戏对象
					gameObjs.splice(i,1);
				}else{
					isDoDestroy=false;
					go.dispatchEvent(_executeEvent);
				}
			}
			return isDoDestroy;
		}
		
		/**手动延时 delayTime<秒>*/
		public function startDelayer():void{
			if(_isDelaying)return;
			scheduleOnce(delayed,_delay);
			_isDelaying=true;
		}
		
		override protected function onDestroyAll():void{
			gList={};
			super.onDestroyAll();
		}
		
		override protected function onDestroy():void {
			for(var key:* in gList){
				if(gList[key]==this) delete gList[key];
			}
			unschedule(delayed);
			_executeEvent=null;
			_oddLinkGameObjects=null;
			_evenLinkGameObjects=null;
			_linkGameObjects=null;
			super.onDestroy();
		}
		/**添加奇数次派发EXECUTE事件的游戏对象 */
		public function addOddGameObject(gameObject:GameObject):void{
			if(_oddLinkGameObjects.indexOf(gameObject)<0)
				_oddLinkGameObjects.push(gameObject);
		}
		/**添加偶数次派发EXECUTE事件的游戏对象 */
		public function addEvenGameObject(gameObject:GameObject):void{
			if(_evenLinkGameObjects.indexOf(gameObject)<0)
				_evenLinkGameObjects.push(gameObject);
		}
		/**添加无论奇/偶次数都派发EXECUTE事件的游戏对象到列表 */
		public function addGameObject(gameObject:GameObject):void{
			if(_linkGameObjects.indexOf(gameObject)<0)
				_linkGameObjects.push(gameObject);
		}
		public function get isDelaying():Boolean{return _isDelaying;}
	};

}