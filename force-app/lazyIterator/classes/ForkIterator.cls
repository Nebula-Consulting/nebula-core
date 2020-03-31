/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 2019-07-25
 * @description Provides an object inside a call to LazyIterator.fork() so that you can call further LazyIterator
 * operations on each branch of the fork
 */

global class ForkIterator extends LazyIterator implements LazyIteratorMutator {

    global ForkIterator() {
        super(new List<Object>());
        ForkManager.forkIterators.add(this);
    }

    public void setIterator(Iterator<Object> iterator) {
        this.iterator = iterator;
    }
}