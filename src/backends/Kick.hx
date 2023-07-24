package backends;

import haxe.Json;
import haxe.Http;
import backends.KickData;
import js.lib.Promise;

using StringTools;

@:expose
class Kick {
	public static var chatroomId = 0;
	public static inline final KICK_PUSHER_KEY = 'eb1d5f283081a78b932c';
	public static inline final KICK_PUSHER_CLUSTER = 'us2';

	public static var pusher:Pusher;

	public static function asyncRequest(url:String):Promise<String> {
		return new Promise((resolve, reject) -> {
			var req = new Http(url);
			req.async = true;
			req.onData = d -> resolve(d);
			req.onError = e -> reject(e);
			req.request(false);
		});
	}

	public static function connect() {
		var req = asyncRequest('https://kick.com/api/v1/channels/${Main.kickChannel}');
		req.then(d -> {
			var data:ChannelData = Json.parse(d);
			chatroomId = data.chatroom.id;
			connectKick();
		});
	}

	public static function connectKick() {
		// Log.mask = Log.INFO; // | Log.DEBUG; // | Log.DATA;
		pusher = new Pusher('wss://ws-$KICK_PUSHER_CLUSTER.pusher.com/app/$KICK_PUSHER_KEY?client=haxe&version=2.0.0&protocol=7');
		// pusher = new Pusher('wss://example.com');
		pusher.subscribe('hx:open', (data) -> {
			pusher.ws.send('{"event": "pusher:subscribe", "data": {"auth": "", "channel": "chatrooms.${chatroomId}.v2"}}');
		});
		pusher.subscribe('App/Events/ChatMessageEvent', (msg) -> {
			var data:ChatData = Json.parse(msg);

			Main.postMessage(data.sender.username, data.content, "kick");
		});

		pusher.subscribe('pusher_internal:subscription_succeeded', (data) -> {
			Main.postMessage('Kick Connect', 'Connected to Kick!', "bot");
		});
		pusher.connect();
	}
}
