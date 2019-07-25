/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 2019-07-25
 * @description (if required)
 */

global class ForEach implements TerminatorFunction {

    private VoidFunction callingFunction;
    private LazyIterator iterator;

    global ForEach(VoidFunction callingFunction) {
        this.callingFunction = callingFunction;
    }

    global void call() {
        while(iterator.hasNext()) {
            callingFunction.call(iterator.next());
        }
    }

    global TerminatorFunction setIterator(LazyIterator iterator) {
        this.iterator = iterator;
        return this;
    }

    global Object getResult() {
        return new NoResult();
    }
}