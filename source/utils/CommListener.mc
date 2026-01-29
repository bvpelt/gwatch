using Toybox.Communications;

class CommListener extends Communications.ConnectionListener
{
    private var _logger;

    function initialize()
    {
        _logger = getLogger();
        ConnectionListener.initialize();
    }

    function onComplete() as Void
    {
        _logger.debug("MessageManager", "Transmit complete");
    }

    function onError() as Void
    {
        _logger.debug("MessageManager", "Transmit error");
    }
}
