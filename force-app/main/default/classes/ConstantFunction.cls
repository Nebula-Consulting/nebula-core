/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 2019-08-21
 */

global class ConstantFunction implements Function, BinaryFunction {
    private Object value;

    global ConstantFunction(Object value) {
        this.value = value;
    }

    global Object call(Object o) {
        return value;
    }

    global Object call(Object o1, Object o2) {
        return value;
    }
}