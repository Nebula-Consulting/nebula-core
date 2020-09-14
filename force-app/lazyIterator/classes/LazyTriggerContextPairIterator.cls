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
        Function matchingFunctionAsFunction = new BooleanFunctionToFunction(matchingFunction);
        return filterT(new IsAll(
                new IsNot(new FunctionToBooleanFunction(new Composition(new OldFromTriggerContextPair()).compose(new Log('Old record: {0}')).compose(matchingFunctionAsFunction).compose(new Log('Old Result: {0}')))),
                new FunctionToBooleanFunction(new Composition(new NewFromTriggerContextPair()).compose(new Log('New record: {0}')).compose(matchingFunctionAsFunction).compose(new Log('New Result: {0}')))
        ));
    }

    global LazyTriggerContextPairIterator mapValuesT(Function mappingFunction) {
        this.iterator = super.mapValues(mappingFunction);
        return this;
    }
}