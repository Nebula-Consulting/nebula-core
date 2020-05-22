/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 19/05/2020
 * @description Function to extract child SObject lists from relationship fields on SObject instances
 */

global class SObjectsFromSObjectString implements ExpansionIterator {

    private String field;

    global SObjectsFromSObjectString(String field) {
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
}