/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 2019-08-16
 */

@Deprecated // Renamed to SObjectPutField
global class SObjectSetField extends SObjectPutField {
    global SObjectSetField(SObjectField field, Object value) {
        super(field, new ConstantFunction(value));
    }
}