package com.kurbmedia.media.players{
	
	import flash.display.Sprite;
	import flash.events.*;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	import flash.media.Video;
	import flash.media.SoundTransform;
	
	import com.kurbmedia.media.players.MediaPlayer;
	import com.kurbmedia.media.MediaEvent;

	public class YouTubePlayer extends MediaPlayer implements MediaInterface{
		
		private var bytes_loaded;
		private var total_bytes;
		private var empty_buffer;
		private var player;
		private var connection;
		private var stream;
		private var audio;
		private var stream_client;
		
		public function YouTubePlayer(params:Object){
			super(params);
			is_video = true;
			connection = new NetConnection();
			connection.addEventListener(NetStatusEvent.NET_STATUS, handle_net_status);
			connection.addEventListener(SecurityErrorEvent.SECURITY_ERROR, handle_error_status);			
			is_connected = false;
			player = new Video();	
		}
		
		private function connect_to_stream(){
			stream = new NetStream(connection);
			audio  = new SoundTransform(0);
			stream.soundTransform = audio;
			
			stream.addEventListener(NetStatusEvent.NET_STATUS, handle_net_status);
			stream.addEventListener(AsyncErrorEvent.ASYNC_ERROR, handle_async_error);

			stream_client = new Object();
			stream_client.onMetaData = metadata_loaded;
			stream.client = stream_client;

			player.attachNetStream(stream);
			
			stream.play(_src, 0, 0);				
			stream.pause();
 			_paused = true;
			dispatchEvent(new MediaEvent(MediaEvent.PAUSE));
			is_connected = true;
		}
		
		public function setCurrentTime(arg:Number):void{
			
		}
		
		public function setMuted(arg:Boolean):void{
			if( arg ) audio.volume = 0;
			else audio.volume = _volume;
		}
		
		public function setPaused(arg:Boolean):void{
			if( arg ) stream.pause();
			else stream.play();
			_paused = true;
		}
		
		public function play():void{
			stream.play();
			_paused = false;
			_played = true;
		}
		
		public function pause():void{
			stream.pause();
			_paused = true;
		}
		
		public function stop():void{
			stream.pause();
			_paused = true;
		}

		public function setSrc(arg:String):void{
			_src = arg;
			this.load();
		}
		
		public function setVolume(arg:Number):void{
			audio.volume = arg;
			_volume = arg;
		}
		
		public function load():void{
			if (is_connected && stream) {
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
			if (bytes_loaded < total_bytes) dispatchEvent(new MediaEvent(MediaEvent.PROGRESS));
		}
		
		///////////////////////////////////////////////////
		// Handle errors
		///////////////////////////////////////////////////
		
		private function handle_net_status(event:*){
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
					dispatchEvent(new MediaEvent(MediaEvent.SEEKED))
				break;
				case "NetStream.Pause.Notify":
					_paused = true;
					dispatchEvent(new MediaEvent(MediaEvent.PAUSE))
				break;
				case "NetStream.Play.Stop":
					_ended = true;
					_paused = false;
					timer.stop();
					empty_buffer ? dispatchEvent(new MediaEvent(MediaEvent.ENDED)) : null;
				break;				
			}
		}
		
		private function handle_error_status(event:*){
			
		}
		
		private function handle_async_error(event:*){}
		
	}

}