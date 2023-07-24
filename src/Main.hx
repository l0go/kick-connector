package;

import js.Browser;
import js.html.MutationObserver;

using StringTools;

class Main {
	public static var kickChannel = "";
	public static var twitchChannel = "";

	static var chatroom:js.html.DOMElement;
	static var observer:MutationObserver;

	static function main() {
		var url = Browser.window.location.href;
		if (url.contains("options.html")) {
			Options.main();
		} else {
			var kickChannelRegex = ~/\.com\/([^\/\?]+)/g;
			kickChannelRegex.match(url);
			Options.getChannels();
			kickChannel = kickChannelRegex.matched(1);
			if (Options.channels.exists(kickChannel)) {
				twitchChannel = Options.channels[kickChannel];
				trace("Kick Connect: Loading");
				var node = Browser.document.body;
				observer = new MutationObserver(checkChatroom);
				observer.observe(node, {
					childList: true,
					subtree: true,
					attributes: false,
					characterData: false,
				});
			}
		}
	}

	/*
	 * Displays a message in chat
	 */
	public static function postMessage(username:String, message:String, backend:String) {
		var element = Browser.document.createElement("div");
		element.className = "mt-0.5";

		var chatEntry = Browser.document.createElement("div");
		chatEntry.className = "chat-entry";
		chatEntry.onmouseenter = () -> {
			chatEntry.style.backgroundColor = "#111827";
		};
		chatEntry.onmouseout = () -> {
			chatEntry.style.backgroundColor = "";
		}

		// Just a blank div, not sure why Kick has this, but I am keeping it in for accuracy
		var div = Browser.document.createElement("div");

		// Holds the username
		var chatMessageIdentity = Browser.document.createElement("span");
		chatMessageIdentity.className = "chat-message-identity";

		// The username itself
		var chatEntryUsername = Browser.document.createElement("span");
		chatEntryUsername.className = "chat-entry-username";
		switch (backend) {
			case "bot":
				chatEntryUsername.style.color = "#FF5964";
			case "kick":
				chatEntryUsername.style.color = "#00FF00";
			case "twitch":
				chatEntryUsername.style.color = "#9146FF";
			default:
				throw "Invalid Backend Name";
		}
		var usernameText = Browser.document.createTextNode(username);
		chatEntryUsername.appendChild(usernameText);

		chatMessageIdentity.appendChild(chatEntryUsername);

		// Now the colon seperating the username and message
		var colon = Browser.document.createElement("span");
		colon.className = "font-bold text-white";
		colon.appendChild(Browser.document.createTextNode(": "));

		var messageContainer = Browser.document.createElement("span");
		var chatEntryContent = Browser.document.createElement("span");
		chatEntryContent.className = "chat-entry-content";
		chatEntryContent.appendChild(Browser.document.createTextNode(message));
		messageContainer.appendChild(chatEntryContent);

		div.appendChild(chatMessageIdentity);
		div.appendChild(colon);
		div.appendChild(messageContainer);
		chatEntry.appendChild(div);
		element.appendChild(chatEntry);
		chatroom.children[1].children[0].appendChild(element);

		// Scroll to bottom
		chatroom.children[1].children[0].scrollTop = chatroom.children[1].children[0].scrollHeight;
	}

	/*
	 * Checks to see if the "chatroom-top" element gets loaded
	 * If so, this means that the chat is rendered
	 */
	static function checkChatroom(_, _) {
		chatroom = Browser.document.getElementById("chatroom");
		if (chatroom.children[1].children.length != 0) {
			chatroom.children[1].children[0].innerHTML = ""; // Ideally we will remove this, but right now this works alright?
			postMessage("Kick Connect", "Connecting...", "bot");
			backends.Kick.connect();
			backends.Twitch.connect();
			observer.disconnect();
		}
	}
}
