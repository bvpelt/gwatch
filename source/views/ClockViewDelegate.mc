using Toybox.WatchUi;
using Toybox.Lang;

class ClockViewDelegate extends WatchUi.BehaviorDelegate
{
    private var _analogView;
    private var _analogViewDelegate;
    private var _messagesView;
    private var _messagesViewDelegate;

    private var _logger;

    function initialize()
    {
        BehaviorDelegate.initialize();
        _logger = getLogger();

        _analogView = new AnalogView();
        _analogViewDelegate = new AnalogViewDelegate();

        _messagesView = new MessagesView(getMessageManager());
        _messagesViewDelegate = new MessagesViewDelegate(_messagesView);

        _logger.debug("ClockViewDelegate",
                      "=== ClockViewDelegate initialized with default view: ClockView");
    }

    function onSwipe(swipeEvent as WatchUi.SwipeEvent) as Lang.Boolean
    {
        var direction = swipeEvent.getDirection();

        if (direction == WatchUi.SWIPE_LEFT) {
            _logger.debug("ClockViewDelegate", "Swipe - switching to Message view");

            WatchUi.switchToView(_messagesView, _messagesViewDelegate, WatchUi.SLIDE_LEFT);

            return true;
        } else if (direction == WatchUi.SWIPE_RIGHT) {
            _logger.debug("ClockViewDelegate", "Swipe - switching to Analog view");

            WatchUi.switchToView(_analogView, _analogViewDelegate, WatchUi.SLIDE_RIGHT);
            return true;
        }
        return false;
    }
}