/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 25/09/2019
 * @description A boolean function which takes two Functions/Objects that can be applied to the test values before
 * comparing with <.
 */

global class IsLessThan implements BooleanFunction {

    private FunctionList functions;

    public IsLessThan(Object left, Object right) {
        functions = new FunctionList(left, right);
    }

    public IsLessThan(Object right) {
        functions = new FunctionList(new IdentityFunction(), right);
    }

    public Boolean isTrueFor(Object o) {
        Object leftValue = functions.functions[0].call(o);
        Object rightValue = functions.functions[1].call(o);

        if(leftValue instanceof String) {
            return (String)leftValue < (String)rightValue;
        } else if (leftValue instanceof Integer) {
            return (Integer)leftValue < (Integer)rightValue;
        } else if (leftValue instanceof Decimal) {
            return (Decimal)leftValue < (Decimal)rightValue;
        }

        throw new TypeException('Cannot convert ' + leftValue + ' to a suitable type for ' + IsLessThan.class.getName());
    }

}