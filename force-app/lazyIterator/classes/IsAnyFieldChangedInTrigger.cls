/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 24/04/2020
 * @description Note that the string version does not support nested fields - you'd never get these from a trigger context
 */

global class IsAnyFieldChangedInTrigger extends TriggerContextBooleanFunction{

    final private List<String> fields;

    global IsAnyFieldChangedInTrigger(SObjectField field1, SObjectField field2) {
        this.fields = new List<String>{ field1.getDescribe().getName(), field2.getDescribe().getName() };
    }

    global IsAnyFieldChangedInTrigger(SObjectField field1, SObjectField field2, SObjectField field3) {
        this.fields = new List<String>{ field1.getDescribe().getName(), field2.getDescribe().getName(), field3.getDescribe().getName() };
    }

    global IsAnyFieldChangedInTrigger(List<SObjectField> fields) {
        this.fields = new List<String>();
        for(SObjectField thisField : fields) {
            this.fields.add(thisField.getDescribe().getName());
        }
    }

    global IsAnyFieldChangedInTrigger(String field1, String field2) {
        this.fields = new List<String>{ field1, field2 };
    }

    global IsAnyFieldChangedInTrigger(String field1, String field2, String field3) {
        this.fields = new List<String>{ field1, field2, field3 };
    }

    global IsAnyFieldChangedInTrigger(List<String> fields) {
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