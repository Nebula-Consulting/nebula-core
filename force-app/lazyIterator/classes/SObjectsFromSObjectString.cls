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
        Iterator<SObject> it = ((SObject)value).getSObjects(field).iterator();
        return (Iterator<Object>)it;
    }
}