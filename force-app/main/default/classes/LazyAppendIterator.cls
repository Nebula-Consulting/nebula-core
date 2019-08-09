/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 2019-08-09
 * @description A LazyIterator that appends another iterator to the end of its own values
 */

public class LazyAppendIterator extends LazyIterator {

    private Iterator<Object> secondIterator;

    public LazyAppendIterator(Iterator<Object> firstIterator, Iterator<Object> secondIterator) {
        super(firstIterator);
        this.secondIterator = secondIterator;
    }

    public override Object next() {
        if(internalHasNext()) {
            return internalNext();
        } else {
            return secondIterator.next();
        }
    }

    public override Boolean hasNext() {
        return internalHasNext() || secondIterator.hasNext();
    }
}