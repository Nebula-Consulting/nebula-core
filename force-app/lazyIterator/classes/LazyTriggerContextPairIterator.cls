/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 2019-03-22
 * @description TriggerContextPair-typed version of LazyIterator
 */

global class LazyTriggerContextPairIterator extends LazyIterator {

    global LazyTriggerContextPairIterator(List<SObject> oldList, List<SObject> newList) {
        super(new TriggerContextIterator(oldList, newList));
    }

    global LazyTriggerContextPairIterator(TriggerContextIterator iterator) {
        super(iterator);
    }

    global LazySObjectIterator newRecords() {
        return new LazySObjectIterator(mapValues(new NewFromTriggerContextPair()));
    }

    global LazySObjectIterator oldRecords() {
        return new LazySObjectIterator(mapValues(new OldFromTriggerContextPair()));
    }

    global LazySObjectIterator bothRecords() {
        return new LazySObjectIterator(flatten());
    }

    global LazyTriggerContextPairIterator filterT(BooleanFunction matchingFunction) {
        this.iterator = super.filter(matchingFunction);
        return this;
    }

    global LazyTriggerContextPairIterator filterT(Function mappingFunction, BooleanFunction matchingFunction) {
        this.iterator = super.filter(mappingFunction, matchingFunction);
        return this;
    }

    global LazyTriggerContextPairIterator filterBecameTrue(BooleanFunction matchingFunction) {
        Function matchingFunctionAsFunction = new BooleanFunctionToFunction(new IsAll(new IsNotNull(), matchingFunction));

        return filterT(new IsAll(
                new IsNot(new FunctionToBooleanFunction(new Composition(new OldFromTriggerContextPair()).compose(matchingFunctionAsFunction))),
                new FunctionToBooleanFunction(new Composition(new NewFromTriggerContextPair()).compose(matchingFunctionAsFunction))
        ));
    }

    global LazyTriggerContextPairIterator filterBecameFalse(BooleanFunction matchingFunction) {
        Function matchingFunctionAsFunction = new BooleanFunctionToFunction(new IsAll(new IsNotNull(), matchingFunction));

        return filterT(new IsAll(
                new FunctionToBooleanFunction(new Composition(new OldFromTriggerContextPair()).compose(matchingFunctionAsFunction)),
                new IsNot(new FunctionToBooleanFunction(new Composition(new NewFromTriggerContextPair()).compose(matchingFunctionAsFunction)))
        ));
    }

    global LazyTriggerContextPairIterator mapValuesT(Function mappingFunction) {
        this.iterator = super.mapValues(mappingFunction);
        return this;
    }

    global LazyTriggerContextPairIterator mapNewFromOld(SObjectField destinationField, SObjectField sourceField) {
        return mapNewFromOld(destinationField, new FieldFromSObject(sourceField));
    }

    global LazyTriggerContextPairIterator mapNewFromOld(SObjectField destinationField, SObjectField sourceField, Function fieldValueMappingFunction) {
        return mapNewFromOld(destinationField, new Composition(new FieldFromSObject(sourceField)).compose(fieldValueMappingFunction));
    }

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