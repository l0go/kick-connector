package backends;

enum abstract ExtensionProvider(Int) from Int to Int {
	var SEVENTV = (1 << 0);
	var BETTERTTV = (1 << 1);
	var FRANKERFACEZ = (1 << 2);
	var CHATTERINO = (1 << 3);

	public static function has7TV(v:Int):Bool {
		return (v & SEVENTV) > 0;
	}

	public static function hasBTTV(v:Int):Bool {
		return (v & BETTERTTV) > 0;
	}

	public static function hasFFZ(v:Int):Bool {
		return (v & FRANKERFACEZ) > 0;
	}

	public static function hasChatterino(v:Int):Bool {
		return (v & CHATTERINO) > 0;
	}
}

enum abstract IRCCommand(String) from String to String {
	var PING;
	var JOIN;
	var CLEARMSG;
	var CLEARCHAT;
	var PRIVMSG;
	var ROOMSTATE;
}

typedef IRCMessage = {
	var raw:String;
	var tags:Map<String, String>;
	var prefix:Null<String>;
	var command:Null<IRCCommand>;
	var params:Array<String>;
}

typedef TwitchBadge = {
	var name:String;
	var value:Null<String>;
}

typedef SevenTVPaint = {
	var id:String;
	var name:String;
	// var function:String; // haxe hates this
	var func:String;
	var ?color:Int;
	var ?stops:Array<{
		var at:Float;
		var color:Int;
	}>;
	var ?repeat:Bool;
	var ?angle:Float;
	var ?shape:String;
	var ?drop_shadows:Array<{
		var x_offset:Float;
		var y_offset:Float;
		var radius:Float;
		var color:Int;
	}>;
	var ?image_url:String;
	var users:Array<String>;
}

typedef ThirdPartyBadge = {
	var url:String;
	var ?color:String;
}

typedef BetterTTVEmoteData = {
	var id:String;
	var code:String;
	var imageType:String;
	var animated:Bool;
	var user:Null<{
		var id:String;
		var name:String;
		var displayName:String;
		var providerId:String;
	}>;
}

typedef BetterTTVUserData = {
	var id:String;
	var bots:Array<String>;
	var avatar:String;
	var channelEmotes:Array<BetterTTVEmoteData>;
	var sharedEmotes:Array<BetterTTVEmoteData>;
}

@:forward(tags, raw)
abstract TwitchMessage(IRCMessage) from IRCMessage to IRCMessage {
	public static var ActionRegex = ~/^\x01ACTION.*\x01$/;

	public function get_messageText():String {
		if (get_isAction()) {
			var txt = this.params[1];
			txt = ~/^\x01ACTION/.replace(txt, '');
			txt = ~/\x01$/.replace(txt, '');
			return txt;
		}
		return this.params[1];
	}

	/*
		public function get_color():String {
			if (this.tags.exists('color'))
				return this.tags.get('color');

			if (Twitch.fallbackColors.exists(get_username()))
				return Twitch.fallbackColors.get(get_username());

			var color = Twitch.defaultTwitchColors[Math.floor(Math.random() * Twitch.defaultTwitchColors.length)];
			Twitch.fallbackColors.set(get_username(), color);
			return color;
		}
	 */
	public function get_displayName():String {
		return this.tags.exists('display-name') ? this.tags.get('display-name') : get_username();
	}

	public function get_username():String {
		return this.prefix.substring(0, this.prefix.indexOf('!'));
	}

	public function get_badges():Array<TwitchBadge> {
		if (!this.tags.exists('badges'))
			return [];

		var badges = [];
		var rawBadges = this.tags.get('badges').split(',');

		if (rawBadges[0] == "")
			return badges;

		for (badge in rawBadges) {
			var split = badge.split('/');
			badges.push({name: split[0], value: split[1]});
		}

		return badges;
	}

	public function get_userId():Null<String> {
		if (!this.tags.exists('user-id'))
			return null;
		return this.tags.get('user-id');
	}

	public function get_isModerator():Bool {
		// id of BNTFryingPan. this override will only exist as long as mods cant do anything harmful with the overlay
		if (get_userId() == '62472684')
			return true;
		if (this.tags.exists('mod') && this.tags.get('mod') != '0')
			return true;
		for (badge in get_badges()) {
			if (badge.name == 'broadcaster')
				return true;
		}

		return false;
	}

	public function get_isSubscriber():Bool {
		if (this.tags.exists('subscriber') && this.tags.get('subscriber') != '0')
			return true;

		return false;
	}

	public function get_isAction():Bool {
		return ActionRegex.match(this.params[1]);
	}
}
