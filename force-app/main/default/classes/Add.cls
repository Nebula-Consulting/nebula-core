/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 30/08/2019
 * @description Works like the + operator, but implements Function so it can be evaluated later
 */

global class Add implements Function {

    private Function left;
    private Function right;

    global Add(Object left, Object right) {
        if(left instanceof Function) {
            this.left = (Function)left;
        } else {
            this.left = new ConstantFunction(left);
        }
        if(right instanceof Function) {
            this.right = (Function)right;
        } else {
            this.right = new ConstantFunction(right);
        }
    }

    global Object call(Object o) {
        Object leftValue = left.call(o);
        Object rightValue = right.call(o);

        if(leftValue instanceof String) {
            return (String)leftValue + rightValue;
        } else if (leftValue instanceof Integer) {
            return (Integer)leftValue + (Integer)rightValue;
        }
        throw new TypeException('Cannot convert ' + leftValue + ' to a suitable type for nebc.Add');
    }
}