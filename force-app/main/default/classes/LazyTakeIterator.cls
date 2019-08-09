/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 2019-08-09
 * @description A LazyIterator that will allow a limited number of items to be taken from the underlying iterator
 */

global class LazyTakeIterator extends LazyIterator {

    private Integer nItemsToTake;

    public LazyTakeIterator(Iterator<Object> iterator, Integer nItemsToTake) {
        super(iterator);
        this.nItemsToTake = nItemsToTake;
    }

    public override Object next() {
        if(nItemsToTake-- > 0) {
            return internalNext();
        } else {
            throw new NoSuchElementException();
        }
    }

    public override Boolean hasNext() {
        if(nItemsToTake > 0) {
            return internalHasNext();
        } else {
            return false;
        }
    }
}
