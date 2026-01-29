using Toybox.Lang;

class Message {
  public var sender as Lang.String;
  public var text as Lang.String;
  public var time as Lang.Number;

  function initialize(
      sender as Lang.String, text as Lang.String, time as Lang.Number) {
    self.sender = sender;
    self.text = text;
    self.time = time;
  }

  function toDictionary() as Lang.Dictionary {
    return {"sender" => sender, "text" => text, "time" => time} as
        Lang.Dictionary<Lang.String, Lang.Object>;
  }

    static function fromDictionary(dict as Lang.Dictionary<Lang.String, Lang.Object>) as
    Message {
      // We cast each 'Object' back to its specific type.
      // If the key might be missing, use a default value (like "" or 0)
      var s = dict.get("sender");
      var t = dict.get("text");
      var tm = dict.get("time");

      return new Message(
          (s != null) ? s as Lang.String : "Unknown",
          (t != null) ? t as Lang.String : "",
          (tm != null) ? tm as Lang.Number : 0);
    }

}