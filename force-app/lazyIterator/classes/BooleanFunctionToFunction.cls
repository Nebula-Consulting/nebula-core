/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 14/09/2020
 */

public class BooleanFunctionToFunction implements Function {

    private BooleanFunction booleanFunction;

    public BooleanFunctionToFunction(BooleanFunction booleanFunction) {
        this.booleanFunction = booleanFunction;
    }

    public Boolean call(Object o) {
        return (Boolean) booleanFunction.isTrueFor(o);
    }
}