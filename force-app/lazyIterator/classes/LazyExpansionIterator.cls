/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 2019-07-12
 * @description A lazy iterator that uses an Expansion function to return more results than the initial iterator
 */

public class LazyExpansionIterator extends LazyIterator implements LazyIteratorMutator {

    private ExpansionFunction expansionFunction;
    private Boolean expansionFunctionInitialised;

    public LazyExpansionIterator(Iterator<Object> iterator, ExpansionFunction expansionFunction) {
        super(iterator);
        this.expansionFunction = expansionFunction;
        this.expansionFunctionInitialised = false;
    }

    public override Boolean hasNext() {
        while(!expansionFunctionInitialised || !expansionFunction.hasNext()) {
            if(super.hasNext()) {
                initialiseExpansionFunction();
            } else {
                return false;
            }
        }
        return true;
    }

    public override Object next() {
        if(!expansionFunctionInitialised || !expansionFunction.hasNext()) {
            initialiseExpansionFunction();
        }
        return expansionFunction.next();
    }

    private void initialiseExpansionFunction() {
        expansionFunction.setValue(super.next());
        expansionFunctionInitialised = true;
    }
}