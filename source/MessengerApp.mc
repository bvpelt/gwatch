using Toybox.Application;
using Toybox.Lang;
using Toybox.WatchUi;
using Toybox.Communications;

class MessengerApp extends Application.AppBase {
  private var _clockView;
  private var _analogView;
  private var _messagesView;
  private var _messageManager;
  private var _syncTimer;
  private var _delegate;
  private var logger;
  private var currentView;

  function getUpdateTimer() {
    if (_syncTimer == null) {
      _syncTimer = new Timer.Timer();
    }
    return _syncTimer;
  }

  function initialize() {
    logger = getLogger();
    logger.debug("MessengerApp", "=== MessengerApp initialize START ===");

    var minimumDebugLevel =
      Application.Properties.getValue("MinimalDebugLevel");
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
    // Register for communication events
    Communications.registerForPhoneAppMessages(method(:onPhoneAppMessage));

    // Request initial sync from phone
    _messageManager.updateConnectionStatus(MessageManager.STATUS_CONNECTING);

    // Delay the sync request by 3 second to let the Simulator stabilize (due to simulator startup timing issues)
    _syncTimer = getUpdateTimer();
    _syncTimer.start(method(:triggerInitialSync), 3000, false);
  }

   function cancelSyncTimer() as Void {
    if (_syncTimer != null) {
      _syncTimer.stop();
      _syncTimer = null;
      logger.debug("MessengerApp", "Sync timer cancelled for safety");
    }
  }

  function triggerInitialSync() as Void {
    logger.debug("MessengerApp", "=== Delayed Sync Triggered ===");

    // 1. FIX: Stop WHATEVER view is currently active, not just clockView
    var currentView = WatchUi.getCurrentView();
    if (currentView == null) { return; }
    if (currentView != null && currentView[0] has :stopClock) {
      currentView[0].stopClock();
    }

    // 2. Clear the screen to a blank state to stop GFX processing
    WatchUi.requestUpdate();

    // 3. Wait 200ms for GFX to settle, THEN transmit
    var settleTimer = new Timer.Timer();
    settleTimer.start(method(:executeTransmit), 500, false);
  }

  function executeTransmit() as Void {
    if (System.getDeviceSettings().phoneConnected) {
      _messageManager.requestSync();
    }

    // 4. Wait 1 second for the network burst to finish before restarting UI
    var restartTimer = new Timer.Timer();
    restartTimer.start(method(:resumeUI), 1000, false);
  }

  function resumeUI() as Void {
    if (_clockView != null) {
      _clockView.onShow();
    }
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
