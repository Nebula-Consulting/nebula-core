/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 19/05/2020
 * @description Converts the old ExpansionFunction into an ExpansionIterator so that the latter can be used
 * internally
 */

public class ExpansionFunctionToIterator implements ExpansionIterator {

    private ExpansionFunction expansionFunction;

    public ExpansionFunctionToIterator(ExpansionFunction expansionFunction) {
        this.expansionFunction = expansionFunction;
    }

    public Iterator<Object> setValue(Object value) {
        expansionFunction.setValue(value);
        return expansionFunction;
    }
}