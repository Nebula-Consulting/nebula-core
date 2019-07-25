/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 2019-07-25
 * @description (if required)
 */

global class ForkIterator extends LazyIterator {

    global ForkIterator() {
        super(new List<Object>());
        ForkManager.forkIterators.add(this);
    }

    public void setIterator(Iterator<Object> iterator) {
        this.iterator = iterator;
    }
}