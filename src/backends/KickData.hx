package backends;

enum abstract KickRole(String) from String to String {
	var HOST = 'broadcaster';
	var MOD = 'moderator';
	var SUPERADMIN = 'super admin';
	var VIP = 'vip';
	var OG = 'og';
	var FOUNDER = 'founder';
	var VERIFIED = 'verified';
	var SUB = 'subscriber';
}

enum abstract UserColorType(String) {
	var GRADIENT = 'gradient';
	var SOLID = 'solid';
	var CUSTOM = 'custom';
}

typedef UserColor = {
	var type:UserColorType;
	var ?start:String;
	var ?end:String;
	var ?value:String;
	var ?custom:String;
}

typedef ChatUserData = {
	var id:Int;
	var username:String;
	var slug:String;
	var identity:{
		var ?color:String;
		var badges:Array<{
			var type:String;
			var text:String;
		}>;
	}
}

typedef ChatData = {
	var id:String;
	var chatroom_id:Int;
	var content:String;
	var type:String;
	var created_at:String;
	var sender:ChatUserData;
}

typedef KickCategory = {
	var id:Int;
	var category_id:Int;
	var name:String;
	var slug:String;
	var tags:Array<String>;
	// var description:Null<?>;
	// var deleted_at:Null<?>;
	var banner:{
		var responsive:String;
		var url:String;
	};
	var category:{
		var id:Int;
		var name:String;
		var slug:String;
		var icon:String;
	};
}

typedef ChannelData = {
	var id:Int;
	var user_id:Int;
	var slug:String;
	var playback_url:String;
	// var name_updated_at:Null<?>;
	var vod_enabled:Bool;
	var subscription_enabed:Bool;
	var ?cf_rate_limiter:String;
	var followersCount:Int;
	// var subscriber_badges:Array<?>;
	// var banner_image:Null<?>;
	var recent_categories:Array<KickCategory>;
	// var livestream:Null<?>;
	// var role:Null<?>;
	var muted:Bool;
	// var follower_badges:Array<?>;
	// var offline_banner_image:Null<?>;
	var can_host:Bool;
	var user:{
		var id:Int;
		var username:String;
		var agreed_to_terms:Bool;
		var ?bio:String;
		var ?country:String;
		var ?city:String;
		var ?instagram:String;
		var ?twitter:String;
		var ?youtube:String;
		var ?discord:String;
		var ?tiktok:String;
		var ?facebook:String;
		var ?birthdate:String; // idfk what the format is
		var ?profile_pic:String;
	}
	var chatroom:{
		var id:Int;
		var chatable_type:String;
		var channel_id:Int;
		var created_at:String;
		var updated_at:String;
		var chat_mode_old:String;
		var chhat_mode:String;
		var slow_mode:Bool;
		var chatable_id:Int;
	}
	// var ascending_links:Array<?>;
	// var plan:Null<?>;
	var previous_livestreams:Array<{
		var id:Int;
		var slug:String;
		var channel_id:Int;
		var created_at:String;
		var session_title:String;
		var is_live:Bool;
		// var risk_level_id:Null<?>;
		// var source:Null<?>;
		// var twitch_channel:Null<?>;
		var duration:Int;
		var language:String;
		var is_mature:Bool;
		var viewer_count:Int;
		var thumbnail:{
			var src:String;
			var srcset:String;
		};
		var views:Int;
		var tags:Array<String>;
		var categories:Array<KickCategory>;
		var video:{
			var id:Int;
			var live_stream_id:Int;
			// var slug:Null<?>;
			// var thumb:Null<?>;
			// var s3:Null<?>;
			// var trading_platform_id:Null<?>;
			var created_at:String;
			var updated_at:String;
			var uuid:String;
			var views:Int;
			// var deleted_at:Null<?>;
		};
	}>;
	// var verified:Null<?>;
	// var media:Array<?>;
}
