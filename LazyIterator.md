## Declarative programming with the LazyIterator

[Declarative programming](https://en.wikipedia.org/wiki/Declarative_programming) is a way of writing code where 
operations are expressed in terms of applying functions. It hides control logic, and emphasises the high-level intent.

For example, consider writing a roll-up summary trigger to count the number of Contacts on Account. 
[ContactNumberOfContactsRollUp](examples/main/default/classes/ContactNumberOfContactsRollUp.cls), shows an imperative 
implementation of this. In that implementation, finding the set of account ids where we need to re-process the roll-ups 
is as follows:

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

The declarative example, using LazyIterator is [ContactNumberOfContactsRollUpDeclarative](examples/main/default/classes/ContactNumberOfContactsRollUpDeclarative.cls).
 In that implementation, finding the set of account ids where we need to re-process the roll-ups 
is as follows (note, it's actually spread across two functions in the orignal code, but I've put it together below, for clarity):
```
Set<Id> accountIds = new LazyTriggerContextPairIterator(oldList, newList)
        .filter(new IsFieldChangedInTrigger(Contact.AccountId))
        .expand(new TriggerContextPairExpandToBoth())
        .mapValues(new FieldFromSObject(Contact.AccountId))
        .toSet(new Set<Id>());

```

It's worth pausing to think about what you did to understand the imperative example. For me, it goes as follows:

 1. See the set of accountIds declared, remember that for later
 1. See a for-loop over the newList, notice that it's an interger-indexed one, not an iterator loop. Interesting.
 1. See that oldContact and newContact are extracted from the lists. OK, the lists ought to be the same length, and that's the reason for the indexed loop
 1. See the if-condition and recognise that this is checking for whether or not AccountId has changed in the trigger 
 1. See the AcountIds from oldContact and newContact going into the set. Now I know what that set was for! 
 1. Finally the set of accountIds was the output, and we're done
 
The thing is, I have to remember context as I go along, and translate low-level constructs (if, for) into ideas about intent.

Now, consider reading the second example:

 1. Immediately see that the output is a set of ids called accountIds, and that the input is a trigger context
 1. See a filtering by a change on Contact.AccountId
 1. See that we're expanding to use both the old and new values from the trigger context
 1. See the AccountId field is being extracted 
 1. As expected, see that the result is going into a set
 
 The declarative style lends itself well to reading in a single direction without having to jump all over the code and 
 remember lots of context as we read. We can very quickly get the gist of what's going on. Then, if necessary, dive into 
 the next level of abstraction to find out the details of any particular part. The code itself is much closer to the 
 intent. 