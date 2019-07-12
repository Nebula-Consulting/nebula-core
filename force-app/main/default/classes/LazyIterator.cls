/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 2019-03-21
 * @description Iterator-based operations for lazy-evaluation on collections/streams
 */

global virtual class LazyIterator implements Iterator<Object> {

    protected Iterator<Object> iterator;

    global LazyIterator(Iterable<Object> iterable) {
        this.iterator = iterable.iterator();
    }

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

    @Deprecated
    global Object findOrDefault(BooleanFunction matchingFunction, Object defaultValue) {
        return filter(matchingFunction).firstOrDefault(defaultValue);
    }

    global virtual List<Object> toList(List<Object> toFill) {
        while(hasNext()) {
            toFill.add(next());
        }

        return toFill;
    }

    global virtual List<SObject> toList(List<SObject> toFill) {
        while(hasNext()) {
            toFill.add((SObject)next());
        }

        return toFill;
    }

    global virtual Set<Id> toSet(Set<Id> toFill) {
        while(hasNext()) {
            toFill.add((Id)next());
        }

        return toFill;
    }

    global virtual Set<Object> toSet(Set<Object> toFill) {
        while(hasNext()) {
            toFill.add(next());
        }

        return toFill;
    }

    global LazyIterator filter(BooleanFunction matchingFunction) {
        return new LazyFilterIterator(this, matchingFunction);
    }

    global LazyIterator expand(ExpansionFunction expansionFunction) {
        return new LazyExpansionIterator(this, expansionFunction);
    }

    global Object reduce(AccumulatorFunction accumulatorFunction, Object initialValue) {
        Object result = initialValue;
        while(hasNext()) {
            result = accumulatorFunction.nextValue(result, next());
        }
        return result;
    }

    global Object reduce(VoidFunction accumulatorObject) {
        while(hasNext()) {
            accumulatorObject.call(next());
        }
        return accumulatorObject;
    }

    global LazyIterator mapValues(Function mappingFunction) {
        return new LazyMapIterator(this, mappingFunction);
    }

    global void forEach(VoidFunction callingFunction) {
        while(hasNext()) {
            callingFunction.call(next());
        }
    }
}