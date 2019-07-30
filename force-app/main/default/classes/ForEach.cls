/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 2019-07-25
 */

global class ForEach implements TerminatorFunction {

    private VoidFunction callingFunction;
    private LazyIterator iterator;

    global ForEach(VoidFunction callingFunction) {
        this.callingFunction = callingFunction;
    }

    global void call() {
        iterator.forEach(callingFunction);
    }

    global TerminatorFunction setIterator(LazyIterator iterator) {
        this.iterator = iterator;
        return this;
    }

    global Object getResult() {
        return new NoResult();
    }
}