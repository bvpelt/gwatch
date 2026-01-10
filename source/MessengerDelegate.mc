using Toybox.WatchUi;
using Toybox.System;
using Toybox.Lang;

class MessengerDelegate extends WatchUi.BehaviorDelegate {
  private var _messageManager;

  function initialize(messageManager as MessageManager) {
    BehaviorDelegate.initialize();
    _messageManager = messageManager;
  }

  // Add this method to handle button presses
  function onKey(keyEvent as WatchUi.KeyEvent) as Lang.Boolean {
    var key = keyEvent.getKey();

    if (key == WatchUi.KEY_ENTER || key == WatchUi.KEY_START) {
      // Add a test message when Enter or Start button is pressed
      addTestMessage();
      return true;
    } else if (key == WatchUi.KEY_ESC || key == WatchUi.KEY_LAP) {
      // Clear messages when Escape or Lap button is pressed
      _messageManager.clearMessages();
      WatchUi.requestUpdate();
      return true;
    } else if (key == WatchUi.KEY_UP) {
      // Scroll up in messages view
      var currentView = WatchUi.getCurrentView();
      if (currentView[0] instanceof MessagesView) {
        (currentView[0] as MessagesView).scroll(-1);
        return true;
      }
    } else if (key == WatchUi.KEY_DOWN) {
      // Scroll down in messages view
      var currentView = WatchUi.getCurrentView();
      if (currentView[0] instanceof MessagesView) {
        (currentView[0] as MessagesView).scroll(1);
        return true;
      }
    }

    return false;
  }

  private function addTestMessage() as Void {
    var testMessages = [
      { "sender" => "Alice", "text" => "Hey, how are you?" },
      { "sender" => "Bob", "text" => "Meeting at 3pm" },
      { "sender" => "Charlie", "text" => "Don't forget to buy milk" },
      { "sender" => "Diana", "text" => "Running 5 minutes late" },
      { "sender" => "Eve", "text" => "Great job on the presentation!" },
      { "sender" => "Frank", "text" => "Can you call me back?" },
      { "sender" => "Grace", "text" => "Lunch tomorrow?" },
      { "sender" => "Henry", "text" => "Check your email" },
      { "sender" => "Iris", "text" => "Project deadline tomorrow" },
      { "sender" => "Jack", "text" => "Thanks for your help!" },
    ];

    // Pick a random message
    var index = (System.getTimer() / 1000) % testMessages.size();
    var testMsg = testMessages[index];

    var message = {
      "type" => "message",
      "sender" => testMsg["sender"],
      "text" => testMsg["text"],
    };

    // Create a test phone message object
    var phoneMsg = new TestPhoneAppMessage(message);
    _messageManager.handlePhoneMessage(phoneMsg);

    getLogger().debug("Test message added from: " + testMsg["sender"]);
    WatchUi.requestUpdate();
  }

  function onSwipe(swipeEvent as WatchUi.SwipeEvent) as Lang.Boolean {
    var direction = swipeEvent.getDirection();
    var currentView = WatchUi.getCurrentView();

    getLogger().debug("Swipe detected: " + direction);

    // Check if we're in Messages view
    if (currentView[0] instanceof MessagesView) {
      if (direction == WatchUi.SWIPE_UP) {
        // Scroll up (show older messages)
        getLogger().debug("Scrolling up in messages");
        (currentView[0] as MessagesView).scroll(-1);
        return true;
      } else if (direction == WatchUi.SWIPE_DOWN) {
        // Scroll down (show newer messages)
        getLogger().debug("Scrolling down in messages");
        (currentView[0] as MessagesView).scroll(1);
        return true;
      } else if (direction == WatchUi.SWIPE_LEFT) {
        // Switch to clock view
        getLogger().debug("Swipe left - switching to Clock view");
        switchView(0);
        return true;
      } else if (direction == WatchUi.SWIPE_RIGHT) {
        // Switch to clock view
        getLogger().debug("Swipe right - switching to Clock view");
        switchView(0);
        return true;
      }
    } else if (currentView[0] instanceof ClockView) {
      // In Clock view, swipe left or right to go to Messages
      if (direction == WatchUi.SWIPE_LEFT || direction == WatchUi.SWIPE_RIGHT) {
        getLogger().debug("Swipe - switching to Messages view");
        switchView(1);
        return true;
      }
    }

    return false;
  }

  private function switchView(viewType as Lang.Number) as Void {
    var view;

    if (viewType == 1) {
      view = new MessagesView(_messageManager);
    } else {
      view = new ClockView(_messageManager);
    }

    WatchUi.switchToView(
      view,
      new MessengerDelegate(_messageManager),
      WatchUi.SLIDE_IMMEDIATE
    );
  }
}

// Helper class for testing
class TestPhoneAppMessage {
  public var data;

  function initialize(d as Lang.Dictionary) {
    data = d;
  }
}
