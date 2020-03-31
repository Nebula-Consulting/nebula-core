/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 13/12/2019
 * @description A lazy iterator that maps values using mappingFunction, but only if the satisfy filterFunction. Values
 * which don't match filterFunction are passed through unchanged
 */

public class LazyMappingConditionalIterator extends LazyIterator implements LazyIteratorMutator {

    private Function mappingFunction;
    private BooleanFunction filterFunction;

    public LazyMappingConditionalIterator(Iterator<Object> iterator, BooleanFunction filterFunction, Function mappingFunction) {
        super(iterator);
        this.mappingFunction = mappingFunction;
        this.filterFunction = filterFunction;
    }

    public override Object next() {
        Object nextValue = iterator.next();
        if(filterFunction.isTrueFor(nextValue)) {
            return (Object)mappingFunction.call(nextValue);
        } else {
            return nextValue;
        }
    }
}
