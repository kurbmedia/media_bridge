package com.kurbmedia.media{
	
	import flash.events.Event;
		
	public class MediaEvent extends Event{
		
		public static const PROGRESS:String 		= "progress";
		public static const TIMEUPDATE:String 		= "timeupdate";
		public static const SEEKED:String 			= "seeked";
		public static const PLAY:String 			= "play";
		public static const PLAYING:String 			= "playing";
		public static const PAUSE:String			= "pause";
		public static const LOADEDMETADATA:String 	= "loadedmetadata";
		public static const ENDED:String 			= "ended";
		public static const VOLUMECHANGE:String 	= "volumechange";
		public static const STOP:String 			= "stop";
		public static const ERROR:String 			= "error";
		public static const LOADSTART:String 		= "loadstart";
		public static const CANPLAY:String 			= "canplay";
		public static const LOADEDDATA:String 		= "loadeddata";
		public static const SEEKING:String 			= "seeking";
		
		public var data;
		
		public function MediaEvent(name, event_data:* = null){
			data = event_data;
			super(name);
		}
						
	}
}