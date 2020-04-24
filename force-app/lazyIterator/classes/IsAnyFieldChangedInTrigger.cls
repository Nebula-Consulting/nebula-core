/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 24/04/2020
 */

global class IsAnyFieldChangedInTrigger extends TriggerContextBooleanFunction{
    private List<SObjectField> fields;

    global IsAnyFieldChangedInTrigger(SObjectField field1, SObjectField field2) {
        this.fields = new List<SObjectField>{ field1, field2 };
    }

    global IsAnyFieldChangedInTrigger(SObjectField field1, SObjectField field2, SObjectField field3) {
        this.fields = new List<SObjectField>{ field1, field2, field3 };
    }

    global IsAnyFieldChangedInTrigger(List<SObjectField> fields) {
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
