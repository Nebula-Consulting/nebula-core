/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 2019-03-22
 * @description SObject-typed version of LazyIterator
 */

global class LazySObjectIterator extends LazyIterator {

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
        List<SObject> records = toList();
        Iterator<Database.SaveResult> resultIterator = Database.update(records, allOrNothing).iterator();
        Iterator<SObject> recordIterator = records.iterator();
        return new LazyIterator(new TupleIterator(new List<Iterator<Object>>{ (Iterator<Object>)resultIterator, (Iterator<Object>)recordIterator}, SaveResult.newInstance));
    }

    global LazySObjectIterator doInsert() {
        List<SObject> records = toList();
        insert records;
        return new LazySObjectIterator(records);
    }

    global LazyIterator doInsert(Boolean allOrNothing) {
        List<SObject> records = toList();
        Iterator<Database.SaveResult> resultIterator = Database.insert(records, allOrNothing).iterator();
        Iterator<SObject> recordIterator = records.iterator();
        return new LazyIterator(new TupleIterator(new List<Iterator<Object>>{ (Iterator<Object>)resultIterator, (Iterator<Object>)recordIterator}, SaveResult.newInstance));
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
}