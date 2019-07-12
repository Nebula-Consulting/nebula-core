/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 2019-07-12
 * @description A lazy iterator that uses an Expansion function to return more results than the initial iterator
 */

public class LazyExpansionIterator extends LazyIterator {

    private ExpansionFunction expansionFunction;
    private Boolean expansionFunctionInitialised;

    public LazyExpansionIterator(Iterator<Object> iterator, ExpansionFunction expansionFunction) {
        super(iterator);
        this.expansionFunction = expansionFunction;
        this.expansionFunctionInitialised = false;
    }

    public override Boolean hasNext() {
        return  iterator.hasNext() || expansionFunction.hasNext();
    }

    public override Object next() {
        if(!expansionFunctionInitialised || !expansionFunction.hasNext()) {
            expansionFunction.setValue(iterator.next());
            expansionFunctionInitialised = true;
        }
        return expansionFunction.next();
    }
}