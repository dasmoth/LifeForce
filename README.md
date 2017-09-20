# Life Force

This was principally an experiment to build a "one-finger" zooming interface for reasonably dense data on devices with
pressure sensitive screens.  It should run on any iPhone 6S or later -- there's currently no point running it on earlier
devices or iPads.  Technically, the pressure sensitive screens on iPhones are called "3D Touch", but Apple describe similar
features on other devices as "Force Touch", and that made a better name...

A gentle touch on the screen zooms in.  A firmer touch toggles a cell on or off (and should give some feedback via the device's
"Taptic engine", too).  You need to release pressure slightly before pressing again to toggle another cell.

Ideally, the haptic feedback would be done using the
`UIImpactFeedbackGenerator` API, but this is only supported on devices
with a second generation Taptic engine (iPhone 7 and later), and I
don't currently have a suitable device for testing.  The original
version abused `UIPreviewInteraction` to get a similar effect, but
this seems to have been broken by iOS 11.  Fortunately, there's
an alternative way of triggering feedback
[via AudioToolbox](http://www.mikitamanko.com/blog/2017/01/29/haptic-feedback-with-uifeedbackgenerator/)
so now I'm using that instead.

Happy Tapping!
