/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 2019-03-22
 * @description TriggerContextPair-typed version of LazyIterator
 */
global class LazyTriggerContextPairIterator extends LazyIterator {

    /** Generates a LazyIterator of <code>TriggerContextPair</code> tuples. Provides methods specific to processing
     * old and new records from the trigger context.
     *
     * @param oldList the trigger.old values
     * @param newList the trigger.new values
     */
    global LazyTriggerContextPairIterator(List<SObject> oldList, List<SObject> newList) {
        super(new TriggerContextIterator(oldList, newList));
    }

    /** Generates a LazyIterator of <code>TriggerContextPair</code> tuples from a <code>TriggerContextIterator</code>. Provides methods specific to processing
     * old and new records from the trigger context.
     *
     * @param iterator a <code>TriggerContextIterator</code> to source the <code>TriggerContextPair</code> from
     */
    global LazyTriggerContextPairIterator(TriggerContextIterator iterator) {
        super(iterator);
    }

    /** Retrieves just the new records from the Trigger Context Pair
     * @example
     * List<Account> newAccounts = new nebc.LazyTriggerContextPairIterator(Trigger.old, Trigger.new)
     *      .newRecords()
     *      .toList();
     *
     * @return <code>LazySObjectIterator</code> of the Trigger.new records from the TriggerContextPair
     */
    global LazySObjectIterator newRecords() {
        return new LazySObjectIterator(mapValues(new NewFromTriggerContextPair()));
    }

    /** Retrieves just the old records from the Trigger Context Pair
     * @example
     * List<Account> oldAccounts = new nebc.LazyTriggerContextPairIterator(Trigger.old, Trigger.new)
     *      .newRecords()
     *      .toList();
     *
     * @return <code>LazySObjectIterator</code> of the Trigger.old records from the TriggerContextPair
     */
    global LazySObjectIterator oldRecords() {
        return new LazySObjectIterator(mapValues(new OldFromTriggerContextPair()));
    }

    /** Retrieves just the old and new records from the Trigger Context Pair into a single iterator
     * @example
     * List<Account> allAccounts = new nebc.LazyTriggerContextPairIterator(Trigger.old, Trigger.new)
     *      .bothRecords()
     *      .toList();
     *
     * @return <code>LazySObjectIterator</code> of the Trigger.old records and Trigger.new records from the TriggerContextPair
     */
    global LazySObjectIterator bothRecords() {
        return new LazySObjectIterator(flatten());
    }

    /**
     * Removes TriggerContextPair instances from the iterator that do not pass the filter conditions. The filter conditions are
     * provided by a <code>BooleanFunction</code>. If the <code>BooleanFunction</code>'s <code>isTrueFor</code> method
     * evaluates to false when called on the TriggerContextPair, the instance is removed.
     *
     * @example //Creates a list of accounts where the name has been changed in the trigger context.
     * new nebc.LazyTriggerContextPairIterator(trigger.old, trigger.new)
     *              .filterT(new nebc.IsFieldChangedInTrigger(Account.Name))
     *              .toList();
     *
     * @param matchingFunction a <code>BooleanFunction</code> to apply to all TriggerContextPair instances within the iterator,
     * to determine whether they should remain in the iterator
     * @return a filtered version of the <code>LazyTriggerContextPairIterator</code>
     */
    global LazyTriggerContextPairIterator filterT(BooleanFunction matchingFunction) {
        this.iterator = super.filter(matchingFunction);
        return this;
    }

    /**
     * Removes TriggerContextPair instances from the iterator that do not pass the filter conditions after the mapping function
     * hass been applied to it. The filter conditions areprovided by a <code>BooleanFunction</code>. If the
     * <code>BooleanFunction</code>'s <code>isTrueFor</code> method evaluates to false when called on the TriggerContextPair,
     * the instance is removed.
     *
     * @example //Creates a list of accounts where the name has been changed and the new name is 'To Archive'
     * new nebc.LazyTriggerContextPairIterator(trigger.old, trigger.new)
     *              .filterT(new nebc.IsFieldChangedInTrigger(Account.Name))
     *              .filterT(
     *                  new nebc.Composition(new nebc.NewFromTriggerContextPair(), new nebc.FieldFromSObject(Account.Name))
     *                  new nebc.IsEqual('To Archive')
     *              )
     *              .toList();
     *
     * @param mappingFunction a <code>Function</code> that is applied to all TriggerContextPair instance prior to the matching
     * function being evaluated.
     * @param matchingFunction a <code>BooleanFunction</code> to apply to all TriggerContextPair instances within the iterator,
     * to determine whether they should remain in the iterator
     * @return a filtered version of the <code>LazyTriggerContextPairIterator</code>
     */
    global LazyTriggerContextPairIterator filterT(Function mappingFunction, BooleanFunction matchingFunction) {
        this.iterator = super.filter(mappingFunction, matchingFunction);
        return this;
    }

    /**
     * Filters the iterator using a matching <code>BooleanFunction</code>. The <code>TriggerContextPair</code>'s left in
     * the iterator are those where the matching function evaluates to false when applied to the old record, but evaluates
     * to true on the new record.
     *
     * @example //filters opportunity records trigger context pairs where the StageName has been changed to Closed Won
     * //then gets the new records and puts them into a list.
     * new nebc.LazyTriggerContextPairIterator(trigger.old, trigger.new)
     *          .filterBecameTrue(new nebc.IsSObjectFieldEqual(Opportunity.StageName, 'Closed Won'))
     *          .newRecords()
     *          .toList();
     *
     * @param matchingFunction a <code>Boolean</code> that is applied to all TriggerContextPair instances. TriggersContextPairs where
     * the matching function evaluates to false on the old record and true on the new record are retained in the iterator.
     *
     * @return a filtered version of the <code>LazyTriggerContextPairIterator</code>
     */
    global LazyTriggerContextPairIterator filterBecameTrue(BooleanFunction matchingFunction) {
        Function matchingFunctionAsFunction = new BooleanFunctionToFunction(new IsAll(new IsNotNull(), matchingFunction));

        return filterT(new IsAll(
                new IsNot(new FunctionToBooleanFunction(new Composition(new OldFromTriggerContextPair()).compose(matchingFunctionAsFunction))),
                new FunctionToBooleanFunction(new Composition(new NewFromTriggerContextPair()).compose(matchingFunctionAsFunction))
        ));
    }

    /**
    * Filters the iterator using a matching <code>BooleanFunction</code>. The <code>TriggerContextPair</code>'s left in
    * the iterator are those where the matching function evaluates to true when applied to the old record, but evaluates
    * to false on the new record.
    *
    * @example //filters opportunity records trigger context pairs where the StageName has been changed from Qualification
    * //then gets the new records and puts them into a list.
    * new nebc.LazyTriggerContextPairIterator(trigger.old, trigger.new)
    *          .filterBecameFalse(new nebc.IsSObjectFieldEqual(Opportunity.StageName, 'Qualification'))
    *          .newRecords()
    *          .toList();
    *
    * @param matchingFunction a <code>Boolean</code> that is applied to all TriggerContextPair instances. TriggersContextPairs where
    * the matching function evaluates to true on the old record and false on the new record are retained in the iterator.
    *
    * @return a filtered version of the <code>LazyTriggerContextPairIterator</code>
    */
    global LazyTriggerContextPairIterator filterBecameFalse(BooleanFunction matchingFunction) {
        Function matchingFunctionAsFunction = new BooleanFunctionToFunction(new IsAll(new IsNotNull(), matchingFunction));

        return filterT(new IsAll(
                new FunctionToBooleanFunction(new Composition(new OldFromTriggerContextPair()).compose(matchingFunctionAsFunction)),
                new IsNot(new FunctionToBooleanFunction(new Composition(new NewFromTriggerContextPair()).compose(matchingFunctionAsFunction)))
        ));
    }

    /**
     * Applies the mapping function to every record in the <code>LazyTriggerContextPairIterator</code>. The target of the mapping function
     * is a <code>TriggerContextPair</code>
     *
     * @example
     * //Applies a TupleMapFunction to the TriggerContextPairs in the iterator.
     * //The TupleMapFunction makes no changes to the oldRecord, but sets the StageName on all newRecord to 'Closed Won'
     * new nebc.LazyTriggerContextPairIterator(trigger.old, trigger.new)
     *      .mapValuesT(new nebc.TupleMapFunction(
     *          new nebc.IdentityFunction(),
     *          new nebc.SObjectPutField(Opportunity.StageName, 'Closed Won')
     *      ))
     *      .newRecords()
     *      .toList();
     *
     * @param mappingFunction an instance of a class implementing <code>Function</code> to apply to each record
     *
     * @return a new version of the iterator where the mapping function has been applied to each record.
     */
    global LazyTriggerContextPairIterator mapValuesT(Function mappingFunction) {
        this.iterator = super.mapValues(mappingFunction);
        return this;
    }

    /** Gets a field value from the old record in the <code>TriggerContextPair</code> and puts it into a field in the
     * new record.
     *
     * @example
     * //When an account description is changed and made null, copy the account description from the old record into the new record.
     * new nebc.LazyTriggerContextPairIterator(trigger.old, trigger.new)
     *      .filterT(new nebc.IsFieldChangedInTrigger(Account.Description))
     *      .filterBecameTrue(new nebc.IsNull(Account.Description))
     *      .mapNewFromOld(Account.Description, Account.Description)
     *      .forEach();
     *
     * @param destinationField the field on the new record where the calculated value will be put
     * @param sourceField the field from the old record that will supply the value
     *
     * @return a modified version of the iterator where the new record of each <code>TriggerContextPair</code> has been updated
     */
    global LazyTriggerContextPairIterator mapNewFromOld(SObjectField destinationField, SObjectField sourceField) {
        return mapNewFromOld(destinationField, new FieldFromSObject(sourceField));
    }

    /** Retrieves a field value from the old record in the <code>TriggerContextPair</code>, applies a function to the value
     * then puts the value into a field on the newRecord.
     *
     * @example
     * //When an opportunity's StageName is updated to 'Closed Won', the Name on the opportunity is updated
     * //The StringFormat function will put 'Closed - ' in front of the name from the old record.
     * new nebc.LazyTriggerContextPairIterator(trigger.old, trigger.new)
     *      .filterBecameTrue(new nebc.IsSObjectFieldEqual(Opportunity.StageName, 'Closed Won'))
     *      .mapNewFromOld(Opportunity.Name, Opportunity.Name, new nebc.StringFormat('Closed - {0}')
     *      .forEach();
     *
     * @param destinationField the field on the new record where the calculated value will be put
     * @param sourceField the field from the old record that will supply the value
     * @param fieldValueMappingFunction the function that will be applied to the value from the sourceField
     *
     * @return a modified version of the iterator where the new record of each <code>TriggerContextPair</code> has been updated
     */
    global LazyTriggerContextPairIterator mapNewFromOld(SObjectField destinationField, SObjectField sourceField, Function fieldValueMappingFunction) {
        return mapNewFromOld(destinationField, new Composition(new FieldFromSObject(sourceField)).compose(fieldValueMappingFunction));
    }

    /** Applies a function to the old record in the <code>TriggerContextPair</code> and puts the result into the supplied
     * <code>SObjectField</code>
     *
     * @example
     * //When an account description is changed and made null, copy the account description from the old record into the new record.
     * new nebc.LazyTriggerContextPairIterator(trigger.old, trigger.new)
     *      .filterT(new nebc.IsFieldChangedInTrigger(Account.Description))
     *      .filterBecameTrue(new nebc.IsNull(Account.Description))
     *      .mapNewFromOld(Account.Description, new nebc.FieldFromSObject(Account.Description))
     *      .forEach();
     *
     * @param destinationField the field on the new record where the calculated value will be put
     * @param functionOnOldRecord the function that will be applied to the old record in the <code>TriggerContextPair</code> to
     * calculate the value
     *
     * @return a modified version of the iterator where the new record of each <code>TriggerContextPair</code> has been updated
     */
    global LazyTriggerContextPairIterator mapNewFromOld(SObjectField destinationField, Function functionOnOldRecord) {
        return mapValuesT(new Swap())
                .mapValuesT(new TupleMapFunction(
                        new SObjectPutField(destinationField, functionOnOldRecord),
                        new IdentityFunction()
                )
                        .setTupleNewInstance(TwoTuple.newInstance)
                )
                .mapValuesT(new Swap());
    }
}