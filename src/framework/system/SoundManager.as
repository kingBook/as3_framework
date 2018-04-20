package framework.system{
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.system.ApplicationDomain;
	import framework.game.Game;
	import framework.events.FrameworkEvent;
	import flash.events.EventDispatcher;
	import framework.objs.GameObject;

	public class SoundManager extends GameObject{
		private var _instances:Object;
		private var _soundList:*;
		private var _mute:Boolean;//静止所有声音
		private var _muteOnce:Boolean;//只静止不循环播放的声音
		private var _muteLoop:Boolean;//静止循环次数>2的声音
		private var _muteEvent:FrameworkEvent;
		private var _muteOnceEvent:FrameworkEvent;
		private var _muteLoopEvent:FrameworkEvent;
		public function SoundManager(){
			super();
		}
		public static function create():SoundManager{
			var game:Game=Game.getInstance();
			return game.createGameObj(new SoundManager()) as SoundManager;
		}
		override protected function init(info:* = null):void{
			super.init(info);
			_soundList={};
			_instances={};
		}
		/**一次性播放*/
		public function play(name:String,volume:Number=1,startTime:Number=0,allowMultiple:Boolean=false,onSoundComplete:Function=null,onSoundCompleteParams:Array=null):SoundInstance{
			var si:SoundInstance=getSoundInstance(name);
			if(si){
				si.play(startTime,volume,allowMultiple,1,onSoundComplete,onSoundCompleteParams);
				si.mute=(_mute||_muteOnce);
			}
			return si;
		}
		/**一次性连续播放多个*/
		public function playSounds(names:Vector.<String>,volume:Number=1,startTimes:Vector.<Number>=null,allowMultiple:Boolean=false):void{
			if(!names||names.length==0)return;
			if(!allowMultiple){
				for(var i:int=0;i<names.length;i++) stop(names[i]);
			}
			var startTime:Number=startTimes?startTimes[0]:0;
			var playFunc:Function=names.length>1?this.play:null;
			var params:Array=getNextPlayParams(names,0,volume,startTimes,allowMultiple);
			play(names[0],volume,startTime,allowMultiple,playFunc,params);
		}
		private function getNextPlayParams(names:Vector.<String>,id:int,volume:Number,startTimes:Vector.<Number>,allowMultiple:Boolean):Array{
			var maxID:int=names.length-1;
			if(id>=maxID)return null;
			id++;
			var startTime:Number=startTimes?startTimes[id]:0;
			var playFunc:Function=id>=maxID?null:play;
			var params:Array=getNextPlayParams(names,id,volume,startTimes,allowMultiple);
			return [names[id],volume,startTime,allowMultiple,playFunc,params];
		}
		/**不允许重复且循环的播放一个声音*/
		public function playLoop(name:String,volume:Number=1,startTime:Number=0):SoundInstance{
			var si:SoundInstance=getSoundInstance(name);
			if(si&&!si.isPlaying){
				si.play(startTime,volume,false,int.MAX_VALUE);
				si.mute=(_mute||_muteLoop);
			}
			return si;
		}
		/**停止一个声音*/
		public function stop(name:String,onlyCurPlaying:Boolean=false):SoundInstance{
			var si:SoundInstance=getSoundInstance(name);
			if(si){
				si.stop(onlyCurPlaying);
			}
			return si;
		}
		/**停止所有声音*/
		public function stopAll():void{
			for each(var si:SoundInstance in _instances){
				si.stop(true);
			}
		}
		/**暂停一个声音*/
		public function pause(name:String):SoundInstance{
			var si:SoundInstance=getSoundInstance(name);
			if(si){
				si.pause();
			}
			return si;
		}
		/**暂停所有声音*/
		public function pauseAll():void{
			var si:SoundInstance;
			for(var name:String in _instances){
				si=_instances[name] as SoundInstance;
				si.pause();
			}
		}
		/**恢复播放一个暂停的声音*/
		public function resume(name:String):SoundInstance{
			var si:SoundInstance=getSoundInstance(name);
			if(si){
				si.resume();
			}
			return si;
		}
		/**恢复播放所有暂停的声音*/
		public function resumeAll():void{
			var si:SoundInstance;
			for(var name:String in _instances){
				si=_instances[name] as SoundInstance;
				si.resume();
			}
		}
		public function addSoundInstance(name:String,sound:Sound):SoundInstance{
			if(_instances[name]){
				trace("警告：已经存在声音实例"+name+",此次添加失败");
				return null;
			}
			var si:SoundInstance=SoundInstance.create(sound);
			GameObject.dontDestroyOnDestroyAll(si);
			_instances[name]=si;
			return si;
		}
		public function getSoundInstance(name:String):SoundInstance{
			if(!name){
				trace("警告：无法返回空字符串的声音SoundManager::getSoundInstance(name:String)");
				return null;
			}
			var si:SoundInstance=_instances[name];
			if(si==null){
				var sound:Sound;
				var domain:ApplicationDomain=ApplicationDomain.currentDomain;
				if(domain.hasDefinition(name))sound=new (domain.getDefinition(name)) as Sound;
				if(sound){ 
					si=addSoundInstance(name,sound);
				}else{
					if(_soundList)sound=_soundList[name] as Sound;
					if(sound==null)trace("警告：找不到声音:"+name+" !");
				}
			}
			return si;
		}
		public function set mute(value:Boolean):void{
			setMute(value);
		}
		private function setMute(value:Boolean,isToMuteOnce:Boolean=true,isToMuteLoop:Boolean=true,isDoMuteHandler:Boolean=true):void{
			if(_mute==value)return;
			_mute=value;
			if(isDoMuteHandler)muteHandler();
			//
			if(isToMuteOnce)setMuteOnce(_mute);
			if(isToMuteLoop)setMuteLoop(_mute);
		}
		private function muteHandler():void{
			var si:SoundInstance;
			for(var name:String in _instances){
				si=_instances[name] as SoundInstance;
				si.mute=_mute;
			}
			_muteEvent||=new FrameworkEvent(FrameworkEvent.MUTE,{});
			_muteEvent.info.mute=_mute;
			dispatchEvent(_muteEvent);
		}
		public function set muteOnce(value:Boolean):void{
			setMuteOnce(value);
		}
		private function setMuteOnce(value:Boolean):void{
			if(_muteOnce==value)return;
			_muteOnce=value;
			if(_muteOnce){
				if(_muteLoop){
					setMute(true,false,false,false);
					muteOnceHandler();
				}else{
					muteOnceHandler();
				}
			}else{
				setMute(false,false,false,false);
				muteOnceHandler();
			}
			
		}
		private function muteOnceHandler():void{
			var si:SoundInstance;
			for(var name:String in _instances){
				si=_instances[name] as SoundInstance;
				if(si.loops==1){
					si.mute=_muteOnce;
				}
			}
			_muteOnceEvent||=new FrameworkEvent(FrameworkEvent.MUTE_ONCE,{});
			_muteOnceEvent.info.mute=_muteOnce;
			dispatchEvent(_muteOnceEvent);
		}
		public function set muteLoop(value:Boolean):void{
			setMuteLoop(value);
		}
		private function setMuteLoop(value:Boolean):void{
			if(_muteLoop==value)return;
			_muteLoop=value;
			if(_muteLoop){
				if(_muteOnce){
					setMute(true,false,false,false);
					muteLoopHandler();
				}else{
					muteLoopHandler();
				}
			}else{
				setMute(false,false,false,false);
				muteLoopHandler();
			}
		}
		private function muteLoopHandler():void{
			var si:SoundInstance;
			for(var name:String in _instances){
				si=_instances[name] as SoundInstance;
				if(si.loops!=1){
					si.mute=_muteLoop;
				}
			}
			_muteLoopEvent||=new FrameworkEvent(FrameworkEvent.MUTE_LOOP,{});
			_muteLoopEvent.info.mute=_muteLoop;
			dispatchEvent(_muteLoopEvent);
		}
		override protected function onDestroy():void{
			if(_instances) stopAll();
			for each(var si:SoundInstance in _instances)GameObject.destroy(si);
			_instances=null;
			_soundList=null;
			_muteEvent=null;
			super.onDestroy();
		}
		
		public function get mute():Boolean    { return _mute;     }
		public function get muteOnce():Boolean{ return _muteOnce; }
		public function get muteLoop():Boolean{ return _muteLoop; }
		
	};

}