# media_bridge

jQuery media_bridge is a simple plugin which provides a HTML5 api compatable flash fallback for un-supporting browsers.
When created, the plugin maps the flash player ExternalInterface to the HTML5 video/audio tag's public methods / properties. 
This way both are controlled in the same manner, making enhancement easier later.

## Usage

Setup a video or audio tag like normal, including src, poster blah blah. Set your source to a mp4/m4v file (see below for more info) 
and call .media_bridge on the element:
	
	<video src="http://path_to_some.mp4" id="my_sick_player"></video>
	
	$('#my_sick_player').media_bridge( options );
	
See the source for a list of available options. By default the plugin will add accessable controls using buttons and 
HTML5 range elements. To support usuability you should manipulate these as necessary (check out jQuerytools rangeelement for a 
good way to handle seek / volume).

## why another one of these?

Because all of the existing "HTML5 players" always felt bloated. For instance, media_bridge assumes mp4 / m4v video files
( supporting the obvious f4v with flash ). Until the HTML5 spec is more solid and people can agree on a standard video format, 
this covers just about every possible scenario. If you'd like to support ogg, webm, blah blah, use something else. In our 
day to day work though, creating 4-5 different versions of the same video just to pat ourselves on the back and say "look we made HTML5!" 
just isn't that big of a deal.

We do however like the ability to skin a player with pure HTML/CSS. This makes it much easier to mesh into any site, and any situation. 
YouTube player support is also planned in the near future. 