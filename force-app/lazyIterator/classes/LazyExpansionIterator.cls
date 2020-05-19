/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 2019-07-12
 * @description A lazy iterator that uses an Expansion function to return more results than the initial iterator
 */

public class LazyExpansionIterator extends LazyIterator implements LazyIteratorMutator {

    private ExpansionIterator expansionIterator;
    private Iterator<Object> iterator;

    public LazyExpansionIterator(Iterator<Object> iterator, ExpansionFunction expansionFunction) {
        super(iterator);
        this.expansionIterator = new ExpansionFunctionToIterator(expansionFunction);
        this.iterator = null;
    }

    public LazyExpansionIterator(Iterator<Object> iterator, ExpansionIterator expansionIterator) {
        super(iterator);
        this.expansionIterator = expansionIterator;
        this.iterator = null;
    }

    public override Boolean hasNext() {
        while(iterator == null || !iterator.hasNext()) {
            if(super.hasNext()) {
                iterator = expansionIterator.setValue(super.next());
            } else {
                return false;
            }
        }
        return true;
    }

    public override Object next() {
        if(iterator == null || !iterator.hasNext()) {
            iterator = expansionIterator.setValue(super.next());
        }
        return iterator.next();
    }
}