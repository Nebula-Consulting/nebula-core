/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 2019-03-21
 * @description Iterator-based operations for lazy-evaluation on collections/streams
 */

global virtual class LazyIterator implements Iterator<Object>, NullaryFunction {

    protected Iterator<Object> iterator;

    global LazyIterator(Object iterableOrIterator) {
        if(iterableOrIterator instanceof Iterator<Object>) {
            iterator = (Iterator<Object>)iterableOrIterator;
        } else if(iterableOrIterator instanceof Iterable<Object>) {
            iterator = ((Iterable<Object>)iterableOrIterator).iterator();
        } else {
            throw new IllegalArgumentException(String.format(
                    'LazyIterator constructed with invalid type {0}. Must be Iterator or Iterable',
                    new List<String>{
                            String.valueOf(iterableOrIterator)
                    })
            );
        }
    }

    global LazyIterator(Iterable<Object> iterable) {
        this.iterator = iterable.iterator();
    }

    global LazyIterator(Iterator<Object> iterator) {
        this.iterator = iterator;
    }

    protected LazyIterator() {}

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
        return new LazyFilterIterator(getIteratorForDecorator(), matchingFunction);
    }

    global LazyIterator filter(Function mappingFunction, BooleanFunction matchingFunction) {
        return new LazyFilterIterator(getIteratorForDecorator(), mappingFunction, matchingFunction);
    }

    global LazyIterator expand(ExpansionFunction expansionFunction) {
        return new LazyExpansionIterator(getIteratorForDecorator(), expansionFunction);
    }

    global Object reduce(AccumulatorFunction accumulatorFunction, Object initialValue) {
        Object result = initialValue;
        while(hasNext()) {
            result = accumulatorFunction.nextValue(result, next());
        }
        return result;
    }

    global Object reduce(AccumulatorObject accumulatorObject) {
        while(hasNext()) {
            accumulatorObject.accumulate(next());
        }
        return accumulatorObject;
    }

    global Object reduce(VoidFunction accumulatorObject) {
        while(hasNext()) {
            accumulatorObject.call(next());
        }
        return accumulatorObject;
    }

    private Iterator<Object> getIteratorForDecorator() {
        if(this instanceof LazyIteratorMutator) {
            return this;
        } else {
            return iterator;
        }
    }

    global LazyIterator mapValues(Function mappingFunction) {
        return new LazyMappingIterator(getIteratorForDecorator(), mappingFunction);
    }

    global LazyIterator mapValues(BooleanFunction filterFunction, Function mappingFunction) {
        return new LazyMappingConditionalIterator(getIteratorForDecorator(), filterFunction, mappingFunction);
    }

    global LazyIterator mapIf(BooleanFunction filterFunction, Function mappingFunction) {
        return new LazyMappingConditionalIterator(getIteratorForDecorator(), filterFunction, mappingFunction);
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
        return new LazyDefaultIfEmptyIterator(getIteratorForDecorator(), defaultValues);
    }

    global LazyIterator take(Integer nItemsToTake) {
        return new LazyTakeIterator(getIteratorForDecorator(), nItemsToTake);
    }

    global LazyIterator prepend(LazyIterator other) {
        return new LazyAppendIterator(other, getIteratorForDecorator());
    }

    global LazyIterator append(LazyIterator other) {
        return new LazyAppendIterator(getIteratorForDecorator(), other);
    }

    global LazyIterator append(Object item) {
        return new LazyAppendIterator(getIteratorForDecorator(), new List<Object>{item}.iterator());
    }

    global LazyIterator prepend(Object item) {
        return new LazyAppendIterator(new List<Object>{item}.iterator(), getIteratorForDecorator());
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