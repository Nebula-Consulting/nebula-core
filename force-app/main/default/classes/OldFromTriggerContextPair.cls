/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 2019-06-21
 */

global class OldFromTriggerContextPair {

    global Object call(Object o) {
        return ((TriggerContextPair)o).oldRecord;
    }
}