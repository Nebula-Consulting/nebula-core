/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 2019-08-21
 * @description Compose multiple functions
 */

global virtual class Composition implements Function {

    private List<Function> functions;

    global Composition(Function function1) {
        functions = new List<Function> { function1 };
    }

    global Composition(Function function1, Function function2) {
        functions = new List<Function> { function1, function2 };
    }

    global Composition(Function function1, Function function2, Function function3) {
        functions = new List<Function> { function1, function2, function3 };
    }

    global Composition add(Function function) {
        functions.add(function);
        return this;
    }

    global Composition compose(Function function) {
        functions.add(function);
        return this;
    }

    global virtual Object call(Object o) {
        Object returnVal = o;
        for(Integer i=0; i < functions.size(); i++) {
            returnVal = functions[i].call(returnVal);
        }
        return returnVal;
    }
}