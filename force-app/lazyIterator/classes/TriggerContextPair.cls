/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 2019-03-22
 * @description A pair of SObject records (old and new) from a trigger context
 */

global class TriggerContextPair extends TwoTuple {

    global SObject oldRecord {get {return (SObject)left;} private set;}
    global SObject newRecord {get {return (SObject)right;} private set;}

    global TriggerContextPair(SObject oldRecord, SObject newRecord) {
        super(oldRecord, newRecord);
    }
}
