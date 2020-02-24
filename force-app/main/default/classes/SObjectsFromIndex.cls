/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 24/02/2020
 * @description Expansion function which uses each item from setValue() to produce an iterator over the results from an
 * SObjectIndex
 */

global class SObjectsFromIndex implements ExpansionFunction {

    private SObjectIndex sObjectIndex;
    private Iterator<SObject> iterator;

    global SObjectsFromIndex(SObjectIndex sObjectIndex) {
        this.sObjectIndex = sObjectIndex;
    }

    public void setValue(Object value) {
        if(value instanceof SObject) {
            iterator = sObjectIndex.getAll((SObject)value).iterator();
        } else {
            iterator = sObjectIndex.getAll(value).iterator();
        }
    }

    public Boolean hasNext() {
        return iterator.hasNext();
    }

    public Object next() {
        return iterator.next();
    }
}