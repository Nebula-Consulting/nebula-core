/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 14/07/2021
 * @description Calls the observer function on each iterated item, returning that item unchanged
 */

public with sharing class LazyObserverIterator extends LazyIterator implements LazyIteratorMutator {

    private Function observerFunction;

    public LazyObserverIterator(Iterator<Object> iterator, Function observerFunction) {
        super(iterator);
        this.observerFunction = observerFunction;
    }

    public override Object next() {
        Object o = iterator.next();
        observerFunction.call(o);
        return o;
    }
}
