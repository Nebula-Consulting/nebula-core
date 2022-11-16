/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 2019-03-22
 * @description SObject-typed version of LazyIterator
 */

global inherited sharing class LazySObjectIterator extends LazyIterator {

    global LazySObjectIterator(Object iterableOrIterator) {
        super(iterableOrIterator);
    }

    global LazySObjectIterator filterT(BooleanFunction matchingFunction) {
        this.iterator = super.filter(matchingFunction);
        return this;
    }

    global LazySObjectIterator filterT(Function mappingFunction, BooleanFunction matchingFunction) {
        this.iterator = super.filter(mappingFunction, matchingFunction);
        return this;
    }

    global LazySObjectIterator filterOnField(SObjectField field, Object valueOrBooleanFunction) {
        this.iterator = super.filter(
                new FieldFromSObject(field),
                valueOrBooleanFunction instanceof BooleanFunction ? (BooleanFunction)valueOrBooleanFunction : new IsEqual(valueOrBooleanFunction)
        );
        return this;
    }

    global LazySObjectIterator filterOnField(String field, Object valueOrBooleanFunction) {
        this.iterator = super.filter(
                new FieldFromSObjectString(field),
                valueOrBooleanFunction instanceof BooleanFunction ? (BooleanFunction)valueOrBooleanFunction : new IsEqual(valueOrBooleanFunction)
        );
        return this;
    }

    global LazySObjectIterator mapValuesT(Function mappingFunction) {
        this.iterator = super.mapValues(mappingFunction);
        return this;
    }

    global LazySObjectIterator mapValuesT(BooleanFunction filterFunction, Function mappingFunction) {
        this.iterator = super.mapValues(filterFunction, mappingFunction);
        return this;
    }

    global LazySObjectIterator observeValuesT(Function mappingFunction) {
        this.iterator = super.observeValues(mappingFunction);
        return this;
    }

    global LazySObjectIterator observeField(SObjectField field, Object addableCollection) {
        return this.observeValuesT(new Composition(new FieldFromSObject(field)).compose(getCollectionAdder(addableCollection)));
    }

    global LazySObjectIterator observeField(String field, Object addableCollection) {
        return this.observeValuesT(new Composition(new FieldFromSObjectString(field)).compose(getCollectionAdder(addableCollection)));
    }

    global LazySObjectIterator observeValuesT(BooleanFunction filterFunction, Function mappingFunction) {
        this.iterator = super.observeValues(filterFunction, mappingFunction);
        return this;
    }

    global LazySObjectIterator put(SObjectField field,  Object valueOrFunction) {
        iterator = new LazyMappingIterator(iterator, new SObjectPutField(field, valueOrFunction));
        return this;
    }

    global LazySObjectIterator putField(SObjectField targetField, SObjectField sourceField) {
        iterator = new LazyMappingIterator(iterator, new SObjectPutField(targetField, new FieldFromSObject(sourceField)));
        return this;
    }

    global LazySObjectIterator putField(SObjectField targetField, String sourceField) {
        iterator = new LazyMappingIterator(iterator, new SObjectPutField(targetField, new FieldFromSObjectString(sourceField)));
        return this;
    }

    global LazySObjectIterator putIf(BooleanFunction filterFunction, SObjectField field,  Object valueOrFunction) {
        iterator = new LazyMappingConditionalIterator(iterator, filterFunction, new SObjectPutField(field, valueOrFunction));
        return this;
    }

    global LazyIterator get(SObjectField field) {
        return mapValues(new FieldFromSObject(field));
    }

    global LazySObjectIterator getSObject(SObjectField field) {
        return mapValuesT(new SObjectFromSObject(field));
    }

    global LazySObjectIterator getSObjects(String field) {
        return new LazySObjectIterator(expand(new SObjectsFromSObjectString(field)));
    }

    global List<Object> get(SObjectField field, List<Object> toFill) {
        return mapValues(new FieldFromSObject(field)).toList(toFill);
    }

    global Set<Id> get(SObjectField field, Set<Id> toFill) {
        return mapValues(new FieldFromSObject(field))
                .toSet(toFill);
    }

    global Set<String> get(SObjectField field, Set<String> toFill) {
        return mapValues(new FieldFromSObject(field))
                .toSet(toFill);
    }

    global LazySObjectIterator addTo(SObjectField field, List<Object> toFill) {
        return observeValuesT(new Composition(new FieldFromSObject(field)).compose(new AddTo(toFill)));
    }

    global LazySObjectIterator addTo(SObjectField field, Set<Id> toFill) {
        return observeValuesT(new Composition(new FieldFromSObject(field)).compose(new AddTo(toFill)));
    }

    global LazySObjectIterator addTo(SObjectField field, Set<String> toFill) {
        return observeValuesT(new Composition(new FieldFromSObject(field)).compose(new AddTo(toFill)));
    }

    global List<SObject> toList() {
        return toList(new List<SObject>());
    }

    // Note: the database methods have the noise-word do in front of them because they are otherwise reserved words
    global LazySObjectIterator doUpdate() {
        List<SObject> records = toList();
        update records;
        return new LazySObjectIterator(records);
    }

    global LazyIterator doUpdate(Boolean allOrNothing) {
        Database.DMLOptions dmlOptions = new Database.DMLOptions();
        dmlOptions.optAllOrNone = allOrNothing;
        return doUpdate(dmlOptions);
    }

    global LazyIterator doUpdate(Database.DMLOptions dmlOptions) {
        List<SObject> records = toList();
        Iterator<Database.SaveResult> resultIterator = Database.update(records, dmlOptions).iterator();
        Iterator<SObject> recordIterator = records.iterator();
        return new LazyIterator(new TupleIterator(new List<Iterator<Object>>{ (Iterator<Object>)resultIterator, (Iterator<Object>)recordIterator}, SaveResult.newInstance));
    }

    global LazySObjectIterator doInsert() {
        List<SObject> records = toList();
        insert records;
        return new LazySObjectIterator(records);
    }

    global LazyIterator doInsert(Boolean allOrNothing) {
        Database.DMLOptions dmlOptions = new Database.DMLOptions();
        dmlOptions.optAllOrNone = allOrNothing;
        return doInsert(dmlOptions);
    }

    global LazyIterator doInsert(Database.DMLOptions dmlOptions) {
        List<SObject> records = toList();
        Iterator<Database.SaveResult> resultIterator = Database.insert(records, dmlOptions).iterator();
        Iterator<SObject> recordIterator = records.iterator();
        return new LazyIterator(new TupleIterator(new List<Iterator<Object>>{ (Iterator<Object>)resultIterator, (Iterator<Object>)recordIterator}, SaveResult.newInstance));
    }

    global LazyIterator doUpsert(SObjectField field, Boolean allOrNone) {
        List<SObject> records = toList();
        Iterator<Database.UpsertResult> resultIterator = Database.upsert(records, field, allOrNone).iterator();
        Iterator<SObject> recordIterator = records.iterator();
        return new LazyIterator(new TupleIterator(new List<Iterator<Object>>{ (Iterator<Object>)resultIterator, (Iterator<Object>)recordIterator}, UpsertResult.newInstance));
    }

    global LazyIterator doUpsert(SObjectField field) {
        return doUpsert(field, true);
    }

    global LazySObjectIterator doDelete() {
        List<SObject> records = toList();
        delete records;
        return new LazySObjectIterator(records);
    }

    global LazyIterator doDelete(Boolean allOrNothing) {
        List<SObject> records = toList();
        Iterator<Database.DeleteResult> resultIterator = Database.delete(records, allOrNothing).iterator();
        Iterator<SObject> recordIterator = records.iterator();
        return new LazyIterator(new TupleIterator(new List<Iterator<Object>>{ (Iterator<Object>)resultIterator, (Iterator<Object>)recordIterator}, DeleteResult.newInstance));
    }

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