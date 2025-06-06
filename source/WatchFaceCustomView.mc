import Toybox.Application;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;
import Toybox.Weather;
import Toybox.Time;

class WatchFaceCustomView extends WatchUi.WatchFace {

    var weatherdata = Weather.getCurrentConditions();
    var currentTemperature = weatherdata.temperature;
    var sysStats = System.getSystemStats();
    var batChargeNum = sysStats.battery.toNumber();

    function initialize() {
        WatchFace.initialize();
    }

    // Load your resources here
    function onLayout(dc as Dc) as Void {
        setLayout(Rez.Layouts.WatchFace(dc));
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() as Void {
        
        // get Rain chance from WeatherData
        var rainfallChance = weatherdata.precipitationChance;
        var rainString = Lang.format(WatchUi.loadResource(Rez.Strings.rainFormat), [rainfallChance]);

        //get Date Information
        var today = new Time.Moment(Time.now().value());
        var details = Gregorian.info(today, Time.FORMAT_MEDIUM);
        var day = details.day as Number;
        var month = details.month as Text;
        var year = details.year as Number;
        var datestring = Lang.format(WatchUi.loadResource(Rez.Strings.DateFormat), [day, month, year]);
        var date = View.findDrawableById("DateTime") as Text;
        date.setColor(Application.Properties.getValue("ForegroundColor") as Number);
        date.setText(datestring);

        //Draw RainChance
        var riskOfRain = View.findDrawableById("RainChance") as Text;
        riskOfRain.setColor(Application.Properties.getValue("ForegroundColor") as Number);
        riskOfRain.setText(rainString);

    }

    // Update the view
    function onUpdate(dc as Dc) as Void {

        //get Date Information
        var today = new Time.Moment(Time.now().value());
        var details = Gregorian.info(today, Time.FORMAT_MEDIUM);
        var day = details.day as Number;
        var month = details.month as Text;
        var year = details.year as Number;
        var datestring = Lang.format(WatchUi.loadResource(Rez.Strings.DateFormat), [day, month, year]);
        var date = View.findDrawableById("DateTime") as Text;
        date.setColor(Application.Properties.getValue("ForegroundColor") as Number);
        date.setText(datestring);

        // Get the current weather data and system stats
        weatherdata = Weather.getCurrentConditions();
        sysStats = System.getSystemStats();
        batChargeNum = sysStats.battery.toNumber();
        // Get the current time and format it correctly
        var clockTime = System.getClockTime();
        var hours = clockTime.hour;
        var seconds = clockTime.sec;
        if (!System.getDeviceSettings().is24Hour) {
            if (hours > 12) {
                hours = hours - 12;

            }
        }
        else{    
            if (hours < 10) {
                hours = "0" + hours;
            }
            if(seconds < 10) {
                seconds = "0" + seconds;
            }
        }
        var timeString = Lang.format(WatchUi.loadResource(Rez.Strings.timeFormat), [hours, clockTime.min.format("%02d"), seconds]);

        // Update the view
        var view = View.findDrawableById("TimeLabel") as Text;
        view.setColor(Application.Properties.getValue("ForegroundColor") as Number);
        view.setText(timeString);

        // Draw Battery
        var batChargeText = Lang.format(WatchUi.loadResource(Rez.Strings.batChargeFormat), [batChargeNum]);
        var batCharge =  View.findDrawableById("BatCharge") as Text;
        batCharge.setColor(Application.Properties.getValue("ForegroundColor") as Number);
        batCharge.setText(batChargeText);

        //get Temperature by reusing WeatherData
        currentTemperature = weatherdata.temperature;
        currentTemperature = currentTemperature.toNumber();
        var temperatureString = Lang.format(WatchUi.loadResource(Rez.Strings.TemperatureFormat), [currentTemperature]);
        var temperatureText = View.findDrawableById("CurrentTemps") as Text;
        temperatureText.setColor(Application.Properties.getValue("ForegroundColor") as Number);
        temperatureText.setText(temperatureString);

        // Call the parent onUpdate function to redraw the layout
        View.onUpdate(dc);
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() as Void {
    }


    // The user has just looked at their watch. Timers and animations may be started here.
    function onExitSleep() as Void {
        requestUpdate();
    }

    // Terminate any active timers and prepare for slow updates.
    function onEnterSleep() as Void {
    }

}
