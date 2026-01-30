/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 2019-07-05
 */
global abstract class TriggerContextPairVoidFunction implements VoidFunction {

    global void call(Object o) {
        TriggerContextPair triggerContextPair = (TriggerContextPair) o;
        call(triggerContextPair.oldRecord, triggerContextPair.newRecord);
    }

    global abstract void call(SObject oldRecord, SObject newRecord);
}