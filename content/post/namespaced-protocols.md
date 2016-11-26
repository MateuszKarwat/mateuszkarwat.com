---
date: 2016-11-26
title: Nested Protocols
headline: How to put a protocol into a namespace
---


Yesterday my friend who has been transfered from iOS team to Android team
showed me something he thinks is really cool in Java and he would love to see in Swift. He showed me that there is a possibility to put an interface declaration inside a class. In Swift it means - put a protocol definition inside a struct, class or enum definition.

Unfortunately, according to the [Swift documentation][1]:

> Swift enables you to define nested types, whereby you nest supporting enumerations, classes, and structures within the definition of the type they support.

It means that currently in Swift there is no way to define a nested protocol. In other words - protocols are valid at file scope only.

*But why would it be nice to have anyway?* - you may ask. Imagine you could write a code like this:

```
// Please remember that this code won't compile.

class FileInformationProvider {
  protocol Delegate: class { }

  weak var delegate: Delegate?
}
```

If you would like to create a class which conforms to that protocol, you would write:

```
class FileManager: FileInformationProvider.Delegate { }
```

I'm sure you can see an advantage of this approach. There is no need to create a protocol called `FileInformationProviderDelegate` which is declared out of `FileInformationProvider` namespace. Having a nested protocol limits it inside a type to which it refers directly to. It gives more clarity to our code without a need of wondering which specific class uses this delegate protocol.

In Swift it's very common practice to create a nested `struct` or `enum` to store all constants, states or keys used within a specific scope. For example:

```
class InformationFetcher {
  struct Constants {
    static let baseURL = "http://mateuszkarwat.com"
  }
}
```

So how can we achieve the same namespacing with protocols? I came up with one solution. It involves a `typealias` keyword. The `typealias` keyword introduces a named alias of an existing type into your program<sup><a href="#fn1" id="ref1">1</a></sup>. Here is what we can do:

```
protocol FileInformationProviderDelegate { }

class FileInformationProvider {
  typealias Delegate = FileInformationProviderDelegate

  weak var delegate: Delegate?
}
```

Our code compiles now and we can conform to nested protocol by calling `FileInformationProvider.Delegate` just as we wanted. It doesn't hide `FileInformationProviderDelegate` declaration though, so the protocol is still accessible outside `FileInformationProvider` namespace. However, with this approach we can go further and for example create nested protocols like `.DataSource` in our table view controllers.

Is this any better than just:

```
class FileInformationProvider {
  weak var delegate: FileInformationProviderDelegate?
}
```

I don't know. I guess it's totally up to you. You might say that this solution requires a bit more code to write and probably looks like some kind of a workaround. It's absolutely true. I'm not a big fan of it either and I probably won't use it. The goal here was to show you there is a way to create a "nestedish" protocol in Swift in case you desperately need it.

If you come up with better solution, please let me know. I would love to try it out.


  [1]: https://developer.apple.com/library/content/documentation/Swift/Conceptual/Swift_Programming_Language/NestedTypes.html

---

  <sup id="fn1">1. <a href="https://developer.apple.com/library/content/documentation/Swift/Conceptual/Swift_Programming_Language/Declarations.html#//apple_ref/doc/uid/TP40014097-CH34-ID361">The Swift Programming Language - Type Alias Declaration</a><a href="#ref1" title="Jump back to footnote 1 in the text.">↩</a></sup>
