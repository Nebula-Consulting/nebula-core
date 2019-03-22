/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 2019-03-22
 * @description TriggerContextIterator.Pair-typed version of LazyIterator
 */

global class LazyTriggerContextPairIterator extends LazyIterator {

    global LazyTriggerContextPairIterator(Iterator<TriggerContextIterator.Pair> iterator) {
        super(new PairIteratorToObjectIterator(iterator));
    }

    global override List<Object> toList() {
        List<SObject> returnVal = new List<SObject>();

        while(iterator.hasNext()) {
            returnVal.add((SObject)iterator.next());
        }

        return returnVal;
    }

    protected override LazyIterator newInstance(Iterator<Object> iterator) {
        LazyIterator returnValue = new LazyTriggerContextPairIterator(null);
        returnValue.iterator = iterator;
        return returnValue;
    }

    private class PairIteratorToObjectIterator implements Iterator<Object> {

        private Iterator<TriggerContextIterator.Pair> iterator;

        public PairIteratorToObjectIterator(Iterator<TriggerContextIterator.Pair> iterator) {
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