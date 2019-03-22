/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 2019-03-21
 * @description Iterator-based operations for lazy-evaluation on collections/streams
 */

global class LazyIterator implements Iterator<SObject> {

    private Iterator<SObject> iterator;

    global LazyIterator(Iterator<SObject> iterator) {
        this.iterator = iterator;
    }

    global Boolean hasNext() {
        return iterator.hasNext();
    }

    global SObject next() {
        return null;
    }

    global Object firstOrDefault(Object defaultValue) {
        if(iterator.hasNext()) {
            return iterator.next();
        } else {
            return defaultValue;
        }
    }

    global List<SObject> toList() {
        List<SObject> returnVal = new List<SObject>();

        while(iterator.hasNext()) {
            returnVal.add(iterator.next());
        }

        return returnVal;
    }

    global LazyIterator filter(BooleanFunction matchingFunction) {
        return new LazyIterator(new FilterIterator(iterator, matchingFunction));
    }

    global void forEach(Function callingFunction) {
        while(iterator.hasNext()) {
            callingFunction.call(iterator.next());
        }
    }

    //NB Map itself is a reserved keyword
    global LazyIterator mapValues(Function mappingFunction) {
        return new LazyIterator(new MapIterator(iterator, mappingFunction));
    }

    private class FilterIterator implements Iterator<SObject>{
        private Iterator<SObject> iterator;
        private BooleanFunction matchingFunction;
        private SObject peek;
        private Boolean peekIsValid;

        public FilterIterator(Iterator<SObject> iterator, BooleanFunction matchingFunction) {
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

        public SObject next() {
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
    
    private class MapIterator implements Iterator<SObject> {
        private Iterator<SObject> iterator;
        private Function mappingFunction;

        public MapIterator(Iterator<SObject> iterator, Function mappingFunction) {
            this.iterator = iterator;
            this.mappingFunction = mappingFunction;
        }
        public Boolean hasNext() {
            return iterator.hasNext();
        }

        public SObject next() {
            return (SObject)mappingFunction.call(iterator.next());
        }
    }
}