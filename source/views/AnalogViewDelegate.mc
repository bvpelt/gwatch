using Toybox.WatchUi;
using Toybox.Lang;

class AnalogViewDelegate extends WatchUi.BehaviorDelegate
{
    private var _logger;

    function initialize()
    {
        BehaviorDelegate.initialize();
        _logger = getLogger();

        _logger.debug("AnalogViewDelegate",
                      "=== AnalogViewDelegate initialized with default view: AnalogView");
    }

    // Start button - go to AnalogView (replaces swipe left)
    function onSelect()
    {
        WatchUi.switchToView(new ClockView(getMessageManager()), new ClockViewDelegate(),
                             WatchUi.SLIDE_LEFT);
        return true;
    }

    // Back button - go to ClockView (replaces swipe right)
    function onBack()
    {
        var messageView = new MessagesView(getMessageManager());
        WatchUi.switchToView(messageView, new MessagesViewDelegate(messageView),
                             WatchUi.SLIDE_RIGHT);
        return true;
    }

    function onSwipe(swipeEvent as WatchUi.SwipeEvent) as Lang.Boolean
    {
        var direction = swipeEvent.getDirection();

        if (direction == WatchUi.SWIPE_LEFT) {
            _logger.debug("AnalogViewDelegate", "Swipe - switching to Clock view");

            WatchUi.switchToView(new ClockView(getMessageManager()), new ClockViewDelegate(),
                                 WatchUi.SLIDE_LEFT);
            return true;
        } else if (direction == WatchUi.SWIPE_RIGHT) {
            _logger.debug("AnalogViewDelegate", "Swipe - switching to Messages view");
            var messageView = new MessagesView(getMessageManager());
            WatchUi.switchToView(messageView, new MessagesViewDelegate(messageView),
                                 WatchUi.SLIDE_RIGHT);
            return true;
        }

        return false;
    }
}