/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 2019-06-21
 */

global class NewFromTriggerContextPair implements Function {

    global Object call(Object o) {
        return ((TriggerContextPair)o).newRecord;
    }
}