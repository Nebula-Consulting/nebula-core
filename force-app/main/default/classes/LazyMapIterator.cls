/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 2019-03-29
 * @description A lazy iterator that maps values using mappingFunction
 */

public class LazyMapIterator extends LazyIterator {

    private Function mappingFunction;

    public LazyMapIterator(Iterator<Object> iterator, Function mappingFunction) {
        super(iterator);
        this.mappingFunction = mappingFunction;
    }

    public override Object next() {
        return (Object)mappingFunction.call(internalNext());
    }
}
