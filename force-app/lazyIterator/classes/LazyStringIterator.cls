/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 28/11/2019
 * @description String-typed version of LazyIterator
 */

global class LazyStringIterator extends LazyIterator {

    global LazyStringIterator(Iterator<String> iterator) {
        super(new StringIteratorToObjectIterator(iterator));
    }

    global LazyStringIterator(Iterable<String> iterable) {
        super(new StringIteratorToObjectIterator(iterable.iterator()));
    }

    private class StringIteratorToObjectIterator implements Iterator<Object> {

        private Iterator<String> iterator;

        public StringIteratorToObjectIterator(Iterator<String> iterator) {
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