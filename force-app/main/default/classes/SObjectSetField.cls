/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 2019-08-16
 */

global class SObjectSetField implements Function {

    private SObjectField field;
    private Object value;

    global SObjectSetField(SObjectField field, Object value) {
        this.field = field;
        this.value = value;
    }

    global Object call(Object o) {
        ((SObject)o).put(field, value);
        return o;
    }
}