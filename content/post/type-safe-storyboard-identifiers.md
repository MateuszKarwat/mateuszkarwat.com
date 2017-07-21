---
date: 2017-07-21
title: Type safe Storyboard Identifiers
headline: Get rid off String type identifiers
---

I don't like to have hardcoded `Strings` anywhere in my codebase. If you use [Storyboards][1] in your project, you probably wrote a code similar to the following:

```
let storyboard = UIStoryboard(name: "MyStoryboardName", bundle: nil)
let controller = storyboard.instantiateViewController(withIdentifier: "MyViewController") as! MyViewController
```

I tried to eliminate a need of writing `MyStoryboardName` and `MyViewController`. If you make a typo, it might lead to a crash very easilly. At the time I was looking into an awesome implementation of [Kickstarter][2] application. I noticed that they have a really neat way to instantiate a View Controller. Let's take a look...

```
enum Storyboard: String {
    case Main
    case Preferences
}

extension Storyboard {
    func instantiate<C: StoryboardIdentifiable>(_ viewController: C.Type, inBundle bundle: Bundle = .main) -> C {
        guard let vc = NSStoryboard(name: self.rawValue, bundle: bundle)
                  .instantiateController(withIdentifier: C.storyboardIdentifier) as? C
        else {
            fatalError("Couldn't instantiate \(C.storyboardIdentifier) from \(self.rawValue)")
        }

        return vc
    }
}
```

To make it work though we have to create a `StoryboardIdentifiable` protocol.

```
protocol StoryboardIdentifiable {
    var storyboardIdentifier: String { get }
    static var storyboardIdentifier: String { get }
}
```

It's super easy to create a default implementation of this protocol. We just need to return a `String` based on `self`'s type.

```
extension StoryboardIdentifiable {
    var storyboardIdentifier: String {
        return String(reflecting: self).components(separatedBy: ".").dropFirst().joined(separator: ".")
    }

    static var storyboardIdentifier: String {
        return String(reflecting: self).components(separatedBy: ".").dropFirst().joined(separator: ".")
    }

    var description: String {
        return storyboardIdentifier
    }
}
```

With this implementation, if you call `storyboardIdentifier` on `MyViewController`, you will receive `"MyViewController"`.
Now, we can make desired class conforming to it. In my case it was `NSViewController` and `NSWindowController`.

```
extension NSViewController: StoryboardIdentifiable { }

extension NSWindowController: StoryboardIdentifiable { }
```

That's it. We can give it a spin now. In order to do so, we need to set an identifier of specific View Controller in Storyboard the same as its name. Then we can instantiate it as follows:

```
let myViewController = Storyboard.Main.instantiate(MyViewController.self)
```

It's neat, isn't it? [Here][4] you can find the whole implementation I use in [Napi][5].

[1]: https://developer.apple.com/library/content/documentation/General/Conceptual/Devpedia-CocoaApp/Storyboard.html
[2]: https://github.com/kickstarter/ios-oss
[3]: https://github.com/kickstarter/ios-oss/blob/f6e5b2c125411816a3a71a4a348d995c4a0a1593/Kickstarter-iOS/Library/Storyboard.swift
[4]: https://github.com/MateuszKarwat/Napi/blob/master/Napi/Views/Storyboards/Storyboard.swift
[5]: https://github.com/MateuszKarwat/Napi
