import Toybox.Application;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;
using Toybox.System;

class Background extends WatchUi.Drawable {

    function initialize() {
        var dictionary = {
            :identifier => "",
            :locX => 0,
            :locY => 0
        };

        Drawable.initialize(dictionary);
    }

    function draw(dc as Dc) as Void {
        dc.setColor(Application.Properties.getValue("ForegroundColor") as Number, Graphics.COLOR_TRANSPARENT);
        dc.clear();
    }

}