/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 2019-03-21
 * @description Iterator-based operations for lazy-evaluation on collections/streams
 */
global virtual class LazyIterator implements Iterator<Object>, NullaryFunction, Iterable<Object> {

    protected Iterator<Object> iterator;

    global LazyIterator(Object iterableOrIterator) {
        if(iterableOrIterator == null) {
            iterator = EmptyIterator.getInstance();
        } else if(iterableOrIterator instanceof Iterator<Object>) {
            iterator = (Iterator<Object>)iterableOrIterator;
        } else if(iterableOrIterator instanceof Iterable<Object>) {
            iterator = ((Iterable<Object>)iterableOrIterator).iterator();
        } else {
            throw new IllegalArgumentException(String.format(
                    'LazyIterator constructed with invalid type {0}. Must be Iterator or Iterable',
                    new List<String>{
                            String.valueOf(iterableOrIterator)
                    })
            );
        }
    }

    global LazyIterator(Iterable<Object> iterable) {
        this.iterator = iterable.iterator();
    }

    global LazyIterator(Iterator<Object> iterator) {
        this.iterator = iterator;
    }

    protected LazyIterator() {}

    global virtual Boolean hasNext() {
        return iterator.hasNext();
    }

    global virtual Object next() {
        return iterator.next();
    }

    global Iterator<Object> iterator() {
        return this;
    }

    /** Returns the first member from the iterator if the iterator has member available. If it does not then
     * then the provided defaultValue is returned.
     *
     * @example
     *
     * @param defaultValue the value returned if the iterator has no members.
     *
     * @return the first member from the iterator if it has one, if it does not then the default value is returned.
     */
    global Object firstOrDefault(Object defaultValue) {
        if(hasNext()) {
            return next();
        } else {
            return defaultValue;
        }
    }

    global Object findOrDefault(BooleanFunction matchingFunction, Object defaultValue) {
        return filter(matchingFunction).firstOrDefault(defaultValue);
    }

   /**
   * Terminates the <code>LazyIterator</code>, converting its contents into a List of Objects.
   *
   * @example
   * //Retrieves the BillingCountry field from each account and puts them into a list of String.
   * List<String> billingCountries = new nebc.LazyIterator(accounts)
   *      .mapValues(new nebc.FieldFromSObject(Account.BillingCountry))
   *      .toList(new List<String>());
   *
   * @param toFill a list of Objects to fill with the values from the iterator
   *
   * @return a list of Objects derived from the <code>LazyIterator</code>
   */
    global virtual List<Object> toList(List<Object> toFill) {
        while(hasNext()) {
            toFill.add(next());
        }

        return toFill;
    }

    /**
    * Terminates the <code>LazyIterator</code>, converting its contents into a List of SObjects.
    *
    * @example
    * //Creates a list of accounts from a list of account names.
    * List<Account> newAccounts = new nebc.LazyIterator(accountNames)
    *      .mapValues(new nebc.SObjectFromPrototype(new Account())
    *          .put(Account.Name)
    *      )
    *      .toList(new List<Account>());
    *
    * @param toFill a list of SObjects to fill with the values from the iterator
    *
    * @return a list of SObjects derived from the <code>LazyIterator</code>
    */
    global virtual List<SObject> toList(List<SObject> toFill) {
        while(hasNext()) {
            toFill.add((SObject)next());
        }

        return toFill;
    }

    /**
    * Terminates the <code>LazyIterator</code>, converting its contents into a Set of Id
    *
    * @example
    * //Creates a set of Account Ids from a list of Contact.
    * Set<Id> accountIds = new nebc.LazyIterator(contacts)
    *      .mapValues(new nebc.FieldFromSObject(Contact.AccountId))
    *      .toSet(new Set<Id>());
    *
    * @param toFill a set of Ids to fill with the values from the iterator
    *
    * @return a Set of Ids derived from the <code>LazyIterator</code>
    */
    global virtual Set<Id> toSet(Set<Id> toFill) {
        while(hasNext()) {
            toFill.add((Id)next());
        }

        return toFill;
    }

    /**
    * Terminates the <code>LazyIterator</code>, converting its contents into a Set of Strings
    *
    * @example
    * //Creates a set of Billing States from a list of accounts
    * Set<String> billingStates = new nebc.LazyIterator(accounts)
    *      .mapValues(new nebc.FieldFromSObject(Account.BillingState))
    *      .toSet(new Set<String>());
    *
    * @param toFill a set of Strings fill with the values from the iterator
    *
    * @return a Set of Strings derived from the <code>LazyIterator</code>
    */
    global virtual Set<String> toSet(Set<String> toFill) {
        while(hasNext()) {
            toFill.add((String)next());
        }

        return toFill;
    }

   /**
   * Terminates the <code>LazyIterator</code>, converting its contents into a Set of Object
   *
   * @example
   * //Creates a set of Close Dates from a list of Opportunities
   * Set<Date> opportunityCloseDates = new nebc.LazyIterator(opportunities)
   *      .mapValues(new nebc.FieldFromSObject(Opportunity.CloseDate))
   *      .toSet(new Set<Date>());
   *
   * @param toFill a set of Object fill with the values from the iterator
   *
   * @return a Set of Object derived from the <code>LazyIterator</code>
   */
    global virtual Set<Object> toSet(Set<Object> toFill) {
        while(hasNext()) {
            toFill.add(next());
        }

        return toFill;
    }

    /**
     * Removes members from the iterator that do not pass the filter conditions. The filter conditions are
     * provided by a <code>BooleanFunction</code>. If the <code>BooleanFunction</code>'s <code>isTrueFor</code> method
     * evaluates to false when called on the member Object, the member is removed.
     *
     * @example //Counts the number of accounts where BillingCity is London
     * Integer numberOfLondonAccounts = new nebc.LazyIterator(accounts)
     *      .mapValues(new nebc.FieldFromSObject(Account.BillingCity))
     *      .filter(new nebc.IsEqual('London'))
     *      .toList()
     *      .size();
     *
     * @param matchingFunction a <code>BooleanFunction</code> to apply to all members within the iterator, to determine
     * whether they should remain in the iterator
     * @return a filtered version of the <code>LazyIterator</code>
     */
    global LazyIterator filter(BooleanFunction matchingFunction) {
        return new LazyFilterIterator(getIteratorForDecorator(), matchingFunction);
    }

    /**
     * Removes members from the iterator that do not pass the filter conditions. The filter conditions are
     * provided by a <code>BooleanFunction</code>. If the <code>BooleanFunction</code>'s <code>isTrueFor</code> method
     * evaluates to false when called on the member Object, the member is removed.
     *
     * @example //Counts the number of accounts where BillingCity is London
     * Integer numberOfLondonAccounts = new nebc.LazyIterator(accounts)
     *      .filter(new nebc.FieldFromSObject(Account.BillingCity), new nebc.IsEqual('London'))
     *      .toList()
     *      .size();
     *
     * @param mappingFunction a <code>Function</code> to modify the member being evaluated
     * @param matchingFunction a <code>BooleanFunction</code> to apply to all member within the iterator, to determine
     * whether they should remain in the iterator
     * @return a filtered version of the <code>LazyIterator</code>
     */
    global LazyIterator filter(Function mappingFunction, BooleanFunction matchingFunction) {
        return new LazyFilterIterator(getIteratorForDecorator(), mappingFunction, matchingFunction);
    }

    global LazyIterator expand(ExpansionFunction expansionFunction) {
        return new LazyExpansionIterator(getIteratorForDecorator(), expansionFunction);
    }

    global LazyIterator expand(ExpansionIterator expansionIterator) {
        return new LazyExpansionIterator(getIteratorForDecorator(), expansionIterator);
    }

    global Object reduce(AccumulatorFunction accumulatorFunction, Object initialValue) {
        Object result = initialValue;
        while(hasNext()) {
            result = accumulatorFunction.nextValue(result, next());
        }
        return result;
    }

    global Object reduce(AccumulatorObject accumulatorObject) {
        while(hasNext()) {
            accumulatorObject.accumulate(next());
        }
        return accumulatorObject;
    }

    global Object reduce(VoidFunction accumulatorObject) {
        while(hasNext()) {
            accumulatorObject.call(next());
        }
        return accumulatorObject;
    }

    private Iterator<Object> getIteratorForDecorator() {
        if(this instanceof LazyIteratorMutator) {
            return this;
        } else {
            return iterator;
        }
    }

    global LazyIterator mapValues(Function mappingFunction) {
        return new LazyMappingIterator(getIteratorForDecorator(), mappingFunction);
    }

    global LazyIterator mapValues(BooleanFunction filterFunction, Function mappingFunction) {
        return new LazyMappingConditionalIterator(getIteratorForDecorator(), filterFunction, mappingFunction);
    }

    global LazyIterator mapIf(BooleanFunction filterFunction, Function mappingFunction) {
        return new LazyMappingConditionalIterator(getIteratorForDecorator(), filterFunction, mappingFunction);
    }

    /**
     * Calls the observer function on each item as it is iterated, returning the original unmodified item. Can be used
     * to add iterated items to a collection whilst also processing them another way later.
     *
     * @param observerFunction a function to call on each item, should not modify them
     *
     * @return iterator on the underlying items, unmodified
     */
    global LazyIterator observeValues(Function observerFunction) {
        return new LazyObserverIterator(getIteratorForDecorator(), observerFunction);

    }

    /**
     * Calls the observer function on each item as it is iterated, as long as is satisfies the filterFunction. The
     * original unmodified item is returned by each iteration. Can be used to add iterated items to a collection whilst
     * also processing them another way later.
     *
     * @param filterFunction a filter on which items to observe
     * @param observerFunction a function to call on each item, should not modify them
     *
     * @return  iterator on the underlying items, unmodified
     */
    global LazyIterator observeValues(BooleanFunction filterFunction, Function observerFunction) {
        return new LazyObserverConditionalIterator(getIteratorForDecorator(), filterFunction, observerFunction);
    }

    /**
     * If you know the underlying items are SObjects and want the convenience methods of LazySObjectIterator, call this
     * to get them.
     *
     * @return a LazySObjectIterator of this iterator
     */
    global LazySObjectIterator toSObjectIterator() {
        return new LazySObjectIterator(this);
    }

    global void forEach(VoidFunction callingFunction) {
        while(hasNext()) {
            callingFunction.call(next());
        }
    }

    global void forEach(Function callingFunction) {
        while(hasNext()) {
            callingFunction.call(next());
        }
    }

    global void forEach() {
        while(hasNext()) {
            next();
        }
    }

    global LazyIterator setDefaultIfEmpty(Object defaultValue) {
        return setDefaultIfEmpty(new List<Object> {defaultValue}.iterator());
    }

    global LazyIterator setDefaultIfEmpty(Iterator<Object> defaultValues) {
        return new LazyDefaultIfEmptyIterator(getIteratorForDecorator(), defaultValues);
    }

    global LazyIterator take(Integer nItemsToTake) {
        return new LazyTakeIterator(getIteratorForDecorator(), nItemsToTake);
    }

    global LazyIterator prepend(LazyIterator other) {
        return new LazyAppendIterator(other, getIteratorForDecorator());
    }

    global LazyIterator append(LazyIterator other) {
        return new LazyAppendIterator(getIteratorForDecorator(), other);
    }

    global LazyIterator append(Object item) {
        return new LazyAppendIterator(getIteratorForDecorator(), new List<Object>{item}.iterator());
    }

    global LazyIterator prepend(Object item) {
        return new LazyAppendIterator(new List<Object>{item}.iterator(), getIteratorForDecorator());
    }

    global LazyIterator flatten() {
        return expand(new LazyIteratorExpansionIterator());
    }

    global Object call() {
        return next();
    }

    global Object call(Object o) {
        return call();
    }
}