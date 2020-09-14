/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 14/09/2020
 */

public class FunctionToBooleanFunction implements BooleanFunction {

    private Function function;

    public FunctionToBooleanFunction(Function function) {
        this.function = function;
    }

    public Boolean isTrueFor(Object o) {
        return (Boolean)function.call(o);
    }
}