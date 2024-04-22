/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 2019-06-28
 */
global abstract class TriggerContextPairFunction implements Function {

    global Object call(Object o) {
        TriggerContextPair triggerContextPair = (TriggerContextPair) o;
        return call(triggerContextPair.oldRecord, triggerContextPair.newRecord);
    }

    global abstract Object call(SObject oldRecord, SObject newRecord);
}