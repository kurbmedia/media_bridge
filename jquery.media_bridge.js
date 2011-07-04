(function(jQuery, undefined) {
	
	var media_instances = 0;
	
	String.prototype.capitalize = function() {
	    return this.charAt(0).toUpperCase() + this.slice(1);
	};
	
	var MediaPlayer = function( element, options ){
		// Check audio or video
		var self			= this,
			media_type 		= options.type || element[0].tagName.toLowerCase(),
			is_video   		= media_type == 'video',
			is_audio   		= !is_video,
			source     		= options.src || element.attr('src'),
			conf 	   		= {},
			flashvars		= {},
			wrapper 		= jQuery("<div class='media-wrapper'></div>"),
			swf_wrapper 	= jQuery("<div class='media-swf-wrapper'></div>"),
			root_element	= element.get(0),
			embed_html,
			domid,
			events,
			flash_api,
			api = root_element,
			controls = {},
			control_pane,
			native_support;
			
		if( element.attr("id") == "" ){
			domid = media_type + "_player_" + media_instances;
			element.attr("id", domid);

		} else domid = element.attr("id");	
			
		native_support = check_support( media_type, source );			
		media_instances++;
		element.wrap(wrapper);			
			
		if( native_support === false ){
			
			element.before(swf_wrapper);
			element.hide();
			flashvars.element    = domid;
			flashvars.src 	     = source;
			flashvars.media_type = media_type;
			if( is_video ) flashvars.poster = options.poster || element.attr('poster') || false;
			
			
			if( jQuery.browser.msie ){
				embed_html = ''
				+ '<object classid="clsid:D27CDB6E-AE6D-11cf-96B8-444553540000" codebase="http://download.macromedia.com/pub/shockwave/cabs/flash/swflash.cab" '
				+ 'id="' + domid + '_fallback" width="100%" height="100%">'
				+ '<param name="movie" value="' + options.swf + '?x=' + (new Date()) + '" />'
				+ '<param name="flashvars" value="' + object_to_query(flashvars) + '" />'
				+ '<param name="quality" value="high" />'
				+ '<param name="bgcolor" value="#000000" />'
				+ '<param name="wmode" value="transparent" />'
				+ '<param name="allowScriptAccess" value="always" />'
				+ '<param name="allowFullScreen" value="true" />'
				+ '</object>';
				
			}else{
				embed_html = ''
				+ '<embed id="' + domid + '_fallback" name="' + domid + '_fallback" '
				+ 'quality="high" bgcolor="#000000" wmode="transparent" '
				+ 'allowScriptAccess="always" allowFullScreen="true" '
				+ 'type="application/x-shockwave-flash" pluginspage="http://www.macromedia.com/go/getflashplayer" '
				+ 'src="' + options.swf + '?x=' + (new Date().getTime()) + '" '
				+ 'flashvars="' + object_to_query(flashvars) + '" '
				+ 'width="100%" height="100%"></embed>';
			}
			
			
			swf_wrapper.append(jQuery(embed_html));
			flash_api = document.getElementById(domid + "_fallback");
			
			if (Object.prototype.__defineGetter__&&!Object.defineProperty) {
			   Object.defineProperty=function(obj,prop,desc) {
			      if ("get" in desc) obj.__defineGetter__(prop,desc.get);
			      if ("set" in desc) obj.__defineSetter__(prop,desc.set);
			   }
			}
			
			Object.defineProperty(flash_api, 'paused', {
				get: function(){  return flash_api.getPaused(); },
				set: function(value){ flash_api.setPaused(value); }
			});
			
			Object.defineProperty(flash_api, 'muted', {
				get: function(){  return flash_api.getMuted(); },
				set: function(value){ flash_api.setMuted(value); }
			});
			
			Object.defineProperty(flash_api, 'currentTime', {
				get: function(){  return flash_api.getCurrentTime(); },
				set: function(value){ flash_api.setCurrentTime(value); }
			});
			
			Object.defineProperty(flash_api, 'volume', {
				get: function(){  return flash_api.getVolume(); },
				set: function(value){ flash_api.setVolume(value); }
			});
			
			Object.defineProperty(flash_api, 'seeking', {
				get: function(){  return flash_api.getSeeking(); },
			});
			
			Object.defineProperty(flash_api, 'duration', {
				get: function(){  return flash_api.getDuration(); },
			});
			
			Object.defineProperty(flash_api, 'played', {
				get: function(){  return flash_api.getPlayed(); },
			});

			api = flash_api;
		}
		
		control_pane = jQuery('<div class="'+ media_type +'-player-controls"></div>');
		
		if( typeof options.controls == 'undefined' ){			
			element.after(control_pane);
			
			controls.play_button = jQuery("<button>Play</button>")
				.addClass(media_type + "-play-button")
				.addClass('paused')
				.attr("title", 'Play ' + media_type.capitalize())
				.attr("aria-controls", domid);
				
			controls.seek_bar = jQuery('<input type="range" min="0" value="0" step="0.1" />')
				.addClass(media_type + "-seek-bar")				
				.attr("title", "Seek Controls")
				.attr("aria-controls", domid);
				
			controls.buffer_bar = jQuery('<div></div>')
				.addClass(media_type + "-buffer-bar");
				
			controls.time_display = jQuery('<span>00:00</span>')
				.addClass(media_type + "-play-timer");
				
			controls.volume_box = jQuery("<div></div>")
				.addClass(media_type + "-volume-box");
				
			controls.mute_button = jQuery("<button>Mute</button>")
				.addClass(media_type + "-mute-button")
				.attr("title", 'Mute volume')
				.attr("aria-controls", domid);
				
			controls.volume_bar = jQuery('<input type="range" value="0" min="0" max="1" step="0.1" />')
				.addClass(media_type + "-volume-bar")				
				.attr("title", "Adjust volume")
				.attr("aria-controls", domid);
								
			controls.play_button.bind('click.media', function(event){
					if( api.paused ) api.play();
					else api.pause();
					control_pane.trigger('playing.media', [domid]);
					return true;
				});

			controls.seek_bar.bind('change.media', function(event){
				api.currentTime = jQuery(this).val();
				return true;
			});
			
			controls.mute_button.bind('click.media', function(event){
				api.muted = !api.muted;
				if( api.muted === true ) jQuery(this).html("UnMute").addClass('muted');
				else jQuery(this).html("Mute").removeClass('muted');				
				return false;
			});
			
			controls.volume_bar.bind('change.media', function(event){
				api.volume = jQuery(this).val();
				return false;
			});
				
		} else controls = options.controls;
		
		control_pane
			.append(controls.play_button);
			
		if( controls.buffer_bar ){
			control_pane.append(controls.buffer_bar);
			if( controls.seek_bar) controls.buffer_bar.append(controls.seek_bar);
		}else{
			if( controls.seek_bar ) controls.buffer_bar.append(controls.seek_bar);
		}
				
		if( controls.time_display )
			control_pane.append(controls.time_display);
			
		if( controls.volume_box ){
			control_pane.append(controls.volume_box);
			controls.volume_box
				.append(controls.mute_button)
				.append(controls.volume_bar);
				
		} else{
			if( controls.mute_button )
				control_pane.append(controls.mute_button);
			if( controls.volume_bar )
				control_pane.append(controls.volume_bar);
		}
		
		// Namespace events for the controlbar, and pass along a player id to support
		// multiple players
		events = [
			'loadeddata',
			'progress',
			'timeupdate',
			'seeked',
			'canplay',
			'play',
			'playing',
			'pause',
			'loadedmetadata',
			'ended',
			'volumechange'
		];
		
		control_pane
			.bind('playing.media play.media pause.media', media_state_changed)
			.bind('timeupdate.media', update_progress)
			.bind('loadedmetadata.media', 
				function(event, pid){
					if( pid != domid ) return true;					
					controls.seek_bar.attr('max', root_element.duration);
					return true;
				})
			.bind('timeupdate.media', 
				function(event){
					if( controls.time_display ){
						controls.time_display.text(
							seconds_to_time(api.currentTime) 
							+ ":" 
							+ seconds_to_time(api.duration)
						);
					}
				});
			
		
		function media_state_changed( event, pid ){
			if( pid != domid ) return true;
			if( api.paused ) controls.play_button.html("Play").addClass('paused');
			else controls.play_button.html("Pause").removeClass('paused');
			return true;
		}
		
		function update_progress( event, pid ){
			if( pid != domid ) return true;					
			controls.seek_bar.val(api.currentTime);
			return true;
		}

		jQuery.each(events, function(i, name){
			element.bind(name, function(event){
				control_pane.trigger(event.type + ".media", [ domid ]);
			});
		});
		
		
		return self;
			
	};
	
	function seconds_to_time( seconds, use_hours ){
		seconds = Math.round(seconds);
		var hours,
		    minutes   = Math.floor(seconds / 60);
		if (minutes >= 60) {
		    hours = Math.floor(minutes / 60);
		    minutes = minutes % 60;
		}
		
		if( typeof use_hours == undefined ) use_hours = (seconds > 3600);
		
		hours = hours === undefined ? "00" : (hours >= 10) ? hours : "0" + hours;
		minutes = (minutes >= 10) ? minutes : "0" + minutes;
		seconds = Math.floor(seconds % 60);
		seconds = (seconds >= 10) ? seconds : "0" + seconds;
		return ((hours > 0 || use_hours === true) ? hours + ":" :'') + minutes + ":" + seconds;
	};

	function time_to_seconds( string ){
		var tab = string.split(':');
		return tab[0]*60*60 + tab[1]*60 + parseFloat(tab[2].replace(',','.'));
	};
	
	function object_to_query( object ){
		var string = [], i;		
		for( i in object ) string.push( i + "=" + object[i] );
		return string.join("&");
	}
	
	function check_support( type, source ){	
		// IE8 or less, no native support at all		
		if( jQuery.browser.msie && Number( jQuery.browser.version) <= 8 ) return false;

		// TODO: Support more media types. For now, only mp4's play natively
		if( (/(mp4)/i).test(source) && jQuery.browser.webkit ) return true;
		return false;
	}
		
	jQuery.fn.media_bridge = function( options ){
		
		// If a media player is already initialized, return it.
		var instance = this.data("mediaPlayer");
		if( instance ) return instance;
		
		this.each( function() {		
			instance = new MediaPlayer( jQuery(this), options );
			jQuery(this).data("mediaPlayer", instance);	
		});
		
		return this;
	
	};

})(jQuery);
