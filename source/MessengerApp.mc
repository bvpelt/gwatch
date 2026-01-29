using Toybox.Application;
using Toybox.Lang;
using Toybox.WatchUi;
using Toybox.Communications;

class MessengerApp extends Application.AppBase
{
    private var _messageManager;
    private var _heartbeatTimer;

    private var _logger;
    private var _propertieUtility;

    function initialize()
    {
        AppBase.initialize();
        _logger = getLogger();
        _propertieUtility = getPropertieUtility();
        _logger.debug("MessengerApp", "=== MessengerApp initialize START ===");

        var minimumDebugLevel = _propertieUtility.getPropertyNumber("MinimalDebugLevel", 0);

        if (minimumDebugLevel != null) {
            _logger.info(
                "MessengerApp",
                "=== Retrieved minimum debuglevel from properties: " + minimumDebugLevel
            );
        } else {
            _logger.info(
                "MessengerApp",
                "=== No minimum debuglevel property found, defaulting to 0 (LEVEL_TRACE)"
            );
            minimumDebugLevel = 0;
        }

        _logger.setMinLevel(minimumDebugLevel);
        _logger.info("MessengerApp", "=== Set minimum debuglevel ===" + minimumDebugLevel);

        _logger.debug("MessengerApp", "=== Creating MessageManager ===");
        _messageManager = getMessageManager();

        _logger.debug("MessengerApp", "=== MessengerApp initialize COMPLETE ===");
    }

    function onStart(state as Lang.Dictionary?) as Void
    {
        _logger.debug("MessengerApp", "=== onStart ===");
        _heartbeatTimer = new Timer.Timer();

        // Register for communication events
        Communications.registerForPhoneAppMessages(method(: onPhoneAppMessage));

        // Request initial sync from phone
        _messageManager.updateConnectionStatus(MessageManager.STATUS_CONNECTING);

        _heartbeatTimer.start(method(: onHeartbeat), 1000, true);
    }

    // Use manually tracked view
    function onHeartbeat() as Void
    {
        // Update the current display
        WatchUi.requestUpdate();
    }

    function onSettingsChanged()
    {
        _logger.info("MessengerApp", "=== Settings changed by user ===");

        // 1. Update the IsCustomProfile logic
        var profile = Application.Properties.getValue("ColorProfile");
        // If profile is 4 (Custom), set the hidden property to true
        Application.Properties.setValue("IsCustomProfile", profile == 4);

        // 2. Tell the active views to refresh their colors/settings
        // Since we use Singletons, we can call them directly
        new AnalogView().updateSettings();

        // 3. Force a UI refresh
        WatchUi.requestUpdate();
    }

    function onStop(state as Lang.Dictionary?) as Void
    {
        _logger.debug("MessengerApp", "=== onStop ===");

        // Unregister communication events
        Communications.registerForPhoneAppMessages(null);
    }

    function getInitialView() as [WatchUi.Views] or[WatchUi.Views, WatchUi.InputDelegates]
    {
        _logger.debug("MessengerApp", "=== getInitialView START ===");

        try {
            var defaultView = Application.Properties.getValue("DefaultView");
            _logger.debug("MessengerApp", "DefaultView: " + defaultView);

            if (defaultView == null) {
                defaultView = 0;  // Default to Clock view
            }

            switch (defaultView) {
                case 0:
                    _logger.debug("MessengerApp", "=== Returning MessagesView ===");
                    var messageView = new MessagesView(getMessageManager());
                    return ([
                        messageView, new MessagesViewDelegate(messageView)
                    ] as [WatchUi.Views, WatchUi.InputDelegates]);

                case 1:
                    _logger.debug("MessengerApp", "=== Returning ClockView ===");

                    return ([
                        new ClockView(getMessageManager()), new ClockViewDelegate()
                    ] as [WatchUi.Views, WatchUi.InputDelegates]);

                case 2:
                    _logger.debug("MessengerApp", "=== Returning AnalogView ===");

                    return ([
                        new AnalogView(), new AnalogViewDelegate()
                    ] as [WatchUi.Views, WatchUi.InputDelegates]);

                default:
                    _logger.debug("MessengerApp", "=== Returning default MessagesView ===");
                    var messageView1 = new MessagesView(getMessageManager());
                    return ([
                        messageView1, new MessagesViewDelegate(messageView1)
                    ] as [WatchUi.Views, WatchUi.InputDelegates]);
            }

        } catch (ex) {
            _logger.debug("MessengerApp", "ERROR in getInitialView: " + ex.getErrorMessage());
            // Return a minimal view as fallback
            _logger.debug("MessengerApp", "=== Returning MessagesView as fallback ===");
            var messageView = new MessagesView(getMessageManager());
            return ([
                messageView, new MessagesViewDelegate(messageView)
            ] as [WatchUi.Views, WatchUi.InputDelegates]);
        }
    }

    function onPhoneAppMessage(msg as Communications.PhoneAppMessage) as Void
    {
        getLogger().info("MessengerApp", "Received message from phone");

        // Mark as connected when we receive any message
        _messageManager.updateConnectionStatus(MessageManager.STATUS_CONNECTED);

        // Handle incoming messages from phone
        _messageManager.handlePhoneMessage(msg);

        // Update display
        WatchUi.requestUpdate();
    }
}

function getApp() as MessengerApp
{
    return Application.getApp() as MessengerApp;
}