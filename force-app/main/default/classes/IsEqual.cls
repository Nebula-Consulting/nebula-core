/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 25/09/2019
 * @description  boolean function which takes two Functions/Objects that can be applied to the test values before
 * comparing with .isEqual(). Note that this means Strings are treated case-sensitively
 */

global class IsEqual implements BooleanFunction {

    private FunctionList functions;

    global IsEqual(Object left, Object right) {
        functions = new FunctionList(left, right);
    }

    global IsEqual(Object right) {
        functions = new FunctionList(new IdentityFunction(), right);
    }

    global Boolean isTrueFor(Object o) {
        Object leftValue = functions.functions[0].call(o);
        Object rightValue = functions.functions[1].call(o);

        return (leftValue == null && rightValue == null) || (leftValue != null && leftValue.equals(rightValue));
    }
}