using Toybox.Lang;
using Toybox.Communications;

class TestPhoneAppMessage extends Communications.PhoneAppMessage {
  public var data;

  function initialize(d as Lang.Dictionary) {
    PhoneAppMessage.initialize();
    data = d;
  }
}