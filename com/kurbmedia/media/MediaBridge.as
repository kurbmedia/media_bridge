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
			
/*					if( !params.src ){
							params = {};
							params.debug = true;
							params.src = "http://cdn.hannahkeeley.com/promotions/boot_camp/boot_camp_day2.mp4";
							params.media_type = 'video';
						}
					
					*/
			stage.align     = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			rect.width 		= stage.stageWidth;
			rect.height 	= stage.stageHeight;
			params.width    = rect.width;
			params.height   = rect.height; 
			element 		= params.element;
			
			trace(params.src);
			
			if( !params.debug ){ 
				removeChild(getChildByName('debug_text'));
			}else{
				debug_text.x = stage.stageWidth - debug_text.width;
				debug_text.y = stage.stageHeight - debug_text.height;
			}
			
			if( isNaN(params.update_interval) ) params.update_interval = 250;
			
			player = detect_player();
			addChildAt(player, 0);
			
			if( player.is_video ){
				player.player.width  	    = stage.stageWidth;
				player.player.height		= stage.stageHeight;
				player.player.smoothing 	= true;
			}

			if( ExternalInterface.available ){
				ExternalInterface.marshallExceptions = true;
				ExternalInterface.addCallback("playMedia", player.play);
				ExternalInterface.addCallback("loadMedia", player.load);
				ExternalInterface.addCallback("pauseMedia", player.pause);
				ExternalInterface.addCallback("stopMedia", player.stop);
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
				ExternalInterface.addCallback('callSetter', call_setter);
				ExternalInterface.addCallback('callGetter', call_getter);
			}
			
			
			stage.addEventListener(MouseEvent.CLICK, function(){ player.play(); });
			stage.addEventListener(MouseEvent.ROLL_OVER, dispatch);
			stage.addEventListener(MouseEvent.ROLL_OUT, dispatch);
			player.addEventListener(MediaEvent.LOADEDDATA, dispatch);
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
		
		public function call_setter( name, value ){
			player['set' + name].apply(player, value);
			return value;
		}
		
		public function call_getter( name ){
			return player['get' + name].apply(player);
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
			
			if(params.debug){
				debug_text.text = to_send;
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