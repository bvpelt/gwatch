using Toybox.Application;
using Toybox.Lang;
using Toybox.WatchUi;
using Toybox.Communications;

class MessengerApp extends Application.AppBase
{
    private var _clockView;
    private var _clockViewDelegate;
    private var _analogView;
    private var _analogViewDelegate;
    private var _messagesView;
    private var _messagesViewDelegate;
    private var _messageManager;
    private var _heartbeatTimer;

    private var _logger;
    private var _propertieUtility;
    //  private var currentView;
    private var _activeView; // ADD THIS: Track active view manually

    private var _views as Lang.Array<AnalogView | ClockView> ? ;

    function initialize ()
    {
        AppBase.initialize ();
        _logger = getLogger ();
        _propertieUtility = getPropertieUtility ();
        _logger.debug ("MessengerApp", "=== MessengerApp initialize START ===");

        var minimumDebugLevel = _propertieUtility.getPropertyNumber ("MinimalDebugLevel", 0);

        if (minimumDebugLevel != null) {
            _logger.info ("MessengerApp",
                          "=== Retrieved minimum debuglevel from properties: " + minimumDebugLevel);
        } else {
            _logger.info (
                "MessengerApp",
                "=== No minimum debuglevel property found, defaulting to 0 (LEVEL_TRACE)");
            minimumDebugLevel = 0;
        }

        _logger.setMinLevel (minimumDebugLevel);
        _logger.info ("MessengerApp", "=== Set minimum debuglevel ===" + minimumDebugLevel);

        _logger.debug ("MessengerApp", "=== Creating MessageManager ===");
        _messageManager = getMessageManager ();
        _activeView = null; // ADD THIS: Initialize to null
        _logger.debug ("MessengerApp", "=== MessengerApp initialize COMPLETE ===");

        _analogView = new AnalogView ();
        _analogViewDelegate = new AnalogViewDelegate (_analogView);
        _clockView = new ClockView (getMessageManager ());
        _clockViewDelegate = new ClockViewDelegate (_clockView);
        _messagesView = new MessagesView (getMessageManager ());
        _messagesViewDelegate = new MessagesViewDelegate (_messagesView);

        _views = [] as Lang.Array<AnalogView or ClockView>;
        _views.add (_analogView);
        _views.add (_clockView);
    }

  function onStart(state as Lang.Dictionary?) as Void
  {
      _logger.debug ("MessengerApp", "=== onStart ===");
      _heartbeatTimer = new Timer.Timer ();

      // Register for communication events
      Communications.registerForPhoneAppMessages (method ( : onPhoneAppMessage));

      // Request initial sync from phone
      _messageManager.updateConnectionStatus (MessageManager.STATUS_CONNECTING);

      _heartbeatTimer.start (method ( : onHeartbeat), 1000, true);
  }

  // Use manually tracked view
  function onHeartbeat () as Void
  {
      // Check if array exists and is not empty
      if (_views != null && _views.size () > 0) {
          for (var i = 0; i < _views.size (); i++) {
              var view = _views[i];
              if (view != null && view has : onUpdateHeartbeat) {
                  view.onUpdateHeartbeat (); // or whatever method you want to call
              }
          }
      }
  }

  function onSettingsChanged ()
  {
      _logger.info ("MessengerApp", "=== Settings changed by user ===");

      // 1. Update the IsCustomProfile logic
      var profile = Application.Properties.getValue ("ColorProfile");
      // If profile is 4 (Custom), set the hidden property to true
      Application.Properties.setValue ("IsCustomProfile", profile == 4);

      // 2. Tell the active views to refresh their colors/settings
      // Since we use Singletons, we can call them directly
      _analogView.updateSettings ();

      // 3. Force a UI refresh
      WatchUi.requestUpdate ();
  }

  function onStop(state as Lang.Dictionary?) as Void
  {
      _logger.debug ("MessengerApp", "=== onStop ===");

      // Unregister communication events
      Communications.registerForPhoneAppMessages (null);
  }

  function getInitialView () as[WatchUi.Views] or[WatchUi.Views, WatchUi.InputDelegates]
  {
      _logger.debug ("MessengerApp", "=== getInitialView START ===");

      try {
          var defaultView = Application.Properties.getValue ("DefaultView");
          _logger.debug ("MessengerApp", "DefaultView: " + defaultView);

          if (defaultView == null) {
              defaultView = 0; // Default to Clock view

              // currentView = defaultView;
          }

          /*
                    _logger.debug ("MessengerApp", "=== Creating AnalogView ===");
                    _analogView = getAnalogView ();

                    _logger.debug ("MessengerApp", "=== Creating ClockView ===");
                    _clockView = getClockView ();

                    _logger.debug ("MessengerApp", "=== Creating MessagesView ===");
                    _messagesView = getMessagesView ();

                    _logger.debug ("MessengerApp", "=== Creating Delegate ===");
                    _delegate = getMessengerDelegate ();
                    */

          switch (defaultView) {
              case 0:
                  _logger.debug ("MessengerApp", "=== Returning MessagesView ===");
                  //_activeView = _messagesView; // ADD THIS: Track active view
                  return ([_messagesView,
                           _messagesViewDelegate] as[WatchUi.Views, WatchUi.InputDelegates]);

              case 1:
                  _logger.debug ("MessengerApp", "=== Returning ClockView ===");
                  //_activeView = _clockView; // ADD THIS: Track active view
                  return (
                      [_clockView, _clockViewDelegate] as[WatchUi.Views, WatchUi.InputDelegates]);

              case 2:
                  _logger.debug ("MessengerApp", "=== Returning AnalogView ===");
                  //_activeView = _analogView; // ADD THIS: Track active view

                  return (
                      [_analogView, _analogViewDelegate] as[WatchUi.Views, WatchUi.InputDelegates]);

              default:
                  _logger.debug ("MessengerApp", "=== Returning MessagesView ===");
                  //_activeView = _messagesView; // ADD THIS: Track active view

                  return ([_messagesView,
                           _messagesViewDelegate] as[WatchUi.Views, WatchUi.InputDelegates]);
          }

      } catch (ex) {
          _logger.debug ("MessengerApp", "ERROR in getInitialView: " + ex.getErrorMessage ());
          // Return a minimal view as fallback
          return ([_clockView, _clockViewDelegate] as[WatchUi.Views, WatchUi.InputDelegates]);
      }
  }

  /*
    // ADD THIS: Method to update active view when switching
    function setActiveView (view)
    {
        _activeView = view;
        _logger.debug ("MessengerApp", "=== Active view changed ===");
    }

    // ADD THIS: Getter for active view
    function getActiveView ()
    {
        return _activeView;
    }
  */

  function onPhoneAppMessage (msg as Communications.PhoneAppMessage) as Void
  {
      getLogger ().info ("MessengerApp", "Received message from phone");

      // Mark as connected when we receive any message
      _messageManager.updateConnectionStatus (MessageManager.STATUS_CONNECTED);

      // Handle incoming messages from phone
      _messageManager.handlePhoneMessage (msg);

      // Update display
      WatchUi.requestUpdate ();
  }

  function onPhoneAppMessagexx (msg as Communications.PhoneAppMessage) as Void
  {
      _messageManager.handlePhoneMessage (msg);
      WatchUi.requestUpdate ();
  }
}

function getApp () as MessengerApp
{
    return Application.getApp () as MessengerApp;
}