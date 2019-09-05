/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 2019-03-29
 * @description A lazy iterator that maps values using mappingFunction
 */

public class LazyMapIterator extends LazyIterator {

    private Function mappingFunction;
    private BooleanFunction filterFunction;

    public LazyMapIterator(Iterator<Object> iterator, Function mappingFunction) {
        super(iterator);
        this.mappingFunction = mappingFunction;
        this.filterFunction = new ConstantBooleanFunction(true);
    }

    public LazyMapIterator(Iterator<Object> iterator, BooleanFunction filterFunction, Function mappingFunction) {
        super(iterator);
        this.mappingFunction = mappingFunction;
        this.filterFunction = filterFunction;
    }

    public override Object next() {
        Object nextValue = internalNext();
        if(filterFunction.isTrueFor(nextValue)) {
            return (Object)mappingFunction.call(nextValue);
        } else {
            return nextValue;
        }
    }
}
