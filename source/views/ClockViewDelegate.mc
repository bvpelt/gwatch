using Toybox.WatchUi;
using Toybox.Lang;

class ClockViewDelegate extends WatchUi.BehaviorDelegate
{
    private var _logger;

    function initialize()
    {
        BehaviorDelegate.initialize();
        _logger = getLogger();

        _logger.debug("ClockViewDelegate",
                      "=== ClockViewDelegate initialized with default view: ClockView");
    }

    function onSwipe(swipeEvent as WatchUi.SwipeEvent) as Lang.Boolean
    {
        var direction = swipeEvent.getDirection();

        if (direction == WatchUi.SWIPE_LEFT) {
            _logger.debug("ClockViewDelegate", "Swipe - switching to Message view");

            var messageView = new MessagesView(getMessageManager());
            WatchUi.switchToView(messageView, new MessagesViewDelegate(messageView),
                                 WatchUi.SLIDE_LEFT);

            return true;
        } else if (direction == WatchUi.SWIPE_RIGHT) {
            _logger.debug("ClockViewDelegate", "Swipe - switching to Analog view");

            WatchUi.switchToView(new AnalogView(), new AnalogViewDelegate(), WatchUi.SLIDE_RIGHT);
            return true;
        }
        return false;
    }
}