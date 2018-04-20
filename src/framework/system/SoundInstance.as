package framework.system{
	import flash.media.Sound;
	import flash.media.SoundTransform;
	import flash.media.SoundChannel;
	import flash.events.Event;
	import flash.utils.Dictionary;
	import framework.game.Game;
	import framework.objs.GameObject;

	public class SoundInstance extends GameObject{
		private var _loops:int;
		private var _allowMultiple:Boolean;
		private var _sound:Sound;
		private var _mute:Boolean;
		private var _volume:Number;
		private var _isPlaying:Boolean;
		private var _pausePos:Number;
		
		private var _sc:SoundChannel;
		private var _oldSc:Vector.<SoundChannel>;
		private var _st:SoundTransform;
		private var _completeCallbackDict:Dictionary;
		
		public function SoundInstance(){
			super();
		}
		public static function create(sound:Sound):SoundInstance{
			var game:Game=Game.getInstance();
			var info:*={};
			info.sound=sound;
			return game.createGameObj(new SoundInstance(),info) as SoundInstance;
		}
		override protected function init(info:* = null):void{
			super.init(info);
			_sound=info.sound;
			_st=new SoundTransform();
			_oldSc=new Vector.<SoundChannel>();
			_completeCallbackDict=new Dictionary();
		}
		/**播放*/
		public function play(startTime:Number=0,volume:Number=1,allowMultiple:Boolean=false,loops:int=1,onSoundCompleteCallback:Function=null,onSoundCompleteParams:Array=null):SoundInstance{
			_allowMultiple=allowMultiple;
			_loops=loops;
			_pausePos=0;
			_st.volume=volume;
			if(allowMultiple){
				if(_sc)_oldSc.push(_sc);
			}else{
				if(_sc)stopChannel(_sc,true);
			}
			_sc=sound.play(startTime,_loops,_st);
			if (_sc){
				_completeCallbackDict[_sc]={func:onSoundCompleteCallback,params:onSoundCompleteParams};
				_sc.addEventListener(Event.SOUND_COMPLETE,onSoundComplete);
				_isPlaying=true;
			}
			return this;
		}
		/**暂停*/
		public function pause():SoundInstance{
			if (_sc)return this;
			_isPlaying=false;
			_pausePos=_sc.position;
			stopChannel(_sc);
			return this;
		}
		/**
		 * 恢复暂停的声音
		 * @param	forceStart：表示如果没有执行暂停的时候这个声音是否重新开始播放
		 */
		public function resume(forceStart:Boolean=false):SoundInstance {
			var isPaused:Boolean=_sc &&_sound&&_pausePos>0;
			if (isPaused||forceStart)play(_pausePos,_volume, _allowMultiple,_loops);
			return this;
		}
		/**
		 * 停止当前声音实例
		 * @param onlyCurPlaying 为true时将只停止当前的，为false时也停止旧的声音控制器列表
		 */
		public function stop(onlyCurPlaying:Boolean=false):SoundInstance{
			_pausePos=0;
			stopChannel(_sc,true);
			_sc=null;
			if(!onlyCurPlaying)stopOldChannels();
			_isPlaying = false;
			return this;
		}
		private function onSoundComplete(e:Event):void{
			var channel:SoundChannel=SoundChannel(e.target);
			channel.removeEventListener(Event.SOUND_COMPLETE, onSoundComplete);
			
			var cb:Function=_completeCallbackDict[channel].func;
			var params:Array=_completeCallbackDict[channel].params;
			if(cb!=null){
				cb.apply(null,params);
				delete _completeCallbackDict[channel];
			}
			_isPlaying = false;
		}
		private function stopChannel(channel:SoundChannel,isRemove:Boolean=false):void{
			if (channel==null) return;
			channel.removeEventListener(Event.SOUND_COMPLETE, onSoundComplete);
			channel.stop();
			delete _completeCallbackDict[channel];
			if (isRemove){
				var id:int=_oldSc.indexOf(channel);
				if(id>-1)_oldSc.splice(id,1);
			}
		}
		private function stopOldChannels():void{
			if (_oldSc.length==0) return;
			var i:int=_oldSc.length;
			while(--i>=0)stopChannel(_oldSc[i],true);
			_oldSc.splice(0,_oldSc.length);
		}
		private function updateOldChannels():void{
			if (_sc==null)return; 
			var i:int=_oldSc.length;
			while(--i>=0)_oldSc[i].soundTransform=_sc.soundTransform;
		}
		public function set mute(value:Boolean):void{
			_mute=value;
			if (_sc){
				_sc.soundTransform=mute ? new SoundTransform(0) : _st;
				updateOldChannels();
			}
		}
		override protected function onDestroy():void{
			for(var k:* in _completeCallbackDict) delete _completeCallbackDict[k];
			_sound=null;
			_st=null;
			_oldSc=null;
			_completeCallbackDict=null;
			super.onDestroy();
		}
		public function get mute():Boolean{return _mute;}
		public function get volume():Number{return _st.volume;}
		public function get sound():Sound{return _sound;}
		public function get allowMultiple():Boolean{return _allowMultiple;}
		public function get isPlaying():Boolean{return _isPlaying;}
		public function get loops():int{ return _loops; }
	};
}