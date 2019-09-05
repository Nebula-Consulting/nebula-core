/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 05/09/2019
 */

global class ConstantBooleanFunction implements BooleanFunction {

    private Boolean value;

    global ConstantBooleanFunction(Boolean value) {
        this.value = value;
    }

    global Boolean isTrueFor(Object o) {
        return value;
    }
}