/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 30/08/2019
 * @description Works like the + operator, but implements Function so it can be evaluated later
 */
global class Add implements Function {

    private FunctionList functions;

    global Add(Object left, Object right) {
        functions = new FunctionList(left, right);
    }

    global Object call(Object o) {
        Object leftValue = functions.functions[0].call(o);
        Object rightValue = functions.functions[1].call(o);

        if(leftValue instanceof String) {
            return (String)leftValue + rightValue;
        } else if (leftValue instanceof Integer) {
            return (Integer)leftValue + (Integer)rightValue;
        }
        throw new TypeException('Cannot convert ' + leftValue + ' to a suitable type for ' + Add.class.getName());
    }

    global Add add(Object another) {
        return new Add(this, another);
    }
}