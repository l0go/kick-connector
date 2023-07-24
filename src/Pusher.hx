package;

import hx.ws.Types.MessageType;
import haxe.Json;
import hx.ws.WebSocket;

using StringTools;

typedef EventMessage = {
	event:String,
	data:String,
	?channel:String,
}

class Pusher {
	var url:String;
	var eventListeners:Map<String, Array<Null<String>->Void>> = [];

	public var ws:WebSocket;

	public function new(url:String) {
		this.url = url;
		this.ws = new WebSocket(url, false);
		this.ws.onopen = () -> {
			this.emit('hx:open');
		}
		this.ws.onmessage = (data:MessageType) -> {
			switch data {
				case BytesMessage(content):
				case StrMessage(content):
					var parsed:EventMessage = Json.parse(content);
					emit(parsed.event, parsed.data);
			}
		}
	}

	public function connect() {
		this.ws.open();
	}

	public function subscribe(event:String, listener:Null<String>->Void):Int {
		event = event.replace('/', '\\');
		if (!eventListeners.exists(event))
			eventListeners.set(event, []);

		if (event.startsWith('hx:'))
			return eventListeners.get(event).push(listener);

		// todo: other stuff?
		return eventListeners.get(event).push(listener);
	}

	function emit(event:String, ?data:String) {
		if (!eventListeners.exists(event))
			return;
		var listeners = eventListeners.get(event);
		if (listeners.length == 0)
			trace('no listeners for $event');
		for (listener in listeners) {
			listener(data);
		}
	}
}
