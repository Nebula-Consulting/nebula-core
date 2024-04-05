/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 25/09/2019
 * @description A boolean function which takes two Functions/Objects that can be applied to the test values before
 * comparing with <.
 */

global class IsLessThan implements BooleanFunction {

    private FunctionList functions;

    global IsLessThan(Object left, Object right) {
        functions = new FunctionList(left, right);
    }

    global IsLessThan(SObjectField left, Object right) {
        functions = new FunctionList(new FieldFromSObject(left), right);
    }

    global IsLessThan(SObjectField left, SObjectField right) {
        functions = new FunctionList(new FieldFromSObject(left), new FieldFromSObject(right));
    }

    global IsLessThan(Object right) {
        functions = new FunctionList(new IdentityFunction(), right);
    }

    global Boolean isTrueFor(Object o) {
        Object leftValue = functions.functions[0].call(o);
        Object rightValue = functions.functions[1].call(o);

        if(leftValue instanceof String) {
            return (String)leftValue < (String)rightValue;
        } else if (leftValue instanceof Integer) {
            return (Integer)leftValue < (Integer)rightValue;
        } else if (leftValue instanceof Decimal) {
            return (Decimal)leftValue < (Decimal)rightValue;
        } else if (leftValue instanceof Datetime) {
            return (Datetime)leftValue < (Datetime)rightValue;
        } else if (leftValue instanceof Date) {
            return (Date)leftValue < (Date)rightValue;
        }

        throw new TypeException('Cannot convert ' + leftValue + ' to a suitable type for ' + IsLessThan.class.getName());
    }
}