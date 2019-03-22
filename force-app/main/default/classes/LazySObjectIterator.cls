/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 2019-03-22
 * @description SObject-typed version of LazyIterator
 */

global class LazySObjectIterator extends LazyIterator {

    global LazySObjectIterator(Iterator<SObject> iterator) {
        super(new SObjectIteratorToObjectIterator(iterator));
    }

    global override List<Object> toList() {
        List<SObject> returnVal = new List<SObject>();

        while(iterator.hasNext()) {
            returnVal.add((SObject)iterator.next());
        }

        return returnVal;
    }

    protected override LazyIterator newInstance(Iterator<Object> iterator) {
        LazyIterator returnValue = new LazySObjectIterator(null);
        returnValue.iterator = iterator;
        return returnValue;
    }

    private class SObjectIteratorToObjectIterator implements Iterator<Object> {

        private Iterator<SObject> iterator;

        public SObjectIteratorToObjectIterator(Iterator<SObject> iterator) {
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