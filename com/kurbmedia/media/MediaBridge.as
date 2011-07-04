package com.kurbmedia.media{
	
	import flash.display.*;
	import flash.events.*;
	import flash.media.*;
	import flash.net.*;
	import flash.system.*;
	
	import flash.utils.Timer;
	import flash.geom.Rectangle;
	
	import flash.external.ExternalInterface;
	import com.kurbmedia.media.MediaEvent;
	import com.kurbmedia.media.players.*;
	
	public class MediaBridge extends MovieClip{
		
		public var media_type;		
		public var element;
		public var rect:Object = {};
		public var player;
		public var params;
		
		public function MediaBridge(){
			
			Security.allowDomain("*");
			params = root.loaderInfo.parameters;
			
			/*if( !params.src ){
				params = {};
				params.src = "http://cdn.hannahkeeley.com/promotions/boot_camp/boot_camp_day2.mp4";
				params.media_type = 'video';
			}*/
			
			
			stage.align     = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			rect.width 		= stage.stageWidth;
			rect.height 	= stage.stageHeight;
			params.width    = rect.width;
			params.height   = rect.height; 
			element 		= params.element;
			
			trace(params.src);
			
			if( isNaN(params.update_interval) ) params.update_interval = 250;
			
			player = detect_player();
			addChild(player);
			
			if( player.is_video ){
				player.player.width  	    = stage.stageWidth;
				player.player.height		= stage.stageHeight;
				player.player.smoothing 	= true;
			}

			ExternalInterface.marshallExceptions = true;
			ExternalInterface.addCallback("play", player.play);
			ExternalInterface.addCallback("load", player.load);
			ExternalInterface.addCallback("pause", player.pause);
			ExternalInterface.addCallback("stop", player.stop);
			ExternalInterface.addCallback("setMuted", player.setMuted);			
			ExternalInterface.addCallback('setCurrentTime', player.setCurrentTime);
			ExternalInterface.addCallback('getCurrentTime', player.getCurrentTime);
			ExternalInterface.addCallback('getDuration', player.getDuration);
			ExternalInterface.addCallback('getEnded', player.getEnded);
			ExternalInterface.addCallback('getPaused', player.getPaused);
			ExternalInterface.addCallback('setPaused', player.setPaused);
			ExternalInterface.addCallback('getPlayed', player.getPlayed);
			ExternalInterface.addCallback('getSeeking', player.getSeeking);
			ExternalInterface.addCallback('setSrc', player.setSrc);
			ExternalInterface.addCallback('getSrc', player.getSrc);
			ExternalInterface.addCallback('getVolume', player.getVolume);
			ExternalInterface.addCallback('setVolume', player.setVolume);
			
			stage.addEventListener(MouseEvent.CLICK, function(){ player.play(); });
			stage.addEventListener(MouseEvent.ROLL_OVER, dispatch);
			stage.addEventListener(MouseEvent.ROLL_OUT, dispatch);
			player.addEventListener(MediaEvent.LOADED_DATA, dispatch);
			player.addEventListener(MediaEvent.PROGRESS, dispatch);
			player.addEventListener(MediaEvent.TIMEUPDATE, dispatch);
			player.addEventListener(MediaEvent.SEEKED, dispatch);
			player.addEventListener(MediaEvent.PLAY, dispatch);
			player.addEventListener(MediaEvent.PLAYING, dispatch);
			player.addEventListener(MediaEvent.PAUSE, dispatch);
			player.addEventListener(MediaEvent.LOADEDMETADATA, dispatch);
			player.addEventListener(MediaEvent.ENDED, dispatch);
			player.addEventListener(MediaEvent.VOLUMECHANGE, dispatch);
			player.addEventListener(MediaEvent.STOP, dispatch);
			player.addEventListener(MediaEvent.LOADSTART, dispatch);
			player.addEventListener(MediaEvent.CANPLAY, dispatch);
			player.addEventListener(MediaEvent.LOADEDDATA, dispatch);
			player.addEventListener(MediaEvent.SEEKING, dispatch);

		}
		
		private function dispatch(event:*){			
			var to_send = false;
			switch( event.type ){
				case "MouseEvent.ROLL_OVER": 
				to_send = 'mouseover'; 
				case "MouseEvent.ROLL_OUT": 
				to_send = 'mouseout';
				break;
				default: to_send = event.type;
			}		

			if( ExternalInterface.available ){
				ExternalInterface.call("setTimeout", "jQuery('#"+ element +"').trigger('"+ to_send +"', ['"+ element +"'])", 0);
			}
		}
		
		private function detect_player():*{
			return new VideoPlayer(params);
			if( params.media_type == 'video' || (/(mp4|flv|m4v|f4v|webm)$/i).test(params.src) ) return new VideoPlayer(params);
			if( (/youtube\.com/i).test(params.src) ) return new YouTubePlayer(params);
			return new AudioPlayer(params);
		}
		
	}
	
	
}