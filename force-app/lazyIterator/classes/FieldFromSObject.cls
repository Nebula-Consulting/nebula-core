/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 2019-04-10
 * @description Function to extract field values from SObject instances
 */
global class FieldFromSObject implements Function {

    private SObjectField field;

    global FieldFromSObject(SObjectField field) {
        this.field = field;
    }

    public Object call(Object o) {
        return ((SObject)o).get(field);
    }
}