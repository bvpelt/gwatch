using Toybox.WatchUi;

class MessagesViewDelegate extends WatchUi.BehaviorDelegate
{
    private var _view;
    private var _messageManager;
    private var _logger;

    function initialize (view)
    {
        BehaviorDelegate.initialize ();
        _logger = getLogger ();
        _messageManager = getMessageManager ();
        _view = view;

        _logger.debug ("MessagesViewDelegate",
                       "=== MessagesViewDelegate initialized with default view: MessagesView");
    }

    function onNextPage ()
    {
        _view.scrollDown (); // Specific to MessagesView
        return true;
    }
}