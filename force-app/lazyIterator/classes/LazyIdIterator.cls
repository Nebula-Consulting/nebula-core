/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 2019-07-12
 * @description Id-typed version of LazyIterator
 */
global class LazyIdIterator extends LazyIterator {

    global LazyIdIterator(Iterator<Id> iterator) {
        super(new IdIteratorToObjectIterator(iterator));
    }

    global LazyIdIterator(Iterable<Id> iterable) {
        super(new IdIteratorToObjectIterator(iterable.iterator()));
    }

    private class IdIteratorToObjectIterator implements Iterator<Object> {

        private Iterator<Id> iterator;

        public IdIteratorToObjectIterator(Iterator<Id> iterator) {
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