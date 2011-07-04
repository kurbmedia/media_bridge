package com.kurbmedia.media.players{
	
	import flash.display.Sprite;
	import flash.utils.Timer;
	
	import com.kurbmedia.media.MediaEvent;
	import com.kurbmedia.media.players.*;
	
	public class MediaPlayer extends Sprite{		
		
		public var _muted:Boolean = false;
		public var _currentTime:Number = 0;
		public var _duration:Number = 0;
		public var _ended:Boolean = false;
		public var _paused:Boolean = true;
		public var _played:Boolean = false;
		public var playbackRate:*;
		public var _seeking:Boolean = true;
		public var readyState:Boolean = true;
		public var _src:String;
		public var _volume:Number = 1;
		public var videoWidth;
		public var videoHeight;
		public var is_video:Boolean = false;

		protected var timer;
		protected var params;
		protected var poster;
		protected var is_connected:Boolean;
		
		public function MediaPlayer( params ){
			timer = new Timer(params.update_interval);		
			_src   = params.src;
			poster = params.poster || null;
			this.graphics.beginFill(0x000000);
			this.graphics.drawRect(0, 0, params.width, params.height);
			this.graphics.endFill();
		}
		
		public function getCurrentTime():Number{
			return _currentTime;
		}
		public function getDuration():Number{
			return _duration;
		}
		public function getEnded():Boolean{
			return _ended;
		}
		public function getMuted():Boolean{
			return _muted;
		}
		public function getPaused():Boolean{
			return _paused;
		}
		
		public function getPlayed():Boolean{
			return _played;
		}
				
		public function getSeeking():Boolean{
			return _seeking;
		}
		
		public function getSrc():String{
			return _src;
		}
		public function getVolume():Number{
			return _volume;
		}
		
		protected function metadata_loaded(info:Object){
			_duration    = info.duration;
			videoWidth  = info.width;
			videoHeight = info.height;
			dispatchEvent(new MediaEvent(MediaEvent.LOADEDMETADATA));
		}
		
	}
	
}