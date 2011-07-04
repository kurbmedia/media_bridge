package com.kurbmedia.media.players{
	
	import flash.display.Sprite;
	import flash.events.*;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	import flash.media.Video;
	import flash.media.SoundTransform;
	
	import com.kurbmedia.media.players.MediaPlayer;
	import com.kurbmedia.media.MediaEvent;

	public class VideoPlayer extends MediaPlayer implements MediaInterface{
		
		public var player;
		
		private var bytes_loaded;
		private var total_bytes;
		private var empty_buffer;		
		private var connection;
		private var stream;
		private var audio;
		private var stream_client;
		private var playback_started:Boolean = false;
		private var play_when_loaded:Boolean = true;
		
		public function VideoPlayer(params:Object){
			super(params);
			is_video = true;			
			timer.addEventListener("timer", update_status);
			player = new Video();			
			connection = new NetConnection();
			connection.addEventListener(NetStatusEvent.NET_STATUS, handle_net_status);
			connection.addEventListener(SecurityErrorEvent.SECURITY_ERROR, handle_error_status);	
			is_connected = false;				
		}
		
		private function connect_to_stream(){
			
			stream = new NetStream(connection);
			audio  = new SoundTransform(_volume);
			stream.soundTransform = audio;
			
			stream.addEventListener(NetStatusEvent.NET_STATUS, handle_net_status);
			stream.addEventListener(AsyncErrorEvent.ASYNC_ERROR, handle_async_error);

			stream_client = new Object();
			stream_client.onMetaData = metadata_loaded;
			stream.client = stream_client;

			player.attachNetStream(stream);
			addChild(player);
			stream.play(_src, 0, 0);
			
			trace('init video');
			
			if( play_when_loaded ){				
				playback_started = true;
				_paused = false;				
			}else{
				stream.pause();
				_paused = true;
				dispatchEvent(new MediaEvent(MediaEvent.PAUSE));
			}
			
			is_connected = true;
		}
		
		public function setCurrentTime(arg:Number):void{
			stream.seek(arg);
			_currentTime = arg;
		}
		
		public function setMuted(arg:Boolean):void{
			if( audio ){
				if( arg ) setVolume(0);
				else setVolume(_volume);
			}
		}
		
		public function setPaused(arg:Boolean):void{
			if( arg ) stream.pause();
			else stream.play();
			_paused = arg;
		}
		
		public function play():void{
			if( playback_started && _paused ){
				stream.resume();
				_paused = false;
				_played = true;
			}else{				
				play_when_loaded;
				//if( is_connected === false ) this.load();
				this.load();
			}
		}
		
		public function pause():void{
			stream.pause();
			_paused = true;
		}

		public function setSrc(arg:String):void{
			if (is_connected && stream) stream.pause();
			_src = arg;
 			is_connected     = false;
			playback_started = false;
			this.load();
		}
		
		public function stop():void{
			stream.pause();
			_paused = true;
		}
		
		public function setVolume(arg:Number):void{
			if( audio){
				audio.volume = arg;
				stream.soundTransform = audio;
			}
			_volume = arg;
		}
		
		public function load():void{
			if ( is_connected && stream ) {
				stream.pause();
				stream.close();
				connection.close();
			}
			
			is_connected = false;
			connection.connect(null);
			dispatchEvent(new MediaEvent(MediaEvent.LOADSTART));
		}		
		
		private function update_status(event:*){
			bytes_loaded = stream.bytesLoaded;
 			total_bytes  = stream.bytesTotal;
			_currentTime = (stream == null) ? 0 : stream.time;
			if( !_paused ) dispatchEvent( new MediaEvent(MediaEvent.TIMEUPDATE ));
			if (bytes_loaded < total_bytes) dispatchEvent(new MediaEvent(MediaEvent.PROGRESS));
		}
		
		///////////////////////////////////////////////////
		// Handle errors
		///////////////////////////////////////////////////
		
		private function handle_net_status(event:*){
			trace(event.info.code);
			switch (event.info.code) {
				case "NetStream.Buffer.Empty":
					empty_buffer = true;
					_ended ? dispatchEvent(new MediaEvent(MediaEvent.ENDED)) : null;
				break;
				case "NetStream.Buffer.Full":
					bytes_loaded = stream.bytesLoaded;
					total_bytes  = stream.bytesTotal;
					empty_buffer = false;
					dispatchEvent(new MediaEvent(MediaEvent.PROGRESS));
				break;
				case "NetConnection.Connect.Success":
					trace('connecting to stream');
					this.connect_to_stream();
				break;
				case "NetStream.Play.StreamNotFound":
				break;
				case "NetStream.Play.Start":
					_paused = false;
					dispatchEvent(new MediaEvent(MediaEvent.LOADEDDATA));
					dispatchEvent(new MediaEvent(MediaEvent.CANPLAY));
					dispatchEvent(new MediaEvent(MediaEvent.PLAY));
					dispatchEvent(new MediaEvent(MediaEvent.PLAYING));
					timer.start();
				break;
				case "NetStream.Pause.Notify":
					_paused = true;
				break;
				case "NetStream.Play.Stop":
					_ended  = true;
					_paused = false;
					timer.stop();
					empty_buffer ? dispatchEvent(new MediaEvent(MediaEvent.ENDED)) : null;
				break;
				case "NetStream.Seek.Notify":
					_seeking = true;
					dispatchEvent(new MediaEvent(MediaEvent.SEEKED))
				break;			
			}
		}
		
		private function handle_error_status(event:*){
			trace("NetStream Error: " + event);
		}
		
		private function handle_async_error(event:*){
			trace("AsyncError: " + event);
		}
		
	}

}