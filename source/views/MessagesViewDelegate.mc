using Toybox.WatchUi;
using Toybox.Lang;

class MessagesViewDelegate extends WatchUi.BehaviorDelegate
{
    private var _view;
    //   private var _messageManager;
    private var _logger;

    function initialize (view)
    {
        BehaviorDelegate.initialize ();
        _logger = getLogger ();
        //       _messageManager = getMessageManager ();
        _view = view;

        _logger.debug ("MessagesViewDelegate",
                       "=== MessagesViewDelegate initialized with default view: MessagesView");
    }

    function onNextPage ()
    {
        /* //_view.scrollDown (); // Specific to MessagesView */
        _view.scroll (-1);
        return true;
    }

    function onPreviousPage ()
    {
        // Scroll up through messages
        _view.scroll (+1);
        return true;
    }

    // Start button - go to AnalogView (replaces swipe left)
    // From Messages: go to Analog
    function onSelect ()
    {
        var view = new AnalogView ();
        var delegate = new AnalogViewDelegate (view);
        WatchUi.switchToView (view, delegate, WatchUi.SLIDE_LEFT);
        return true;
    }

    // Back button - go to ClockView (replaces swipe right)
    // From Messages: go to Clock
    function onBack ()
    {
        var view = new ClockView (getMessageManager ());
        var delegate = new ClockViewDelegate (view);

        WatchUi.switchToView (view, delegate, WatchUi.SLIDE_RIGHT);
        return true;
    }

    function onSwipe (swipeEvent as WatchUi.SwipeEvent) as Lang.Boolean
    {
        var direction = swipeEvent.getDirection ();

        // swipe left -> AnalogView (2)
        // swipe right -> ClockView (1)
        if (direction == WatchUi.SWIPE_UP) {
            // Scroll up (show older messages)
            _logger.debug ("MessagesViewDelegate", "Scrolling up in messages");
            _view.scroll (-1);
            return true;
        } else if (direction == WatchUi.SWIPE_DOWN) {
            // Scroll down (show newer messages)
            _logger.debug ("MessagesViewDelegate", "Scrolling down in messages");
            _view.scroll (1);
            return true;
        } else if (direction == WatchUi.SWIPE_LEFT) {
            // Switch to clock view
            _logger.debug ("MessagesViewDelegate", "Swipe left - switching to Analog view");
            var view = new AnalogView ();
            var delegate = new AnalogViewDelegate (view);
            WatchUi.switchToView (view, delegate, WatchUi.SLIDE_LEFT);
            return true;
        } else if (direction == WatchUi.SWIPE_RIGHT) {
            _logger.debug ("MessagesViewDelegate", "Swipe right - switching to Analog view");
            var view = new ClockView (getMessageManager ());
            var delegate = new ClockViewDelegate (view);
            WatchUi.switchToView (view, delegate, WatchUi.SLIDE_RIGHT);
            return true;
        }
        return false;
    }
}