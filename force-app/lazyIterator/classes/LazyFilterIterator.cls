/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 2019-03-29
 * @description A lazy iterator which only returns values that return true according to the matchingFunction
 */

public class LazyFilterIterator extends LazyIterator implements LazyIteratorMutator {

    private BooleanFunction matchingFunction;
    private Object peek;
    private Boolean peekIsValid;
    private Boolean peekMatches;

    public LazyFilterIterator(Iterator<Object> iterator, BooleanFunction matchingFunction) {
        super(iterator);
        this.matchingFunction = matchingFunction;
        this.peekIsValid = false;    }

    public LazyFilterIterator(Iterator<Object> iterator, Function mappingFunction, BooleanFunction matchingFunction) {
        this(iterator, new MapThenTest(mappingFunction, matchingFunction));
    }

    private void peek() {
        if(super.hasNext()) {
            peek = super.next();
            peekMatches = matchingFunction.isTrueFor(peek);
            peekIsValid = true;
        } else {
            peekIsValid = false;
        }
    }

    public override Boolean hasNext() {
        if (!peekIsValid) {
            peek();
        }
        while(peekIsValid) {
            if(peekMatches) {
                return true;
            } else {
                peek();
            }
        }
        return false;
    }

    public override Object next() {
        if(hasNext()) {
            peekIsValid = false;
            return peek;
        } else {
            throw new NoSuchElementException();
        }
    }

    private class MapThenTest implements BooleanFunction {

        private Function mappingFunction;
        private BooleanFunction matchingFunction;

        public MapThenTest(Function mappingFunction, BooleanFunction matchingFunction) {
            this.mappingFunction = mappingFunction;
            this.matchingFunction = matchingFunction;
        }

        public Boolean isTrueFor(Object o) {
            return matchingFunction.isTrueFor(mappingFunction.call(o));
        }
    }
}