/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 2019-03-22
 * @description SObject-typed version of LazyIterator
 */
global inherited sharing class LazySObjectIterator extends LazyIterator {

    /**
     * Builds an SObject-typed version of LazyIterator, making SObject specific methods available.
     *
     * @example
     * LazySObjectIterator accountsIterator = new nebc.LazySObjectIterator([SELECT Id FROM Account]);
     *
     * @param iterableOrIterator the source collection or iterator used to generate the <code>LazySObjectIterator</code>
     */
    global LazySObjectIterator(Object iterableOrIterator) {
        super(iterableOrIterator);
    }

    /**
     * Removes SObject records from the iterator that do not pass the filter conditions. The filter conditions are
     * provided by a <code>BooleanFunction</code>. If the <code>BooleanFunction</code>'s <code>isTrueFor</code> method
     * evaluates to false when called on the SObject, the record is removed.
     *
     * @example //Removes accounts where the name is not 'Test Account'
     * new nebc.LazySObjectIterator(accounts)
     *     .filterT(new nebc.IsSObjectFieldEqual(Account.Name, 'Test Account'))
     *     .toList();
     *
     * @param matchingFunction a <code>BooleanFunction</code> to apply to all SObjects within the iterator, to determine
     * whether they should remain in the iterator
     * @return a filtered version of the <code>LazySObjectIterator</code>
     */
    global LazySObjectIterator filterT(BooleanFunction matchingFunction) {
        this.iterator = super.filter(matchingFunction);
        return this;
    }

    /**
     * Removes SObject records from the iterator that do not pass the filter conditions after a mapping <code>Function</code> has been
     * applied. The filter conditions are provided by a <code>BooleanFunction</code>. If the <code>BooleanFunction</code>'s
     * <code>isTrueFor</code> method evaluates to false when called on the modified value, the record is removed.
     *
     * @example //Removes accounts where the name is not 'Test Account'
     * new nebc.LazySObjectIterator(accounts)
     *     .filterT(new nebc.FieldFromSObject(Account.Name), new nebc.IsEqual('Test Account'))
     *     .toList();
     *
     * @param mappingFunction a <code>Function</code> to modify the record being evaluated
     * @param matchingFunction a <code>BooleanFunction</code> to apply to all SObjects within the iterator, to determine
     * whether they should remain in the iterator
     * @return a filtered version of the <code>LazySObjectIterator</code>
     */
    global LazySObjectIterator filterT(Function mappingFunction, BooleanFunction matchingFunction) {
        this.iterator = super.filter(mappingFunction, matchingFunction);
        return this;
    }

    /**
     * Removes SObject records from the iterator where the specified field does not equal the value provided or does not pass the
     * provided <code>BooleanFunction</code>'s <code>isTrueFor</code> method
     *
     * @example
     * //removes accounts where the Name field is not 'Test Account' from the iterator
     * new nebc.LazySObjectIterator(accounts)
     *     .filterOnField(Account.Name, 'Test Account')
     *     .toList();
     * //removes accounts where the BillingCountry field is null
     * new nebc.LazySObjectIterator(accounts)
     *     .filterOnField(Account.BillingCountry, new nebc.IsNotNull())
     *     .toList();
     *
     * @param field the SObjectField on the record to be evaluated
     * @param valueOrBooleanFunction either a value or a BooleanFunction to evaluate the field with
     *
     * @return a filtered version of the <code>LazySObjectIterator</code>
     */
    global LazySObjectIterator filterOnField(SObjectField field, Object valueOrBooleanFunction) {
        this.iterator = super.filter(
                new FieldFromSObject(field),
                valueOrBooleanFunction instanceof BooleanFunction ? (BooleanFunction)valueOrBooleanFunction : new IsEqual(valueOrBooleanFunction)
        );
        return this;
    }

    /**
     * Removes SObject records from the iterator where the specified field does not equal the value provided or does not pass the
     * provided <code>BooleanFunction</code>'s <code>isTrueFor</code> method
     *
     * @example
     * //removes accounts where the Name field is not 'Test Account' from the iterator
     * new nebc.LazySObjectIterator(accounts)
     *     .filterOnField('Name', 'Test Account')
     *     .toList();
     * //removes accounts where the BillingCountry field is null
     * new nebc.LazySObjectIterator(accounts)
     *     .filterOnField('BillingCountry', new nebc.IsNotNull())
     *     .toList();
     *
     * @param field a String representation of the field on the record to be evaluated
     * @param valueOrBooleanFunction either a value or a <code>BooleanFunction</code> to evaluate the field with
     *
     * @return a filtered version of the <code>LazySObjectIterator</code>
     */
    global LazySObjectIterator filterOnField(String field, Object valueOrBooleanFunction) {
        this.iterator = super.filter(
                new FieldFromSObjectString(field),
                valueOrBooleanFunction instanceof BooleanFunction ? (BooleanFunction)valueOrBooleanFunction : new IsEqual(valueOrBooleanFunction)
        );
        return this;
    }

    /**
     * Applies the mapping function to every record in the LazySObjectIterator.
     *
     * @example
     * //creates a list of contacts related to each account using the SObjectFromPrototype function.
     * List<Contact> contacts = new nebc.LazySObjectIterator(accounts)
     *   .mapValuesT(
     *           new nebc.SObjectFromPrototype(new Contact())
     *                   .putField(Contact.AccountId, Account.Id)
     *                   .put(Contact.LastName, 'Default Contact')
     *   )
     *   .toList();
     *
     * @param mappingFunction an instance of a class implementing <code>Function</code> to apply to each record
     *
     * @return a new version of the iterator where the mapping function has been applied to each record.
     */
    global LazySObjectIterator mapValuesT(Function mappingFunction) {
        this.iterator = super.mapValues(mappingFunction);
        return this;
    }

    /**
    * Applies the mapping function to every record in the LazySObjectIterator that meets the filter criteria.
    *
    * @example
    * //For every account that has a billing address a contact is created using
    * //the SObjectFromPrototype function and put into a list.
    * List<Contact> contacts = new nebc.LazySObjectIterator(accounts)
    *   .mapValuesT(
    *           new nebc.IsNotNull(Account.BillingCountry),
    *           new nebc.SObjectFromPrototype(new Contact())
    *                   .putField(Contact.AccountId, Account.Id)
    *                   .put(Contact.LastName, 'Default Contact')
    *   )
    *   .toList();
    *
    * @param filterFunction an instance of a class implementing <code>BooleanFunction</code> that determines which records the mapping function
    * should be applied to
    * @param mappingFunction an instance of a class implementing <code>Function</code>
    *
    * @return a new version of the <code>LazySObjectIterator</code> where the mapping function has been applied to each record that met the filter criteria
    */
    global LazySObjectIterator mapValuesT(BooleanFunction filterFunction, Function mappingFunction) {
        this.iterator = super.mapValues(filterFunction, mappingFunction);
        return this;
    }

    /**
     * Calls the mapping function on each item as it is iterated, returning the original unmodified item. Can be used
     * to add iterated items to a collection whilst also processing them another way later.
     *
     * @example
     * //Retrieves the parentId from every account and adds it to the parentIds set using a composition.
     * Set<Id> parentIds = new Set<Id>();
     * new nebc.LazySObjectIterator(accounts)
     *      .observeValuesT(
     *           new Composition(new FieldFromSObject(Account.ParentId))
     *               .compose(new nebc.AddTo(parentIds))
     *      )
     *      .forEach();
     *
     * @param mappingFunction an instance of a class implementing <code>Function</code> to call on each item. Calling
     * the function should not modify the underlying values.
     *
     * @return an unmodified version of the <code>LazySObjectIterator</code>
     */
    global LazySObjectIterator observeValuesT(Function mappingFunction) {
        this.iterator = super.observeValues(mappingFunction);
        return this;
    }

    /**
     * Adds a field value to a collection and returns an unmodified version of the iterator
     *
     * @example
     * //Retrieves the parent and grandparent account Ids and adds them to a set.
     * Set<Id> parentAndGrandParentIds = new Set<Id>();
     * new nebc.LazySObjectIterator(accounts)
     *      .observeField(Account.Id, parentAndGrandParentIds)
     *      .observeField('Parent.ParentId', parentAndGrandParentIds)
     *      .forEach();
     *
     * @param field the <code>SObjectField</code> to retrieve
     * @param addableCollection the collection to add the value to
     *
     * @return a new version of the <code>LazySObjectIterator</code> where the mapping function has been applied to each record.
     */
    global LazySObjectIterator observeField(SObjectField field, Object addableCollection) {
        return this.observeValuesT(new Composition(new FieldFromSObject(field)).compose(getCollectionAdder(addableCollection)));
    }

    /**
     * Adds a field value to a collection and returns an unmodified version of the iterator
     *
     * @example
     * //Retrieves the parent and grandparent account Ids and adds them to a set.
     * Set<Id> parentAndGrandParentIds = new Set<Id>();
     * new nebc.LazySObjectIterator(accounts)
     *      .observeField(Account.Id, parentAndGrandParentIds)
     *      .observeField('Parent.ParentId', parentAndGrandParentIds)
     *      .forEach();
     *
     * @param field the <code>SObjectField</code> to retrieve
     * @param addableCollection the collection to add the value to
     *
     * @return a new version of the <code>LazySObjectIterator</code> where the mapping function has been applied to each record.
     */
    global LazySObjectIterator observeField(String field, Object addableCollection) {
        return this.observeValuesT(new Composition(new FieldFromSObjectString(field)).compose(getCollectionAdder(addableCollection)));
    }

    /**
     * Adds a field value to a collection and returns an unmodified version of the iterator
     *
     * @example
     * //Collect two sets of non-null IDs from a list of records in a single iterator
     * //e.g. Only collect AccountId & ContactId from a list of Cases where those individual fields are not null.
     * Set<Id> accountIds = new Set<Id>();
     * Set<Id> contactIds = new Set<Id>();
     * new nebc.LazySObjectIterator(cases)
     *      .observeValuesT(new nebc.IsNotNull(Case.AccountId), new nebc.Composition(Case.AccountId).compose(new nebc.AddTo(accountIds)))
     *      .observeValuesT(new nebc.IsNotNull(Case.ContactId), new nebc.Composition(Case.ContactId).compose(new nebc.AddTo(contactIds)))
     *      .forEach();
     *
     * @param filterFunction the <code>SObjectField</code> to retrieve
     * @param mappingFunction the collection to add the value to
     *
     * @return a new version of the <code>LazySObjectIterator</code> where the mapping function has been applied to each record.
     */
    global LazySObjectIterator observeValuesT(BooleanFunction filterFunction, Function mappingFunction) {
        this.iterator = super.observeValues(filterFunction, mappingFunction);
        return this;
    }

    /**
     * Equivalent to calling record.put(SObjectField, value) on all items in the iterator
     *
     * @example
     * //Sets all BillingCountry fields to 'United Kingdom'
     * new nebc.LazySObjectIterator(accounts)
     *      .put(Account.BillingCountry, 'United Kingdom')
     *      .forEach();
     * //Sets all ShippingCountry fields to the value from BillingCountry
     * new nebc.LazySObjectIterator(accounts)
     *      .put(Account.ShippingCountry, new nebc.FieldFromSObject(Account.BillingCountry))
     *      .forEach();
     *
     * @param field the <code>SObjectField</code> to be set
     * @param valueOrFunction the value or <code>Function</code> to provide a value for the field
     *
     * @return a <code>LazySObjectIterator</code> of the modified sObjects
     */
    global LazySObjectIterator put(SObjectField field, Object valueOrFunction) {
        iterator = new LazyMappingIterator(iterator, new SObjectPutField(field, valueOrFunction));
        return this;
    }

    /**
     * For every record in the iterator, the value from the source field is put into the target field.
     *
     * @example //Sets all ShippingCountry fields to the value from BillingCountry
     * new nebc.LazySObjectIterator(accounts)
     *      .putField(Account.ShippingCountry, Account.BillingCountry)
     *      .forEach();
     *
     * @param targetField the <code>SObjectField</code> to be set
     * @param sourceField the <code>SObjectField</code> to provide a value
     *
     * @return a <code>LazySObjectIterator</code> of the modified sObjects
     */
    global LazySObjectIterator putField(SObjectField targetField, SObjectField sourceField) {
        iterator = new LazyMappingIterator(iterator, new SObjectPutField(targetField, new FieldFromSObject(sourceField)));
        return this;
    }

    /**
     * For every record in the iterator, the value from the source field is put into the target field.
     *
     * @example //Sets all ShippingCountry fields to the value from BillingCountry
     * new nebc.LazySObjectIterator(accounts)
     *      .putField(Account.ShippingCountry, 'BillingCountry')
     *      .forEach();
     *
     * @param targetField the <code>SObjectField</code> to be set
     * @param sourceField A string representation of the SObject field to provide a value. Your can use multilevel references
     * in this method. i.e Parent.BillingCountry
     *
     * @return a <code>LazySObjectIterator</code> of the modified sObjects
     */
    global LazySObjectIterator putField(SObjectField targetField, String sourceField) {
        iterator = new LazyMappingIterator(iterator, new SObjectPutField(targetField, new FieldFromSObjectString(sourceField)));
        return this;
    }

    /**
     * Equivalent to calling record.put(SObjectField, value) on all items in the iterator that meet the filter criteria
     *
     * @example
     * //If the BillingCountry field is null, it is set to 'United Kingdom'
     * new nebc.LazySObjectIterator(accounts)
     *      .putIf(new nebc.IsNull(Account.BillingCountry), Account.BillingCountry, 'United Kingdom')
     *      .forEach();
     * //If the BillingCountry field is null, it is set to the value from BillingCountry
     * new nebc.LazySObjectIterator(accounts)
     *      .putIf(new nebc.IsNull(Account.ShippingCountry), Account.ShippingCountry, new nebc.FieldFromSObject(Account.BillingCountry))
     *      .forEach();
     *
     * @param filterFunction an instance of a class implementing <code>BooleanFunction</code> that provides the filter criteria
     * @param field the <code>SObjectField</code> to be set
     * @param valueOrFunction the value or <code>Function</code> to provide a value for the field
     *
     * @return a <code>LazySObjectIterator</code> of the modified sObjects
     */
    global LazySObjectIterator putIf(BooleanFunction filterFunction, SObjectField field,  Object valueOrFunction) {
        iterator = new LazyMappingConditionalIterator(iterator, filterFunction, new SObjectPutField(field, valueOrFunction));
        return this;
    }

    /**
    * Retrieves the value from the specified field in every record in the iterator. Returns a LazyIterator of the values.
    *
    * @example
    * //Retrieves all billing countries from 'accounts' and puts it into a new List of strings.
    * new nebc.LazySObjectIterator(accounts)
    *      .get(Account.BillingCountry)
    *      .toList(new List<String>());
    *
    * @param field the <code>SObjectField</code> to retrieve from each record
    *
    * @return a <code>LazyIterator</code> of the field values
    */
    global LazyIterator get(SObjectField field) {
        return mapValues(new FieldFromSObject(field));
    }

    /**
    * Calls the SObject.getSObject(SObjectField) method on each member of the iterator. Returns an SObject referenced by
    * a lookup field
    *
    * @example
    * //Creates a list of parent accounts from a list of contacts.
    * List<Contact> contacts = [SELECT Id, Account.Name, Account.CreatedDate FROM Contact];
    * List<Account> accounts = new nebc.LazySObjectIterator(contacts)
    *      .getSObject(Contact.AccountId)
    *      .toList();
    *
    * @param field the lookup <code>SObjectField</code> that should be used to retrieve an SObject
    *
    * @return a <code>LazySObjectIterator</code> of the retrieved SObjects
    */
    global LazySObjectIterator getSObject(SObjectField field) {
        return mapValuesT(new SObjectFromSObject(field));
    }

    /**
    * Calls the SObject.getSObjects(String) method on each member of the iterator. Extracts child SObject lists from
    * relationship fields on SObject instances
    *
    * @example
    * //Creates a list of child contacts from a list of accounts.
    * List<Account> accounts = [SELECT Id, (SELECT Id, Name FROM Contacts) FROM Account];
    * List<Contact> contacts = new nebc.LazySObjectIterator(accounts)
    *      .getSObjects('Contacts')
     *     .flatten()
     *     .toSObjectIterator()
    *      .toList();
    *
    * @param field the child relationship field name.
    *
    * @return a <code>LazyIterator</code> of Lists of the retrieved SObjects
    */
    global LazySObjectIterator getSObjects(String field) {
        return new LazySObjectIterator(expand(new SObjectsFromSObjectString(field)));
    }

    /**
    * Retrieves the value from the specified field in every record in the iterator and puts them into a new List
    *
    * @example
    * //Retrieves all billing countries from 'accounts' and puts it into a new List of strings.
    * new nebc.LazySObjectIterator(accounts).get(Account.BillingCountry, new List<String>());
    *
    * @param field the <code>SObjectField</code> to retrieve from each record
    * @param toFill a list of Objects to fill with the retrieved values
    *
    * @return a List of the retrieved values
    */
    global List<Object> get(SObjectField field, List<Object> toFill) {
        return mapValues(new FieldFromSObject(field)).toList(toFill);
    }

    /**
    * Retrieves the value from the specified Id field in every record in the iterator and puts them into a new Set
    *
    * @example
    * //Retrieves all parentIds from 'accounts' and puts it into a new Set of Id.
    * new nebc.LazySObjectIterator(accounts).get(Account.ParentId, new Set<Id>());
    *
    * @param field the Id <code>SObjectField</code> to retrieve from each record
    * @param toFill a set of Id to fill with the retrieved values
    *
    * @return a Set of the retrieved values
    */
    global Set<Id> get(SObjectField field, Set<Id> toFill) {
        return mapValues(new FieldFromSObject(field))
                .toSet(toFill);
    }

    /**
    * Retrieves the Id from every record in the iterator and puts them into a new Set
    *
    * @example
    * //Retrieves all Ids from 'accounts' and puts it into a new Set of Ids
    * new nebc.LazySObjectIterator(accounts).getIds(new Set<Id>());
    *
    * @param toFill a set of Id to fill with the retrieved values
    *
    * @return a Set of the retrieved values
    */
    global Set<Id> getIds(Set<Id> toFill) {
        return mapValues(new IdFromSObject())
                .toSet(toFill);
    }

    /**
    * Retrieves the value from the specified String field in every record in the iterator and puts them into a new Set
    *
    * @example
    * //Retrieves all billing countries from 'accounts' and puts it into a new Set of strings.
    * new nebc.LazySObjectIterator(accounts).get(Account.BillingCountry, new Set<String>());
    *
    * @param field the <code>SObjectField</code> to retrieve from each record
    * @param toFill a set of String to fill with the retrieved values
    *
    * @return a Set of the retrieved values
    */
    global Set<String> get(SObjectField field, Set<String> toFill) {
        return mapValues(new FieldFromSObject(field))
                .toSet(toFill);
    }

    /**
    * Retrieves the value from the specified field and adds it to a List. The iterator must have a terminator function
    * (e.g. forEach) to complete successfully.
    *
    * @example
    * //Retrieves all created dates from 'accounts' and adds it to an existing List of Datetime
    * List<Datetime> createdDates = new List<Datetime>();
    * new nebc.LazySObjectIterator(accounts)
    *      .addTo(Account.CreatedDate, createdDates)
    *      .forEach();
    *
    * @param field the <code>SObjectField</code> to retrieve from each record
    * @param toFill a list of Objects to fill with the retrieved values
    *
    * @return the same <code>LazySObjectIterator</code>
    */
    global LazySObjectIterator addTo(SObjectField field, List<Object> toFill) {
        return observeValuesT(new Composition(new FieldFromSObject(field)).compose(new AddTo(toFill)));
    }

    /**
    * Retrieves the value from the specified field and adds it to a Set of Ids. The iterator must have a terminator function
    * (e.g. forEach) to complete successfully.
    *
    * @example
    * //Retrieves all parentIds from Account and adds it to an existing set.
    * Set<Id> parentIds = new Set<Id>();
    * new nebc.LazySObjectIterator(accounts)
    *     .addTo(Account.ParentId, parentIds)
    *     .forEach();
    *
    * @param field the <code>SObjectField</code> to retrieve from each record
    * @param toFill a set of Id to fill with the retrieved values
    *
    * @return the same <code>LazySObjectIterator</code>
    */
    global LazySObjectIterator addTo(SObjectField field, Set<Id> toFill) {
        return observeValuesT(new Composition(new FieldFromSObject(field)).compose(new AddTo(toFill)));
    }

    /**
    * Retrieves the value from the specified field and adds it to a Set of Strings. The iterator must have a terminator function
    * (e.g. forEach) to complete successfully.
    *
    * @example
    * //Retrieves all billing countries from 'accounts' and puts it into a Set of strings.
    * Set<String> countries = new Set<String>();
    * new nebc.LazySObjectIterator(accounts)
    *     .addTo(Account.BillingCountry, countries)
    *     .forEach();
    *
    * @param field the <code>SObjectField</code> to retrieve from each record
    * @param toFill a set of String to fill with the retrieved values
    *
    * @return the same <code>LazySObjectIterator</code>
    */
    global LazySObjectIterator addTo(SObjectField field, Set<String> toFill) {
        return observeValuesT(new Composition(new FieldFromSObject(field)).compose(new AddTo(toFill)));
    }

    /**
    * Terminates the LazySObjectIterator, converting it's contents into a List of SObjects.
    *
    * @example
    * //Sets the Billing address of all accounts to 'United Kingdom' and returns them in a new list.
    * List<Account> modifiedAccounts = new nebc.LazySObjectIterator(accounts)
    *      .put(Account.BillingAddress, 'United Kingdom')
    *      .toList();
    *
    * @return a list of SObjects derived from the <code>LazySObjectIterator</code>
    */
    global List<SObject> toList() {
        return toList(new List<SObject>());
    }

    // Note: the database methods have the noise-word do in front of them because they are otherwise reserved words

    /**
    * Performs an update DML Operation on the contents of the LazySObjectIterator
    *
    * @example //Sets all ShippingCountry fields to the value from BillingCountry, then updates the database.
    * new nebc.LazySObjectIterator(accounts)
    *      .putField(Account.ShippingCountry, Account.BillingCountry)
    *      .doUpdate();
    *
    * @return a <code>LazySObjectIterator</code> of the updated records
    */
    global LazySObjectIterator doUpdate() {
        List<SObject> records = toList();
        update records;
        return new LazySObjectIterator(records);
    }

    /**
    * Performs an update DML Operation on the contents of the LazySObjectIterator with the specified allOrNone flag
    *
    * @example //Sets all ShippingCountry fields to the value from BillingCountry, then updates the database.
    * List<nebc.SaveResult> results = (List<nebc.SaveResult) new nebc.LazySObjectIterator(accounts)
    *      .putField(Account.ShippingCountry, Account.BillingCountry)
    *      .doUpdate(false)
    *      .toList();
    *
    * @param allOrNothing sets the allOrNone DML option
    *
    * @return a <code>LazyIterator</code> of <code>SaveResult</code>
    */
    global LazyIterator doUpdate(Boolean allOrNothing) {
        Database.DMLOptions dmlOptions = new Database.DMLOptions();
        dmlOptions.optAllOrNone = allOrNothing;
        return doUpdate(dmlOptions);
    }

    /**
    * Performs an update DML Operation on the contents of the LazySObjectIterator with the specified allOrNone flag
    *
    * @example //Sets all ShippingCountry fields to the value from BillingCountry, then updates the database.
    * Database.DMLOptions options = new Database.DMLOptions();
    * options.optAllOrNone = true;
    * List<nebc.SaveResult> results = (List<nebc.SaveResult) new nebc.LazySObjectIterator(accounts)
    *      .putField(Account.ShippingCountry, Account.BillingCountry)
    *      .doUpdate(options)
    *      .toList();
    *
    * @param dmlOptions applies the provided <code>DMLOptions</code> to the DML Operation.
    *
    * @return a <code>LazyIterator</code> of <code>SaveResult</code>
    */
    global LazyIterator doUpdate(Database.DMLOptions dmlOptions) {
        List<SObject> records = toList();
        Iterator<Database.SaveResult> resultIterator = Database.update(records, dmlOptions).iterator();
        Iterator<SObject> recordIterator = records.iterator();
        return new LazyIterator(new TupleIterator(new List<Iterator<Object>>{ (Iterator<Object>)resultIterator, (Iterator<Object>)recordIterator}, SaveResult.newInstance));
    }

    /**
    * Performs an insert DML Operation on the contents of the LazySObjectIterator
    *
    * @example //Inserts a new contact for each account with a last name 'Default Contact'
    * new nebc.LazySObjectIterator(accounts)
    *    .mapValuesT(
    *            new nebc.SObjectFromPrototype(new Contact())
    *                    .putField(Contact.AccountId, Account.Id)
    *                    .put(Contact.LastName, 'Default Contact')
    *    )
    *    .doInsert();
    *
    * @return a <code>LazySObjectIterator</code> of the updated records
    */
    global LazySObjectIterator doInsert() {
        List<SObject> records = toList();
        insert records;
        return new LazySObjectIterator(records);
    }

    /**
    * Performs an insert DML Operation on the contents of the LazySObjectIterator with the specified allOrNone flag
    *
    * @example //Inserts a new contact for each account with a last name 'Default Contact'
    * List<nebc.SaveResult> results = (List<nebc.SaveResult>) new nebc.LazySObjectIterator(accounts)
    *    .mapValuesT(
    *            new nebc.SObjectFromPrototype(new Contact())
    *                    .putField(Contact.AccountId, Account.Id)
    *                    .put(Contact.LastName, 'Default Contact')
    *    )
    *    .doInsert(false)
    *    .toList();
    *
    * @param allOrNothing sets the allOrNone DML option
    *
    * @return a <code>LazyIterator</code> of <code>SaveResult</code>
    */
    global LazyIterator doInsert(Boolean allOrNothing) {
        Database.DMLOptions dmlOptions = new Database.DMLOptions();
        dmlOptions.optAllOrNone = allOrNothing;
        return doInsert(dmlOptions);
    }

    /**
    * Performs an insert DML Operation on the contents of the LazySObjectIterator with the specified DML Options
    *
    * @example //Inserts a new contact for each account with a last name 'Default Contact'
    * Database.DMLOptions options = new Database.DMLOptions();
    * options.optAllOrNone = true;
    * List<nebc.SaveResult> results = (List<nebc.SaveResult>) new nebc.LazySObjectIterator(accounts)
    *    .mapValuesT(
    *            new nebc.SObjectFromPrototype(new Contact())
    *                    .putField(Contact.AccountId, Account.Id)
    *                    .put(Contact.LastName, 'Default Contact')
    *    )
    *    .doInsert(options)
    *    .toList();
    *
    * @param dmlOptions applies the provided <code>DMLOptions</code> to the DML Operation.
    *
    * @return a <code>LazyIterator</code> of <code>SaveResult</code>
    */
    global LazyIterator doInsert(Database.DMLOptions dmlOptions) {
        List<SObject> records = toList();
        Iterator<Database.SaveResult> resultIterator = Database.insert(records, dmlOptions).iterator();
        Iterator<SObject> recordIterator = records.iterator();
        return new LazyIterator(new TupleIterator(new List<Iterator<Object>>{ (Iterator<Object>)resultIterator, (Iterator<Object>)recordIterator}, SaveResult.newInstance));
    }

    /**
    * Performs an upsert DML Operation on the contents of the LazySObjectIterator, using the specified SObjectField as an external Id field
    * and the specified allOrNone flag
    *
    * @example //Upserts a list of contacts with the External Id Field set as External_Id__c
    * List<nebc.UpsertResult> results = (List<nebc.UpsertResult>) new nebc.LazySObjectIterator(contacts)
    *    .doUpsert(Contact.External_Id__c, false)
    *    .toList();
    *
    * @param field <code>SObjectField</code> to use as an ExternalIdField
    * @param allOrNone sets the allOrNone DML option
    *
    * @return a <code>LazyIterator</code> of <code>UpsertResult</code>
    */
    global LazyIterator doUpsert(SObjectField field, Boolean allOrNone) {
        List<SObject> records = toList();
        Iterator<Database.UpsertResult> resultIterator = Database.upsert(records, field, allOrNone).iterator();
        Iterator<SObject> recordIterator = records.iterator();
        return new LazyIterator(new TupleIterator(new List<Iterator<Object>>{ (Iterator<Object>)resultIterator, (Iterator<Object>)recordIterator}, UpsertResult.newInstance));
    }

    /**
    * Performs an upsert DML Operation on the contents of the LazySObjectIterator, using the specified SObjectField as an external Id field.
    *
    * @example //Upserts a list of contacts with the External Id Field set as External_Id__c
    * List<nebc.UpsertResult> results = (List<nebc.UpsertResult>) new nebc.LazySObjectIterator(contacts)
    *    .doUpsert(Contact.External_Id__c)
    *    .toList();
    *
    * @param field <code>SObjectField</code> to use as an ExternalIdField
    *
    * @return a <code>LazyIterator</code> of <code>UpsertResult</code>
    */
    global LazyIterator doUpsert(SObjectField field) {
        return doUpsert(field, true);
    }

    /**
    * Performs a delete DML Operation on the contents of the LazySObjectIterator with the specified allOrNone flag
    *
    * @example //Creates an LazySObjectIterator from an Id iterator and deletes the resulting records.
    * new nebc.LazyIdIterator(contactIds)
    *    .mapValues(new nebc.SObjectFromPrototype(new Contact()).put(Contact.Id))
    *    .toSObjectIterator()
    *    .doDelete();
    *
    * @return the <code>LazySObjectIterator</code> of deleted records
    */
    global LazySObjectIterator doDelete() {
        List<SObject> records = toList();
        delete records;
        return new LazySObjectIterator(records);
    }

    /**
    * Performs a delete DML Operation on the contents of the LazySObjectIterator with the specified allOrNone flag
    *
    * @example //Creates an LazySObjectIterator from an Id iterator and deletes the resulting records.
    * List<nebc.DeleteResult> results = (List<nebc.DeleteResult>) new nebc.LazyIdIterator(contactIds)
    *    .mapValues(new nebc.SObjectFromPrototype(new Contact()).put(Contact.Id))
    *    .toSObjectIterator()
    *    .doDelete(false)
    *    .toList();
    *
    * @param allOrNothing sets the allOrNone DML option
    *
    * @return a <code>LazyIterator</code> of <code>DeleteResult</code>
    */
    global LazyIterator doDelete(Boolean allOrNothing) {
        List<SObject> records = toList();
        Iterator<Database.DeleteResult> resultIterator = Database.delete(records, allOrNothing).iterator();
        Iterator<SObject> recordIterator = records.iterator();
        return new LazyIterator(new TupleIterator(new List<Iterator<Object>>{ (Iterator<Object>)resultIterator, (Iterator<Object>)recordIterator}, DeleteResult.newInstance));
    }

    /**
    * Appends one LazySObjectIterator onto the end of an existing LazySObjectIterator.
    *
    * @example //Creates a LazySObjectIterator for a list of accounts. Then appends a second iterator onto the first.
    * LazySObjectIterator iterator = new nebc.LazySObjectIterator(someAccounts);
    * iterator.append(new nebc.LazySObjectIterator(someOtherAccounts);
    *
    * @param other the LazySObjectIterator to be appended to the end of this LazySObjectIterator
    *
    * @return a <code>LazySObjectIterator</code> consisting of all elements in both iterators
    */
    global LazySObjectIterator append(LazySObjectIterator other) {
        return new LazySObjectIterator(super.append(other));
    }

    private AddTo getCollectionAdder(Object addableCollection) {
        if(addableCollection instanceof Set<Id>) {
            return new AddTo((Set<Id>)addableCollection);
        } else if(addableCollection instanceof Set<String>) {
            return new AddTo((Set<String>)addableCollection);
        } else if(addableCollection instanceof List<Object>) {
            return new AddTo((List<Object>)addableCollection);
        } else if(addableCollection instanceof SObjectIndex) {
            return new AddTo((SObjectIndex)addableCollection);
        }

        Assertion.is('Expected collection to be Set<Id>, Set<String>, List<Object>, or nebc.SObjectType. Got ' + addableCollection)
                .that(false);

        return null;
    }
}