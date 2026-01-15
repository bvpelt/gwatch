using Toybox.WatchUi;
using Toybox.Graphics;
using Toybox.System;
using Toybox.Lang;
using Toybox.Time;
using Toybox.Time.Gregorian;
using Toybox.Math;
using Toybox.Application.Properties;

class AnalogView extends WatchUi.View {
  private static var _instance as AnalogView?;
  static var ID = "Watch01";
  private var logger;
  private var _updateTimer;
  private var propertieUtility;

  private var radius = 0;
  private var centerX = 0;
  private var centerY = 0;

  // Colors
  private var handbgcolor; // = 0x504949;
  private var handfgcolor; // = 0xff0000;
  private var handcentercolor; // = handfgcolor;

  private var facebgcolor; // = 0x000000;
  private var facebordercolor; // = 0xc0c0c0;

  private var daybgcolor; // = 0x000000;
  private var daynamecolor; // = 0xff3333;
  private var daynumbercolor; // = 0xa0a0a0;
  private var dayoutlinecolor; // = 0xc0c0c0;

  private var hourmarkercolor; // = 0xffffff;
  private var minutetickcolor; // = 0xa0a0a0;
  private var numbercolor; // = 0xffffff;

  private var updateEverySecond = true; // default value

  // Profile definitions
  private const PROFILE_CLASSIC = 0;
  private const PROFILE_BLUE_STEEL = 1;
  private const PROFILE_GREEN_NATURE = 2;
  private const PROFILE_GOLD_LUXURY = 3;
  private const PROFILE_CUSTOM = 4;

  // Private constructor
  private function initialize() {
    View.initialize();
    logger = getLogger();
    propertieUtility = getPropertieUtility();
    logger.debug("AnalogView", "Initializing AnalogView");
    
    // Load settings immediately on startup
    updateSettings();
  }

  // Get singleton instance
  static function getInstance() as AnalogView {
    if (_instance == null) {
      _instance = new AnalogView();
    }
    return _instance;
  }

  function stopClock() as Void {
    if (_updateTimer != null) {
      _updateTimer.stop();
      _updateTimer = null;
    }
  }

  function startClock() as Void {
    onShow(); // This re-initializes the timer
  }

  function onShow() as Void {
    _updateTimer = getUpdateTimer();
    logger.debug("AnalogView", "=== AnalogView onShow === start 1 second timer");
    // Update every 1000ms (1 second)
    _updateTimer.start(method(:onTimer), 1000, true);
  }

  // This is called when the view is hidden/closed
  function onHide() {
    logger.debug("AnalogView", "=== AnalogView onHide === stop 1 second timer");
    stopClock();
  }

  function onTimer() as Void {
    logger.trace("AnalogView", "=== onTimer === requesting update");
    // Request the UI to call onUpdate()
    WatchUi.requestUpdate();
  }

  function getUpdateTimer() {
    if (_updateTimer == null) {
      _updateTimer = new Timer.Timer();
    }
    return _updateTimer;
  }

  public function updateSettings() {
    logger.debug("AnalogView", "Updatesettings AnalogView");

    // applyClassicProfile(); // Set defaults first to make sure all values are set

    var profile = propertieUtility.getPropertyNumber("ColorProfile", 0);
    logger.debug(
      "AnalogView",
      "Initialize AnalogView - Update every second: " +
        updateEverySecond.toString()
    );
    updateEverySecond = propertieUtility.getPropertyBoolean(
      "UpdateSeconds",
      true
    );
    logger.debug(
      "AnalogView",
      "Initialize AnalogView - Update every second: " +
        updateEverySecond.toString()
    );

    if (profile == null) {
      profile = PROFILE_CLASSIC;
    }

    logger.debug(
      "AnalogView",
      "Initializing AnalogView with profile: " + profile.toString()
    );

    // Apply predefined profile or load custom values
    if (profile == PROFILE_CLASSIC) {
      applyClassicProfile();
    } else if (profile == PROFILE_BLUE_STEEL) {
      applyBlueSteelProfile();
    } else if (profile == PROFILE_GREEN_NATURE) {
      applyGreenNatureProfile();
    } else if (profile == PROFILE_GOLD_LUXURY) {
      applyGoldLuxuryProfile();
    } else if (profile == PROFILE_CUSTOM) {
      loadCustomColors();
    } else {
      applyClassicProfile(); // Default fallback
    }
  }

  private function applyClassicProfile() {
    logger.debug("AnalogView", "Applying Classic Profile");
    handbgcolor = 0x504949; // Dark gray
    handfgcolor = 0xff0000; // Red
    facebgcolor = 0x000000; // Black
    facebordercolor = 0xc0c0c0; // Silver
    handcentercolor = 0xff0000; // Red
    daybgcolor = 0x000000; // Black
    daynamecolor = 0xff3333; // Light red
    daynumbercolor = 0xa0a0a0; // Light gray
    dayoutlinecolor = 0xc0c0c0; // Silver
    hourmarkercolor = 0xffffff; // White
    minutetickcolor = 0xa0a0a0; // Light gray
    numbercolor = 0xffffff; // White
  }

  private function applyBlueSteelProfile() {
    logger.debug("AnalogView", "Applying Blue Steel Profile");
    handbgcolor = 0x2c3e50; // Dark blue-gray
    handfgcolor = 0x3498db; // Bright blue
    facebgcolor = 0x000000; // Black
    facebordercolor = 0x95a5a6; // Gray-blue
    handcentercolor = 0x3498db; // Bright blue
    daybgcolor = 0x000000; // Black
    daynamecolor = 0x5dade2; // Light blue
    daynumbercolor = 0xbdc3c7; // Light gray
    dayoutlinecolor = 0x95a5a6; // Gray-blue
    hourmarkercolor = 0xe8f8f5; // Off-white
    minutetickcolor = 0x85929e; // Medium gray
    numbercolor = 0xecf0f1; // Light gray-white
  }

  private function applyGreenNatureProfile() {
    logger.debug("AnalogView", "Applying Green Nature Profile");
    handbgcolor = 0x27371f; // Dark green
    handfgcolor = 0x7cb342; // Bright green
    facebgcolor = 0x000000; // Black
    facebordercolor = 0x8d6e63; // Brown
    handcentercolor = 0x7cb342; // Bright green
    daybgcolor = 0x000000; // Black
    daynamecolor = 0x9ccc65; // Light green
    daynumbercolor = 0xa1887f; // Light brown
    dayoutlinecolor = 0x8d6e63; // Brown
    hourmarkercolor = 0xf1f8e9; // Cream
    minutetickcolor = 0xa1887f; // Light brown
    numbercolor = 0xdcedc8; // Light green-white
  }

  private function applyGoldLuxuryProfile() {
    logger.debug("AnalogView", "Applying Gold Luxury Profile");
    handbgcolor = 0x3e2723; // Dark brown
    handfgcolor = 0xffd700; // Gold
    facebgcolor = 0x000000; // Black
    facebordercolor = 0xffd700; // Gold
    handcentercolor = 0xffd700; // Gold
    daybgcolor = 0x000000; // Black
    daynamecolor = 0xffeb3b; // Light gold
    daynumbercolor = 0xd7ccc8; // Beige
    dayoutlinecolor = 0xffd700; // Gold
    hourmarkercolor = 0xfffde7; // Cream
    minutetickcolor = 0xbcaaa4; // Light brown
    numbercolor = 0xfff9c4; // Light gold
  }

  private function loadCustomColors() {
    logger.debug("AnalogView", "Loading custom colors from properties");
    // Load each color from properties
    handbgcolor = propertieUtility.getPropertyNumber("HandBgColor", 0x504949);
    handfgcolor = propertieUtility.getPropertyNumber("HandFgColor", 0xff0000);
    facebgcolor = propertieUtility.getPropertyNumber("FaceBgColor", 0x000000);
    facebordercolor = propertieUtility.getPropertyNumber(
      "FaceBorderColor",
      0xc0c0c0
    );
    handcentercolor = propertieUtility.getPropertyNumber(
      "HandCenterColor",
      0xff0000
    );
    daybgcolor = propertieUtility.getPropertyNumber("DayBgColor", 0x000000);
    daynamecolor = propertieUtility.getPropertyNumber("DayNameColor", 0xff3333);
    daynumbercolor = propertieUtility.getPropertyNumber(
      "DayNumberColor",
      0xa0a0a0
    );
    dayoutlinecolor = propertieUtility.getPropertyNumber(
      "DayOutlineColor",
      0xc0c0c0
    );
    hourmarkercolor = propertieUtility.getPropertyNumber(
      "HourMarkerColor",
      0xffffff
    );
    minutetickcolor = propertieUtility.getPropertyNumber(
      "MinuteTickColor",
      0xa0a0a0
    );
    numbercolor = propertieUtility.getPropertyNumber("NumberColor", 0xffffff);
  }

  function onLayout(dc) {
    logger.debug("AnalogView", "Layout AnalogView");
    centerX = dc.getWidth() / 2;
    centerY = dc.getHeight() / 2;
    var minDimension = centerX < centerY ? centerX : centerY;
    radius = minDimension * 0.95;
  }

  function onUpdate(dc) {
    logger.debug("AnalogView", "Updating AnalogView display");
    if (centerX == 0 || centerY == 0) {
        onLayout(dc); // Safety fallback
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

  private function drawFace(dc) {
    // Dark background
    dc.setColor(facebgcolor, Graphics.COLOR_TRANSPARENT);
    dc.fillCircle(centerX, centerY, radius * 0.97);

    // Outer silver ring
    dc.setColor(facebordercolor, Graphics.COLOR_TRANSPARENT);
    dc.setPenWidth(radius * 0.06);
    dc.drawCircle(centerX, centerY, radius * 0.97);

    // Inner ring
    dc.setPenWidth(radius * 0.01);
    dc.drawCircle(centerX, centerY, radius * 0.9);

    // Center point
    dc.setColor(handcentercolor, Graphics.COLOR_TRANSPARENT);
    dc.fillCircle(centerX, centerY, radius * 0.04);
  }

  private function drawLoad(dc) {
    var startAngle = 90;
    var loadPercentage = System.getSystemStats().battery;
    var sweepAngle = (loadPercentage / 100.0) * 360;

    // Green portion (loaded)
    dc.setColor(Graphics.COLOR_GREEN, Graphics.COLOR_TRANSPARENT);
    dc.setPenWidth(radius * 0.05);
    dc.drawArc(
      centerX,
      centerY,
      radius * 0.92,
      Graphics.ARC_CLOCKWISE,
      startAngle,
      startAngle - sweepAngle
    );

    // Red portion (remaining)
    dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
    dc.drawArc(
      centerX,
      centerY,
      radius * 0.92,
      Graphics.ARC_CLOCKWISE,
      startAngle - sweepAngle,
      startAngle
    );
  }

  private function drawHourMarkers(dc) {
    var triangleHeight = radius * 0.07;
    var triangleBase = radius * 0.04;

    for (var i = 0; i < 12; i++) {
      var angle = (i * Math.PI) / 6;

      var cosAngle = Math.cos(angle);
      var sinAngle = Math.sin(angle);
      var perpAngle = angle + Math.PI / 2;
      var cosPerAngle = Math.cos(perpAngle);
      var sinPerAngle = Math.sin(perpAngle);

      var xOuter = centerX + cosAngle * radius * 0.88;
      var yOuter = centerY + sinAngle * radius * 0.88;

      var xBase1 = xOuter + cosPerAngle * (triangleBase / 2);
      var yBase1 = yOuter + sinPerAngle * (triangleBase / 2);
      var xBase2 = xOuter - cosPerAngle * (triangleBase / 2);
      var yBase2 = yOuter - sinPerAngle * (triangleBase / 2);

      var xTip = centerX + cosAngle * (radius * 0.88 - triangleHeight);
      var yTip = centerY + sinAngle * (radius * 0.88 - triangleHeight);

      dc.setColor(hourmarkercolor, Graphics.COLOR_TRANSPARENT);
      dc.fillPolygon([
        [xBase1, yBase1],
        [xBase2, yBase2],
        [xTip, yTip],
      ]);
    }
  }

  private function drawMinuteTicks(dc) {
    var tickLength = radius * 0.04;

    dc.setColor(minutetickcolor, Graphics.COLOR_TRANSPARENT);
    dc.setPenWidth(radius * 0.008);

    for (var i = 0; i < 60; i++) {
      if (i % 5 != 0) {
        var angle = (i * Math.PI) / 30;

        var cosAngle = Math.cos(angle);
        var sinAngle = Math.sin(angle);

        var xStart = centerX + cosAngle * radius * 0.88;
        var yStart = centerY + sinAngle * radius * 0.88;
        var xEnd = centerX + cosAngle * (radius * 0.88 - tickLength);
        var yEnd = centerY + sinAngle * (radius * 0.88 - tickLength);

        dc.drawLine(xStart, yStart, xEnd, yEnd);
      }
    }
  }

  private function drawNumbers(dc) {
    dc.setColor(numbercolor, Graphics.COLOR_TRANSPARENT);
    var font = Graphics.FONT_XTINY;
    var numbers = [12, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11];

    for (var i = 0; i < 12; i++) {
      var angle = (i * Math.PI) / 6 - Math.PI / 2;
      var cosAngle = Math.cos(angle);
      var sinAngle = Math.sin(angle);

      var x = centerX + cosAngle * radius * 0.7;
      var y = centerY + sinAngle * radius * 0.7;

      dc.drawText(
        x,
        y,
        font,
        numbers[i].toString(),
        Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
      );
    }
  }

  private function drawDateInfo(dc) {
    var now = Gregorian.info(Time.now(), Time.FORMAT_LONG);
    var weekday = Lang.format("$1$", [now.day_of_week]);
    var dayNum = now.day;
    var dayString = dayNum < 10 ? "0" + dayNum.toString() : dayNum.toString();

    var centerYPos = centerY.toNumber();

    var font = Graphics.FONT_XTINY;
    var boxNumberWidth = dc.getTextWidthInPixels(dayString, font);
    var boxWeekdayWidth = dc.getTextWidthInPixels(weekday, font);

    var boxHeight = (radius * 0.16).toNumber();
    var boxSpacing = (radius * 0.03).toNumber();

    // Weekday box (left) for instance "Ma" "Mon" for Maandag, Monday
    var maxlen = centerX + radius * 0.65;
    var boxDNumberX = maxlen - boxNumberWidth; // date number
    var boxWDNameX = maxlen - boxWeekdayWidth - boxNumberWidth - boxSpacing; // weekday name

    var boxY = centerYPos - boxHeight / 2;

    dc.setColor(daybgcolor, Graphics.COLOR_TRANSPARENT);
    dc.fillRectangle(boxWDNameX, boxY, boxWeekdayWidth, boxHeight);

    dc.setColor(dayoutlinecolor, Graphics.COLOR_TRANSPARENT);
    dc.setPenWidth((radius * 0.008).toNumber());
    dc.drawRectangle(boxWDNameX, boxY, boxWeekdayWidth, boxHeight);

    dc.setColor(daynamecolor, Graphics.COLOR_TRANSPARENT);
    dc.drawText(
      boxWDNameX + boxWeekdayWidth / 2,
      centerYPos,
      font,
      weekday,
      Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
    );

    // Day box (right)
    dc.setColor(daybgcolor, Graphics.COLOR_TRANSPARENT);
    dc.fillRectangle(boxDNumberX, boxY, boxNumberWidth, boxHeight);

    dc.setColor(dayoutlinecolor, Graphics.COLOR_TRANSPARENT);
    dc.setPenWidth((radius * 0.008).toNumber());
    dc.drawRectangle(boxDNumberX, boxY, boxNumberWidth, boxHeight);

    dc.setColor(daynumbercolor, Graphics.COLOR_TRANSPARENT);
    dc.drawText(
      boxDNumberX + boxNumberWidth / 2,
      centerYPos,
      font,
      dayString,
      Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
    );
  }

  private function drawTime(dc) {
    var clockTime = System.getClockTime();
    var hour = clockTime.hour % 12;
    var minute = clockTime.min;
    var second = clockTime.sec;

    // Hour hand
    var hourAngle =
      (hour * Math.PI) / 6 + (minute * Math.PI) / 360 - Math.PI / 2;
    drawHand(dc, hourAngle, radius * 0.55, radius * 0.035);

    // Minute hand
    var minuteAngle =
      (minute * Math.PI) / 30 + (second * Math.PI) / 1800 - Math.PI / 2;
    drawHand(dc, minuteAngle, radius * 0.7, radius * 0.025);

    if (updateEverySecond) {
      // Second hand
      var secondAngle = (second * Math.PI) / 30 - Math.PI / 2;
      dc.setColor(handfgcolor, Graphics.COLOR_TRANSPARENT);
      dc.setPenWidth(radius * 0.025);
      var x1 = centerX - Math.cos(secondAngle) * radius * 0.1;
      var y1 = centerY - Math.sin(secondAngle) * radius * 0.1;
      var x2 = centerX + Math.cos(secondAngle) * radius * 0.75;
      var y2 = centerY + Math.sin(secondAngle) * radius * 0.75;
      dc.drawLine(x1, y1, x2, y2);
    }
  }

  private function drawHand(dc, angle, length, width) {
    var cosAngle = Math.cos(angle);
    var sinAngle = Math.sin(angle);
    var l = length;
    var w = width;

    // Outline hand
    var points = [
      [centerX, centerY],
      [centerX - sinAngle * w * 0.5, centerY + cosAngle * w * 0.5],
      [
        centerX + (cosAngle * l) / 15 - sinAngle * w * 0.5,
        centerY + (sinAngle * l) / 15 + cosAngle * w * 0.5,
      ],
      [
        centerX + (cosAngle * 2 * l) / 15 - sinAngle * w * 1.5,
        centerY + (sinAngle * 2 * l) / 15 + cosAngle * w * 1.5,
      ],
      [
        centerX + (cosAngle * 10 * l) / 15 - sinAngle * w * 1.5,
        centerY + (sinAngle * 10 * l) / 15 + cosAngle * w * 1.5,
      ],
      [
        centerX + (cosAngle * 11 * l) / 15 - sinAngle * w * 0.5,
        centerY + (sinAngle * 11 * l) / 15 + cosAngle * w * 0.5,
      ],
      [
        centerX + cosAngle * l - sinAngle * w * 0.5,
        centerY + sinAngle * l + cosAngle * w * 0.5,
      ],
      [
        centerX + cosAngle * l + sinAngle * w * 0.5,
        centerY + sinAngle * l - cosAngle * w * 0.5,
      ],
      [
        centerX + (cosAngle * 11 * l) / 15 + sinAngle * w * 0.5,
        centerY + (sinAngle * 11 * l) / 15 - cosAngle * w * 0.5,
      ],
      [
        centerX + (cosAngle * 10 * l) / 15 + sinAngle * w * 1.5,
        centerY + (sinAngle * 10 * l) / 15 - cosAngle * w * 1.5,
      ],
      [
        centerX + (cosAngle * 2 * l) / 15 + sinAngle * w * 1.5,
        centerY + (sinAngle * 2 * l) / 15 - cosAngle * w * 1.5,
      ],
      [
        centerX + (cosAngle * l) / 15 + sinAngle * w * 0.5,
        centerY + (sinAngle * l) / 15 - cosAngle * w * 0.5,
      ],
      [centerX + sinAngle * w * 0.5, centerY - cosAngle * w * 0.5],
      [centerX, centerY],
    ];

    dc.setColor(handbgcolor, Graphics.COLOR_TRANSPARENT);
    dc.fillPolygon(points);

    // Inside line hand
    var innerPoints = [
      [centerX + (cosAngle * 2 * l) / 15, centerY + (sinAngle * 2 * l) / 15],
      [
        centerX + (cosAngle * 2.8 * l) / 15 - sinAngle * w * 0.8,
        centerY + (sinAngle * 2.8 * l) / 15 + cosAngle * w * 0.8,
      ],
      [
        centerX + (cosAngle * 9.2 * l) / 15 - sinAngle * w * 0.8,
        centerY + (sinAngle * 9.2 * l) / 15 + cosAngle * w * 0.8,
      ],
      [
        centerX + (cosAngle * 10.2 * l) / 15,
        centerY + (sinAngle * 10.2 * l) / 15,
      ],
      [
        centerX + (cosAngle * 9.2 * l) / 15 + sinAngle * w * 0.8,
        centerY + (sinAngle * 9.2 * l) / 15 - cosAngle * w * 0.8,
      ],
      [
        centerX + (cosAngle * 2.8 * l) / 15 + sinAngle * w * 0.8,
        centerY + (sinAngle * 2.8 * l) / 15 - cosAngle * w * 0.8,
      ],
      [centerX + (cosAngle * 2 * l) / 15, centerY + (sinAngle * 2 * l) / 15],
    ];

    dc.setColor(handfgcolor, Graphics.COLOR_TRANSPARENT);
    dc.fillPolygon(innerPoints);
  }

  function onEnterSleep() {
    logger.debug("AnalogView", "Entering sleep mode");
  }

  function onExitSleep() {
    logger.debug("AnalogView", "Exiting sleep mode");
  }
}

// Global convenience function
function getAnalogView() as AnalogView {
  return AnalogView.getInstance();
}
