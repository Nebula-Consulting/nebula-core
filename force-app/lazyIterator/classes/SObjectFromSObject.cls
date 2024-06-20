/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 15/05/2020
 * @description Function to extract SObjects from reference fields on SObject instances
 */
global class SObjectFromSObject implements Function {

    private SObjectField field;

    global SObjectFromSObject(SObjectField field) {
        this.field = field;
    }

    global Object call(Object o) {
        return ((SObject)o).getSObject(field);
    }
}