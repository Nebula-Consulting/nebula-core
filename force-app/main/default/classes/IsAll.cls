/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 2019-06-21
 */

global class IsAll implements BooleanFunction {

    private List<BooleanFunction> booleanFunctions;

    global IsAll(List<BooleanFunction> booleanFunctions) {
        this.booleanFunctions = booleanFunctions;
    }

    global Boolean isTrueFor(Object o) {
        for(BooleanFunction thisBooleanFunction : booleanFunctions) {
            if(!thisBooleanFunction.isTrueFor(o)) {
                return false;
            }
        }
        return true;
    }
}
