/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 2019-07-25
 */

global class Reduce implements TerminatorFunction {

    private LazyIterator iterator;
    private AccumulatorFunction accumulatorFunction;
    private VoidFunction accumulatorObject;
    private Object currentValue;

    global Reduce(AccumulatorFunction accumulatorFunction, Object initialValue) {
        this.accumulatorFunction = accumulatorFunction;
        this.currentValue = initialValue;
    }

    global Reduce(VoidFunction accumulatorObject) {
        this.accumulatorObject = accumulatorObject;
    }

    global void call() {
        if(accumulatorObject != null) {
            iterator.reduce(accumulatorObject);
        } else {
            currentValue = iterator.reduce(accumulatorFunction, currentValue);
        }
    }

    global TerminatorFunction setIterator(LazyIterator iterator) {
        this.iterator = iterator;
        return this;
    }

    global Object getResult() {
        return accumulatorObject != null ? accumulatorObject : currentValue;
    }
}