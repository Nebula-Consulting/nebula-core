/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 2019-03-22
 * @description TriggerContextPair-typed version of LazyIterator
 */

global class LazyTriggerContextPairIterator extends LazyIterator {

    global LazyTriggerContextPairIterator(List<SObject> oldList, List<SObject> newList) {
        this(new TriggerContextIterator(oldList, newList));
    }

    global LazyTriggerContextPairIterator(Iterator<TriggerContextPair> iterator) {
        super(new PairIteratorToObjectIterator(iterator));
    }

    private class PairIteratorToObjectIterator implements Iterator<Object> {

        private Iterator<TriggerContextPair> iterator;

        public PairIteratorToObjectIterator(Iterator<TriggerContextPair> iterator) {
            this.iterator = iterator;
        }

        public Boolean hasNext() {
            return iterator.hasNext();
        }
        public Object next() {
            return iterator.next();
        }
    }

    global LazySObjectIterator newRecords() {
        return new LazySObjectIterator(mapValues(new NewFromTriggerContextPair()));
    }

    global LazySObjectIterator oldRecords() {
        return new LazySObjectIterator(mapValues(new OldFromTriggerContextPair()));
    }

    global LazyTriggerContextPairIterator filterT(BooleanFunction matchingFunction) {
        this.iterator = super.filter(matchingFunction);
        return this;
    }

    global LazyTriggerContextPairIterator filterT(Function mappingFunction, BooleanFunction matchingFunction) {
        this.iterator = super.filter(mappingFunction, matchingFunction);
        return this;
    }

    global LazyTriggerContextPairIterator mapValuesT(Function mappingFunction) {
        this.iterator = super.mapValues(mappingFunction);
        return this;
    }
}