using Toybox.WatchUi;
using Toybox.Graphics;
using Toybox.System;
using Toybox.Lang;
using Toybox.Time;
using Toybox.Time.Gregorian;
using Toybox.Math;
using Toybox.Application.Properties;

class AnalogView extends WatchUi
.View
{
    private static var _instance as AnalogView ? ;
    private var _logger;
    private var _propertieUtility;

    private var _radius = 0;
    private var _centerX = 0;
    private var _centerY = 0;

    // Colors
    private var _handbgcolor;      // = 0x504949;
    private var _handfgcolor;      // = 0xff0000;
    private var _handcentercolor;  // = _handfgcolor;

    private var _facebgcolor;      // = 0x000000;
    private var _facebordercolor;  // = 0xc0c0c0;

    private var _daybgcolor;       // = 0x000000;
    private var _daynamecolor;     // = 0xff3333;
    private var _day_numbercolor;  // = 0xa0a0a0;
    private var _dayoutlinecolor;  // = 0xc0c0c0;

    private var _hourmarkercolor;  // = 0xffffff;
    private var _minutetickcolor;  // = 0xa0a0a0;
    private var _numbercolor;      // = 0xffffff;

    private var _batteryfull;   // = 0x26A924 green
    private var _batteryempty;  // = 0xff0000 red

    private var _updateEverySecond = true;  // default value

    // Profile definitions
    private const PROFILE_CLASSIC = 0;
    private const PROFILE_BLUE_STEEL = 1;
    private const PROFILE_ORANGE = 2;
    private const PROFILE_WHITE = 3;
    private const PROFILE_CUSTOM = 4;

    // Constructor
    private function initialize()
    {
        View.initialize();
        _logger = getLogger();
        _propertieUtility = getPropertieUtility();
        _logger.debug("AnalogView", "Initializing AnalogView");

        // Load settings immediately on startup
        updateSettings();
    }

    // Get singleton instance
    static function getInstance() as AnalogView
    {
        if (_instance == null) {
            _instance = new AnalogView();
        }
        return _instance;
    }

    function onUpdateHeartbeat()
    {
        WatchUi.requestUpdate();
    }

    function onShow() as Void
    {
        _logger.debug("AnalogView", "=== AnalogView onShow ===");
    }

    // This is called when the view is hidden/closed
    function onHide()
    {
        _logger.debug("AnalogView", "=== AnalogView onHide");
    }

    public function updateSettings()
    {
        _logger.debug("AnalogView", "==== Updatesettings AnalogView ====");

        var profile = _propertieUtility.getPropertyNumber("ColorProfile", 0);

        _updateEverySecond = _propertieUtility.getPropertyBoolean("UpdateSeconds", true);
        _logger.debug(
            "AnalogView",
            "==== Initialize AnalogView - Update every second: " + _updateEverySecond.toString() +
                " ===="
        );

        if (profile == null) {
            profile = PROFILE_CLASSIC;
        }

        _logger.debug(
            "AnalogView",
            "==== Initializing AnalogView with profile: " + profile.toString() + " ===="
        );

        // Apply predefined profile or load custom values
        if (profile == PROFILE_CLASSIC) {
            applyClassicProfile();
        } else if (profile == PROFILE_BLUE_STEEL) {
            applyBlueSteelProfile();
        } else if (profile == PROFILE_ORANGE) {
            applyOrangeProfile();
        } else if (profile == PROFILE_WHITE) {
            applyWhiteProfile();
        } else if (profile == PROFILE_CUSTOM) {
            loadCustomColors();
        } else {
            applyClassicProfile();  // Default fallback
        }

        WatchUi.requestUpdate();
    }

    private function applyClassicProfile()
    {
        _logger.debug("AnalogView", "=== Applying Classic Profile ===");
        _handbgcolor = 0x504949;      // { "charcoal", "#504949" },
        _handfgcolor = 0xff0000;      // { "red", "#ff0000" },
        _facebgcolor = 0x000000;      // { "black", "#000000" },
        _facebordercolor = 0xc0c0c0;  // { "silver", "#c0c0c0" },
        _handcentercolor = 0xff0000;  // { "red", "#ff0000" },
        _daybgcolor = 0x000000;       // { "black", "#000000" },
        _daynamecolor = 0xff3333;     // { "cinnabar", "#ff3333" },
        _day_numbercolor = 0xa0a0a0;  // { "cool steel", "#a0a0a0" },
        _dayoutlinecolor = 0xc0c0c0;  // { "silver", "#c0c0c0" },
        _hourmarkercolor = 0xffffff;  // { "white", "#ffffff" },
        _minutetickcolor = 0xa0a0a0;  // { "cool steel", "#a0a0a0" },
        _numbercolor = 0xffffff;      // { "white", "#ffffff" },
        _batteryfull = 0x26a924;      // { "green" , "#26a924" },
        _batteryempty = 0xff0000;     // { "red", "#ff0000" },
    }

    private function applyBlueSteelProfile()
    {
        _logger.debug("AnalogView", "=== Applying Blue Steel Profile ===");
        _handbgcolor = 0x0d2c54;      // {"oxford navy", "#0d2c54"}
        _handfgcolor = 0x00a6ed;      // {"fresh sky", "#00a6ed"},
        _facebgcolor = 0x061a40;      // {"prussian blue", "#061a40"},
        _facebordercolor = 0x061a40;  // {"prussian blue", "#061a40"},
        _handcentercolor = 0x061a40;  // {"prussian blue", "#061a40"},
        _daybgcolor = 0x061a40;       // {"prussian blue", "#061a40"},
        _daynamecolor = 0xffffff;     // {"white", "#ffffff" }
        _day_numbercolor = 0xffffff;  // {"white", "#ffffff" }
        _dayoutlinecolor = 0x0d2c54;  // {"oxford navy", "#0d2c54"}
        _hourmarkercolor = 0xffffff;  // {"white", "#ffffff" }
        _minutetickcolor = 0xffffff;  // {"white", "#ffffff" }
        _numbercolor = 0x00a6ed;      // {"fresh sky", "#00a6ed"},
        _batteryfull = 0x26a924;      // { "green" , "#26a924" },
        _batteryempty = 0xff0000;     // { "red", "#ff0000" },
    }

    private function applyOrangeProfile()
    {
        _logger.debug("AnalogView", "=== Applying Orange Profile ===");
        _handbgcolor = 0xffcdbc;      // {"almond silk", "#ffcdbc"}
        _handfgcolor = 0xf5853f;      // {"pumpkin spice","#f5853f"},
        _facebgcolor = 0x130303;      // {"coffee bean", "#130303"},
        _facebordercolor = 0x130303;  // {"coffee bean", "#130303"},
        _handcentercolor = 0xf5853f;  // {"pumpkin spice","#f5853f"},
        _daybgcolor = 0x130303;       // {"coffee bean", "#130303"},
        _daynamecolor = 0xf5853f;     // {"pumpkin spice","#f5853f"},
        _day_numbercolor = 0xf5853f;  // {"pumpkin spice","#f5853f"},
        _dayoutlinecolor = 0xc0c0c0;  // {"silver", "#c0c0c0" },
        _hourmarkercolor = 0xf5853f;  // {"pumpkin spice","#f5853f"},
        _minutetickcolor = 0xf5853f;  // {"pumpkin spice","#f5853f"},
        _numbercolor = 0xf5853f;      // {"pumpkin spice","#f5853f"},
        _batteryfull = 0x26a924;      // { "green" , "#26a924" },
        _batteryempty = 0xff0000;     // { "red", "#ff0000" },
    }

    private function applyWhiteProfile()
    {
        _logger.debug("AnalogView", "=== Applying White Profile ===");
        _handbgcolor = 0xc0c0c0;      // { "silver", "#c0c0c0" },
        _handfgcolor = 0x000000;      // { "black", "#000000" },
        _facebgcolor = 0xc0c0c0;      // { "silver", "#c0c0c0" },
        _facebordercolor = 0x000000;  // { "black", "#000000" },
        _handcentercolor = 0xc0c0c0;  // { "silver", "#c0c0c0" },
        _daybgcolor = 0xc0c0c0;       // { "silver", "#c0c0c0" },
        _daynamecolor = 0x000000;     // { "black", "#000000" },
        _day_numbercolor = 0x000000;  // { "black", "#000000" },
        _dayoutlinecolor = 0xc0c0c0;  // { "silver", "#c0c0c0" },
        _hourmarkercolor = 0x000000;  // { "black", "#000000" },
        _minutetickcolor = 0x000000;  // { "black", "#000000" },
        _numbercolor = 0x000000;      // { "black", "#000000" },
        _batteryfull = 0x26a924;      // { "green" , "#26a924" },
        _batteryempty = 0xff0000;     // { "red", "#ff0000" },
    }

    private function loadCustomColors()
    {
        _logger.debug("AnalogView", "=== Loading custom colors from properties ===");
        // Load each color from properties
        _handbgcolor = _propertieUtility.getPropertyNumber("HandBgColor", 0x504949);
        _handfgcolor = _propertieUtility.getPropertyNumber("HandFgColor", 0xff0000);
        _facebgcolor = _propertieUtility.getPropertyNumber("FaceBgColor", 0x000000);
        _facebordercolor = _propertieUtility.getPropertyNumber("FaceBorderColor", 0xc0c0c0);
        _handcentercolor = _propertieUtility.getPropertyNumber("HandCenterColor", 0xff0000);
        _daybgcolor = _propertieUtility.getPropertyNumber("DayBgColor", 0x000000);
        _daynamecolor = _propertieUtility.getPropertyNumber("DayNameColor", 0xff3333);
        _day_numbercolor = _propertieUtility.getPropertyNumber("DayNumberColor", 0xa0a0a0);
        _dayoutlinecolor = _propertieUtility.getPropertyNumber("DayOutlineColor", 0xc0c0c0);
        _hourmarkercolor = _propertieUtility.getPropertyNumber("HourMarkerColor", 0xffffff);
        _minutetickcolor = _propertieUtility.getPropertyNumber("MinuteTickColor", 0xa0a0a0);
        _numbercolor = _propertieUtility.getPropertyNumber("NumberColor", 0xffffff);
        _batteryfull = _propertieUtility.getPropertyNumber("BatteryFullColor", 0x26a924);
        _batteryempty = _propertieUtility.getPropertyNumber("BatteryEmptyColor", 0xff0000);
    }

    function onLayout(dc)
    {
        _logger.debug("AnalogView", "=== Layout AnalogView ===");
        _centerX = dc.getWidth() / 2;
        _centerY = dc.getHeight() / 2;
        var minDimension = _centerX < _centerY ? _centerX : _centerY;
        _radius = minDimension * 0.95;
    }

    function onUpdate(dc)
    {
        _logger.trace("AnalogView", "=== AnalogView onUpdate ===");

        if (_centerX == 0 || _centerY == 0) {
            onLayout(dc);  // Safety fallback
        }

        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();

        dc.setPenWidth(1);
        drawFace(dc);
        drawHourMarkers(dc);
        drawMinuteTicks(dc);
        drawNumbers(dc);
        drawLoad(dc);
        drawDateInfo(dc);
        drawTime(dc);
    }

    private function drawFace(dc)
    {
        // Dark background
        dc.setColor(_facebgcolor, Graphics.COLOR_TRANSPARENT);
        dc.fillCircle(_centerX, _centerY, (_radius * 0.97).toNumber());

        // Outer silver ring
        dc.setColor(_facebordercolor, Graphics.COLOR_TRANSPARENT);
        var outerPenWidth = (_radius * 0.06).toNumber();
        if (outerPenWidth < 1) {
            outerPenWidth = 1;
        }
        dc.setPenWidth(outerPenWidth);
        dc.drawCircle(_centerX, _centerY, (_radius * 0.97).toNumber());

        // Inner ring
        var innerPenWidth = (_radius * 0.01).toNumber();
        if (innerPenWidth < 1) {
            innerPenWidth = 1;
        }
        dc.setPenWidth(innerPenWidth);
        dc.drawCircle(_centerX, _centerY, (_radius * 0.9).toNumber());

        // Center point
        dc.setColor(_handcentercolor, Graphics.COLOR_TRANSPARENT);
        dc.fillCircle(_centerX, _centerY, (_radius * 0.04).toNumber());
    }

    private function drawLoad(dc)
    {
        var startAngle = 90;
        var loadPercentage = System.getSystemStats().battery;
        var sweepAngle = (loadPercentage / 100.0) * 360;

        var loadPenWidth = (_radius * 0.05).toNumber();
        if (loadPenWidth < 1) {
            loadPenWidth = 1;
        }

        var arcRadius = (_radius * 0.92).toNumber();

        // Green portion (loaded)
        dc.setColor(_batteryfull, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(loadPenWidth);
        dc.drawArc(
            _centerX, _centerY, arcRadius, Graphics.ARC_CLOCKWISE, startAngle,
            startAngle - sweepAngle
        );

        // Red portion (remaining)
        dc.setColor(_batteryempty, Graphics.COLOR_TRANSPARENT);
        dc.drawArc(
            _centerX, _centerY, arcRadius, Graphics.ARC_CLOCKWISE, startAngle - sweepAngle,
            startAngle
        );
    }

    private function drawHourMarkers(dc)
    {
        var triangleHeight = (_radius * 0.07).toNumber();
        var triangleBase = (_radius * 0.04).toNumber();

        for (var i = 0; i < 12; i++) {
            var angle = (i * Math.PI) / 6;

            var cosAngle = Math.cos(angle);
            var sinAngle = Math.sin(angle);
            var perpAngle = angle + Math.PI / 2;
            var cosPerAngle = Math.cos(perpAngle);
            var sinPerAngle = Math.sin(perpAngle);

            var xOuter = (_centerX + cosAngle * _radius * 0.88).toNumber();
            var yOuter = (_centerY + sinAngle * _radius * 0.88).toNumber();

            var xBase1 = (xOuter + cosPerAngle * (triangleBase / 2)).toNumber();
            var yBase1 = (yOuter + sinPerAngle * (triangleBase / 2)).toNumber();
            var xBase2 = (xOuter - cosPerAngle * (triangleBase / 2)).toNumber();
            var yBase2 = (yOuter - sinPerAngle * (triangleBase / 2)).toNumber();

            var xTip = (_centerX + cosAngle * (_radius * 0.88 - triangleHeight)).toNumber();
            var yTip = (_centerY + sinAngle * (_radius * 0.88 - triangleHeight)).toNumber();

            dc.setColor(_hourmarkercolor, Graphics.COLOR_TRANSPARENT);
            dc.fillPolygon([
                [xBase1, yBase1],
                [xBase2, yBase2],
                [xTip, yTip],
            ]);
        }
    }

    private function drawMinuteTicks(dc)
    {
        var tickLength = (_radius * 0.04).toNumber();

        dc.setColor(_minutetickcolor, Graphics.COLOR_TRANSPARENT);

        // FIX: Ensure pen width is at least 1 pixel and is an integer
        var penWidth = (_radius * 0.008).toNumber();
        if (penWidth < 1) {
            penWidth = 1;
        }
        dc.setPenWidth(penWidth);

        for (var i = 0; i < 60; i++) {
            if (i % 5 != 0) {
                var angle = (i * Math.PI) / 30;

                var cosAngle = Math.cos(angle);
                var sinAngle = Math.sin(angle);

                var xStart = (_centerX + cosAngle * _radius * 0.88).toNumber();
                var yStart = (_centerY + sinAngle * _radius * 0.88).toNumber();
                var xEnd = (_centerX + cosAngle * (_radius * 0.88 - tickLength)).toNumber();
                var yEnd = (_centerY + sinAngle * (_radius * 0.88 - tickLength)).toNumber();

                dc.drawLine(xStart, yStart, xEnd, yEnd);
            }
        }
    }

    private function drawNumbers(dc)
    {
        dc.setColor(_numbercolor, Graphics.COLOR_TRANSPARENT);
        var font = Graphics.FONT_XTINY;
        var numbers = [12, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11];

        for (var i = 0; i < 12; i++) {
            var angle = (i * Math.PI) / 6 - Math.PI / 2;
            var cosAngle = Math.cos(angle);
            var sinAngle = Math.sin(angle);

            var x = (_centerX + cosAngle * _radius * 0.7).toNumber();
            var y = (_centerY + sinAngle * _radius * 0.7).toNumber();

            dc.drawText(
                x, y, font, numbers[i].toString(),
                Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
            );
        }
    }

    private function drawDateInfo(dc)
    {
        var now = Gregorian.info(Time.now(), Time.FORMAT_LONG);
        var weekday = Lang.format("$1$", [now.day_of_week]);
        var dayNum = now.day;
        var dayString = dayNum < 10 ? "0" + dayNum.toString() : dayNum.toString();

        var _centerYPos = _centerY.toNumber();

        var font = Graphics.FONT_XTINY;
        var boxNumberWidth = 1.1 * dc.getTextWidthInPixels(dayString, font);
        var boxWeekdayWidth = 1.1 * dc.getTextWidthInPixels(weekday, font);

        var boxHeight = (_radius * 0.19).toNumber();
        var boxSpacing = (_radius * 0.03).toNumber();

        var maxlen = (_centerX + _radius * 0.60).toNumber();
        var boxDNumberX = maxlen - boxNumberWidth;
        var boxWDNameX = maxlen - boxWeekdayWidth - boxNumberWidth - boxSpacing;

        var boxY = _centerYPos - boxHeight / 2;

        var outlinePenWidth = (_radius * 0.008).toNumber();
        if (outlinePenWidth < 1) {
            outlinePenWidth = 1;
        }

        // Weekday box
        dc.setColor(_daybgcolor, Graphics.COLOR_TRANSPARENT);
        dc.fillRectangle(boxWDNameX, boxY, boxWeekdayWidth, boxHeight);

        dc.setColor(_dayoutlinecolor, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(outlinePenWidth);
        dc.drawRectangle(boxWDNameX, boxY, boxWeekdayWidth, boxHeight);

        dc.setColor(_daynamecolor, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            boxWDNameX + boxWeekdayWidth / 2, _centerYPos, font, weekday,
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        );

        // Day box
        dc.setColor(_daybgcolor, Graphics.COLOR_TRANSPARENT);
        dc.fillRectangle(boxDNumberX, boxY, boxNumberWidth, boxHeight);

        dc.setColor(_dayoutlinecolor, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(outlinePenWidth);
        dc.drawRectangle(boxDNumberX, boxY, boxNumberWidth, boxHeight);

        dc.setColor(_day_numbercolor, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            boxDNumberX + boxNumberWidth / 2, _centerYPos, font, dayString,
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        );
    }

    private function drawTime(dc)
    {
        var clockTime = System.getClockTime();
        var hour = clockTime.hour % 12;
        var minute = clockTime.min;
        var second = clockTime.sec;

        // Hour hand
        var hourAngle = (hour * Math.PI) / 6 + (minute * Math.PI) / 360 - Math.PI / 2;
        drawHand(dc, hourAngle, _radius * 0.55, _radius * 0.035);

        // Minute hand
        var minuteAngle = (minute * Math.PI) / 30 + (second * Math.PI) / 1800 - Math.PI / 2;
        drawHand(dc, minuteAngle, _radius * 0.7, _radius * 0.025);

        if (_updateEverySecond) {
            // Second hand
            var secondAngle = (second * Math.PI) / 30 - Math.PI / 2;
            dc.setColor(_handfgcolor, Graphics.COLOR_TRANSPARENT);

            var secondPenWidth = (_radius * 0.025).toNumber();
            if (secondPenWidth < 1) {
                secondPenWidth = 1;
            }
            dc.setPenWidth(secondPenWidth);

            var x1 = (_centerX - Math.cos(secondAngle) * _radius * 0.1).toNumber();
            var y1 = (_centerY - Math.sin(secondAngle) * _radius * 0.1).toNumber();
            var x2 = (_centerX + Math.cos(secondAngle) * _radius * 0.75).toNumber();
            var y2 = (_centerY + Math.sin(secondAngle) * _radius * 0.75).toNumber();
            dc.drawLine(x1, y1, x2, y2);
        }
    }

    private function drawHand(dc, angle, length, width)
    {
        var cosAngle = Math.cos(angle);
        var sinAngle = Math.sin(angle);
        var l = length;
        var w = width;

        // Outline hand
        var points = [
            [_centerX, _centerY],
            [_centerX - sinAngle * w * 0.5, _centerY + cosAngle * w * 0.5],
            [
                _centerX + (cosAngle * l) / 15 - sinAngle * w * 0.5,
                _centerY + (sinAngle * l) / 15 + cosAngle * w * 0.5,
            ],
            [
                _centerX + (cosAngle * 2 * l) / 15 - sinAngle * w * 1.5,
                _centerY + (sinAngle * 2 * l) / 15 + cosAngle * w * 1.5,
            ],
            [
                _centerX + (cosAngle * 10 * l) / 15 - sinAngle * w * 1.5,
                _centerY + (sinAngle * 10 * l) / 15 + cosAngle * w * 1.5,
            ],
            [
                _centerX + (cosAngle * 11 * l) / 15 - sinAngle * w * 0.5,
                _centerY + (sinAngle * 11 * l) / 15 + cosAngle * w * 0.5,
            ],
            [
                _centerX + cosAngle * l - sinAngle * w * 0.5,
                _centerY + sinAngle * l + cosAngle * w * 0.5,
            ],
            [
                _centerX + cosAngle * l + sinAngle * w * 0.5,
                _centerY + sinAngle * l - cosAngle * w * 0.5,
            ],
            [
                _centerX + (cosAngle * 11 * l) / 15 + sinAngle * w * 0.5,
                _centerY + (sinAngle * 11 * l) / 15 - cosAngle * w * 0.5,
            ],
            [
                _centerX + (cosAngle * 10 * l) / 15 + sinAngle * w * 1.5,
                _centerY + (sinAngle * 10 * l) / 15 - cosAngle * w * 1.5,
            ],
            [
                _centerX + (cosAngle * 2 * l) / 15 + sinAngle * w * 1.5,
                _centerY + (sinAngle * 2 * l) / 15 - cosAngle * w * 1.5,
            ],
            [
                _centerX + (cosAngle * l) / 15 + sinAngle * w * 0.5,
                _centerY + (sinAngle * l) / 15 - cosAngle * w * 0.5,
            ],
            [_centerX + sinAngle * w * 0.5, _centerY - cosAngle * w * 0.5],
            [_centerX, _centerY],
        ];

        dc.setColor(_handbgcolor, Graphics.COLOR_TRANSPARENT);
        dc.fillPolygon(points);

        // Inside line hand
        var innerPoints = [
            [_centerX + (cosAngle * 2 * l) / 15, _centerY + (sinAngle * 2 * l) / 15],
            [
                _centerX + (cosAngle * 2.8 * l) / 15 - sinAngle * w * 0.8,
                _centerY + (sinAngle * 2.8 * l) / 15 + cosAngle * w * 0.8,
            ],
            [
                _centerX + (cosAngle * 9.2 * l) / 15 - sinAngle * w * 0.8,
                _centerY + (sinAngle * 9.2 * l) / 15 + cosAngle * w * 0.8,
            ],
            [
                _centerX + (cosAngle * 10.2 * l) / 15,
                _centerY + (sinAngle * 10.2 * l) / 15,
            ],
            [
                _centerX + (cosAngle * 9.2 * l) / 15 + sinAngle * w * 0.8,
                _centerY + (sinAngle * 9.2 * l) / 15 - cosAngle * w * 0.8,
            ],
            [
                _centerX + (cosAngle * 2.8 * l) / 15 + sinAngle * w * 0.8,
                _centerY + (sinAngle * 2.8 * l) / 15 - cosAngle * w * 0.8,
            ],
            [_centerX + (cosAngle * 2 * l) / 15, _centerY + (sinAngle * 2 * l) / 15],
        ];

        dc.setColor(_handfgcolor, Graphics.COLOR_TRANSPARENT);
        dc.fillPolygon(innerPoints);
    }

    function onEnterSleep()
    {
        _logger.debug("AnalogView", "=== Entering sleep mode ===");
    }

    function onExitSleep()
    {
        _logger.debug("AnalogView", "=== Exiting sleep mode ===");
    }
}

// Global convenience function
function getAnalogView() as AnalogView
{
    return AnalogView.getInstance();
}
