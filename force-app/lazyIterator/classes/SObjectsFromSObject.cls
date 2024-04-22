/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 14/09/2020
 * @description Function to extract child SObject lists from relationship fields on SObject instances
 */
global virtual class SObjectsFromSObject implements ExpansionIterator, Function {

    private String field;

    global SObjectsFromSObject(String field) {
        this.field = field;
    }

    global Iterator<Object> setValue(Object value) {
        List<SObject> sObjects = ((SObject)value).getSObjects(field);
        if(sObjects != null) {
            // Note that we need to cast in two steps because Apex is weird
            Iterator<SObject> it = sObjects.iterator();
            return (Iterator<Object>)it;
        } else {
            return EmptyIterator.getInstance();
        }
    }

    global Object call(Object o) {
        return setValue(o);
    }
}