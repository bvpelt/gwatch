using Toybox.WatchUi;
using Toybox.Lang;

class ClockViewDelegate extends WatchUi
.BehaviorDelegate
{
    private var _logger;

    function initialize()
    {
        BehaviorDelegate.initialize();
        _logger = getLogger();

        _logger.debug(
            "ClockViewDelegate", "=== ClockViewDelegate initialized with default view: ClockView"
        );
    }

    // ============================================================
    // PREVIOUS VIEW (ENTER long press)
    // Works on button-only devices
    // ============================================================

    function onSelectHold()
    {
        _logger.debug("ClockViewDelegate", "onSelectHold → PREVIOUS view");

        goPreviousView();
        return true;
    }

    // ============================================================
    // NEXT VIEW (BACK short press)
    // ESC always maps here on simulator + devices
    // ============================================================

    function onBack()
    {
        _logger.debug("ClockViewDelegate", "onBack → NEXT view");

        goNextView();
        return true;
    }

    function onSwipe(swipeEvent as WatchUi.SwipeEvent) as Lang.Boolean
    {
        var direction = swipeEvent.getDirection();

        if (direction == WatchUi.SWIPE_LEFT) {
            _logger.debug("ClockViewDelegate", "Swipe - switching to Message view");
            /*
                        var messageView = new MessagesView(getMessageManager());
                        WatchUi.switchToView(messageView, new
               MessagesViewDelegate(messageView), WatchUi.SLIDE_LEFT);
            */
            goPreviousView();
            return true;
        } else if (direction == WatchUi.SWIPE_RIGHT) {
            _logger.debug("ClockViewDelegate", "Swipe - switching to Analog view");

            // WatchUi.switchToView(new AnalogView(), new AnalogViewDelegate(),
            // WatchUi.SLIDE_RIGHT);

            goNextView();
            return true;
        }
        return false;
    }

    // ============================================================
    // NAVIGATION HELPERS (keep logic clean)
    // ============================================================

    private function goNextView()
    {
        _logger.debug("ClockViewDelegate", "Switching to (next) Analog view");

        WatchUi.switchToView(new AnalogView(), new AnalogViewDelegate(), WatchUi.SLIDE_RIGHT);
        return true;
    }

    private function goPreviousView()
    {
        _logger.debug("ClockViewDelegate", "Switching to (previous) Messages view");
        var messageView = new MessagesView(getMessageManager());
        WatchUi.switchToView(
            messageView, new MessagesViewDelegate(messageView), WatchUi.SLIDE_LEFT
        );
        return true;
    }
}