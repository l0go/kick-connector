package backends;

import haxe.Json;
import hx.ws.Types.MessageType;
import hx.ws.WebSocket;

using StringTools;

@:expose
class Twitch {
	public static var ws:WebSocket;
	public static var socketConnected = false;

	public static function connect() {
		ws = new WebSocket('wss://irc-ws.chat.twitch.tv', false);

		ws.onopen = () -> {
			socketConnected = true;
			send('PASS nerd');
			send('NICK justinfan69');
			send('CAP REQ :twitch.tv/commands twitch.tv/tags');
			send('JOIN #${Main.twitchChannel}');
			Main.postMessage('Kick Connect', 'Connected to Twitch!', "bot");
		}

		ws.onclose = () -> {
			socketConnected = false;
			Main.postMessage('Kick Connect', 'Disconnected from Twitch, Reconnecting...', "bot");
			ws.close();
			connect();
		}

		ws.onmessage = (data) -> {
			switch data {
				case BytesMessage(content):
				case StrMessage(content):
					for (message in content.split('\r\n')) {
						var msg = parseIRCMessage(message);
						if (msg == null || msg.command == null)
							continue;
						if (msg.command == PRIVMSG)
							Main.postMessage(msg.tags["display-name"], msg.params[1], "twitch");
					}
			}
		}

		ws.open();
	}

	public static function send(str:String) {
		if (!socketConnected)
			return;
		ws.send(str + '\r\n');
	}

	public static function parseIRCMessage(str:String):Null<TwitchData.IRCMessage> {
		var message:TwitchData.IRCMessage = {
			raw: str,
			tags: [],
			prefix: null,
			command: null,
			params: []
		};

		var pos = 0;
		var nextSpace = 0;

		if (str.charCodeAt(0) == '@'.code) {
			nextSpace = str.indexOf(' ');
			if (nextSpace == -1)
				return null; // malformed message

			var rawTags = str.substring(1, nextSpace).split(';');

			for (tag in rawTags) {
				var pair = tag.split('=');
				message.tags.set(pair[0], pair.length > 1 ? pair[1] : 'true');
			}

			pos = nextSpace + 1;
		}

		while (str.isSpace(pos++)) {} // skip whitespace
		pos--;

		if (str.charCodeAt(pos) == ':'.code) {
			nextSpace = str.indexOf(' ', pos);
			if (nextSpace == -1)
				return null; // malformed message

			message.prefix = str.substring(pos + 1, nextSpace);
			pos = nextSpace + 1;

			while (str.isSpace(pos++)) {} // skip whitespace
			pos--;
		}

		nextSpace = str.indexOf(' ', pos);

		if (nextSpace == -1) {
			if (str.length > pos) {
				message.command = str.substring(pos);
				return message;
			}

			return null;
		}

		message.command = str.substring(pos, nextSpace);
		pos = nextSpace + 1;

		while (str.isSpace(pos++)) {}
		pos--;

		while (pos < str.length) {
			nextSpace = str.indexOf(' ', pos);

			if (str.charCodeAt(pos) == ':'.code) {
				message.params.push(str.substring(pos + 1));
				break;
			}

			if (nextSpace == -1) {
				message.params.push(str.substring(pos));
				break;
			}

			message.params.push(str.substring(pos, nextSpace));
			pos = nextSpace + 1;

			while (str.isSpace(pos++)) {}
			pos--;
		}

		return message;
	}
}
