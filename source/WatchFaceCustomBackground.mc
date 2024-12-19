import Toybox.Application;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;

class Background extends WatchUi.Drawable {

    function initialize() {
        var dictionary = {
            :identifier => "Background"
        };

        Drawable.initialize(dictionary);
    }

    function draw(dc as Dc) as Void {
        // set the Background color to Black, disabled because worthles
        //dc.setColor(Graphics.COLOR_TRANSPARENT, getApp().getProperty("BackgroundColor") as Number);
        dc.drawBitmap(0, 0, loadResource(Rez.Drawables.BackgroundPng));
        // clears the entire screen, so deletes all, disabled be cause the background must be visible
        //dc.clear();
    }

}
