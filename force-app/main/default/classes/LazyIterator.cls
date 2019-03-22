/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 2019-03-21
 * @description Iterator-based operations for lazy-evaluation on collections/streams
 */

global virtual class LazyIterator implements Iterator<Object> {

    protected Iterator<Object> iterator;

    global LazyIterator(Iterator<Object> iterator) {
        this.iterator = iterator;
    }

    global Boolean hasNext() {
        return iterator.hasNext();
    }

    global Object next() {
        return iterator.next();
    }

    global Object firstOrDefault(Object defaultValue) {
        if(iterator.hasNext()) {
            return iterator.next();
        } else {
            return defaultValue;
        }
    }

    global Object findOrDefault(BooleanFunction matchingFunction, Object defaultValue) {
        while(iterator.hasNext()) {
            Object value = iterator.next();
            if(matchingFunction.isTrueFor(value)) {
                return value;
            }
        }
        return defaultValue;
    }

    global virtual List<Object> toList() {
        List<Object> returnVal = new List<Object>();

        while(iterator.hasNext()) {
            returnVal.add(iterator.next());
        }

        return returnVal;
    }

    global LazyIterator filter(BooleanFunction matchingFunction) {
        return newInstance(new FilterIterator(iterator, matchingFunction));
    }

    global void forEach(Function callingFunction) {
        while(iterator.hasNext()) {
            callingFunction.call(iterator.next());
        }
    }

    //NB Map itself is a reserved keyword
    global LazyIterator mapValues(Function mappingFunction) {
        return newInstance(new MapIterator(iterator, mappingFunction));
    }

    protected virtual LazyIterator newInstance(Iterator<Object> iterator) {
        return new LazyIterator(iterator);
    }

    private class FilterIterator implements Iterator<Object>{
        private Iterator<Object> iterator;
        private BooleanFunction matchingFunction;
        private Object peek;
        private Boolean peekIsValid;

        public FilterIterator(Iterator<Object> iterator, BooleanFunction matchingFunction) {
            this.iterator = iterator;
            this.matchingFunction = matchingFunction;
            this.peekIsValid = false;
        }

        private void peek() {
            if(iterator.hasNext()) {
                peek = iterator.next();
                peekIsValid = true;
            } else {
                peekIsValid = false;
            }
        }

        public Boolean hasNext() {
            if (!peekIsValid) {
                peek();
            }
            while(peekIsValid) {
                if(matchingFunction.isTrueFor(peek)) {
                    return true;
                } else {
                    peek();
                }
            }
            return false;
        }

        public Object next() {
            if(peekIsValid) {
                peekIsValid = false;
                return peek;
            }

            while(true) {
                peek();

                if(matchingFunction.isTrueFor(peek)) {
                    peekIsValid = false;
                    return peek;
                }
            }
            // Returning null would be wrong, but is actually impossible. The loop above either returns a value, or it
            // loops forever, but the compiler can't see this
            return null;
        }
    }
    
    private class MapIterator implements Iterator<Object> {
        private Iterator<Object> iterator;
        private Function mappingFunction;

        public MapIterator(Iterator<Object> iterator, Function mappingFunction) {
            this.iterator = iterator;
            this.mappingFunction = mappingFunction;
        }
        public Boolean hasNext() {
            return iterator.hasNext();
        }

        public Object next() {
            return (Object)mappingFunction.call(iterator.next());
        }
    }
}