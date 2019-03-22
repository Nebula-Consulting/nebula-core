/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 2019-03-22
 * @description Iterates over the pair of lists that you get from a Trigger context, returning them in Pairs
 */

global class TriggerContextIterator implements Iterator<TriggerContextPair> {

    private Iterator<SObject> newIterator;
    private Iterator<SObject> oldIterator;

    global TriggerContextIterator(List<SObject> oldList, List<SObject> newList) {
        // NB, these can't be ternaries because: "Operation cast is not allowed on type: System.ListIterator<SObject>"
        if(newList == null) {
            newIterator = new NullIterator();
        } else {
            newIterator = newList.iterator();
        }
        if(oldList == null) {
            oldIterator = new NullIterator();
        } else {
            oldIterator = oldList.iterator();
        }
    }

    global Boolean hasNext() {
        return newIterator.hasNext() && oldIterator.hasNext();
    }

    global TriggerContextPair next() {
        return new TriggerContextPair(oldIterator.next(), newIterator.next());
    }

    private class NullIterator implements Iterator<SObject> {
        public Boolean hasNext() {
            return true;
        }

        public SObject next() {
            return null;
        }
    }
}