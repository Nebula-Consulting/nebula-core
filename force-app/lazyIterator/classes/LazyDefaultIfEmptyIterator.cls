/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 09/12/2019
 * @description A LazyIterator which returns the given default iterator if the underlying iterator turns out to be empty
 * on the first call
 */

public class LazyDefaultIfEmptyIterator extends LazyIterator implements LazyIteratorMutator {

    private Iterator<Object> defaultIterator;

    public LazyDefaultIfEmptyIterator(Iterator<Object> iterator, Iterator<Object> defaultIterator) {
        super(iterator);
        this.defaultIterator = defaultIterator;
    }

    public override Boolean hasNext() {
        Boolean result = super.hasNext();
        if(!result && defaultIterator != null) {
            iterator = defaultIterator;
            result = super.hasNext();
        }
        defaultIterator = null;
        return result;
    }

}