/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 2019-06-21
 */

global class IsAny implements BooleanFunction {

    private List<BooleanFunction> booleanFunctions;

    global IsAny(List<BooleanFunction> booleanFunctions) {
        this.booleanFunctions = booleanFunctions;
    }

    global Boolean isTrueFor(Object o) {
        for(BooleanFunction thisBooleanFunction : booleanFunctions) {
            if(thisBooleanFunction.isTrueFor(o)) {
                return true;
            }
        }
        return false;
    }
}
