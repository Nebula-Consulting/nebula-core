/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 2019-03-22
 * @description SObject-typed version of LazyIterator
 */

global class LazySObjectIterator extends LazyIterator {

    global LazySObjectIterator(Iterator<SObject> iterator) {
        super(new SObjectIteratorToObjectIterator(iterator));
    }

    global LazySObjectIterator(Iterable<SObject> iterable) {
        super(new SObjectIteratorToObjectIterator(iterable.iterator()));
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