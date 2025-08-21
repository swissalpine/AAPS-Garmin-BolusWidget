using Toybox.Graphics as Gfx;
using Toybox.WatchUi as Ui;
using Toybox.System as Sys;
using Toybox.Communications as Comm;

var bolus = 0.0;
var error = null;
var abfrage = 1; // 1: start, 2: selected, 3: waiting, 4: finished
var circle, errorCircle = false;

class MyBehaviorDelegate extends Ui.BehaviorDelegate {

    function initialize() {
        BehaviorDelegate.initialize();
        circle = Gfx.COLOR_BLACK;
    }

    // Detect Menu button input
    function onKey(keyEvent) {
        System.println(keyEvent.getKey()); // e.g. KEY_MENU = 7, Start = 4
        if( keyEvent.getKey() == 4 ) {
            if( abfrage == 1 ) {
                onMenu();
            } else if( abfrage == 2 ) {
                frageURL();
                error = "Contacting\nAAPS...";
            } else if ( abfrage == 3 ) {
                error = "Waiting for\nAAPS...";
            } else {
                error = "Click SELECT to start!";
                abfrage = 1;
                bolus = 0.0;
                circle = Gfx.COLOR_BLACK;
            }
            Ui.requestUpdate();
        }
        return false;
    }

    // Same function as onKey()
    function onHold(touchEvent) {
        if( abfrage == 1 ) {
            onMenu();
        } else if( abfrage == 2 ) {
            frageURL();
            error = "Contacting\nAAPS...";
        } else if ( abfrage == 3 ) {
            error = "Waiting for\nAAPS...";
        } else {
            error = "Click SELECT to start!";
            abfrage = 1;
            bolus = 0.0;
            circle = Gfx.COLOR_BLACK;
        }
        Ui.requestUpdate();
    }

    function onMenu() {
        abfrage = 2;
        var menu = new Ui.Menu();
        var delegate;
        menu.setTitle("Choose Bolus");
        menu.addItem("0.2 U", :a);
        menu.addItem("0.5 U", :b);
        menu.addItem("1.0 U", :c);
        menu.addItem("1.5 U", :d);
        menu.addItem("2.0 U", :e);
        menu.addItem("2.5 U", :f);
        menu.addItem("3.0 U", :g);
        menu.addItem("3.5 U", :h);
        menu.addItem("4.0 U", :i);
        menu.addItem("4.5 U", :j);
        menu.addItem("5.0 U", :k);
        menu.addItem("6.0 U", :l);
        menu.addItem("7.0 U", :m);
        menu.addItem("8.0 U", :n);
        delegate = new MenuInputDelegate(); // a WatchUi.MenuInputDelegate
        WatchUi.pushView(menu, delegate, WatchUi.SLIDE_IMMEDIATE);
     }

    //! Aufbereitete URL abfragen
    function frageURL() {
        circle = Gfx.COLOR_WHITE;
        Comm.makeWebRequest( url, { "bolus" => bolus, "enteredBy" => "Garmin Widget" }, { :method => Comm.HTTP_REQUEST_METHOD_POST, :headers => { "Content-Type" => Comm.HTTP_RESPONSE_CONTENT_TYPE_JSON }, :responseType => Comm.HTTP_RESPONSE_CONTENT_TYPE_JSON}, method(:verarbeiteWerte) );
        abfrage = 3;
        return true;
     }

     //!  Abfrage auswerten
     function verarbeiteWerte( responseCode, data ) {
        if( responseCode == 200 ) {
            Sys.println(data);
            //error = data.toString();
            error = "transmitted to\nAAPS";
            circle = Gfx.COLOR_GREEN;
        } else {
            error = "Error: " + responseCode.toString();
            circle = Gfx.COLOR_RED;
            errorCircle = true;
        }
        abfrage = 4;
        Ui.requestUpdate();
     }

}

class MenuInputDelegate extends Ui.BehaviorDelegate {

    function initialize() {
       BehaviorDelegate.initialize();
    }

    function onMenuItem(item) {
        circle = Gfx.COLOR_YELLOW;
       if (item == :a) {
            bolus = 0.2;
       } else if (item == :b) {
            bolus = 0.5;
        } else if (item == :c) {
            bolus = 1.0;
        } else if (item == :d) {
            bolus = 1.5;
        } else if (item == :e) {
            bolus = 2.0;
        } else if (item == :f) {
            bolus = 2.5;
        } else if (item == :g) {
            bolus = 3.0;
        } else if (item == :h) {
            bolus = 3.5;
        } else if (item == :i) {
            bolus = 4.0;
        } else if (item == :j) {
            bolus = 4.5;
        } else if (item == :k) {
            bolus = 5.0;
        } else if (item == :l) {
            bolus = 6.0;
        } else if (item == :m) {
            bolus = 7.0;
        } else if (item == :n) {
            bolus = 8.0;
        }
    }
}


class BolusWidgetView extends Ui.View {

    function initialize() {
        View.initialize();
    }

    // Load your resources here
    function onLayout(dc) as Void {
        setLayout(Rez.Layouts.MainLayout(dc));
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() as Void {
    }

    // Update the view
    function onUpdate(dc) as Void {
        // Call the parent onUpdate function to redraw the layout
        View.onUpdate(dc);

        // AUSGABE
        var addPadding = dc.getWidth() >= 360 ? 10 : 0;
        // Circle
        dc.setColor(circle, circle);
        dc.fillCircle(dc.getWidth() * 0.5, dc.getHeight() * 0.5, dc.getHeight() * 0.5);
        if (errorCircle == false ) {
            dc.setColor(Gfx.COLOR_BLACK, Gfx.COLOR_BLACK);
        } else {
            dc.setColor(Gfx.COLOR_DK_RED, Gfx.COLOR_BLACK);
            errorCircle = false;
        }
        dc.fillCircle(dc.getWidth() * 0.5, dc.getHeight() * 0.5, dc.getHeight() * 0.5 - 5);


        // Titel
        dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
        dc.drawText(
                dc.getWidth() * 0.5,
                dc.getHeight() * 0.5 + 10 - dc.getFontHeight(Gfx.FONT_LARGE) * 0.5 - 40 - 5 - dc.getFontHeight(Gfx.FONT_LARGE) - 5 - addPadding,
                Gfx.FONT_LARGE,
                "Bolus",
                Gfx.TEXT_JUSTIFY_CENTER
        );
        // Icon
        dc.drawBitmap(
            dc.getWidth() * 0.5 - 20,
            dc.getHeight() * 0.5 + 10 - dc.getFontHeight(Gfx.FONT_LARGE) * 0.5 - 40 - 5 - addPadding,
            Ui.loadResource(Rez.Drawables.LauncherIcon)
        );
        // Aufgabe
        dc.drawText(
                dc.getWidth() * 0.5,
                dc.getHeight() * 0.5 + 10 + 5,
                Gfx.FONT_LARGE,
                bolus.format("%.1f") + " U",
                Gfx.TEXT_JUSTIFY_CENTER | Gfx.TEXT_JUSTIFY_VCENTER
        );
        // Anweisung
        var fontSize = Gfx.FONT_TINY;
        var anweisung = (bolus == 0.0) ? "Click SELECT to start!" : "Push it to\nAAPS?";
        if (error != null ) {
            anweisung = error;
            error = null;
            //fontSize = Gfx.FONT_XTINY;
        }
        dc.drawText(
                dc.getWidth() * 0.5,
                dc.getHeight() * 0.5 + 10 + dc.getFontHeight(Gfx.FONT_LARGE) * 0.5 + 10,
                fontSize,
                anweisung,
                Gfx.TEXT_JUSTIFY_CENTER
        );

    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() as Void {
    }

}