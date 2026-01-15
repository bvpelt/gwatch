using Toybox.Lang;
using Toybox.System;
using Toybox.Communications;
using Toybox.Time;
using Toybox.Application;

class MessageManager {
  private static var _instance as MessageManager?;
  private var _messages as Lang.Array<Lang.Dictionary>;
  private var _connectionStatus as Lang.Number;
  private var _maxMessages as Lang.Number;
  private var logger;

  enum {
    STATUS_DISCONNECTED,
    STATUS_CONNECTING,
    STATUS_CONNECTED,
  }

  // Private constructor
  private function initialize() {
    logger = getLogger();
    _messages = [];
    _connectionStatus = STATUS_DISCONNECTED;

    var limit = Application.Properties.getValue("MessageLimit");
    logger.debug(
      "MessageManager",
      "MessageManager Retrieved MessageLimit property: " + limit
    );
    _maxMessages = limit != null ? limit : 20;
    logger.debug(
      "MessageManager",
      "MessageManager initialized with maxMessages: " + _maxMessages
    );
  }

  // Get singleton instance
  static function getInstance() as MessageManager {
    if (_instance == null) {
      _instance = new MessageManager();
    }
    return _instance;
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
    logger.debug("MessageManager", "Received phone message");

    var data = msg.data;

    if (data == null) {
      logger.warn("MessageManager", "Received null data from phone");
      return;
    }

    if (!(data instanceof Lang.Dictionary)) {
      logger.warn("MessageManager", "Received non-dictionary data from phone");
      return;
    }

    var dict = data as Lang.Dictionary;

    if (!dict.hasKey("type")) {
      logger.warn("MessageManager", "Message missing 'type' field");
      return;
    }

    var msgType = dict.get("type");
    logger.debug("MessageManager", "Message type: " + msgType);

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
      logger.warn("MessageManager", "Unknown message type: " + typeStr);
    }
  }

  public function addMessage(data as Lang.Dictionary) as Void {
    var sender = data.get("sender");
    var text = data.get("text");

    if (sender == null || text == null) {
      logger.warn("MessageManager", "Message missing sender or text");
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

    logger.debug("MessageManager", "New message from: " + sender.toString());
  }

  function getMessages() as Lang.Array {
    return _messages;
  }

  function clearMessages() as Void {
    _messages = [];
    logger.debug("MessageManager", "Messages cleared");
  }

  function updateConnectionStatus(status as Lang.Number) as Void {
    var oldStatus = _connectionStatus;
    _connectionStatus = status;

    if (oldStatus != status) {
      logger.info("MessageManager", "Connection status changed: " + status);
    }
  }

  function getConnectionStatus() as Lang.Number {
    return _connectionStatus;
  }

  function sendToPhonexx(data as Lang.Dictionary or Lang.String) as Void {
    // Detect if we are in the simulator to avoid the GTK Segfault
    var deviceSettings = System.getDeviceSettings();
    if (deviceSettings has :isSimulator && deviceSettings.isSimulator) {
      logger.warn(
        "MessageManager",
        "Skipping transmit in Simulator to prevent crash"
      );
      return;
    }

    logger.debug("MessageManager", "Sending data to phone");
    try {
      Communications.transmit(data, null, new CommListener());
    } catch (ex) {
      logger.error("MessageManager", "Transmit Error");
    }
  }

  function sendToPhone(data as Lang.Dictionary or Lang.String) as Void {
    // 1. Check if we are in the Simulator
    var deviceSettings = System.getDeviceSettings();

    // Most Linux Simulator versions support 'isSimulator'
    // If not, we check if partNumber is the generic simulator string
    var isSim =
      (deviceSettings has :isSimulator && deviceSettings.isSimulator) ||
      deviceSettings.partNumber.equals("006-B0000-00");

    if (isSim) {
      logger.debug(
        "MessageManager",
        "SIMULATOR: Logging data instead of transmitting to avoid GTK crash"
      );
      logger.trace("MessageManager", "Data: " + data.toString());

      // Manually trigger the "Complete" logic if you have a listener
      // This keeps your app logic flowing without the crash
      return;
    }

    // 2. Physical transmit ONLY happens on real hardware
    logger.debug("MessageManager", "HARDWARE: Sending data to phone");
    try {
      Communications.transmit(data, null, new CommListener());
    } catch (ex) {
      logger.error("MessageManager", "Transmit Error: " + ex.getErrorMessage());
    }
  }

  function requestSync() as Void {
    logger.debug("MessageManager", "Requesting sync (String test)");
    try {
      var deviceSettings = System.getDeviceSettings();
      if (deviceSettings has :isSimulator && deviceSettings.isSimulator) {
        logger.warn(
          "MessageManager",
          "Skipping transmit in Simulator to prevent crash"
        );
        return;
      }

      // Change from { "type" => "request_sync" } to just a string
      Communications.transmit("SYNC", null, new CommListener());
    } catch (ex) {
      logger.error("MessageManager", "Transmit Error");
    }
  }
}

class CommListener extends Communications.ConnectionListener {
  private var logger = getLogger();

  function initialize() {
    ConnectionListener.initialize();
  }

  function onComplete() as Void {
    logger.debug("MessageManager", "Transmit complete");
  }

  function onError() as Void {
    logger.debug("MessageManager", "Transmit error");
  }
}

// Global convenience function
function getMessageManager() as MessageManager {
  return MessageManager.getInstance();
}
