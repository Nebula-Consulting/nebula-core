/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 14/07/2021
 * @description Calls the observer function on each iterated item satisfying filterFunction, returns all items unchanged
 */

public with sharing class LazyObserverConditionalIterator extends LazyIterator implements LazyIteratorMutator {

    private Function observerFunction;
    private BooleanFunction filterFunction;

    public LazyObserverConditionalIterator(Iterator<Object> iterator, BooleanFunction filterFunction, Function observerFunction) {
        super(iterator);
        this.filterFunction = filterFunction;
        this.observerFunction = observerFunction;
    }

    public override Object next() {
        Object o = iterator.next();
        if(filterFunction.isTrueFor(o)) {
            observerFunction.call(o);
        }
        return o;
    }
}
