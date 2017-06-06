---
date: 2017-02-15
title: Return keyword and following expression
headline: Why function after return keyword is called if function doesn't return anything
---

Lately I was left with question which made me a bit like "whaaaaaat?".

A friend of mine told me that some time ago while he was debugging something, he used a `return` keyword in the middle of a function, because he wanted to check what happens when that function ends its execution earlier. He was really surprised when it turned out that a function following `return` statement had been called anyway.

To simplify our problem let's make a very easy example:

```
func returnInTheMiddle() {
  print("This is called as expected")
  return
  print("This is called as well")
}

returnInTheMiddle()
```

When you run that piece of code, you'll see that **second `print` statement will be called. Why is that?**

Fortunately Xcode doesn't leave us without a warning here. It displays the following message:

> Expression following 'return' is treated as an argument of a 'return'.

That pretty much is an answers to our question. When `return` is being called it sometimes takes an expression, which in this case is a function. Passed function is called before its return value is passed to the `return` statement. That's why second `print` statement is called.

Despite how good that answer is, I wanted to know how actually `return` keyword is implemented. What kind of expression it actually is.

In [Statements][1] chapter of [Language Reference][2] we can find a description of a `return` keyword, which also contains information about any following expression:

> When a return statement is followed by an expression, the value of the expression is returned to the calling function or method. If the value of the expression does not match the value of the return type declared in the function or method declaration, the expression’s value is converted to the return type before it is returned to the calling function or method.

With that information in hand I tried to find an actual implementation of it and I did find what I was looking for. Parsing `return` statement is located in [ParseStmt.cpp][3] file and function which does that is called `ParserResult<Stmt> Parser::parseStmtReturn(SourceLoc tryLoc)`. There is one particular comment which is interesting:

> Handle the ambiguity between consuming the expression and allowing the enclosing stmt-brace to get it by eagerly eating it unless the return is followed by a '}', ';', statement or decl start keyword sequence.

Now we can be really sure, that if `return` statement is followed by an expression which returns the same type as a type of calling function, it will be called and treated as an argument of `return` statement.

To avoid this kind of behaviour, if you really need to put `return` statement in the middle of a function, make sure it's either followed by `}` (which is very common scenario and used everywhere) or `;` character. `;` character following `return` keyword is not a very good idea. Using that, you probably have some code which has no chance to be called. Anyway, for debugging purposes our example could look like this:

```
func returnInTheMiddle() {
  print("This is called as expected")
  return;
  print("This is called as well")
}

returnInTheMiddle()
```

This time, second `print` statement is not called and never will be.


  [1]: https://developer.apple.com/library/prerelease/content/documentation/Swift/Conceptual/Swift_Programming_Language/Statements.html#//apple_ref/doc/uid/TP40014097-CH33-ID428
  [2]: https://developer.apple.com/library/prerelease/content/documentation/Swift/Conceptual/Swift_Programming_Language/AboutTheLanguageReference.html#//apple_ref/doc/uid/TP40014097-CH29-ID345
  [3]: https://github.com/apple/swift/blob/cb3bdcc2a36699abf1b7d5b0a791b9011959ac4a/lib/Parse/ParseStmt.cpp
