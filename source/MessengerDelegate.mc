using Toybox.WatchUi;
using Toybox.System;
using Toybox.Lang;
using Toybox.Communications;

class MessengerDelegate extends WatchUi.BehaviorDelegate {
  private static var _instance as MessengerDelegate?;
  private var _messageManager;
  private var logger;
  private var propertieUtility;
  private var currentWatchView as Lang.Integer;

  // Private constructor
  private function initialize(messageManager as MessageManager) {
    logger = getLogger();
    propertieUtility = getPropertieUtility();
    currentWatchView = propertieUtility.getPropertyNumber("DefaultView", 0);
    BehaviorDelegate.initialize();
    _messageManager = getMessageManager();
  }

  // Get singleton instance
  static function getInstance() as MessengerDelegate {
    if (_instance == null) {
      _instance = new MessengerDelegate(getMessageManager());
    }
    return _instance;
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

    logger.debug(
      "MessengerDelegate",
      "Test message added from: " + testMsg["sender"]
    );
    WatchUi.requestUpdate();
  }

  function onSwipe(swipeEvent as WatchUi.SwipeEvent) as Lang.Boolean {
    var direction = swipeEvent.getDirection();
    var currentView = WatchUi.getCurrentView();

    logger.debug("MessengerDelegate", "Swipe detected: " + direction);

    // Check if we're in Messages view
    if (currentView[0] instanceof MessagesView) {
      // currentWatchView == 0
      if (direction == WatchUi.SWIPE_UP) {
        // Scroll up (show older messages)
        logger.debug("MessengerDelegate", "Scrolling up in messages");
        (currentView[0] as MessagesView).scroll(-1);
        return true;
      } else if (direction == WatchUi.SWIPE_DOWN) {
        // Scroll down (show newer messages)
        logger.debug("MessengerDelegate", "Scrolling down in messages");
        (currentView[0] as MessagesView).scroll(1);
        return true;
      } else if (direction == WatchUi.SWIPE_LEFT) {
        currentWatchView = 2; // AnalogView  0 -> 2
        // Switch to clock view
        logger.debug(
          "MessengerDelegate",
          "Swipe left - switching to Clock view"
        );
        switchView(currentWatchView);
        return true;
      } else if (direction == WatchUi.SWIPE_RIGHT) {
        currentWatchView = 1; // Switch to ClockView 0 -> 1
        logger.debug(
          "MessengerDelegate",
          "Swipe right - switching to Analog view"
        );
        switchView(currentWatchView);
        return true;
      }
    } else if (currentView[0] instanceof ClockView) {
      // currentWatchView == 1
      // In Clock view, swipe left or right to go to Messages
      if (direction == WatchUi.SWIPE_LEFT) {
        currentWatchView = 0; // 1 -> 0
        logger.debug("MessengerDelegate", "Swipe - switching to Message view");
        switchView(currentWatchView);
        return true;
      } else if (direction == WatchUi.SWIPE_RIGHT) {
        currentWatchView = 2; // 1 -> 2
        logger.debug("MessengerDelegate", "Swipe - switching to Analog view");
        switchView(currentWatchView);
        return true;
      }
    } else if (currentView[0] instanceof AnalogView) {
      // currentWatchView == 2
      // In Clock view, swipe left or right to go to Messages
      if (direction == WatchUi.SWIPE_LEFT) {
        currentWatchView = 1; // 2 -> 1
        logger.debug("MessengerDelegate", "Swipe - switching to Clock view");
        switchView(currentWatchView);
        return true;
      } else if (direction == WatchUi.SWIPE_RIGHT) {
        currentWatchView = 0; // 2 -> 0
        logger.debug("MessengerDelegate", "Swipe - switching to Messages view");
        switchView(currentWatchView);
        return true;
      }
    }

    return false;
  }

  private function switchViewxx(viewType as Lang.Number) as Void {

    var nextView;
    switch (viewType) {
      case 0:
        nextView = getMessagesView();
        break;
      case 1:
        nextView = getClockView();
        break;
      case 2:
        nextView = getAnalogView();
        break;
      default:
        nextView = getMessagesView();
    }

    WatchUi.switchToView(nextView, self, WatchUi.SLIDE_IMMEDIATE);
  }

  private function switchView(viewType as Lang.Number) as Void {

    var nextView;
    switch (viewType) {
      case 0:
        nextView = getMessagesView();
        break;
      case 1:
        nextView = getClockView();
        break;
      case 2:
        nextView = getAnalogView();
        break;
      default:
        nextView = getMessagesView();
    }

    // SLIDE_IMMEDIATE can sometimes be too fast for the Linux Sim.
    // SLIDE_LEFT/RIGHT is actually more stable as it forces a formal transition.
    WatchUi.switchToView(nextView, self, WatchUi.SLIDE_IMMEDIATE);
  }
}

// Global convenience function
function getMessengerDelegate() as MessengerDelegate {
  return MessengerDelegate.getInstance();
}

// Helper class for testing
class TestPhoneAppMessage extends Communications.PhoneAppMessage {
  public var data;

  function initialize(d as Lang.Dictionary) {
    PhoneAppMessage.initialize();
    data = d;
  }
}
