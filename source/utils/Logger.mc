using Toybox.Lang;
using Toybox.System;
using Toybox.Time;
using Toybox.Time.Gregorian;

class Logger
{
    private static var _instance as Logger?;

    // Log levels
    enum {
        LEVEL_TRACE = 0,
        LEVEL_DEBUG = 1,
        LEVEL_INFO = 2,
        LEVEL_WARN = 3,
        LEVEL_ERROR = 4,
    }

    private var _minLevel as Lang.Number;
    private var _enabled as Lang.Boolean;

    // Private constructor
    private function initialize()
    {
        _minLevel = LEVEL_TRACE;
        _enabled = true;
    }

    // Get singleton instance
    static function getInstance() as Logger
    {
        if (_instance == null) {
            _instance = new Logger();
        }
        return _instance;
    }

    // Configuration methods
    function setMinLevel(level as Lang.Number) as Void
    {
        _minLevel = level;
    }

    function setEnabled(enabled as Lang.Boolean) as Void
    {
        _enabled = enabled;
    }

    private function log(
        source as Lang.String, level as Lang.String, levelValue as Lang.Number,
        message as Lang.String
    ) as Void
    {
        if (!_enabled || levelValue < _minLevel) {
            return;
        }

        var now = Gregorian.info(Time.now(), Time.FORMAT_LONG);
        var timeStamp = Lang.format("[$1$:$2$:$3$]", [
            now.hour.format("%02d"),
            now.min.format("%02d"),
            now.sec.format("%02d"),
        ]);

        System.println(timeStamp + " " + source + " [" + level + "]: " + message);
    }

    function trace(source as Lang.String, message as Lang.String) as Void
    {
        log(source, "TRACE", LEVEL_TRACE, message);
    }

    function debug(source as Lang.String, message as Lang.String) as Void
    {
        log(source, "DEBUG", LEVEL_DEBUG, message);
    }

    function info(source as Lang.String, message as Lang.String) as Void
    {
        log(source, "INFO", LEVEL_INFO, message);
    }

    function warn(source as Lang.String, message as Lang.String) as Void
    {
        log(source, "WARN", LEVEL_WARN, message);
    }

    function error(source as Lang.String, message as Lang.String) as Void
    {
        log(source, "ERROR", LEVEL_ERROR, message);
    }
}

// Global convenience function
function getLogger() as Logger
{
    return Logger.getInstance();
}
