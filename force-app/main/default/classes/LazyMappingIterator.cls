/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 2019-03-29
 * @description A lazy iterator that maps values using mappingFunction
 */

public class LazyMappingIterator extends LazyIterator implements LazyIteratorMutator {

    private Function mappingFunction;

    public LazyMappingIterator(Iterator<Object> iterator, Function mappingFunction) {
        super(iterator);
        this.mappingFunction = mappingFunction;
    }

    public override Object next() {
        return (Object)mappingFunction.call(iterator.next());
    }
}
