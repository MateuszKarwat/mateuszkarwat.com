---
date: 2017-07-07
title: UserDefaults in a Swift way
headline: Readable and type safe UserDefaults
---


[UserDefaults][1] is a class used in almost every iOS and macOS project out there. It's the most common way to store key-value pairs persistently. I saw a lot of projects and almost every one of them had its own unique way to handle `UserDefaults`.

The most popular way though is to extend `UserDefaults` to add properties with custom getters and setters.

```
extension UserDefaults {
  private struct Keys {
    let convertSubtitles = "convertSubtitles"
  }

  var convertSubtitles: Bool {
    get { bool(forKey: Keys.convertSubtitles) }
    set { set(newValue, forKey: Keys.convertSubtitles) }
  }
}

UserDefaults.standard.convertSubtitles = false
let shouldConvert = UserDefaults.standard.convertSubtitles
```

It looks nice and clean when you use it. However, if you have a lot of keys it can grow really fast and file with all keys and properties becomes messy. Please also notice that there is a lot of `convertSubtitles` repetition. To avoid it we can use Swift's `#function` keyword if property name is the same as the key it uses. `#function` returns a `String` with name of the declaration in which it appears.

```
extension UserDefaults {
  var convertSubtitles: Bool {
    get { bool(forKey: #function) }
    set { set(newValue, forKey: #function) }
  }
}

UserDefaults.standard.convertSubtitles = false
let shouldConvert = UserDefaults.standard.convertSubtitles
```

Sometimes developers create an extra struct to avoid writing `UserDefaults.standard` all over again.

```
struct Preferences {
  private let defaults = UserDefaults.standard

  static var convertSubtitles: Bool {
    get { defaults.bool(forKey: #function) }
    set { defaults.set(newValue, forKey: #function) }
  }
}

Preferences.convertSubtitles = false
let shouldConvert = Preferences.convertSubtitles
```

And I love it. It's smart, simple and clean. The only problem I see is that sometimes you need a property with a different name than the key itself. `#function` keyword does not allow it, so you would have to use something like `Keys` struct anyway.

So, can we do better? Sure we can. Let's create an extension of `UserDefaults`, but this time with substring which takes a value of our own type `DefaultsKey`.

```
let Preferences = UserDefaults.standard

class Defaults {
  fileprivate init() {}
}

class DefaultsKey<ValueType>: Defaults {
  let key: String

  init(_ key: String) {
    self.key = key
  }
}

extension UserDefaults {
  subscript(key: DefaultsKey<Bool>) -> Bool {
    get { return bool(forKey: key.key) }
    set { set(newValue, forKey: key.key) }
  }
}    
```

Some of this code might look redundant, but let's take a look how we can add support for `String`. To do this, we just add another subscript.

```
extension UserDefaults {
  subscript(key: DefaultsKey<String?>) -> String? {
    get { return string(forKey: key.key) }
    set { set(newValue, forKey: key.key) }
  }
}    
```

*"Yeah, that's all great, but what does it give me?"*. Once you have subscripts for all types you want, adding a new key to `UserDefaults` is as easy as this:

```
extension Defaults {
  static let convertSubtitles = DefaultsKey<Bool>("convertSubtitles")
}

Preferences[.convertSubtitles] = false
let shouldConvert = Preferences[.convertSubtitles]
```

... and that's it! In my opinion it's a really neat way to use `UserDefaults` and of course I used it in [Napi][2].

This approach is based on an awesome framework called [SwiftyUserDefaults][3]. I highly recommend you to get familiar with it, especially with a set of Radek's blog posts listed in [More like this][4] section.

[1]: https://developer.apple.com/documentation/foundation/userdefaults
[2]: https://github.com/MateuszKarwat/Napi/blob/master/Napi/Models/Preferences.swift
[3]: https://github.com/radex/SwiftyUserDefaults
[4]: https://github.com/radex/SwiftyUserDefaults#more-like-this
