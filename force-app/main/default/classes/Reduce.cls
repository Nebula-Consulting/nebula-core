/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 2019-07-25
 * @description (if required)
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
        while(iterator.hasNext()) {
            if(accumulatorObject != null) {
                accumulatorObject.call(iterator.next());
            } else {
                currentValue = accumulatorFunction.nextValue(currentValue, iterator.next());
            }
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