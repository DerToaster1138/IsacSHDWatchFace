import Toybox.Application;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;
import Toybox.Weather;

class WatchFaceCustomView extends WatchUi.WatchFace {

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
        var rainFormat = "$1$ R%";
        var weatherdata = Weather.getCurrentConditions();
        var rainfallChance = weatherdata.precipitationChance;
        var rainString = Lang.format(rainFormat, [rainfallChance]);

        //get Temperature by reusing WeatherData
        var temperatureFormat = "$1$°C";
        var currentTemperature = weatherdata.temperature;
        currentTemperature = currentTemperature.toNumber();
        var temperatureString = Lang.format(temperatureFormat, [currentTemperature]);

        //TODO 1: get BatteryCharge


        //Draw RainChance
        var riskOfRain = View.findDrawableById("RainChance") as Text;
        riskOfRain.setColor(Application.Properties.getValue("ForegroundColor") as Number);
        riskOfRain.setText(rainString);

        //Draw Temperature
        var temperatureText = View.findDrawableById("CurrentTemps") as Text;
        temperatureText.setColor(Application.Properties.getValue("ForegroundColor") as Number);
        temperatureText.setText(temperatureString);

        //TODO 2: Draw BatteryCharge
    }

    // Update the view
    function onUpdate(dc as Dc) as Void {
        // Get the current time and format it correctly
        var timeFormat = "$1$:$2$:$3$";
        var clockTime = System.getClockTime();
        var hours = clockTime.hour;
        if (!System.getDeviceSettings().is24Hour) {
            if (hours > 12) {
                hours = hours - 12;
            }
        } else {
            if (Application.Properties.getValue("UseMilitaryFormat")) {
                timeFormat = "$1$$2$$3$";
                hours = hours.format("%02d");
            }
        }
        var timeString = Lang.format(timeFormat, [hours, clockTime.min.format("%02d"), clockTime.sec]);

        // Update the view
        var view = View.findDrawableById("TimeLabel") as Text;
        view.setColor(Application.Properties.getValue("ForegroundColor") as Number);
        view.setText(timeString);

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
    }

    // Terminate any active timers and prepare for slow updates.
    function onEnterSleep() as Void {
    }

}
