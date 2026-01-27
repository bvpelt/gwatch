using Toybox.WatchUi;
using Toybox.Graphics;
using Toybox.System;
using Toybox.Lang;
using Toybox.Time;
using Toybox.Time.Gregorian;

class ClockViewbvp extends WatchUi.View
{
    private static var _instance as ClockViewbvp ? ;
    private var _messageManager;
    private var logger;

    // Private constructor
    private function initialize (messageManager as MessageManager)
    {
        logger = getLogger ();
        View.initialize ();
        _messageManager = messageManager;
        logger.debug ("ClockViewbvp", "=== ClockViewbvp initialized ===");
    }

    // Get singleton instance
    static function getInstance () as ClockViewbvp
    {
        if (_instance == null) {
            _instance = new ClockViewbvp (getMessageManager ());
        }
        return _instance;
    }

    function onLayout (dc as Graphics.Dc) as Void
    {
        logger.debug ("ClockView", "=== ClockView onLayout ===");
    }

    function onUpdateHeartbeat ()
    {
        WatchUi.requestUpdate ();
    }

    function onShow () as Void
    {
        logger.debug ("ClockView", "=== ClockView onShow ===");
    }

    // This is called when the view is hidden/closed
    function onHide ()
    {
        logger.debug ("ClockView", "=== ClockView onHide ===");
    }

    function onUpdate (dc as Graphics.Dc) as Void
    {
        logger.trace ("ClockView", "=== ClockView onUpdate ===");
        var width = dc.getWidth ();
        var height = dc.getHeight ();

        // Clear screen
        dc.setColor (Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear ();

        // Draw time
        var clockTime = System.getClockTime ();
        var timeString = Lang.format ("$1$:$2$", [
            clockTime.hour.format ("%02d"),
            clockTime.min.format ("%02d"),
        ]);

        dc.setColor (Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText (width / 2, height / 3, Graphics.FONT_NUMBER_HOT, timeString,
                     Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

        // Draw seconds
        dc.drawText (width / 2, height / 2, Graphics.FONT_MEDIUM, clockTime.sec.format ("%02d"),
                     Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

        // Draw date
        var now = Gregorian.info (Time.now (), Time.FORMAT_MEDIUM);
        var dateString = Lang.format ("$1$ $2$ $3$", [
            now.day_of_week,
            now.day,
            now.month,
        ]);

        dc.drawText (width / 2, (height * 2) / 3, Graphics.FONT_SMALL, dateString,
                     Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

        // Draw message count indicator
        var messageCount = _messageManager.getMessages ().size ();
        if (messageCount > 0) {
            dc.setColor (Graphics.COLOR_BLUE, Graphics.COLOR_TRANSPARENT);
            dc.fillCircle (width - 20, 20, 10);

            dc.setColor (Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
            dc.drawText (width - 20, 20, Graphics.FONT_XTINY, messageCount.toString (),
                         Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        }

        // Draw connection status
        drawConnectionStatus (dc, width, height);
    }

    private function drawConnectionStatus (dc as Graphics.Dc, width as Lang.Number,
                                           height as Lang.Number) as Void
    {
        var status = _messageManager.getConnectionStatus ();
        var statusText;
        var statusColor;

        if (status == MessageManager.STATUS_CONNECTED) {
            statusText = "●";
            statusColor = Graphics.COLOR_GREEN;
        } else if (status == MessageManager.STATUS_CONNECTING) {
            statusText = "●";
            statusColor = Graphics.COLOR_YELLOW;
        } else {
            statusText = "●";
            statusColor = Graphics.COLOR_RED;
        }

        dc.setColor (statusColor, Graphics.COLOR_TRANSPARENT);
        dc.drawText (20, 20, Graphics.FONT_MEDIUM, statusText,
                     Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
    }

    function onEnterSleep () as Void {}

    function onExitSleep () as Void {}
}

// Global convenience function
function getClockViewbvp () as ClockViewbvp
{
    return ClockViewbvp.getInstance ();
}
