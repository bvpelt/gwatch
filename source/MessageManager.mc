using Toybox.Lang;
using Toybox.System;
using Toybox.Communications;
using Toybox.Time;
using Toybox.Application;

class MessageManager {
  private var _messages as Lang.Array<Lang.Dictionary>;
  private var _connectionStatus as Lang.Number;
  private var _maxMessages as Lang.Number;

  enum {
    STATUS_DISCONNECTED,
    STATUS_CONNECTING,
    STATUS_CONNECTED,
  }

  function initialize() {
    _messages = [];
    _connectionStatus = STATUS_DISCONNECTED;

    var limit = Application.Properties.getValue("MessageLimit");
    getLogger().debug(
      "MessageManager",
      "MessageManager Retrieved MessageLimit property: " + limit
    );
    _maxMessages = limit != null ? limit : 20;
    getLogger().debug(
      "MessageManager",
      "MessageManager initialized with maxMessages: " + _maxMessages
    );
  }

  function handlePhoneMessagexx(msg as Communications.PhoneAppMessage) as Void {
    var data = msg.data;
    if (data != null && data instanceof Lang.Dictionary) {
      if (data.hasKey("type")) {
        var msgType = data["type"];
        if (msgType.equals("message")) {
          addMessage(data);
        } else if (msgType.equals("status")) {
          updateConnectionStatus(data["status"]);
        } else if (msgType.equals("clear")) {
          clearMessages();
        }
      }
    }
  }

  function handlePhoneMessage(msg as Communications.PhoneAppMessage) as Void {
    getLogger().debug("MessageManager", "Received phone message");

    var data = msg.data;

    if (data == null) {
      getLogger().warn("MessageManager", "Received null data from phone");
      return;
    }

    if (!(data instanceof Lang.Dictionary)) {
      getLogger().warn(
        "MessageManager",
        "Received non-dictionary data from phone"
      );
      return;
    }

    var dict = data as Lang.Dictionary;

    if (!dict.hasKey("type")) {
      getLogger().warn("MessageManager", "Message missing 'type' field");
      return;
    }

    var msgType = dict.get("type");
    getLogger().debug("MessageManager", "Message type: " + msgType);

    if (msgType == null) {
      return;
    }

    var typeStr = msgType.toString();

    if (typeStr.equals("message")) {
      addMessage(dict);
    } else if (typeStr.equals("status")) {
      var status = dict.get("status");
      if (status != null) {
        updateConnectionStatus(status as Lang.Number);
      }
    } else if (typeStr.equals("clear")) {
      clearMessages();
    } else if (typeStr.equals("ping")) {
      // Respond to ping to confirm connection
      sendToPhone({ "type" => "pong" });
    } else {
      getLogger().warn("MessageManager", "Unknown message type: " + typeStr);
    }
  }

  public function addMessage(data as Lang.Dictionary) as Void {
    var sender = data.get("sender");
    var text = data.get("text");

    if (sender == null || text == null) {
      getLogger().warn("MessageManager", "Message missing sender or text");
      return;
    }

    var message = {
      "sender" => sender,
      "text" => text,
      "time" => Time.now().value(),
    };

    _messages.add(message);

    if (_messages.size() > _maxMessages) {
      _messages = _messages.slice(-_maxMessages, null);
    }

    getLogger().debug(
      "MessageManager",
      "New message from: " + sender.toString()
    );
  }

  function getMessages() as Lang.Array {
    return _messages;
  }

  function clearMessages() as Void {
    _messages = [];
    getLogger().debug("MessageManager", "Messages cleared");
  }

  function updateConnectionStatus(status as Lang.Number) as Void {
    var oldStatus = _connectionStatus;
    _connectionStatus = status;

    if (oldStatus != status) {
      getLogger().info(
        "MessageManager",
        "Connection status changed: " + status
      );
    }
  }

  function getConnectionStatus() as Lang.Number {
    return _connectionStatus;
  }

  function sendToPhone(data as Lang.Dictionary) as Void {
    getLogger().debug("MessageManager", "Sending data to phone");
    Communications.transmit(data, null, new CommListener());
  }

  // Request connection status from phone
  function requestSync() as Void {
    getLogger().debug("MessageManager", "Requesting sync from phone");
    sendToPhone({ "type" => "request_sync" });
  }
}

class CommListener extends Communications.ConnectionListener {
  function initialize() {
    ConnectionListener.initialize();
  }

  function onComplete() as Void {
    getLogger().debug("MessageManager", "Transmit complete");
  }

  function onError() as Void {
    getLogger().debug("MessageManager", "Transmit error");
  }
}
