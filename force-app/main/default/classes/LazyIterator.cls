/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 2019-03-21
 * @description Iterator-based operations for lazy-evaluation on collections/streams
 */

global virtual class LazyIterator implements Iterator<Object>, NullaryFunction {

    protected Iterator<Object> iterator {private get; set;}
    private Iterator<Object> defaultIterator;

    protected Boolean internalHasNext() {
        Boolean result = iterator.hasNext();
        if(!result && defaultIterator != null) {
            iterator = defaultIterator;
            result = iterator.hasNext();
        }
        defaultIterator = null;
        return result;
    }

    protected Object internalNext() {
        return iterator.next();
    }

    global LazyIterator(Iterable<Object> iterable) {
        this.iterator = iterable.iterator();
    }

    global LazyIterator(Iterator<Object> iterator) {
        this.iterator = iterator;
    }

    global virtual Boolean hasNext() {
        return internalHasNext();
    }

    global virtual Object next() {
        return internalNext();
    }

    global Object firstOrDefault(Object defaultValue) {
        if(hasNext()) {
            return next();
        } else {
            return defaultValue;
        }
    }

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

    global virtual Set<String> toSet(Set<String> toFill) {
        while(hasNext()) {
            toFill.add((String)next());
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

    global LazyIterator filter(Function mappingFunction, BooleanFunction matchingFunction) {
        return new LazyFilterIterator(this, mappingFunction, matchingFunction);
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

    global LazyIterator mapValues(BooleanFunction filterFunction, Function mappingFunction) {
        return new LazyMapIterator(this, filterFunction, mappingFunction);
    }

    global void forEach(VoidFunction callingFunction) {
        while(hasNext()) {
            callingFunction.call(next());
        }
    }

    global void forEach(Function callingFunction) {
        while(hasNext()) {
            callingFunction.call(next());
        }
    }

    global void forEach() {
        while(hasNext()) {
            next();
        }
    }

    global LazyIterator setDefaultIfEmpty(Object defaultValue) {
        return setDefaultIfEmpty(new List<Object> {defaultValue}.iterator());
    }

    global LazyIterator setDefaultIfEmpty(Iterator<Object> defaultValues) {
        defaultIterator = defaultValues;
        return this;
    }

    global LazyIterator take(Integer nItemsToTake) {
        return new LazyTakeIterator(this, nItemsToTake);
    }

    global LazyIterator append(LazyIterator other) {
        return new LazyAppendIterator(this, other);
    }

    global ForkManager fork() {
        return new ForkManager(this);
    }

    global LazyIterator fork(List<TerminatorFunction> forks) {
        return new ForkManager(this, forks).evaluateForks();
    }

    global LazyIterator fork(TerminatorFunction fork1, TerminatorFunction fork2) {
        return fork(new List<TerminatorFunction>{fork1, fork2});
    }

    global LazyIterator fork(TerminatorFunction fork1, TerminatorFunction fork2, TerminatorFunction fork3) {
        return fork(new List<TerminatorFunction>{fork1, fork2, fork3});
    }

    global TerminatorFunction postpone(TerminatorFunction terminatorFunction) {
        return terminatorFunction.setIterator(this);
    }

    global Object call() {
        return next();
    }

    global Object call(Object o) {
        return call();
    }
}