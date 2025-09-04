import Toybox.Application;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;
import Toybox.Weather;
import Toybox.Time;

class WatchFaceCustomView extends WatchUi.WatchFace {

    var weatherdata;
    var currentTemperature;
    var sysStats;
    var batChargeNum;

    var _backgroundAnimationLayer as AnimationLayer;
    private var _drawLayer as Layer;
    var iterationCount as Number = 0;
    var returncount as Number = 0;

    function initialize() {
        WatchFace.initialize();
        weatherdata = Weather.getCurrentConditions();
        currentTemperature = weatherdata.temperature;
        sysStats = System.getSystemStats();
        batChargeNum = sysStats.battery.toNumber();

        _backgroundAnimationLayer = new AnimationLayer($.Rez.Drawables.isacbg, 
        {
            :locX => 0,
            :locY => 0,
            :width => 416,
            :height => 416,
        });
        _drawLayer = new WatchUi.Layer({
            :locX=> 0,
            :locY=> 0,
            :width=> 416,
            :height=> 416});
    }

    // Load your resources here
    function onLayout(dc as Dc) as Void {
    dc.setColor(Application.Properties.getValue("ForegroundColor") as Number, Graphics.COLOR_TRANSPARENT);
    dc.clear();
    addLayer(_backgroundAnimationLayer);
    setLayout($.Rez.Layouts.WatchFace(_drawLayer.getDc()));
    insertLayer(_drawLayer,1);
    }

    function onShow() as Void {
    _backgroundAnimationLayer.play(null); // Start animation when shown
    }

    public function play() as Void
    {
        if(!_backgroundAnimationLayer.play(null))
        {}
        
    }
    // Update the view
    function onUpdate(dc as Dc) as Void {
    updateWatchOverlay(true, dc);
    }

    function onPartialUpdate(dc as Dc) as Void {
        updateWatchOverlay(false, dc);
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() as Void {
    }

    // Request an update of the watch face
    private function updateWatchOverlay(_isFullUpdate as Boolean, dc as Dc) as Void {
        // Clear the draw layer
        _drawLayer.getDc().clear();
        // get the Device Context for the drawLayer
        dc = _drawLayer.getDc();
        // If the drawLayerDc is not null, update
        if (dc != null) 
        {
            // Update the time
            var timeString = updateTime(_isFullUpdate);
            var time = View.findDrawableById("TimeLabel") as Text;
            time.setColor(Application.Properties.getValue("ForegroundColor") as Number);
            time.setText(timeString);

            if (_isFullUpdate) 
            {
                // Get the current weather data and system stats
                weatherdata = Weather.getCurrentConditions();
                sysStats = System.getSystemStats();
                batChargeNum = sysStats.battery.toNumber();

                // Update the rain chance
                var rainString = getRainChance();
                var riskOfRain = View.findDrawableById("RainChance") as Text;
                riskOfRain.setColor(Application.Properties.getValue("ForegroundColor") as Number);
                riskOfRain.setText(rainString);

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

                // Draw Battery
                var batChargeText = Lang.format(WatchUi.loadResource(Rez.Strings.batChargeFormat), [batChargeNum]);
                var batCharge =  View.findDrawableById("BatCharge") as Text;
                batCharge.setColor(Application.Properties.getValue("ForegroundColor") as Number);
                batCharge.setText(batChargeText);

                //get Temperature by reusing WeatherData
                currentTemperature = weatherdata.temperature.toNumber() ;
                var temperatureString = Lang.format(WatchUi.loadResource(Rez.Strings.TemperatureFormat), [currentTemperature]);
                var temperatureText = View.findDrawableById("CurrentTemps") as Text;
                temperatureText.setColor(Application.Properties.getValue("ForegroundColor") as Number);
                temperatureText.setText(temperatureString);
            } 

            _backgroundAnimationLayer.setVisible(true);
            View.drawLayout(dc);
            returncount++;
        }
    }

    function updateTime(fullupdate as Boolean) as Lang.String 
    {
            // Get current Time
            var clockTime = System.getClockTime();
            var hours = clockTime.hour;
            var seconds = clockTime.sec;
            if (!System.getDeviceSettings().is24Hour) 
                {
                    if (hours > 12) 
                    {
                    hours = hours - 12;
                }
            }   
            else
            {
                if (hours < 10) 
                {
                    hours = "0" + hours;
                }
                if(seconds < 10) 
                {
                    seconds = "0" + seconds;
                }
            }
            var timeString = Lang.format(WatchUi.loadResource(Rez.Strings.timeFormat), [hours, clockTime.min.format("%02d"), seconds]);
            return timeString;
    }

    function getRainChance() as Lang.String
    {
        var rainfallChance = weatherdata.precipitationChance;
        var rainString = Lang.format(WatchUi.loadResource(Rez.Strings.rainFormat), [rainfallChance]);
        return rainString;
    }

    // The user has just looked at their watch. Timers and animations may be started here.
    function onExitSleep() as Void {
        requestUpdate();
        _backgroundAnimationLayer.play(null); // Restart animation when exiting sleep
    }

    // Terminate any active timers and prepare for slow updates.
    function onEnterSleep() as Void {
        _backgroundAnimationLayer.stop(); // Stop animation when entering sleep
    }

}