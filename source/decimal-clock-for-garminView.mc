import Toybox.WatchUi;
import Toybox.Graphics;
import Toybox.System;
import Toybox.Lang;

class decimal_clock_for_garminView extends WatchUi.WatchFace {

    function initialize() {
        WatchFace.initialize();
    }

    // טעינת ה-Layout שהגדרת ב-XML
    function onLayout(dc as Dc) as Void {
        setLayout(Rez.Layouts.WatchFace(dc));
    }

    // פונקציה שרצה בכל פעם שהמסך מתרענן (לפחות פעם בדקה)
    function onUpdate(dc as Dc) as Void {
        // 1. השגת זמן המערכת (שעות, דקות, שניות)
        var clockTime = System.getClockTime();
        
        // 2. חישוב סך השניות שעברו מתחילת היום (0 עד 86,400)
        var totalSeconds = (clockTime.hour * 3600) + (clockTime.min * 60) + clockTime.sec;

        // 3. המרה לזמן עשרוני (לפי הלוגיקה של ה-HTML שלך)
        // יום עשרוני מלא הוא 100,000 יחידות
        var decimalTotal = (totalSeconds.toDouble() / 86400.0) * 100000.0;
        
        // פירוק ליחידות (ספרה ראשונה, שתי ספרות אמצעיות, שתי ספרות אחרונות)
        var dHour = (decimalTotal / 10000).toNumber(); // 0-9
        var dMin = (decimalTotal.toNumber() % 10000) / 100; // 00-99
        var dSec = decimalTotal.toNumber() % 100; // 00-99

        // 4. בניית המחרוזת להצגה (פורמט X:XX:XX)
        var timeString = Lang.format("$1$:$2$:$3$", [
            dHour,
            dMin.format("%02d"),
            dSec.format("%02d")
        ]);

        // 5. מציאת ה-Label מה-Layout ועדכון הטקסט שלו
        var view = View.findDrawableById("TimeLabel") as Text;
        view.setText(timeString);

        // 6. קריאה לפונקציה של המערכת שתצייר הכל
        View.onUpdate(dc);
    }
}