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
    getLogger().debug("MessageManager Retrieved MessageLimit property: " + limit);
    _maxMessages = limit != null ? limit : 30;
    getLogger().debug(
      "MessageManager initialized with maxMessages: " + _maxMessages
    );
  }

  function handlePhoneMessage(msg as Communications.PhoneAppMessage) as Void {
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

  public function addMessage(data as Lang.Dictionary) as Void {
    var message = {
      "sender" => data["sender"],
      "text" => data["text"],
      "time" => Time.now().value(),
    };

    _messages.add(message);

    if (_messages.size() > _maxMessages) {
      _messages = _messages.slice(-_maxMessages, null);
    }

    getLogger().debug("New message from: " + data["sender"]);
  }

  function getMessages() as Lang.Array {
    return _messages;
  }

  function clearMessages() as Void {
    _messages = [];
    getLogger().debug("Messages cleared");
  }

  function updateConnectionStatus(status as Lang.Number) as Void {
    _connectionStatus = status;
  }

  function getConnectionStatus() as Lang.Number {
    return _connectionStatus;
  }

  function sendToPhone(data as Lang.Dictionary) as Void {
    Communications.transmit(data, null, new CommListener());
  }
}

class CommListener extends Communications.ConnectionListener {
  function initialize() {
    ConnectionListener.initialize();
  }

  function onComplete() as Void {
    getLogger().debug("Transmit complete");
  }

  function onError() as Void {
    getLogger().debug("Transmit error");
  }
}
