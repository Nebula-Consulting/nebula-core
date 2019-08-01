/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 2019-08-01
 */

global with sharing class ToSet implements TerminatorFunction {

    private LazyIterator iterator;
    private Set<Object> toFill;
    private Set<Id> toFillId;

    global ToSet(Set<Object> toFill) {
        this.toFill = toFill;
    }

    global ToSet(Set<Id> toFill) {
        this.toFillId = toFill;
    }

    global void call() {
        if(toFillId != null) {
            iterator.toSet(toFillId);
        } else {
            iterator.toSet(toFill);
        }
    }

    global TerminatorFunction setIterator(LazyIterator iterator) {
        this.iterator = iterator;
        return this;
    }

    global Object getResult() {
        return toFillId != null ? (Object)toFillId : (Object)toFill;
    }
}