package com.kurbmedia.media.players{
	
	public interface MediaInterface{
		
		function getCurrentTime():Number;
		function setCurrentTime(arg:Number):void;
		function getDuration():Number;
		function getEnded():Boolean;
		function getMuted():Boolean;
		function setMuted(arg:Boolean):void;
		function getPaused():Boolean;		
		function getPlayed():Boolean;
		function getSeeking():Boolean;
		function getSrc():String;
		function setSrc(arg:String):void;
		function getVolume():Number;
		function setVolume(arg:Number):void;
		
		function load():void;
		function play():void;
		function pause():void;
		function stop():void;		
	}	
}