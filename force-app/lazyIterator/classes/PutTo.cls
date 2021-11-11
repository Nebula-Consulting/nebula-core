/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 10/11/2021
 * @description Puts values into map-like objects e.g. Map, SObjectIndex, SObject. Call with a 2-tuple of <key, value>
 */

public class PutTo implements nebc.Function {

    private SObject target;

    public PutTo(SObject target) {
        this.target = target;
    }

    public Object call(Object o) {
        Tuple keyValue = (Tuple) o;
        target.put((String)keyValue.get(0), keyValue.get(1));
        return keyValue;
    }
}