using Toybox.WatchUi;
using Toybox.Lang;

class ClockViewDelegate extends WatchUi.BehaviorDelegate
{
    //    private var _view;

    private var _logger;

    function initialize (view)
    {
        BehaviorDelegate.initialize ();
        _logger = getLogger ();
        //        _view = view;

        _logger.debug ("ClockViewDelegate",
                       "=== ClockViewDelegate initialized with default view: ClockView");
    }

    function onSwipe (swipeEvent as WatchUi.SwipeEvent) as Lang.Boolean
    {
        var direction = swipeEvent.getDirection ();

        // currentWatchView == 1
        // swipe left -> MessagesView (0)
        // swipe right -> AnalogView (2)
        if (direction == WatchUi.SWIPE_LEFT) {
            _logger.debug ("ClockViewDelegate", "Swipe - switching to Message view");
            var view1 = new MessagesView (getMessageManager ());
            var delegate1 = new MessagesViewDelegate (view1);
            WatchUi.switchToView (view1, delegate1, WatchUi.SLIDE_LEFT);

            return true;
        } else if (direction == WatchUi.SWIPE_RIGHT) {
            _logger.debug ("ClockViewDelegate", "Swipe - switching to Analog view");
            var view2 = new AnalogView ();
            var delegate2 = new AnalogViewDelegate (view2);
            WatchUi.switchToView (view2, delegate2, WatchUi.SLIDE_RIGHT);
            return true;
        }
        return false;
    }
}