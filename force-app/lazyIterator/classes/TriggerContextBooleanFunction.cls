/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 2019-03-26
 */
global abstract class TriggerContextBooleanFunction implements BooleanFunction {
    global Boolean isTrueFor(Object o) {
        TwoTuple pair = (TwoTuple) o;
        return isTrueFor((SObject)pair.left, (SObject)pair.right);
    }

    global abstract Boolean isTrueFor(SObject oldRecord, SObject newRecord);
}
