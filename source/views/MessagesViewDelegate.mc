using Toybox.WatchUi;
using Toybox.Lang;

class MessagesViewDelegate extends WatchUi.BehaviorDelegate
{
    private var _view;
    private var _messageManager;
    private var _logger;
    private var _analogView;
    private var _analogViewDelegate;
    private var _clockView;
    private var _clockViewDelegate;

    function initialize(view)
    {
        BehaviorDelegate.initialize();
        _logger = getLogger();
        _messageManager = getMessageManager();
        _view = view;

        _analogView = new AnalogView();
        _analogViewDelegate = new AnalogViewDelegate();

        _clockView = new ClockView(getMessageManager());
        _clockViewDelegate = new ClockViewDelegate();

        _logger.debug("MessagesViewDelegate",
                      "=== MessagesViewDelegate initialized with default view: MessagesView");
    }

    function onNextPage()
    {
        /* //_view.scrollDown (); // Specific to MessagesView */
        _view.scroll(-1);
        return true;
    }

    function onPreviousPage()
    {
        // Scroll up through messages
        _view.scroll(+1);
        return true;
    }

    // Start button - go to AnalogView (replaces swipe left)
    // From Messages: go to Analog
    function onSelect()
    {
        WatchUi.switchToView(_analogView, _analogViewDelegate, WatchUi.SLIDE_LEFT);
        return true;
    }

    // Back button - go to ClockView (replaces swipe right)
    // From Messages: go to Clock
    function onBack()
    {
        WatchUi.switchToView(_clockView, _clockViewDelegate, WatchUi.SLIDE_RIGHT);
        return true;
    }

    function onSwipe(swipeEvent as WatchUi.SwipeEvent) as Lang.Boolean
    {
        var direction = swipeEvent.getDirection();

        // swipe left -> AnalogView (2)
        // swipe right -> ClockView (1)
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
            WatchUi.switchToView(_analogView, _analogViewDelegate, WatchUi.SLIDE_LEFT);
            return true;
        } else if (direction == WatchUi.SWIPE_RIGHT) {
            _logger.debug("MessagesViewDelegate", "Swipe right - switching to Clock view");
            WatchUi.switchToView(_clockView, _clockViewDelegate, WatchUi.SLIDE_RIGHT);
            return true;
        }
        return false;
    }

    function onKey(keyEvent as WatchUi.KeyEvent) as Lang.Boolean
    {
        var key = keyEvent.getKey();

        if (key == WatchUi.KEY_ENTER || key == WatchUi.KEY_START) {
            // Add a test message when Enter or Start button is pressed
            _messageManager.addTestMessage();
            WatchUi.requestUpdate();
            return true;
        } else if (key == WatchUi.KEY_ESC || key == WatchUi.KEY_LAP) {
            // Clear messages when Escape or Lap button is pressed
            _messageManager.clearMessages();
            WatchUi.requestUpdate();
            return true;
        } else if (key == WatchUi.KEY_UP) {
            // Scroll up in messages view

            var currentView = WatchUi.getCurrentView();
            if (currentView[0] instanceof MessagesView) {
                (currentView[0] as MessagesView).scroll(-1);
                return true;
            }
        } else if (key == WatchUi.KEY_DOWN) {
            // Scroll down in messages view

            var currentView = WatchUi.getCurrentView();
            if (currentView[0] instanceof MessagesView) {
                (currentView[0] as MessagesView).scroll(1);
                return true;
            }
        }

        return false;
    }
}