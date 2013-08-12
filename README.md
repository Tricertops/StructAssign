# StructAssign

Allows dot assignment for fields of structures in properties.

```objc
view._(bounds.size.width) = 20;
```

_**Disclaimer:** Early stage of development. Code si dirty, but works fine._

### Pros
  - It works.
  - Works with any `CGRect`, `CGSize` or `CGPoint` properties.
  - Supports `+=`, `-=` and similar operators.
  - Code completion inside the parenthesis.
  
### Cons
  - Emits warning for unused value, so you will need to turn that one off.
  - Not thread-safe. You can't use this syntax from multiple thread at the same time. This is caused by poor design, but I had to sacrifice few things for this to be possible.

### How does is work?
There is macro `_` which is just defined another macro (this allows you to choose different name if `_` is already taken in your project). That macro uses very dirty tricks to achieve the desired syntax. It expands to three expressions separated by `,`. (1) The first part calls intermediate property (no, it's just a method), that allows us to run code there. The method just returns `self` and then the key-path continues. This ensures validity of the key-path and also this part emits the warning. The code we run inside the method initializes new assignment sequece by assigning self (the receiver) to a singleton. Yes, singleton. There's the problem with thread safety. (2) So the second part of the macro sets key-path to the same singleton, so it now has both and can do the magic. It splits the key-path to first key and the rest. The first key is the real property, the rest is just path of structure fields. Then there is special class cluster with one subclass for each supprted structure type. The singleton initilizes the right one and then we come to the last part. (3) Third macro part assigns the value after macro into singleton property. So the assignment invokes another code, simple. This code sets this floating-point value for the correct key-path to our special class. We use the “path of structure fields” as a key-path to invoke correct setter. Setters are defined in the mentioned special classes, one for each supported structure type. These setter set values back to the original object whose property we wanted to adjust. At the end of everything the temporary singleton properties are cleared and we can continue. **Simple as that.**