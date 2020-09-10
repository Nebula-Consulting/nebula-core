/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 2019-03-22
 * @description A pair of SObject records (old and new) from a trigger context
 */

global class TriggerContextPair extends ListTuple {

    global SObject oldRecord {get {return (SObject)get(0);} set;}
    global SObject newRecord {get {return (SObject)get(1);} set;}

    global TriggerContextPair(SObject oldRecord, SObject newRecord) {
        super(oldRecord, newRecord);
    }
}