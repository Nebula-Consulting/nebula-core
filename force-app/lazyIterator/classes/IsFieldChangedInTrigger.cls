/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 2019-06-21
 */

global class IsFieldChangedInTrigger extends TriggerContextBooleanFunction {

    private List<SObjectField> fields;

    global IsFieldChangedInTrigger(SObjectField field) {
        this.fields = new List<SObjectField>{ field };
    }

    global IsFieldChangedInTrigger(SObjectField field1, SObjectField field2) {
        this.fields = new List<SObjectField>{ field1, field2 };
    }

    global IsFieldChangedInTrigger(SObjectField field1, SObjectField field2, SObjectField field3) {
        this.fields = new List<SObjectField>{ field1, field2, field3 };
    }

    global IsFieldChangedInTrigger(List<SObjectField> fields) {
        this.fields = fields;
    }

    global override Boolean isTrueFor(SObject oldRecord, SObject newRecord) {
        if(oldRecord == null) {
            return true;
        }
        for(Integer i=fields.size()-1; i >= 0; i--) {
            if(oldRecord.get(fields[i]) != newRecord.get(fields[i])) {
                return true;
            }
        }
        return false;
    }
}
