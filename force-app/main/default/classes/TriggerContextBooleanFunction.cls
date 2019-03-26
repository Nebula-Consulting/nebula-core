/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 2019-03-26
 */

public abstract class TriggerContextBooleanFunction implements BooleanFunction {
    public Boolean isTrueFor(Object o) {
        TriggerContextPair pair = (TriggerContextPair)o;
        return isTrueFor(pair.oldRecord, pair.newRecord);
    }

    public abstract Boolean isTrueFor(SObject oldRecord, SObject newRecord);
}