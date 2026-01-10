using Toybox.Application;
using Toybox.Lang;
using Toybox.WatchUi;
using Toybox.Communications;

class MessengerApp extends Application.AppBase {
  private var _clockView;
  private var _messagesView;
  private var _messageManager;

  function initialize() {
    getLogger().debug("=== MessengerApp initialize START ===");
    AppBase.initialize();
    getLogger().debug("=== Creating MessageManager ===");
    _messageManager = new MessageManager();
    getLogger().debug("=== MessengerApp initialize COMPLETE ===");
  }

  function onStart(state as Lang.Dictionary?) as Void {
    getLogger().debug("=== onStart ===");
    Communications.registerForPhoneAppMessages(method(:onPhoneAppMessage));
  }

  function onStop(state as Lang.Dictionary?) as Void {
    getLogger().debug("=== onStop ===");
    Communications.registerForPhoneAppMessages(null);
  }

  function getInitialView() as [WatchUi.Views] or
    [WatchUi.Views, WatchUi.InputDelegates] {
    getLogger().debug("=== getInitialView START ===");

    try {
      var defaultView = Application.Properties.getValue("DefaultView");
      getLogger().debug("DefaultView: " + defaultView);

      if (defaultView == null) {
        defaultView = 0; // Default to Clock view
      }

      getLogger().debug("=== Creating ClockView ===");
      _clockView = new ClockView(_messageManager);

      getLogger().debug("=== Creating MessagesView ===");
      _messagesView = new MessagesView(_messageManager);

      getLogger().debug("=== Creating Delegate ===");
      var delegate = new MessengerDelegate(_messageManager);

      if (defaultView == 1) {
        getLogger().debug("=== Returning MessagesView ===");
        return (
          [_messagesView, delegate] as [WatchUi.Views, WatchUi.InputDelegates]
        );
      } else {
        getLogger().debug("=== Returning ClockView ===");
        return (
          [_clockView, delegate] as [WatchUi.Views, WatchUi.InputDelegates]
        );
      }
    } catch (ex) {
      getLogger().debug("ERROR in getInitialView: " + ex.getErrorMessage());
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
