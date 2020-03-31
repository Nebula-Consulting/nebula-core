/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 2019-08-21
 */

global class BinaryComposition extends BinaryFunctionWithConversion implements AccumulatorObject {

    private List<BinaryFunction> functions;

    global BinaryComposition() {
        functions = new List<BinaryFunction>();
    }

    global BinaryComposition(BinaryFunction function1, BinaryFunction function2) {
        functions = new List<BinaryFunction> { function1, function2 };
    }

    global BinaryComposition compose(BinaryFunction function) {
        functions.add(function);
        return this;
    }

    global override Object call(Object o1, Object o2) {
        Object returnVal = o1;
        for(Integer i=0; i < functions.size(); i++) {
            returnVal = functions[i].call(returnVal, o2);
        }
        return returnVal;
    }

    global void accumulate(Object o) {
        functions.add((BinaryFunction)o);
    }
}