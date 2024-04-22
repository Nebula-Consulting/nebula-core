/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 2019-06-21
 * @description Note that the string version does not support nested fields - you'd never get these from a trigger context
 */
global class IsFieldChangedInTrigger extends TriggerContextBooleanFunction {

    final private String field;

    global IsFieldChangedInTrigger(SObjectField field) {
        this.field = field.getDescribe().getName();
    }

    global IsFieldChangedInTrigger(String field) {
        this.field = field;
    }

    global override Boolean isTrueFor(SObject oldRecord, SObject newRecord) {
        return oldRecord == null || oldRecord.get(field) != newRecord.get(field);
    }
}