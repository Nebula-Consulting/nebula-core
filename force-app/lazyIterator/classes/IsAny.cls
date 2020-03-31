/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 2019-06-21
 */

global class IsAny implements BooleanFunction {

    private List<BooleanFunction> booleanFunctions;

    global IsAny(List<BooleanFunction> booleanFunctions) {
        this.booleanFunctions = booleanFunctions;
    }

    global IsAny(BooleanFunction booleanFunction1, BooleanFunction booleanFunction2) {
        this(new List<BooleanFunction>{booleanFunction1, booleanFunction2});
    }

    global IsAny(BooleanFunction booleanFunction1, BooleanFunction booleanFunction2, BooleanFunction booleanFunction3) {
        this(new List<BooleanFunction>{booleanFunction1, booleanFunction2, booleanFunction3});
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
