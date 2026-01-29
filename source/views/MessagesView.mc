using Toybox.WatchUi;
using Toybox.Graphics;
using Toybox.System;
using Toybox.Lang;
using Toybox.Time;
using Toybox.Time.Gregorian;

class MessagesView extends WatchUi
.View
{
    private var _messageManager;
    private var _scrollOffset as Lang.Number = 0;  // number of messages
    private var _logger;

    // Constructor
    function initialize(messageManager as MessageManager)
    {
        View.initialize();
        _logger = getLogger();
        _messageManager = messageManager;
        _scrollOffset = 0;
    }

    function onLayout(dc as Graphics.Dc) as Void {}

    function onUpdate(dc as Graphics.Dc) as Void
    {
        _logger.trace("MessagesView", "=== onUpdate ===");
        var width = dc.getWidth();
        var height = dc.getHeight();
        var font = Graphics.FONT_SMALL;
        var lineY = 10 + getTextHeight(dc, font);

        // Clear screen
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();

        // Draw header
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(width / 2, 10, font, "Messages", Graphics.TEXT_JUSTIFY_CENTER);

        // Draw line separator
        dc.drawLine(0, lineY, width, lineY);

        // Draw messages
        var messages = _messageManager.getMessages();
        if (messages.size() == 0) {
            dc.drawText(
                width / 2, height / 2, font, "No Messages",
                Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
            );
        } else {
            drawMessages(dc, messages, lineY + 10, width, height);
        }

        // Draw connection status
        drawConnectionStatus(dc, width);
    }

    private function getTextHeight(dc as Graphics.Dc, font)
    {
        return dc.getFontHeight(font);
    }

    private function getLineSpacing(dc as Graphics.Dc, font)
    {
        // A line consists of
        // - line
        // - spacing
        var textHeight = getTextHeight(dc, font);
        var spacing = 5;

        return textHeight + spacing;
    }

    private function getMessageSpacing(dc as Graphics.Dc, font)
    {
        // A message consists of two lines
        // - line 1
        //  - sender + timestamp
        //  - spacing
        // - line 2
        //  - text
        //  - spacing

        return 2 * getLineSpacing(dc, font);
    }

    private function getMessageIndex(messages as Lang.Array<Lang.Dictionary>)
    {
        var maxMessages = messages.size();
        var messageIndex = 0;

        if (maxMessages > 0) {
            messageIndex = maxMessages - _scrollOffset;
        }

        _logger.trace(
            "MessagesView",
            "getMessageIndex maxMessages: " + maxMessages + " messageIndex: " + messageIndex
        );
        return messageIndex;
    }

    private function drawMessages(
        dc as Graphics.Dc, messages as Lang.Array<Lang.Dictionary>, offset as Lang.Number,
        width as Lang.Number, height as Lang.Number
    ) as Void
    {
        var font = Graphics.FONT_XTINY;
        var y = offset;  // lineHeight;
        var lineX = 35;

        _logger.trace("MessagesView", "Drawing: " + messages.size() + " messages");

        // Draw from newest (bottom of array) to oldest (top)
        if (messages.size() > 0) {
            for (var i = getMessageIndex(messages); i > 0; i--) {
                drawMessage(dc, font, messages[i - 1], lineX, y, width);
                y += getMessageSpacing(dc, font);

                if (y + getMessageSpacing(dc, font) > height) {
                    break;
                }
            }
        }

        _logger.trace("MessagesView", "drawScrollIndicators offset: " + offset);
        drawScrollIndicators(dc, offset);
    }

    private var visibleMessages = 4;

    private function drawUpArrow(dc as Graphics.Dc, y, maxMessages)
    {
        var condition = maxMessages - (visibleMessages + _scrollOffset);
        _logger.debug(
            "MessagesView",
            "drawUpArrow y: " + y + " _scrollOffset: " + _scrollOffset + " condition: " + condition
        );

        var centerX = dc.getWidth() / 2;
        // Show "more above" indicator

        if (condition > 0) {
            // Draw upward pointing triangle
            dc.fillPolygon([
                [centerX, y],          // Top point
                [centerX - 6, y + 7],  // Bottom left
                [centerX + 6, y + 7],  // Bottom right
            ]);
        }
    }

    private function drawDownArrow(dc as Graphics.Dc, y, maxMessages)
    {
        var condition = maxMessages - (_scrollOffset + visibleMessages);
        _logger.debug(
            "MessagesView",
            "drawDownArrow y: " + y + " _scrollOffset: " + _scrollOffset +
                " condition: " + condition
        );

        var centerX = dc.getWidth() / 2;

        if (condition > 0) {
            // Draw downward pointing triangle
            dc.fillPolygon([
                [centerX, y + 7],  // Bottom point
                [centerX - 6, y],  // Top left
                [centerX + 6, y],  // Top right
            ]);
        }
    }

    private function drawScrollIndicators(dc as Graphics.Dc, offset)
    {
        var maxMessages = 0;

        if (_messageManager.getMessages() == null) {
            return;
        }

        maxMessages = _messageManager.getMessages().size();

        // Draw scroll indicators using graphics
        dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);

        var y = offset;
        drawUpArrow(dc, y, maxMessages);
        y = dc.getHeight() - 20;
        drawDownArrow(dc, y, maxMessages);
    }

    private function drawMessage(dc as Graphics.Dc, font, message as Lang.Dictionary, x, y, width)
    {
        // Safely extract values with type checking
        var sender = message.get("sender");
        var text = message.get("text");
        var time = message.get("time");

        _logger.trace(
            "MessagesView",
            "Drawingmessage sender: " + sender + " text: " + text + " at (" + x + ", " + y + ")"
        );

        drawSender(dc, x, y, width, font, sender, time);
        drawText(dc, x, y + getLineSpacing(dc, font), font, text);
    }

    private function drawSender(dc as Graphics.Dc, x, y, width, font, sender, time)
    {
        // Draw sender (only if visible)
        dc.setColor(Graphics.COLOR_BLUE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(x, y, font, sender, Graphics.TEXT_JUSTIFY_LEFT);

        // Draw time
        if (time != null) {
            var timeStr = formatTime(time);
            dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
            dc.drawText(width - x, y, font, timeStr, Graphics.TEXT_JUSTIFY_RIGHT);
        }
    }

    private function drawText(dc as Graphics.Dc, x, y, font, text)
    {
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);

        if (text.length() > 30) {
            text = text.substring(0, 27) + "...";
        }
        dc.drawText(x, y, font, text, Graphics.TEXT_JUSTIFY_LEFT);
    }

    private function formatTime(timestamp) as Lang.String
    {
        var moment = new Time.Moment(timestamp);
        var info = Gregorian.info(moment, Time.FORMAT_SHORT);
        return Lang.format("$1$:$2$", [
            info.hour.format("%02d"),
            info.min.format("%02d"),
        ]);
    }

    private function drawConnectionStatus(dc as Graphics.Dc, width as Lang.Number) as Void
    {
        var status = _messageManager.getConnectionStatus();
        var statusColor;
        var statusText;

        if (status == MessageManager.STATUS_CONNECTED) {
            statusColor = Graphics.COLOR_GREEN;
            statusText = "Connected";
        } else if (status == MessageManager.STATUS_CONNECTING) {
            statusColor = Graphics.COLOR_YELLOW;
            statusText = "Connecting";
        } else {
            statusColor = Graphics.COLOR_RED;
            statusText = "Disconnected";
        }

        dc.setColor(statusColor, Graphics.COLOR_TRANSPARENT);
        dc.fillCircle(width / 2, 15, 5);

        /*
                // Optional: Draw status text
                dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
                dc.drawText(width - 25, 5, Graphics.FONT_XTINY, statusText,
           Graphics.TEXT_JUSTIFY_RIGHT);
        */
    }

    public function scroll(direction as Lang.Number) as Void
    {
        // direction: -1 = scroll up (show older), +1 = scroll down (show newer)
        _scrollOffset += direction;

        if (_scrollOffset <= 0) {
            _scrollOffset = 0;
        }

        if (_scrollOffset >= _messageManager.getMessages().size()) {
            _scrollOffset = _messageManager.getMessages().size() - 1;
        }

        WatchUi.requestUpdate();
    }

    function onEnterSleep() as Void
    {
        _logger.debug("MessagesView", "Entering sleep mode");
    }

    function onExitSleep() as Void
    {
        _logger.debug("MessagesView", "Exiting sleep mode");
    }
}
