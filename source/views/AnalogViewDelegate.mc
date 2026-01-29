using Toybox.WatchUi;
using Toybox.Lang;

class AnalogViewDelegate extends WatchUi.BehaviorDelegate {
  private var _logger;

  function initialize() {
    BehaviorDelegate.initialize();
    _logger = getLogger();

    _logger.debug(
        "AnalogViewDelegate",
        "=== AnalogViewDelegate initialized with default view: AnalogView");
  }


  // ============================================================
  // PREVIOUS VIEW (ENTER long press)
  // Works on button-only devices
  // ============================================================

  function onSelectHold() {
    _logger.debug("AnalogViewDelegate", "onSelectHold → PREVIOUS view");

    goPreviousView();
    return true;
  }


  // ============================================================
  // NEXT VIEW (BACK short press)
  // ESC always maps here on simulator + devices
  // ============================================================

  function onBack() {
    _logger.debug("AnalogViewDelegate", "onBack → NEXT view");

    goNextView();
    return true;
  }

  /*
      // Enter long - go to MessagesView / swipe right
      function onSelectHold()
      {
          var messagesView = new MessagesView(getMessageManager());
          _logger.debug("AnalogViewDelegate", "Enter - switching to MessagesView
     view");

          WatchUi.switchToView(messagesView, new
     MessagesViewDelegate(messagesView), WatchUi.SLIDE_RIGHT); return true;
      }

      // Back button - go to ClockView / swipe left
      function onBack()
      {
          _logger.debug("AnalogViewDelegate", "Back - switching to Clock view");
          WatchUi.switchToView(new ClockView(getMessageManager()), new
     ClockViewDelegate(), WatchUi.SLIDE_LEFT); return true;
      }
  */

  function onSwipe(swipeEvent as WatchUi.SwipeEvent) as Lang.Boolean {
    var direction = swipeEvent.getDirection();

    if (direction == WatchUi.SWIPE_LEFT) {
      _logger.debug("AnalogViewDelegate", "Swipe - switching to Clock view");

      /*
                  WatchUi.switchToView(new ClockView(getMessageManager()), new
         ClockViewDelegate(), WatchUi.SLIDE_LEFT);
                                       */
      goPreviousView();
      return true;
    } else if (direction == WatchUi.SWIPE_RIGHT) {
      _logger.debug("AnalogViewDelegate", "Swipe - switching to Messages view");
      /*
      var messageView = new MessagesView(getMessageManager());
      WatchUi.switchToView(messageView, new MessagesViewDelegate(messageView),
                           WatchUi.SLIDE_RIGHT);
                           */
      goNextView();
      return true;
    }

    return false;
  }

  // ============================================================
  // NAVIGATION HELPERS (keep logic clean)
  // ============================================================

  private function goNextView() {
    _logger.debug("AnalogViewDelegate", "Switching to (next) Messages view");

    var messageView = new MessagesView(getMessageManager());
    WatchUi.switchToView(
        messageView, new MessagesViewDelegate(messageView),
        WatchUi.SLIDE_RIGHT);
    return true;
  }

  private function goPreviousView() {
    _logger.debug("AnalogViewDelegate", "Switching to (previous) Clock view");
    WatchUi.switchToView(
        new ClockView(getMessageManager()), new ClockViewDelegate(),
        WatchUi.SLIDE_LEFT);
    return true;
  }
}