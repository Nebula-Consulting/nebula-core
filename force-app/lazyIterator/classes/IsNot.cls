/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 2019-06-21
 */
global class IsNot implements BooleanFunction {

    private BooleanFunction booleanFunction;

    global IsNot(BooleanFunction booleanFunction) {
        this.booleanFunction = booleanFunction;
    }

    global Boolean isTrueFor(Object o) {
        return !booleanFunction.isTrueFor(o);
    }
}
