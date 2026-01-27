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
    // From Messages: go to Analog
    function onSelect()
    {
        var view = new ClockView(getMessageManager());
        var delegate = new ClockViewDelegate();
        WatchUi.switchToView(view, delegate, WatchUi.SLIDE_LEFT);
        return true;
    }

    // Back button - go to ClockView (replaces swipe right)
    // From Messages: go to Clock
    function onBack()
    {
        var view = new MessagesView(getMessageManager());
        var delegate = new MessagesViewDelegate(view);
        WatchUi.switchToView(view, delegate, WatchUi.SLIDE_RIGHT);
        return true;
    }

    function onSwipe(swipeEvent as WatchUi.SwipeEvent) as Lang.Boolean
    {
        var direction = swipeEvent.getDirection();

        // swipe left -> MessagesView (1)
        // swipe right -> AnalogView (0)
        if (direction == WatchUi.SWIPE_LEFT) {
            _logger.debug("AnalogViewDelegate", "Swipe - switching to Clock view");
            var view1 = new ClockView(getMessageManager());
            var delegate1 = new ClockViewDelegate();
            WatchUi.switchToView(view1, delegate1, WatchUi.SLIDE_LEFT);
            return true;
        } else if (direction == WatchUi.SWIPE_RIGHT) {
            _logger.debug("AnalogViewDelegate", "Swipe - switching to Messages view");
            var view2 = new MessagesView(getMessageManager());
            var delegate2 = new MessagesViewDelegate(view2);
            WatchUi.switchToView(view2, delegate2, WatchUi.SLIDE_RIGHT);
            return true;
        }

        return false;
    }
}