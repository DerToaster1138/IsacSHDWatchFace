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
    var activityInformation;
    var DeviceSettings;

    var _backgroundAnimationLayer as AnimationLayer;
    var _drawLayer as Layer;
    var _circleLayer as Layer;
    var circleX;
    var circleY;
    var _playing = false;
    
    function initialize() {

        WatchFace.initialize();
        weatherdata = Weather.getCurrentConditions();
        sysStats = System.getSystemStats();
        activityInformation = ActivityMonitor.getInfo();
        DeviceSettings = System.getDeviceSettings();

        circleY = (DeviceSettings.screenHeight / 2);
        circleX = (DeviceSettings.screenWidth / 2);

        _backgroundAnimationLayer = new AnimationLayer($.Rez.Drawables.isacbg, 
        {
            :locX => 0,
            :locY => 0,
            :width => DeviceSettings.screenWidth,
            :height => DeviceSettings.screenHeight,
        });
        _drawLayer = new WatchUi.Layer({
            :locX=> 0,
            :locY=> 0,
            :width=> DeviceSettings.screenWidth,
            :height=> DeviceSettings.screenHeight});
        
        _circleLayer = new WatchUi.Layer({
            :locX=> 0,
            :locY=> 0,
            :width=> DeviceSettings.screenWidth,
            :height=> DeviceSettings.screenHeight});
    }

    // Load your resources here
    function onLayout(dc as Dc) as Void {
        dc.setColor(Application.Properties.getValue("ForegroundColor") as Number, Graphics.COLOR_TRANSPARENT);
        dc.clear();
        addLayer(_backgroundAnimationLayer);
        setLayout($.Rez.Layouts.WatchFace(_drawLayer.getDc()));
        insertLayer(_drawLayer,1);
        insertLayer(_circleLayer,2);
    }

    function onShow() as Void {
    play(); // Start animation when shown
    }

    public function play() as Void
    {
        if(!_playing)
        {
            _backgroundAnimationLayer.play({
                :delegate => new AnimationDelegate(self)
            });
            _playing = true;
        }
    }
    // Update the view
    function onUpdate(dc as Dc) as Void {
        updateWatchOverlay(true, dc);
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() as Void {
        _backgroundAnimationLayer.stop();
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

            activityInformation = ActivityMonitor.getInfo();
            // Update the time
            var timeString = updateTime(_isFullUpdate);
            var time = View.findDrawableById("TimeLabel") as Text;
            time.setColor(Application.Properties.getValue("ForegroundColor") as Number);
            time.setText(timeString);

            // Update Step Counter
            var stepString = getSteps();
            var stepsTaken = View.findDrawableById("Steps") as Text;
            stepsTaken.setColor(Application.Properties.getValue("ForegroundColor") as Number);
            stepsTaken.setText(stepString);

            // Update HeartRate
            var hr = getHeartRate();
            var hrNow = View.findDrawableById("Heartrate") as Text;
            hrNow.setColor(Application.Properties.getValue("ForegroundColor") as Number);
            hrNow.setText(hr);

            if (_isFullUpdate) 
            {
                // Get the current weather data and system stats
                weatherdata = Weather.getCurrentConditions();
                sysStats = System.getSystemStats();
                batChargeNum = sysStats.battery.toNumber();

                // Get Stress Score
                var stress = getStressScore();
                var stressCurrent = View.findDrawableById("Stress") as Text;
                stressCurrent.setColor(Application.Properties.getValue("ForegroundColor") as Number);
                stressCurrent.setText(stress);

                // Update the rain chance
                var rainString = getRainChance();
                var riskOfRain = View.findDrawableById("RainChance") as Text;
                riskOfRain.setColor(Application.Properties.getValue("ForegroundColor") as Number);
                riskOfRain.setText(rainString);

                //get Date Information

                var date = View.findDrawableById("DateTime") as Text;
                date.setColor(Application.Properties.getValue("ForegroundColor") as Number);
                date.setText(getCurrentDate());

                // Draw Battery

                var batCharge =  View.findDrawableById("BatCharge") as Text;
                batCharge.setColor(Application.Properties.getValue("ForegroundColor") as Number);
                batCharge.setText(batteryCharge());

                //get Temperature by reusing WeatherData
                currentTemperature = weatherdata.temperature.toNumber() ;
                var temperatureString = Lang.format(WatchUi.loadResource(Rez.Strings.TemperatureFormat), [currentTemperature]);
                var temperatureText = View.findDrawableById("CurrentTemps") as Text;
                temperatureText.setColor(Application.Properties.getValue("ForegroundColor") as Number);
                temperatureText.setText(temperatureString);
            } 
        
            View.drawLayout(dc);
            _circleLayer.getDc().clear();
            dc = _circleLayer.getDc();
            dc.setPenWidth(20);
            dc.drawCircle(circleX, circleY, circleX);
            _backgroundAnimationLayer.setVisible(true);
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

    function getSteps() as Lang.String
    {
        var steps = activityInformation.steps;
        var stepString = Lang.format(WatchUi.loadResource(Rez.Strings.stepFormat),[steps]);
        return stepString;
    }

    function getHeartRate() as Lang.String
    {
        var hr = ActivityMonitor.getHeartRateHistory(null,true);
        var sample = hr.next();
        var hrString = Lang.format(WatchUi.loadResource(Rez.Strings.hrFormat), [sample.heartRate]);
        return hrString;
    }

    function getStressScore() as Lang.String
    {
        var stress = activityInformation.stressScore;
        if(stress == null)
        {
            stress = 0;
        }
        var stressString = Lang.format(WatchUi.loadResource(Rez.Strings.stressFormat),[stress]);
        return stressString;
    }

    function getCurrentDate() as Lang.String
    {
        var today = new Time.Moment(Time.now().value());
        var details = Gregorian.info(today, Time.FORMAT_MEDIUM);
        var day = details.day as Number;
        var month = details.month as Text;
        var year = details.year as Number;
        var datestring = Lang.format(WatchUi.loadResource(Rez.Strings.DateFormat), [day, month, year]);
        return datestring;
    }

    function batteryCharge() as Lang.String
    {
        var charging = sysStats.charging;
        batChargeNum = sysStats.battery.toNumber();
        if(charging)
        {
            batChargeNum = "CHRG";
        }
        var batChargeText = Lang.format(WatchUi.loadResource(Rez.Strings.batChargeFormat), [batChargeNum]);
        return batChargeText;
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

class AnimationDelegate extends WatchUi.AnimationDelegate {

    var _controller;

    function initialize(controller){
        AnimationDelegate.initialize();
        _controller = controller;
    }

    function onAnimationEvent(event, options){
        switch(event) {
            case WatchUi.ANIMATION_EVENT_COMPLETE:
                _controller._playing = false;
                _controller.play();
                break;
            case WatchUi.ANIMATION_EVENT_CANCELED:
                break;
        }
    }
}