# Life Force

This was principally an experiment to build a "one-finger" zooming interface for reasonably dense data on devices with
pressure sensitive screens.  It should run on any iPhone 6S or later -- there's currently no point running it on earlier
devices or iPads.  Technically, the pressure sensitive screens on iPhones are called "3D Touch", but Apple describe similar
features on other devices as "Force Touch", and that made a better name...

A gentle touch on the screen zooms in.  A firmer touch toggles a cell on or off (and should give some feedback via the device's
"Taptic engine", too).  You need to release pressure slightly before pressing again to toggle another cell.

The haptic feedback is actually a bit of a hack, and somewhat abuses the `UIPreviewInteraction` API.  On iPhone 7 and later,
there's a much more flexible `UIImpactFeedbackGenerator` API, but I don't currently have a suitable device for testing.

Happy Tapping!
