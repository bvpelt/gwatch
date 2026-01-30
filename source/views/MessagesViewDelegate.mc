using Toybox.WatchUi;
using Toybox.Lang;

class MessagesViewDelegate extends WatchUi
.BehaviorDelegate
{
    private var _view;
    private var _logger;

    function initialize(view as MessagesView)
    {
        BehaviorDelegate.initialize();
        _logger = getLogger();
        _view = view;

        _logger.debug(
            "MessagesViewDelegate",
            "=== MessagesViewDelegate initialized with default view: MessagesView"
        );
    }

    // ============================================================
    // SCROLLING (works everywhere)
    // ============================================================

    function onNextPage()
    {
        _logger.debug("MessagesViewDelegate", "onNextPage → scroll up");
        _view.scroll(-1);
        return true;
    }

    function onPreviousPage()
    {
        _logger.debug("MessagesViewDelegate", "onPreviousPage → scroll down");
        _view.scroll(1);
        return true;
    }

    // ============================================================
    // PRIMARY ACTION (ENTER short press)
    // ============================================================

    function onSelect()
    {
        _logger.debug("MessagesViewDelegate", "onSelect → add test message");

        getMessageManager().addTestMessage();
        WatchUi.requestUpdate();

        return true;
    }

    // ============================================================
    // PREVIOUS VIEW (ENTER long press)
    // Works on button-only devices
    // ============================================================

    function onSelectHold()
    {
        _logger.debug("MessagesViewDelegate", "onSelectHold → PREVIOUS view");

        goPreviousView();
        return true;
    }

    // ============================================================
    // NEXT VIEW (BACK short press)
    // ESC always maps here on simulator + devices
    // ============================================================

    function onBack()
    {
        _logger.debug("MessagesViewDelegate", "onBack → NEXT view");

        goNextView();
        return true;
    }

    // ============================================================
    // SECONDARY ACTION (BACK long press)
    // Clear messages everywhere
    // ============================================================

    function onBackHold()
    {
        _logger.debug("MessagesViewDelegate", "onBackHold → clear messages");

        getMessageManager().clearMessages();
        WatchUi.requestUpdate();

        return true;
    }

    function onSwipe(swipeEvent as WatchUi.SwipeEvent) as Lang.Boolean
    {
        var direction = swipeEvent.getDirection();
        // var view = WatchUi.getCurrentView();
        _logger.debug("MessagesViewDelegate", "Received swipe, direction: " + direction.toString());

        if (direction == WatchUi.SWIPE_UP) {
            // Scroll up (show older messages)
            _logger.debug("MessagesViewDelegate", "Scrolling up in messages");
            onNextPage();
            //_view.scroll(-1);
            return true;
        } else if (direction == WatchUi.SWIPE_DOWN) {
            // Scroll down (show newer messages)
            _logger.debug("MessagesViewDelegate", "Scrolling down in messages");
            onPreviousPage();
            //_view.scroll(1);
            return true;
        } else if (direction == WatchUi.SWIPE_LEFT) {
            _logger.debug("MessagesViewDelegate", "Swipe left");
            goPreviousView();
            return true;
        } else if (direction == WatchUi.SWIPE_RIGHT) {
            _logger.debug("MessagesViewDelegate", "Swipe right");
            goNextView();
            return true;
        }
        return false;
    }

    // ============================================================
    // DO NOT USE onKey() FOR ENTER OR ESC
    // Only for extra hardware keys if needed
    // ============================================================

    function onKey(evt as WatchUi.KeyEvent) as Lang.Boolean
    {
        var key = evt.getKey();
        _logger.debug("MessagesViewDelegate", "onKey → " + key);

        // Example: LAP button for debug
        if (key == WatchUi.KEY_LAP) {
            _logger.debug("MessagesViewDelegate", "LAP pressed → debug action");
            return true;
        }

        return false;
    }

    // ============================================================
    // NAVIGATION HELPERS (keep logic clean)
    // ============================================================

    private function goNextView()
    {
        _logger.debug("MessagesViewDelegate", "Switching to (next) Clock view");

        WatchUi.switchToView(
            new ClockView(getMessageManager()), new ClockViewDelegate(), WatchUi.SLIDE_RIGHT
        );
    }

    private function goPreviousView()
    {
        _logger.debug("MessagesViewDelegate", "Switching to (previous) Analog view");

        WatchUi.switchToView(getAnalogView(), new AnalogViewDelegate(), WatchUi.SLIDE_LEFT);
        return true;
    }
}