/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 2019-03-22
 * @description TriggerContextIterator.Pair-typed version of LazyIterator
 */

global class LazyTriggerContextPairIterator extends LazyIterator {

    global LazyTriggerContextPairIterator(List<SObject> oldList, List<SObject> newList) {
        this(new TriggerContextIterator(oldList, newList));
    }

    global LazyTriggerContextPairIterator(Iterator<TriggerContextPair> iterator) {
        super(new PairIteratorToObjectIterator(iterator));
    }

    global override List<Object> toList() {
        List<TriggerContextPair> returnVal = new List<TriggerContextPair>();

        while(iterator.hasNext()) {
            returnVal.add((TriggerContextPair)iterator.next());
        }

        return returnVal;
    }

    protected override LazyIterator newInstance(Iterator<Object> iterator) {
        LazyIterator returnValue = new LazyTriggerContextPairIterator(null);
        returnValue.iterator = iterator;
        return returnValue;
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