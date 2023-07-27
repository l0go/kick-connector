package;

import js.Browser;
import js.html.Storage;

class Options {
	public static var channels:Map<String, String> = [];
	static var storage:Storage = Browser.getLocalStorage();

	public static function main() {
		loadChannels();
		Browser.document.getElementById("add").onclick = () -> {
			var kick:js.html.InputElement = cast Browser.document.getElementById("kick-input");
			var twitch:js.html.InputElement = cast Browser.document.getElementById("twitch-input");

			if (kick.value != "" && twitch.value != "") {
				addChannel(kick.value, twitch.value);
			}
		}
	}

	static function addChannel(kick:String, twitch:String) {
		channels.set(kick, twitch);
		storage.setItem("channels", haxe.Serializer.run(channels));
	}

	static function loadChannels() {
		getChannels();

		Browser.document.getElementById("channels").innerHTML = "";

		for (channel in channels.keys()) {
			var tr = Browser.document.createElement("tr");

			var kickChannel = Browser.document.createElement("td");
			kickChannel.appendChild(Browser.document.createTextNode(channel));
			tr.appendChild(kickChannel);

			var twitchChannel = Browser.document.createElement("td");
			twitchChannel.appendChild(Browser.document.createTextNode(channels[channel]));
			tr.appendChild(twitchChannel);

			Browser.document.getElementById("channels").appendChild(tr);
		}
	}

	public static function getChannels() {
		var channelsSerialize = storage.getItem("channels");
		if (channelsSerialize == null) {
			addChannel("yms", "adumplaze");
		    Browser.location.reload();
        }
		channels = haxe.Unserializer.run(channelsSerialize);
	}
}
