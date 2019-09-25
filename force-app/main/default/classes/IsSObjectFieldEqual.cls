/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 2019-06-21
 */

@Deprecated // Use new nebc.IsEqual(new nebc.FieldFromSObject(Object.Field), value) instead
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