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

    enum {
        STATUS_DISCONNECTED,
        STATUS_CONNECTING,
        STATUS_CONNECTED,
    }

    // Private constructor
    private function initialize() {
        _logger = getLogger();
        _propertieUtility = getPropertieUtility();
        _messages = [];
        _connectionStatus = STATUS_DISCONNECTED;

        var limit = _propertieUtility.getPropertyNumber("MessageLimit", 30);
        _logger.debug("MessageManager",
                      "=== MessageManager Retrieved MessageLimit property: " + limit + " ===");
        _maxMessages = limit != null ? limit : 20;
        _logger.debug("MessageManager",
                      "=== MessageManager initialized with maxMessages: " + _maxMessages + " ===");
    }

        // Get singleton instance
        static function getInstance() as MessageManager
    {
        if (_instance == null) {
            _instance = new MessageManager ();
        }
        return _instance;
    }

    function handlePhoneMessage (msg as Communications.PhoneAppMessage) as Void
    {
        _logger.debug ("MessageManager", "Received phone message");

        var data = msg.data;

        if (data == null) {
            _logger.warn ("MessageManager", "Received null data from phone");
            return;
        }

        if (!(data instanceof Lang.Dictionary)) {
            _logger.warn ("MessageManager", "Received non-dictionary data from phone");
            return;
        }

        var dict = data as Lang.Dictionary;

        if (!dict.hasKey ("type")) {
            _logger.warn ("MessageManager", "Message missing 'type' field");
            return;
        }

        var msgType = dict.get ("type");
        _logger.debug ("MessageManager", "Message type: " + msgType);

        if (msgType == null) {
            return;
        }

        var typeStr = msgType.toString ();

        if (typeStr.equals ("message")) {
            addMessage (dict);
        } else if (typeStr.equals ("status")) {
            var status = dict.get ("status");
            if (status != null) {
                updateConnectionStatus (status as Lang.Number);
            }
        } else if (typeStr.equals ("clear")) {
            clearMessages ();
        } else if (typeStr.equals ("ping")) {
            // Respond to ping to confirm connection
            sendToPhone ({"type" => "pong"});
        } else {
            _logger.warn ("MessageManager", "Unknown message type: " + typeStr);
        }
    }

    public function addMessage (data as Lang.Dictionary) as Void
    {
        var sender = data.get ("sender");
        var text = data.get ("text");

        if (sender == null || text == null) {
            _logger.warn ("MessageManager", "Message missing sender or text");
            return;
        }

        var message = {
            "sender" => sender,
            "text" => text,
            "time" => Time.now ().value (),
        };

        _messages.add (message);

        if (_messages.size () > _maxMessages) {
            _messages = _messages.slice (-_maxMessages, null);
        }

        _logger.debug ("MessageManager", "New message from: " + sender.toString ());
    }

    function getMessages () as Lang.Array<Lang.Dictionary>
    {
        return _messages;
    }

    function clearMessages () as Void
    {
        _messages = [];
        _logger.debug ("MessageManager", "Messages cleared");
    }

    function updateConnectionStatus (status as Lang.Number) as Void
    {
        var oldStatus = _connectionStatus;
        _connectionStatus = status;

        if (oldStatus != status) {
            _logger.info ("MessageManager", "Connection status changed: " + status);
        }
    }

    function getConnectionStatus () as Lang.Number
    {
        return _connectionStatus;
    }

    function sendToPhone (data as Lang.Dictionary or Lang.String) as Void
    {
        // 1. Check if we are in the Simulator
        var deviceSettings = System.getDeviceSettings ();

        // Most Linux Simulator versions support 'isSimulator'
        // If not, we check if partNumber is the generic simulator string
        var isSim = (deviceSettings has
                     : isSimulator && deviceSettings.isSimulator)
                    || deviceSettings.partNumber.equals ("006-B0000-00");

        if (isSim) {
            _logger.debug ("MessageManager",
                          "SIMULATOR: Logging data instead of transmitting to avoid GTK crash");
            _logger.trace ("MessageManager", "Data: " + data.toString ());

            // Manually trigger the "Complete" logic if you have a listener
            // This keeps your app logic flowing without the crash
            return;
        }

        // 2. Physical transmit ONLY happens on real hardware
        _logger.debug ("MessageManager", "HARDWARE: Sending data to phone");
        try {
            Communications.transmit (data, null, new CommListener ());
        } catch (ex) {
            _logger.error ("MessageManager", "Transmit Error: " + ex.getErrorMessage ());
        }
    }

    function requestSync () as Void
    {
        _logger.debug ("MessageManager", "Requesting sync (String test)");
        try {
            var deviceSettings = System.getDeviceSettings ();
            if (deviceSettings has : isSimulator && deviceSettings.isSimulator) {
                _logger.warn ("MessageManager", "Skipping transmit in Simulator to prevent crash");
                return;
            }

            // Change from { "type" => "request_sync" } to just a string
            Communications.transmit ("SYNC", null, new CommListener ());
        } catch (ex) {
            _logger.error ("MessageManager", "Transmit Error");
        }
    }

    public function addTestMessage () as Void {
        var testMessages = [
            {"sender" => "Alice", "text" => "Hey, how are you?"},
            {"sender" => "Bob", "text" => "Meeting at 3pm"},
            {"sender" => "Charlie", "text" => "Don't forget to buy milk"},
            {"sender" => "Diana", "text" => "Running 5 minutes late"},
            {"sender" => "Eve", "text" => "Great job on the presentation!"},
            {"sender" => "Frank", "text" => "Can you call me back?"},
            {"sender" => "Grace", "text" => "Lunch tomorrow?"},
            {"sender" => "Henry", "text" => "Check your email"},
            {"sender" => "Iris", "text" => "Project deadline tomorrow"},
            {"sender" => "Karl", "text" => "You were realy helpfull"},
            {"sender" => "Liam", "text" => "Macbeth is the best"},
            {"sender" => "Mick", "text" => "There is no end to the universe"},
            {"sender" => "Nigel", "text" => "Who should I thank"},
            {"sender" => "Odin", "text" => "Yesterday is a long time ago"},
            {"sender" => "Paul", "text" => "The apprentice succeeded"},
        ];

        // Pick a random message
        var index = (System.getTimer () / 1000) % testMessages.size ();
        var testMsg = testMessages[index];

        var message = {
            "type" => "message",
            "sender" => testMsg["sender"],
            "text" => testMsg["text"],
        };

        // Create a test phone message object
        var phoneMsg = new TestPhoneAppMessage (message);
        handlePhoneMessage (phoneMsg);

        _logger.debug ("MessengerDelegate", "addTestMessage from: " + testMsg["sender"]);
        WatchUi.requestUpdate ();
    }
}

class CommListener extends Communications.ConnectionListener
{
    private var _logger;

    function initialize ()
    {
        _logger = getLogger ();
        ConnectionListener.initialize ();
    }

    function onComplete () as Void
    {
        _logger.debug ("MessageManager", "Transmit complete");
    }

    function onError () as Void
    {
        _logger.debug ("MessageManager", "Transmit error");
    }

}


// Helper class for testing
class TestPhoneAppMessage extends Communications.PhoneAppMessage
{
    public var data;

    function initialize (d as Lang.Dictionary)
    {
        PhoneAppMessage.initialize ();
        data = d;
    }
}
// Global convenience function
function getMessageManager () as MessageManager
{
    return MessageManager.getInstance ();
}
