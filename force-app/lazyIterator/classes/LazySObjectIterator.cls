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

    global LazySObjectIterator mapValuesT(Function mappingFunction) {
        this.iterator = super.mapValues(mappingFunction);
        return this;
    }

    global LazySObjectIterator put(SObjectField field,  Object valueOrFunction) {
        iterator = new LazyMappingIterator(iterator, new SObjectPutField(field, valueOrFunction));
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
}