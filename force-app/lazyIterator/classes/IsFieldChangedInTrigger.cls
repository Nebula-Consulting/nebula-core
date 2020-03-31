/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 2019-06-21
 */

global class IsFieldChangedInTrigger extends TriggerContextBooleanFunction {

    private SObjectField field;

    global IsFieldChangedInTrigger(SObjectField field) {
        this.field = field;
    }

    global override Boolean isTrueFor(SObject oldRecord, SObject newRecord) {
        return oldRecord == null || oldRecord.get(field) != newRecord.get(field);
    }
}
