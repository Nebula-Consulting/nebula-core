/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 2019-07-25
 */

global class ToList implements TerminatorFunction {

    private LazyIterator iterator;
    private List<Object> toFill;

    global ToList(List<Object> toFill) {
        this.toFill = toFill;
    }

    global void call() {
        iterator.toList(toFill);
    }

    global TerminatorFunction setIterator(LazyIterator iterator) {
        this.iterator = iterator;
        return this;
    }

    global Object getResult() {
        return toFill;
    }
}