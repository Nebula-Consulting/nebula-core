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
}