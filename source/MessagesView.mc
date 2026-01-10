using Toybox.WatchUi;
using Toybox.Graphics;
using Toybox.System;
using Toybox.Lang;
using Toybox.Time;
using Toybox.Time.Gregorian;

class MessagesView extends WatchUi.View {
  private var _messageManager;
  private var _scrollOffset as Lang.Number;

  function initialize(messageManager as MessageManager) {
    WatchUi.View.initialize();
    _messageManager = messageManager;
    _scrollOffset = 0;
  }

  function onLayout(dc as Graphics.Dc) as Void {}

  function onUpdate(dc as Graphics.Dc) as Void {
    var width = dc.getWidth();
    var height = dc.getHeight();

    // Clear screen
    dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
    dc.clear();

    // Draw header
    dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
    dc.drawText(
      width / 2,
      10,
      Graphics.FONT_SMALL,
      "Messages",
      Graphics.TEXT_JUSTIFY_CENTER
    );

    var textHeight = dc.getFontHeight(Graphics.FONT_SMALL);
    var lineY = 10 + textHeight;

    // Draw line separator
    dc.drawLine(0, lineY, width, lineY);

    // Draw messages
    var messages = _messageManager.getMessages();
    if (messages.size() == 0) {
      dc.drawText(
        width / 2,
        height / 2,
        Graphics.FONT_SMALL,
        "No Messages",
        Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
      );
    } else {
      drawMessages(dc, messages, lineY + 10, width, height);
    }

    // Draw connection status
    drawConnectionStatus(dc, width);
  }

  private function drawMessages(
    dc as Graphics.Dc,
    messages as Lang.Array,
    offset as Lang.Number,
    width as Lang.Number,
    height as Lang.Number
  ) as Void {
    var y = offset + _scrollOffset;
    var font = Graphics.FONT_XTINY;
    var lineHeight = dc.getFontHeight(font);
    var lineX = 35;
    var messageSpacing = 5;
    var messageHeight = lineHeight * 2 + messageSpacing;

    // Draw from newest (bottom of array) to oldest (top)
    for (var i = messages.size() - 1; i >= 0; i--) {
      // Skip messages that are above the visible area
      if (y + messageHeight < offset) {
        y += messageHeight;
        continue;
      }

      // Stop if we're past the bottom of the screen
      if (y > height) {
        break;
      }

      var message = Message.fromDictionary(messages[i] as Lang.Dictionary);
      //var message = messages[i] as Lang.Dictionary;

      // Safely extract values with type checking
      var sender = messages[i].get("sender");
      var text = messages[i].get("text");

      // Skip if essential data is missing
      if (sender == null || text == null) {
        y += messageHeight;
        continue;
      }

      // Draw sender (only if visible)
      if (y >= offset && y < height) {
        dc.setColor(Graphics.COLOR_BLUE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(lineX, y, font, message.sender, Graphics.TEXT_JUSTIFY_LEFT);
      }

      // Draw message text
      if (y + lineHeight >= offset && y + lineHeight < height) {
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        var textStr = message.text;
        if (textStr.length() > 30) {
          textStr = textStr.substring(0, 27) + "...";
        }
        dc.drawText(
          lineX,
          y + lineHeight,
          font,
          textStr,
          Graphics.TEXT_JUSTIFY_LEFT
        );
      }

      // Draw time
      if (y >= offset && y < height && message.time != null) {
        var timeStr = formatTime(message.time);
        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
          width - lineX,
          y,
          font,
          timeStr,
          Graphics.TEXT_JUSTIFY_RIGHT
        );
      }

      y += messageHeight;
    }

    // Draw scroll indicators using graphics
    dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
    var centerX = width / 2;

    // Show "more above" indicator
    if (_scrollOffset < 0) {
      var arrowY = offset + 5;
      // Draw upward pointing triangle
      dc.fillPolygon([
        [centerX, arrowY], // Top point
        [centerX - 6, arrowY + 7], // Bottom left
        [centerX + 6, arrowY + 7], // Bottom right
      ]);
    }

    // Check if there are more messages below
    var totalContentHeight = messages.size() * messageHeight;
    var visibleContentEnd = offset - _scrollOffset + (height - offset);

    if (totalContentHeight > visibleContentEnd) {
      var arrowY = height - 20;
      // Draw downward pointing triangle
      dc.fillPolygon([
        [centerX, arrowY + 7], // Bottom point
        [centerX - 6, arrowY], // Top left
        [centerX + 6, arrowY], // Top right
      ]);
    }
  }

  private function formatTime(timestamp) as Lang.String {
    var moment = new Time.Moment(timestamp);
    var info = Gregorian.info(moment, Time.FORMAT_SHORT);
    return Lang.format("$1$:$2$", [
      info.hour.format("%02d"),
      info.min.format("%02d"),
    ]);
  }

  private function drawConnectionStatus(
    dc as Graphics.Dc,
    width as Lang.Number
  ) as Void {
    var status = _messageManager.getConnectionStatus();
    var statusColor;

    if (status == MessageManager.STATUS_CONNECTED) {
      statusColor = Graphics.COLOR_GREEN;
    } else if (status == MessageManager.STATUS_CONNECTING) {
      statusColor = Graphics.COLOR_YELLOW;
    } else {
      statusColor = Graphics.COLOR_RED;
    }

    dc.setColor(statusColor, Graphics.COLOR_TRANSPARENT);
    dc.fillCircle(width - 15, 15, 5);
  }

  public function scroll(direction as Lang.Number) as Void {
    // direction: -1 = scroll up (show older), +1 = scroll down (show newer)
    _scrollOffset += direction * 30;

    // Prevent scrolling past the top (newest messages)
    if (_scrollOffset > 0) {
      _scrollOffset = 0;
    }

    // Calculate maximum scroll based on message count
    var messages = _messageManager.getMessages();

    // Approximate calculation
    var messageHeight = 40; // Approximate height per message (2 lines + spacing)
    var totalHeight = messages.size() * messageHeight;
    var visibleHeight = 200; // Approximate visible area height

    var maxScroll = -(totalHeight - visibleHeight);

    // Prevent scrolling past the bottom (oldest messages)
    if (_scrollOffset < maxScroll && totalHeight > visibleHeight) {
      _scrollOffset = maxScroll;
    }

    WatchUi.requestUpdate();
  }

  function onEnterSleep() as Void {}
  function onExitSleep() as Void {}
}
