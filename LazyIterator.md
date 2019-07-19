## Declarative programming with the LazyIterator

[Declarative programming](https://en.wikipedia.org/wiki/Declarative_programming) is a way of writing code where 
the program is expressed in terms of applying functions. It hides control logic, and emphasises the high-level intent.

By contrast, [imperative programming](https://en.wikipedia.org/wiki/Imperative_programming) uses sequences of statements 
to modify the program state. This is the style adopted in most Apex code.

The LazyIterator class allows you to write Apex in a declarative style.  

For example, consider writing a roll-up summary trigger to count the number of Contacts on Account. 
[ContactNumberOfContactsRollUp](examples/main/default/classes/ContactNumberOfContactsRollUp.cls), shows an imperative 
implementation of this. In that implementation, we find the set of account ids where we need to re-process the roll-ups 
with the following code:

```
Set<Id> accountIds = new Set<Id>();
for(Integer i=0; i < newList.size(); i++) {
    Contact oldContact = oldList[i];
    Contact newContact = newList[i];

    if(oldContact.AccountId != newContact.AccountId) {
        accountIds.add(oldContact.AccountId);
        accountIds.add(newContact.AccountId);
    }
}
updateAccountRollUps(accountIds);
```

The declarative version, using LazyIterator, is [ContactNumberOfContactsRollUpDeclarative](examples/main/default/classes/ContactNumberOfContactsRollUpDeclarative.cls).
 In that implementation, finding the set of account ids where we need to re-process the roll-ups 
is as follows (note, it's actually spread across two functions in the orignal code, but I've put it together below, for clarity):
```
Set<Id> accountIds = new LazyTriggerContextPairIterator(oldList, newList)
        .filter(new IsFieldChangedInTrigger(Contact.AccountId))
        .expand(new TriggerContextPairExpandToBoth())
        .mapValues(new FieldFromSObject(Contact.AccountId))
        .toSet(new Set<Id>());

```

It's worth pausing to think about the process you go through to understand each of these code examples. For me, I
read the imperative one as follows:

 1. See the set of `accountIds` declared, remember that for later
 1. See a for-loop over the `newList`, notice that it's an integer-indexed one, not the usual iterator loop. Interesting
 1. See that oldContact and newContact are extracted from the lists. OK, the lists ought to be the same length, and that's the reason for the indexed loop
 1. See the if-condition and recognise that this is checking for whether or not `AccountId` has changed in the trigger 
 1. See the `AccountId`s from `oldContact` and `newContact` going into the set. Now I know what that set was for! 
 1. Finally the set of accountIds was the output, and we're done
 
The thing is, I have to remember context as I go along, and translate low-level constructs (if, for) into ideas about intent.

Now, consider reading the second example:

 1. Immediately see that the output is a set of ids called `accountIds`, and that the input is a trigger context
 1. See that the trigger context is filtered to items where `Contact.AccountId` has changed
 1. See that we're expanding to use both the old and new values from the trigger context
 1. See the `AccountId` field is being extracted 
 1. As expected, see that the result is going into the `accountId` set
 
 The declarative style lends itself well to reading in a single direction without having to jump all over the code and 
 remember lots of context as we read. And the intent is clear at the top-level. We can very quickly get the gist of 
 what's going on. Then, if necessary, dive into 
 the next level of abstraction to find out the details of any particular part. The code itself is much closer to the 
 intent. 
 
### What's in LazyIterator

LazyIterator is most commonly used for working on Lists or Sets. You do some work on the List/Set, and return a new List/Set or
a single object. 

You can construct a LazyIterator from either an Iterator, or an Iterable (the standard List and Set 
classes are Iterable). When the source is an Iterator, the data need not necessarily come from a data structure, it 
could be a function e.g. [PositiveIntegers](examples/main/default/classes/PositiveIntegers.cls) will generate Integers
forever. 

For simplicity in the example, we will talk about the content behind the LazyIterator being a list. It can always be any 
iterator or iterable, though. 

A LazyIterator can perform a number of operations. Each operation changes what you will get out on each iteration, and 
returns another LazyIterator. So, the operations can be chained together. 

The operations are:

 - `filter(BooleanFunction matchingFunction)` this allows you to filter to just items accepted by the matchingFunction. e.g. we could filter a list of Integers to just the odd ones.
 - `mapValues(Function mappingFunction)` this maps each value in the list to a new value e.g. we could double each item in a list of Integers    
 - `expand(ExpansionFunction expansionFunction)` this allows each value in the list to be mapped to multiple values, and then iterates over all the results e.g. to flatten a list of lists [[1],[2,3],[4]] could be expanded to [1, 2, 3, 4] with an appropriate expansion function

There are also termination functions, which do not return a LazyIterator. These are typically called at the end, to 
obtain a final result. 
 
 - `reduce(AccumulatorFunction accumulatorFunction, Object initialValue)` reduces the list to a single object. The single object starts as `initialValue` and `accumulatorFunction` is applied to it on each iteration. e.g. we could sum a list of integers
 - `reduce(VoidFunction accumulatorObject)` a form of reduce where the accumulation goes into an object that provides both the accumulator function and also the state to store it
 - 