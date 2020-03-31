/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 2019-03-26
 */

global abstract class TriggerContextBooleanFunction implements BooleanFunction {
    global Boolean isTrueFor(Object o) {
        TriggerContextPair pair = (TriggerContextPair)o;
        return isTrueFor(pair.oldRecord, pair.newRecord);
    }

    global abstract Boolean isTrueFor(SObject oldRecord, SObject newRecord);
}