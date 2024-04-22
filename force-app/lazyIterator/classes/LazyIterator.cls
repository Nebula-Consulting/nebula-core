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

    /**
     * Reduces all of the iterator members into a single object by applying the same accumulator function to each member.
     *
     * //Returns a total of the Amount field on records in opportunities.
     * @example Decimal total = new nebc.LazySObjectIterator(opportunities)
     *      .get(Opportunity.Amount)
     *      .reduce(new SumDecimalField(), 0)
     * 
     * @param accumulatorFunction the accumulator function to apply to each member in the iterator
     * @param initialValue the starting value for the accumulator
     * @return the end result of the accumulation.
     */
    global Object reduce(AccumulatorFunction accumulatorFunction, Object initialValue) {
        Object result = initialValue;
        while(hasNext()) {
            result = accumulatorFunction.nextValue(result, next());
        }
        return result;
    }

    /**
     * Reduces all of the iterator members into a single object by calling the accumulate function on a provided 
     * <code>AccumulatorObject</code>, for each member.
     * 
     * @example //summing the Amount field on opportunity. Assumes SumDecimalField is a user-written class implementing AccumulatorObject
     * SumDecimalField accumulator = new SumDecimalField(Opportunity.Amount, 0)
     * new nebc.LazySObjectIterator(opportunities)
     *      .reduce(accumulator)
     * 
     * @param accumulatorObject an <code>AccumulatorObject</code> instance that will have it's accumulate method called 
     * on every iterator member
     * @return the provided accumulator object
     */
    global Object reduce(AccumulatorObject accumulatorObject) {
        while(hasNext()) {
            accumulatorObject.accumulate(next());
        }
        return accumulatorObject;
    }

    /**
     * Reduces all of the iterator members into a single object by calling the accumulate function on a provided 
     * <code>VoidFunction</code>, for each member.
     * 
     * @example //summing the Amount field on opportunity. Assumes SumDecimalField is a user-written class implementing VoidFunction
     * SumDecimalField accumulator = new SumDecimalField(Opportunity.Amount, 0)
     * new nebc.LazySObjectIterator(opportunities)
     *      .reduce(accumulator)
     * 
     * @param accumulatorObject an <code>VoidFunction</code> instance that will have it's accumulate method called 
     * on every iterator member
     * @return the provided accumulator object
     */
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

    /**
     * Applies the mapping function to every record in the LazyIterator.
     *
     * @example
     * //converts a list of lead last names into lead records and inserts them.
     * new nebc.LazyIterator(leadLastNames)
     *   .mapValues(
     *      new nebc.SObjectFromPrototype(new Lead())
     *          .put(Lead.LastName)
     *          .put(Lead.LeadSource, 'Name List')
     *   )
     *   .toSObjectIterator()
     *   .doInsert();
     *
     * @param mappingFunction an instance of a class implementing <code>Function</code> to apply to each record
     *
     * @return a new version of the iterator where the mapping function has been applied to each record.
     */
    global LazyIterator mapValues(Function mappingFunction) {
        return new LazyMappingIterator(getIteratorForDecorator(), mappingFunction);
    }

    /** Applies the mapping function to every item in the LazySObjectIterator that meets the filter criteria.
     *
     * @example //creates a log records from an iterator of save results. Only creates logs for failed saves.
     * new nebc.LazyIterator(saveResults)
     *      .mapValues(new nebc.IsNotSuccess(), new CreateLogRecord())
     *      .toSObjectIterator()
     *      .doInsert();
     *
     * @param filterFunction an instance of a class implementing <code>BooleanFunction</code> that determines which items
     * the mapping function should be applied to
     * @param mappingFunction an instance of a class implementing <code>Function</code>
     *
     * @return a new version of the <code>LazyIterator</code> where the mapping function has been applied to each item
     * that met the filter criteria
     */
    global LazyIterator mapValues(BooleanFunction filterFunction, Function mappingFunction) {
        return new LazyMappingConditionalIterator(getIteratorForDecorator(), filterFunction, mappingFunction);
    }

    /** Applies the mapping function to every item in the LazySObjectIterator that meets the filter criteria.
     *
     * @example //creates a log records from an iterator of save results. Only creates logs for failed saves.
     * new nebc.LazyIterator(saveResults)
     *      .mapIf(new nebc.IsNotSuccess(), new CreateLogRecord())
     *      .toSObjectIterator()
     *      .doInsert();
     *
     * @param filterFunction an instance of a class implementing <code>BooleanFunction</code> that determines which items
     * the mapping function should be applied to
     * @param mappingFunction an instance of a class implementing <code>Function</code>
     *
     * @return a new version of the <code>LazyIterator</code> where the mapping function has been applied to each item
     * that met the filter criteria
     */
    global LazyIterator mapIf(BooleanFunction filterFunction, Function mappingFunction) {
        return new LazyMappingConditionalIterator(getIteratorForDecorator(), filterFunction, mappingFunction);
    }

    /**
     * Calls the observer function on each item as it is iterated, returning the original unmodified item. Can be used
     * to add iterated items to a collection whilst also processing them another way later.
     *
     * @example //filters a list of dates for those that are older than 30 days then adds them to a set, before filtering again
     * Set<Date> datesOlderThan30Days = new Set<Date>()
     * Set<Date> datesOlderThan90Days = (Set<Date>) new nebc.LazyIterator(dates)
     *      .filter(new nebc.IsLessThan(Date.today().addDays(-30))
     *      .observeValues(new nebc.AddTo(datesOlderThan30Days))
     *      .filter(new nebc.IsLessThan(Date.today().addDays(-90))
     *      .toSet(new Set<Date>());
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
     * @example //filters a list of dates for those that are older than 30 days then adds them to a set, before filtering again
     * Set<Date> datesOlderThan30Days = new Set<Date>()
     * Set<Date> datesOlderThan90Days = (Set<Date>) new nebc.LazyIterator(dates)
     *      .observeValues(new nebc.IsLessThan(Date.today().addDays(-30), new nebc.AddTo(datesOlderThan30Days))
     *      .filter(new nebc.IsLessThan(Date.today().addDays(-90))
     *      .toSet(new Set<Date>());
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
     * If you know the underlying items are SObjects and want the convenience methods of <code>LazySObjectIterator</code>, call this
     * to convert the <Code>LazyIterator</Code> instance into a code>LazySObjectIterator</code>.
     *
     * @example //converts an iterator of invoice dates into a SObjectIterator of Invoice records using a user-written
     * //'BuildInvoices' class implementing nebc.Function.
     * new nebc.LazyIterator(invoiceDates)
     *      .mapValues(new BuildInvoices())
     *      .toSObjectIterator()
     *      .doInsert();
     *
     * @return a LazySObjectIterator of this iterator
     */
    global LazySObjectIterator toSObjectIterator() {
        return new LazySObjectIterator(this);
    }

    /**
     * Calls a <code>VoidFunction</code> on every item within the iterator. Is a terminator for the iterator.
     *
     * @param callingFunction a function to call for each item in the iterator.
     */
    global void forEach(VoidFunction callingFunction) {
        while(hasNext()) {
            callingFunction.call(next());
        }
    }

    /**
     * Calls a <code>Function</code> on every item within the iterator. Is a terminator for the iterator.
     *
     * @param callingFunction a function to call for each item in the iterator.
     */
    global void forEach(Function callingFunction) {
        while (hasNext()) {
            callingFunction.call(next());
        }
    }

    /**
     * Acts as a terminator for the iterator. Required for iterator to complete.
     *
     * @example //Sets the billing country for every record in accounts to "United Kingdom".
     * new nebc.LazySObjectIterator(accounts)
     *      .put(Account.BillingCountry, 'United Kingdom')
     *      .forEach();
     */
    global void forEach() {
        while(hasNext()) {
            next();
        }
    }

    /** If the iterator is empty, this method will return the supplied defaultValue instead.
     *
     * @param defaultValue the value to use if the iterator is empty
     *
     * @return returns either existing iterator or a defaultValue if there are no items in the original iterator.
     */
    global LazyIterator setDefaultIfEmpty(Object defaultValue) {
        return setDefaultIfEmpty(new List<Object> {defaultValue}.iterator());
    }

    /** If the iterator is empty, this method will return the supplied defaultValues instead.
     *
     * @param defaultValues the values to use if the iterator is empty.
     *
     * @return returns either existing iterator or defaultValues if there are no items in the original iterator.
     */
    global LazyIterator setDefaultIfEmpty(Iterator<Object> defaultValues) {
        return new LazyDefaultIfEmptyIterator(getIteratorForDecorator(), defaultValues);
    }

    /**
     * Retrieves n items from a LazyIterator.
     *
     * @example //Gets the first four account records from accounts and creates a list
     * List<Account> firstFourAccounts = (List<Account>) new nebc.LazyIterator(accounts)
     *      .take(4)
     *      .toList(List<Account>());
     *
     * @return a <code>LazyIterator</code> of <code>nItemsToTake</code> length
     */
    global LazyIterator take(Integer nItemsToTake) {
        return new LazyTakeIterator(getIteratorForDecorator(), nItemsToTake);
    }

    /**
     * Prepends a LazyIterator onto the start of another LazyIterator
     *
     * @example //Creates a list of account records from otherAccounts and accounts, in that order.
     * List<Account> allAccounts = (List<Account>) new nebc.LazyIterator(accounts)
     *      .prepend(new nebc.LazyIterator(otherAccounts))
     *      .toList(List<Account>());
     *
     * @return a <code>LazyIterator</code> of the combined iterators
     */
    global LazyIterator prepend(LazyIterator other) {
        return new LazyAppendIterator(other, getIteratorForDecorator());
    }

    /**
     * Appends a LazyIterator onto the end of another LazyIterator
     *
     * @example //Creates a list of account records from accounts and otherAccounts, in that order.
     * List<Account> allAccounts = (List<Account>) new nebc.LazyIterator(accounts)
     *      .append(new nebc.LazyIterator(otherAccounts))
     *      .toList(List<Account>());
     *
     * @return a <code>LazyIterator</code> of the combined iterators
     */
    global LazyIterator append(LazyIterator other) {
        return new LazyAppendIterator(getIteratorForDecorator(), other);
    }

    /**
     * Appends an item onto the end of another LazyIterator
     *
     * @example //Creates a list of account records from accounts and otherAccount, in that order.
     * List<Account> allAccounts = (List<Account>) new nebc.LazyIterator(accounts)
     *      .append(otherAccount)
     *      .toList(List<Account>());
     *
     * @return a <code>LazyIterator</code> of the iterator and the appended record
     */
    global LazyIterator append(Object item) {
        return new LazyAppendIterator(getIteratorForDecorator(), new List<Object>{item}.iterator());
    }

    /**
     * Prepends an item onto the start of another LazyIterator
     *
     * @example //Creates a list of account records from otherAccount and accounts, in that order.
     * List<Account> allAccounts = (List<Account>) new nebc.LazyIterator(accounts)
     *      .prepend(otherAccount)
     *      .toList(List<Account>());
     *
     * @return a <code>LazyIterator</code> of the prepended record and the iterator
     */
    global LazyIterator prepend(Object item) {
        return new LazyAppendIterator(new List<Object>{item}.iterator(), getIteratorForDecorator());
    }

    /** Flattens one level of nesting in an iterator.
     *
     * @example //From a iterator of invoices, Invoice schedules turns the iterator into an iterator of lists of invoice schedules
     * //This is then flattened and inserted.
     * new nebc.LazySObjectIterator(invoices)
     *      .expand(new CreateInvoiceSchedules())
     *      .flatten()
     *      .toSObjectIterator()
     *      .doInsert();
     *
     * @return a LazyIterator of the flattened items.
     */
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