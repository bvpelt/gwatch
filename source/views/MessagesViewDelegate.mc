using Toybox.WatchUi;
using Toybox.Lang;

class MessagesViewDelegate extends WatchUi.BehaviorDelegate
{
    private var _view;
    private var _logger;

    function initialize(view as MessagesView)
    {
        BehaviorDelegate.initialize();
        _logger = getLogger();
        _view = view;

        _logger.debug("MessagesViewDelegate",
                      "=== MessagesViewDelegate initialized with default view: MessagesView");
    }

    function onNextPage()
    {
        _logger.debug("MessagesViewDelegate", "onNextPage called - scrolling up");
        _view.scroll(-1);
        return true;
    }

    function onPreviousPage()
    {
        _logger.debug("MessagesViewDelegate", "onPreviousPage called - scrolling down");
        _view.scroll(1);
        return true;
    }

    /*
    // Start button - go to AnalogView (replaces swipe left)
    function onSelect()
    {
        WatchUi.switchToView(new AnalogView(), new AnalogViewDelegate(), WatchUi.SLIDE_LEFT);
        return true;
    }

    // Back button - go to ClockView (replaces swipe right)
    function onBack()
    {
        WatchUi.switchToView(new ClockView(getMessageManager()), new ClockViewDelegate(),
                             WatchUi.SLIDE_RIGHT);
        return true;
    }
    */

    function onSelect()
    {
        // Add a test message when Enter or Start button is pressed
        getMessageManager().addTestMessage();
        WatchUi.requestUpdate();
        return true;
    }

    function onBack()
    {
        // Clear messages when Escape or Lap button is pressed
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
            _view.scroll(-1);
            return true;
        } else if (direction == WatchUi.SWIPE_DOWN) {
            // Scroll down (show newer messages)
            _logger.debug("MessagesViewDelegate", "Scrolling down in messages");
            _view.scroll(1);
            return true;
        } else if (direction == WatchUi.SWIPE_LEFT) {
            // Switch to clock view
            _logger.debug("MessagesViewDelegate", "Swipe left - switching to Analog view");
            WatchUi.switchToView(new AnalogView(), new AnalogViewDelegate(), WatchUi.SLIDE_LEFT);
            return true;
        } else if (direction == WatchUi.SWIPE_RIGHT) {
            _logger.debug("MessagesViewDelegate", "Swipe right - switching to Clock view");
            WatchUi.switchToView(new ClockView(getMessageManager()), new ClockViewDelegate(),
                                 WatchUi.SLIDE_RIGHT);
            return true;
        }
        return false;
    }

    /*

    function onKey(keyEvent as WatchUi.KeyEvent) as Lang.Boolean
    {
        var key = keyEvent.getKey();
        var type = keyEvent.getType();

        _logger.debug("MessagesViewDelegate", "onKey - key: " + key + ", type: " + type);

        if (key == WatchUi.KEY_ENTER || key == WatchUi.KEY_START) {
            // Add a test message when Enter or Start button is pressed
            getMessageManager().addTestMessage();
            WatchUi.requestUpdate();
            return true;
        } else if (key == WatchUi.KEY_ESC || key == WatchUi.KEY_LAP) {
            // Clear messages when Escape or Lap button is pressed
            getMessageManager().clearMessages();
            WatchUi.requestUpdate();
            return true;
        }

        return false;
    }
    */
}