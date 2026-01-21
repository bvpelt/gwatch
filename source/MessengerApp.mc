using Toybox.Application;
using Toybox.Lang;
using Toybox.WatchUi;
using Toybox.Communications;

class MessengerApp extends Application.AppBase {
  private var _clockView;
  private var _analogView;
  private var _messagesView;
  private var _messageManager;
  private var _heartbeatTimer;
  private var _delegate;
  private var logger;
  private var propertieUtility;
  private var currentView;

  function initialize() {
    logger = getLogger();
    propertieUtility = getPropertieUtility();
    logger.debug("MessengerApp", "=== MessengerApp initialize START ===");

    var minimumDebugLevel = propertieUtility.getPropertyNumber(
      "MinimalDebugLevel",
      0
    );

    if (minimumDebugLevel != null) {
      logger.info(
        "MessengerApp",
        "=== Retrieved minimum debuglevel from properties: " + minimumDebugLevel
      );
    } else {
      logger.info(
        "MessengerApp",
        "=== No minimum debuglevel property found, defaulting to 0 (LEVEL_TRACE)"
      );
      minimumDebugLevel = 0;
    }

    logger.setMinLevel(minimumDebugLevel);
    logger.info(
      "MessengerApp",
      "=== Set minimum debuglevel ===" + minimumDebugLevel
    );

    AppBase.initialize();
    logger.debug("MessengerApp", "=== Creating MessageManager ===");
    _messageManager = getMessageManager();
    logger.debug("MessengerApp", "=== MessengerApp initialize COMPLETE ===");
  }

  function onStart(state as Lang.Dictionary?) as Void {
    logger.debug("MessengerApp", "=== onStart ===");
    _heartbeatTimer = new Timer.Timer();

    // Register for communication events
    Communications.registerForPhoneAppMessages(method(:onPhoneAppMessage));

    // Request initial sync from phone
    _messageManager.updateConnectionStatus(MessageManager.STATUS_CONNECTING);

    _heartbeatTimer.start(method(:onHeartbeat), 1000, true);
  }

  function onHeartbeat() as Void {
    var currentView = WatchUi.getCurrentView()[0];

    // Check if the current view wants a heartbeat
    if (currentView != null && currentView has :onUpdateHeartbeat) {
      currentView.onUpdateHeartbeat();
    }
  }

  function onSettingsChanged() {
    logger.info("MessengerApp", "=== Settings changed by user ===");

    // 1. Update the IsCustomProfile logic
    var profile = Application.Properties.getValue("ColorProfile");
    // If profile is 4 (Custom), set the hidden property to true
    Application.Properties.setValue("IsCustomProfile", profile == 4);

    // 2. Tell the active views to refresh their colors/settings
    // Since we use Singletons, we can call them directly
    getAnalogView().updateSettings();

    // 3. Force a UI refresh
    WatchUi.requestUpdate();
  }

  function onStop(state as Lang.Dictionary?) as Void {
    logger.debug("MessengerApp", "=== onStop ===");

    // Unregister communication events
    Communications.registerForPhoneAppMessages(null);
  }

  function getInitialView() as [WatchUi.Views] or
    [WatchUi.Views, WatchUi.InputDelegates] {
    logger.debug("MessengerApp", "=== getInitialView START ===");

    try {
      var defaultView = Application.Properties.getValue("DefaultView");
      logger.debug("MessengerApp", "DefaultView: " + defaultView);
      if (defaultView == null) {
        defaultView = 0; // Default to Clock view
      }
      currentView = defaultView;

      logger.debug("MessengerApp", "=== Creating AnalogView ===");
      _analogView = getAnalogView();

      logger.debug("MessengerApp", "=== Creating ClockView ===");
      _clockView = getClockView();

      logger.debug("MessengerApp", "=== Creating MessagesView ===");
      _messagesView = getMessagesView();

      logger.debug("MessengerApp", "=== Creating Delegate ===");
      _delegate = getMessengerDelegate();

      switch (currentView) {
        case 0:
          logger.debug("MessengerApp", "=== Returning MessagesView ===");
          return (
            [_messagesView, _delegate] as
            [WatchUi.Views, WatchUi.InputDelegates]
          );

        case 1:
          logger.debug("MessengerApp", "=== Returning ClockView ===");
          return (
            [_clockView, _delegate] as [WatchUi.Views, WatchUi.InputDelegates]
          );

        case 2:
          logger.debug("MessengerApp", "=== Returning AnalogView ===");
          return (
            [_analogView, _delegate] as [WatchUi.Views, WatchUi.InputDelegates]
          );

        default:
          logger.debug("MessengerApp", "=== Returning MessagesView ===");
          return (
            [_messagesView, _delegate] as
            [WatchUi.Views, WatchUi.InputDelegates]
          );
      }
    } catch (ex) {
      logger.debug(
        "MessengerApp",
        "ERROR in getInitialView: " + ex.getErrorMessage()
      );
      // Return a minimal view as fallback
      return (
        [getClockView(), getMessengerDelegate()] as
        [WatchUi.Views, WatchUi.InputDelegates]
      );
    }
  }

  function onPhoneAppMessage(msg as Communications.PhoneAppMessage) as Void {
    getLogger().info("MessengerApp", "Received message from phone");

    // Mark as connected when we receive any message
    _messageManager.updateConnectionStatus(MessageManager.STATUS_CONNECTED);

    // Handle incoming messages from phone
    _messageManager.handlePhoneMessage(msg);

    // Update display
    WatchUi.requestUpdate();
  }

  function onPhoneAppMessagexx(msg as Communications.PhoneAppMessage) as Void {
    _messageManager.handlePhoneMessage(msg);
    WatchUi.requestUpdate();
  }
}

function getApp() as MessengerApp {
  return Application.getApp() as MessengerApp;
}
