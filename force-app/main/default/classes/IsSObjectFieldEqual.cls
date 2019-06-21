/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 2019-06-21
 */

global class IsSObjectFieldEqual implements BooleanFunction{

    private SObjectField field;
    private Object value;

    global IsSObjectFieldEqual(SObjectField field, Object value) {
        this.field = field;
        this.value = value;
    }

    global Boolean isTrueFor(Object o) {
        return ((SObject)o).get(field) == value;
    }
}