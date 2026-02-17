import Toybox.WatchUi;
import Toybox.Graphics;
import Toybox.System;
import Toybox.Lang;

class decimal_clock_for_garminView extends WatchUi.WatchFace {

    function initialize() {
        WatchFace.initialize();
    }

    function onLayout(dc as Dc) as Void {
        // ציור ידני
    }

    function onUpdate(dc as Dc) as Void {
        var width  = dc.getWidth();
        var height = dc.getHeight();
        var cx = width  / 2;
        var cy = height / 2;

        // --- 1. רקע שחור ---
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();

        // --- 2. חישוב הזמן העשרוני ---
        var clockTime = System.getClockTime();

        // סך השניות מתחילת היום כ-double
        var totalSec   = clockTime.hour.toDouble() * 3600.0
                       + clockTime.min.toDouble()  * 60.0
                       + clockTime.sec.toDouble();
        var dayPercent = totalSec / 86400.0;   // 0.0 – 1.0

        // 100,000 יחידות עשרוניות ביום
        var decTotal = dayPercent * 100000.0;
        var dHour    = (decTotal / 10000.0).toNumber();          // 0–9
        var dMin     = ((decTotal - dHour.toDouble() * 10000.0) / 100.0).toNumber(); // 0–99
        var dSec     = (decTotal - dHour.toDouble() * 10000.0 - dMin.toDouble() * 100.0).toNumber(); // 0–99

        // --- 3. זוויות מחוגים (מעלות, 0° = למעלה) ---

        // מחוג שעות: כל שעה עשרונית = 36°, דקות מוסיפות עד 36°
        var hourAngle = dHour.toDouble() * 36.0
                      + dMin.toDouble() / 100.0 * 36.0;

        // מחוג דקות: כל דקה עשרונית = 3.6°, שניות מוסיפות קצת
        var minAngle = dMin.toDouble() * 3.6
                     + dSec.toDouble() / 100.0 * 3.6;

        // מחוג שניות: כל שנייה עשרונית = 3.6°
        var secAngle = dSec.toDouble() * 3.6;

        // --- 4. גיאומטריה ---
        var radius  = (width < height ? width : height) / 2 - 4;
        var hourLen = (radius.toDouble() * 0.5).toNumber();
        var minLen  = (radius.toDouble() * 0.72).toNumber();
        var secLen  = (radius.toDouble() * 0.86).toNumber();

        // --- 5. עיגול חיצוני ---
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(2);
        dc.drawCircle(cx, cy, radius);

        // --- 6. מספרים 0–9 ---
        var numR    = radius - 14;
        var numbers = ["0","1","2","3","4","5","6","7","8","9"];
        for (var i = 0; i < 10; i++) {
            var ang = (i * 36.0 - 90.0) * (Math.PI / 180.0);
            var nx  = (cx.toDouble() + numR.toDouble() * Math.cos(ang)).toNumber();
            var ny  = (cy.toDouble() + numR.toDouble() * Math.sin(ang)).toNumber();
            dc.drawText(nx, ny, Graphics.FONT_XTINY, numbers[i],
                        Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        }

        // --- 7. מחוג שעות (צהוב, עבה וקצר) ---
        var hRad = (hourAngle - 90.0) * (Math.PI / 180.0);
        dc.setColor(Graphics.COLOR_YELLOW, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(5);
        dc.drawLine(
            cx, cy,
            (cx.toDouble() + hourLen.toDouble() * Math.cos(hRad)).toNumber(),
            (cy.toDouble() + hourLen.toDouble() * Math.sin(hRad)).toNumber()
        );

        // --- 8. מחוג דקות (לבן, בינוני) ---
        var mRad = (minAngle - 90.0) * (Math.PI / 180.0);
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(3);
        dc.drawLine(
            cx, cy,
            (cx.toDouble() + minLen.toDouble() * Math.cos(mRad)).toNumber(),
            (cy.toDouble() + minLen.toDouble() * Math.sin(mRad)).toNumber()
        );

        // --- 9. מחוג שניות (כחול, דק + זנב) ---
        var sRad = (secAngle - 90.0) * (Math.PI / 180.0);
        dc.setColor(Graphics.COLOR_BLUE, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(2);
        dc.drawLine(
            cx, cy,
            (cx.toDouble() + secLen.toDouble() * Math.cos(sRad)).toNumber(),
            (cy.toDouble() + secLen.toDouble() * Math.sin(sRad)).toNumber()
        );
        dc.drawLine(
            cx, cy,
            (cx.toDouble() - secLen.toDouble() * 0.2 * Math.cos(sRad)).toNumber(),
            (cy.toDouble() - secLen.toDouble() * 0.2 * Math.sin(sRad)).toNumber()
        );

        // --- 10. נקודת מרכז ---
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.fillCircle(cx, cy, 5);

        // --- 11. שעה דיגיטלית קטנה בתחתית ---
        var timeStr = Lang.format("$1$:$2$:$3$", [
            dHour,
            dMin.format("%02d"),
            dSec.format("%02d")
        ]);
        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, cy + (radius.toDouble() * 0.45).toNumber(),
                    Graphics.FONT_TINY, timeStr, Graphics.TEXT_JUSTIFY_CENTER);
    }
}
