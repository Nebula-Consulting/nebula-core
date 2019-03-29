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

    global virtual Boolean hasNext() {
        return iterator.hasNext();
    }

    global virtual Object next() {
        return iterator.next();
    }

    global Object firstOrDefault(Object defaultValue) {
        if(hasNext()) {
            return next();
        } else {
            return defaultValue;
        }
    }

    global virtual List<Object> toList(List<Object> toFill) {
        List<Object> returnVal = toFill;

        while(hasNext()) {
            returnVal.add(next());
        }

        return returnVal;
    }

    global LazyIterator filter(BooleanFunction matchingFunction) {
        return new LazyFilterIterator(this, matchingFunction);
    }

    global LazyIterator mapValues(Function mappingFunction) {
        return new LazyMapIterator(this, mappingFunction);
    }

    global void forEach(Function callingFunction) {
        while(hasNext()) {
            callingFunction.call(next());
        }
    }
}