## Iterator operations with LazyIterator

A number of languages support neat operations for working with lists/streams/iterators by providing a set of powerful 
operations on them. These operations hide the details of having to write lower-level constructs such a for-loops, and 
can be composed together to provide a succinct way of working with data. 

[LazyIterator](force-app/main/default/classes/LazyIterator.cls) provides this functionality in Apex. 

For example, if we had a list of contacts and we wanted to get the accounts ids of those with no `FirstName`, we can 
write this as:

    Set<Id> accountIdsNoFirstName = new LazySObjectIterator(allContacts)
            .filter(new IsSObjectFieldEqual(Contact.FirstName, null))
            .mapValues(new FieldFromSObject(Contact.AccountId))
            .toSet(new Set<Id>());

As you can see, Nebula Core includes some filtering and mapping functions for common use-cases. These also include trigger-related use-cases.
For example, if we want to get the list of contacts in a trigger where the FirstName has changed, we can do it like this:

    List<Contact> contactsWithChangedFirstName = new LazyTriggerContextPairIterator(oldContacts, newContacts)
            .filter(new IsFieldChangedInTrigger(Contact.FirstName))
            .mapValues(new NewFromTriggerContextPair())
            .toList(new List<Contact>());

The "lazy" in the name refers to the fact this implementation is lazily evaluated i.e. it does the minimum amount of work possible and 
doesn't build any intermediate lists. So, even though the examples above chain together filter() and mapValues(), the 
input list is only iterated over once - each item passes through all of the functions individually. 

### What's in LazyIterator

You can construct a LazyIterator from either an Iterator, or an Iterable (the standard List and Set 
classes are Iterable). When the source is an Iterator, the data need not even necessarily come from a data structure, it 
could be a function that generates an unbounded amount of data e.g. [PositiveIntegers](examples/main/default/classes/PositiveIntegers.cls) 
is an iterator that will generate Integers forever. 

In this section, we will talk about the data source for the LazyIterator being a list. It can always be any 
iterator or iterable, but it's easier to give concrete examples with lists. 

The LazyIterator operations returning another LazyIterator are:

 - `filter(BooleanFunction matchingFunction)` this allows you to filter to just items accepted by the matchingFunction. e.g. we could filter a list of Integers to just the odd ones
 - `mapValues(Function mappingFunction)` this maps each value in the list to a new value e.g. we could double each item in a list of Integers, or even map it to a different type    
 - `expand(ExpansionFunction expansionFunction)` this allows each value in the list to be mapped to multiple values, and then iterates over all the results e.g. to flatten a list of lists [[1],[2,3],[4]] could be expanded to [1, 2, 3, 4] with an appropriate expansion function
 - `setDefaultIfEmpty(Object defaultValue)` when you don't know whether the underlying list will have any data, you can supply a default in case it is empty. This saves a typical pattern of getting the data, checking if it is empty and explicitly assigning a default e.g. if you are querying metadata for settings, and have a reasonable default for when no setting is found 

There are also terminator functions, which do not return a LazyIterator. These are typically called at the end of 
expression, to obtain a final result. 
 
 - `reduce(AccumulatorFunction accumulatorFunction, Object initialValue)` reduces the list to a single object. The single object starts as `initialValue` and `accumulatorFunction` is applied to it on each iteration. e.g. we could sum a list of integers
 - `reduce(VoidFunction accumulatorObject)` a form of reduce where the accumulation goes into the object that provides the accumulator function
 - `firstOrDefault(Object defaultValue)` get the first value, or the provided defaultValue if the iterator is empty
 - `List<Object> toList(List<Object> toFill)` iterate until there are no more items, putting them into the provided list
 - `Set<Object> toSet(Set<Object> toFill)` iterate until there are no more items, putting them into the provided set
 - `forEach(VoidFunction callingFunction)` call the supplied function on all items
 
Finally, there is an option to fork the iterator into multiple results. This allows you to filter into different 
streams which can then be handled differently; or obtain multiple results from the same iterator e.g.

    Map<String, Object> accountIds = new LazySObjectIterator(allContacts)
            .fork()
            .addFork('noFirstName', new ForkIterator()
                    .filter(new IsSObjectFieldEqual(Contact.FirstName, null))
                    .mapValues(new FieldFromSObject(Contact.AccountId))
                    .postpone(new ToSet(new Set<Id>())))
            .addFork('withFirstName', new ForkIterator()
                    .filter(new IsNot(new IsSObjectFieldEqual(Contact.FirstName, null)))
                    .mapValues(new FieldFromSObject(Contact.AccountId))
                    .postpone(new ToSet(new Set<Id>())))
            .toMap();

    Set<Id> accountIdsNoFirstName = (Set<Id>)accountIds.get('noFirstName');
    Set<Id> accountIdsWithFirstName = (Set<Id>)accountIds.get('withFirstName');

### Mapping and Boolean Functions

There are some functions included in the package for common scenarios. Boolean functions are all named `Is*` and mapping 
functions are all named `*From*`. The boolean functions include the standard logical operations: `IsNot`, `IsAny`, and `IsAll`.

### More examples

The code examples above are written in whole tests in [LazyIteratorExamples](examples/main/default/classes/LazyIteratorExamples.cls).

There is a trigger handler example in [ContactNumberOfContactsRollUpDeclarative](examples/main/default/classes/ContactNumberOfContactsRollUpDeclarative.cls) 

###Why?

The style of programming that you can do with LazyIterator is called [Declarative programming](https://en.wikipedia.org/wiki/Declarative_programming). It is a way of writing code where 
the program is expressed in terms of applying functions. It hides control logic, and emphasises the high-level intent.

By contrast, [imperative programming](https://en.wikipedia.org/wiki/Imperative_programming) uses sequences of statements 
and explicit control-flow to modify the program state. This is the style adopted in most Apex code.

The declarative style encouraged by LazyIterator allows you to write code that is very easy to read, and separates 
concerns by their level of abstraction. 

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

The declarative implementation, using LazyIterator, is [ContactNumberOfContactsRollUpDeclarative](examples/main/default/classes/ContactNumberOfContactsRollUpDeclarative.cls).
In that implementation, finding the set of account ids where we need to re-process the roll-ups 
is as follows (note: it's actually spread across two functions in the orignal code, but I've put it together below, for 
clarity/brevity):
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
1. See a for-loop over the `newList`, notice that it's an integer-indexed one, not the usual iterator loop
1. See that `oldContact` and `newContact` are extracted from the lists. OK, the lists ought to be the same length, and that's the reason for the indexed loop
1. See the if-condition and recognise that this is checking for whether or not `AccountId` has changed in the trigger 
1. See the `AccountId`s from `oldContact` and `newContact` going into the set. Now I know what that set was for! 
1. Finally the set of accountIds was the output, and we're done

The problem with reading code like that is that I have to remember context as I go along, and translate low-level 
constructs (if, for) into ideas about intent.

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

You could achieve similar clarity in an imperative style (e.g. by breaking into more function and giving them good 
names), but LazyIterator provides a sort of handrail to go straight to the readable version. 

