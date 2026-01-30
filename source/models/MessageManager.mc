using Toybox.Lang;
using Toybox.System;
using Toybox.Communications;
using Toybox.Time;
using Toybox.Application;

class MessageManager
{
    private static var _instance as MessageManager?;
    private var _messages as Lang.Array<Lang.Dictionary>;
    private var _connectionStatus as Lang.Number;
    private var _maxMessages as Lang.Number;
    private var _propertieUtility;
    private var _logger;
    private var _counter = -1;  // Initialization for 0..testmessages.size()

    enum {
        STATUS_DISCONNECTED,
        STATUS_CONNECTING,
        STATUS_CONNECTED,
    }

    // Private constructor
    private function initialize()
    {
        _logger = getLogger();
        _propertieUtility = getPropertieUtility();
        _messages = [];
        _connectionStatus = STATUS_DISCONNECTED;

        var limit = _propertieUtility.getPropertyNumber("MessageLimit", 30);
        _logger.debug(
            "MessageManager",
            "=== MessageManager Retrieved MessageLimit property: " + limit + " ==="
        );

        _maxMessages = limit != null ? limit : 20;
        _logger.debug(
            "MessageManager",
            "=== MessageManager initialized with maxMessages: " + _maxMessages + " ==="
        );
    }

    //
    // Messages
    //
    public function addMessage(data as Lang.Dictionary) as Void
    {
        var sender = data.get("sender");
        var text = data.get("text");

        if (sender == null || text == null) {
            _logger.warn("MessageManager", "Message missing sender or text");
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

        _logger.debug("MessageManager", "New message from: " + sender.toString());
    }

    function getMessages() as Lang.Array<Lang.Dictionary>
    {
        return _messages;
    }

    function clearMessages() as Void
    {
        _messages = [];
        _logger.debug("MessageManager", "Messages cleared");
    }

    public function addTestMessage() as Void
    {
        var testMessages = [
            { "sender" => "Alice", "text" => "01 Hey, how are you?" },
            { "sender" => "Bob", "text" => "02 Meeting at 3pm" },
            { "sender" => "Charlie", "text" => "03 Don't forget to buy milk" },
            { "sender" => "Diana", "text" => "04 Running 5 minutes late" },
            { "sender" => "Eve", "text" => "05 Great job on the presentation!" },
            { "sender" => "Frank", "text" => "06 Can you call me back?" },
            { "sender" => "Grace", "text" => "07 Lunch tomorrow?" },
            { "sender" => "Henry", "text" => "08 Check your email" },
            { "sender" => "Iris", "text" => "09 Project deadline tomorrow" },
            { "sender" => "Karl", "text" => "10 You were realy helpfull" },
            { "sender" => "Liam", "text" => "11 Macbeth is the best" },
            { "sender" => "Mick", "text" => "12 There is no end to the universe" },
            { "sender" => "Nigel", "text" => "13 Who should I thank" },
            { "sender" => "Odin", "text" => "14 Yesterday is a long time ago" },
            { "sender" => "Paul", "text" => "15 The apprentice succeeded" },
        ];

        // Pick a random message
        _counter = (_counter + 1) % testMessages.size();
        // var index = (System.getTimer () / 1000) % testMessages.size ();
        var testMsg = testMessages[_counter];

        var message = {
            "type" => "message",
            "sender" => testMsg["sender"],
            "text" => testMsg["text"],
        };

        // Create a test phone message object
        var phoneMsg = new TestPhoneAppMessage(message);
        handlePhoneMessage(phoneMsg);

        _logger.debug("MessengerDelegate", "addTestMessage from: " + testMsg["sender"]);
        WatchUi.requestUpdate();
    }

    //
    // Connections
    //
    function updateConnectionStatus(status as Lang.Number) as Void
    {
        var oldStatus = _connectionStatus;
        _connectionStatus = status;

        if (oldStatus != status) {
            _logger.info("MessageManager", "Connection status changed: " + status);
        }
    }

    function getConnectionStatus() as Lang.Number
    {
        return _connectionStatus;
    }

    function isConnected()
    {
        return _connectionStatus == 2;
    }

    //
    // Phone
    //
    function handlePhoneMessage(msg as Communications.PhoneAppMessage) as Void
    {
        _logger.debug("MessageManager", "Received phone message");

        var data = msg.data;

        if (data == null) {
            _logger.warn("MessageManager", "Received null data from phone");
            return;
        }

        if (!(data instanceof Lang.Dictionary)) {
            _logger.warn("MessageManager", "Received non-dictionary data from phone");
            return;
        }

        var dict = data as Lang.Dictionary;

        if (!dict.hasKey("type")) {
            _logger.warn("MessageManager", "Message missing 'type' field");
            return;
        }

        var msgType = dict.get("type");
        _logger.debug("MessageManager", "Message type: " + msgType);

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
            sendToPhone( { "type" => "pong" });
        } else {
            _logger.warn("MessageManager", "Unknown message type: " + typeStr);
        }
    }

    function sendToPhone(data as Lang.Dictionary or Lang.String) as Void
    {
        // 1. Check if we are in the Simulator
        var deviceSettings = System.getDeviceSettings();

        // Most Linux Simulator versions support 'isSimulator'
        // If not, we check if partNumber is the generic simulator string
        var isSim = (deviceSettings has: isSimulator && deviceSettings.isSimulator) ||
            deviceSettings.partNumber.equals("006-B0000-00");

        if (isSim) {
            _logger.debug(
                "MessageManager",
                "SIMULATOR: Logging data instead of transmitting to avoid GTK crash"
            );
            _logger.trace("MessageManager", "Data: " + data.toString());

            // Manually trigger the "Complete" logic if you have a listener
            // This keeps your app logic flowing without the crash
            return;
        }

        // 2. Physical transmit ONLY happens on real hardware
        _logger.debug("MessageManager", "HARDWARE: Sending data to phone");
        try {
            Communications.transmit(data, null, new CommListener());
        } catch (ex) {
            _logger.error("MessageManager", "Transmit Error: " + ex.getErrorMessage());
        }
    }

    function requestSync() as Void
    {
        _logger.debug("MessageManager", "Requesting sync (String test)");
        try {
            var deviceSettings = System.getDeviceSettings();
            if (deviceSettings has: isSimulator && deviceSettings.isSimulator) {
                _logger.warn("MessageManager", "Skipping transmit in Simulator to prevent crash");
                return;
            }

            // Change from { "type" => "request_sync" } to just a string
            Communications.transmit("SYNC", null, new CommListener());
        } catch (ex) {
            _logger.error("MessageManager", "Transmit Error");
        }
    }

    // NEW: Delete a message by index
    public function deleteMessage(index as Lang.Number) as Void
    {
        if (index >= 0 && index < _messages.size()) {
            var deletedMsg = _messages[index];
            _logger.debug("MessageManager", "Deleting message from: " + deletedMsg.get("sender"));

            // Create new array without the deleted message
            var newMessages = [] as Lang.Array<Lang.Dictionary>;
            for (var i = 0; i < _messages.size(); i++) {
                if (i != index) {
                    newMessages.add(_messages[i]);
                }
            }
            _messages = newMessages;

            _logger.info("MessageManager", "Message deleted. Remaining: " + _messages.size());
        }
    }

    // NEW: Delete all read messages (optional helper)
    public function deleteReadMessages(readIndices as Lang.Array<Lang.Number>) as Void
    {
        // Sort indices in descending order to delete from end first
        // (prevents index shifting issues)
        for (var i = readIndices.size() - 1; i >= 0; i--) {
            deleteMessage(readIndices[i]);
        }
    }

    // Get singleton instance
    static function getInstance() as MessageManager
    {
        if (_instance == null) {
            _instance = new MessageManager();
        }
        return _instance;
    }
}

// Global convenience function
function getMessageManager() as MessageManager
{
    return MessageManager.getInstance();
}
