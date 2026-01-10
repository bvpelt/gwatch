using Toybox.Application;
using Toybox.Lang;
using Toybox.WatchUi;
using Toybox.Communications;

class MessengerApp extends Application.AppBase {
  private var _clockView;
  private var _messagesView;
  private var _messageManager;

  function initialize() {
    getLogger().debug("MessengerApp", "=== MessengerApp initialize START ===");
    AppBase.initialize();
    getLogger().debug("MessengerApp", "=== Creating MessageManager ===");
    _messageManager = new MessageManager();
    getLogger().debug(
      "MessengerApp",
      "=== MessengerApp initialize COMPLETE ==="
    );
  }

  function onStart(state as Lang.Dictionary?) as Void {
    getLogger().debug("MessengerApp", "=== onStart ===");
    // Register for communication events
    Communications.registerForPhoneAppMessages(method(:onPhoneAppMessage));

    // Request initial sync from phone
    _messageManager.updateConnectionStatus(MessageManager.STATUS_CONNECTING);
    _messageManager.requestSync();
  }

  function onStop(state as Lang.Dictionary?) as Void {
    getLogger().debug("MessengerApp", "=== onStop ===");

    // Unregister communication events
    Communications.registerForPhoneAppMessages(null);
  }

  function getInitialView() as [WatchUi.Views] or
    [WatchUi.Views, WatchUi.InputDelegates] {
    getLogger().debug("MessengerApp", "=== getInitialView START ===");

    try {
      var defaultView = Application.Properties.getValue("DefaultView");
      getLogger().debug("MessengerApp", "DefaultView: " + defaultView);
      if (defaultView == null) {
        defaultView = 0; // Default to Clock view
      }

      getLogger().debug("MessengerApp", "=== Creating ClockView ===");
      _clockView = new ClockView(_messageManager);

      getLogger().debug("MessengerApp", "=== Creating MessagesView ===");
      _messagesView = new MessagesView(_messageManager);

      getLogger().debug("MessengerApp", "=== Creating Delegate ===");
      var delegate = new MessengerDelegate(_messageManager);

      if (defaultView == 1) {
        getLogger().debug("MessengerApp", "=== Returning MessagesView ===");
        return (
          [_messagesView, delegate] as [WatchUi.Views, WatchUi.InputDelegates]
        );
      } else {
        getLogger().debug("MessengerApp", "=== Returning ClockView ===");
        return (
          [_clockView, delegate] as [WatchUi.Views, WatchUi.InputDelegates]
        );
      }
    } catch (ex) {
      getLogger().debug(
        "MessengerApp",
        "ERROR in getInitialView: " + ex.getErrorMessage()
      );
      // Return a minimal view as fallback
      return (
        [
          new ClockView(_messageManager),
          new MessengerDelegate(_messageManager),
        ] as [WatchUi.Views, WatchUi.InputDelegates]
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

  function getMessageManager() as MessageManager {
    return _messageManager;
  }
}

function getApp() as MessengerApp {
  return Application.getApp() as MessengerApp;
}
