/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 2019-03-22
 * @description A pair of SObject records (old and new) from a trigger context
 */

global class TriggerContextPair {

    global SObject newRecord;
    global SObject oldRecord;

    global TriggerContextPair(SObject oldRecord, SObject newRecord) {
        this.oldRecord = oldRecord;
        this.newRecord = newRecord;
    }

    global class NewRecordFromPair implements Function {
        global Object call(Object o) {
            return ((TriggerContextPair)o).newRecord;
        }

    }

    global class OldRecordFromPair implements Function {
        global Object call(Object o) {
            return ((TriggerContextPair)o).oldRecord;
        }

    }
}