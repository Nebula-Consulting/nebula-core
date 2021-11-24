/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 11/11/2021
 * @description Turns an object, o,  and a pair of functions, f1 and f2, into a two-tuple as <f1(o), f2(o)>
 */

global class ToTwoTuple implements Function {

    private Function function1;
    private Function function2;

    global ToTwoTuple(Function function1, Function function2) {
        this.function1 = function1;
        this.function2 = function2;
    }

    global Object call(Object o) {
        return new TwoTuple(function1.call(o), function2.call(o));
    }
}