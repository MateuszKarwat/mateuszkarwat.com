---
date: 2018-04-05
title: Native binding
headline: macOS binding without an external framework
---

Did you know that you can, while developing macOS application, use UI binding to a view model without any reactive framework whatsoever?

While I was working on a preferences window for [Napi][1] application, I was thinking how to pin UI to a model. Because we want to store user's choice permanently, usually the UI is directly connected to [UserDefaults][2].

First thing that comes to mind is to detect when a checkbox changes its state and store a new value in `UserDefaults`.

```
@IBOutlet weak var displayNotificationCheckbox: NSButton!
@IBAction func displayNotificationCheckboxStateChanged(_ sender: NSButton) {
    switch sender.state {
    case .on:
        UserDefaults.standard.set(true, forKey: "displayNotifications")
    case .off:
        UserDefaults.standard.set(false, forKey: "displayNotifications")
    default:
        return
    }
}
```

It works, but this code very repetitive. Fortunately, you can avoid it using bindings.
If you open your storyboard and navigate to *Bindings inspector* `(CMD+ALT+7)`, you'll see a lot of properties you can bind. What is great about it, you can bind predefined properties as well as your custom ones. In this tutorial, let's focus on a basic example, so you have a good place to start from.

First, expand *Value* section and select *Bind to* checkbox. By default, it will choose *Shared User Defaults* option for you and that's exactly what we want. In addition, it will add a green circle which indicates that `Shared User Defaults Controller` has been added to a specific view controller.

![](/post/native-binding/1.png)

With *Bind to* option selected, all you need to do is to specify *Model Key Path*. In our case let's write `displayNotifications`. This is a name of a property which will store the state of the checkbox in `UserDefaults`. Your final setup should look like this:

![](/post/native-binding/2.png)

That's it! No code is required and the checkbox's state is stored in `UserDefaults` persistently. If you reopen the application, checkbox's state will be just as you set it.

I highly encourage you to experiment with other options. You can create a quite complex binding rules there.

[1]: https://github.com/MateuszKarwat/Napi/
[2]: https://developer.apple.com/documentation/foundation/userdefaults
