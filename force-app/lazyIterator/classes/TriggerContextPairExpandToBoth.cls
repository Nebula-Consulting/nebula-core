/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 2019-07-12
 * @description Expands a TriggerContextPair to both records by themselves
 */

global class TriggerContextPairExpandToBoth implements ExpansionFunction {

    private Iterator<Object> iterator;

    public void setValue(Object value) {
        TriggerContextPair triggerContextPair = (TriggerContextPair)value;
        iterator = new List<Object>{triggerContextPair.oldRecord, triggerContextPair.newRecord}.iterator();
    }

    public Boolean hasNext() {
        return iterator.hasNext();
    }

    public Object next() {
        return iterator.next();
    }
}
