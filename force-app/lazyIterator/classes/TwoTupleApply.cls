/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 11/11/2021
 * @description Applies two functions to the corresponding elements of a tuple (at least size 2) i.e. given a tuple,
 * <o1, o2, ...>,  and a pair of functions, f1 and f2, returns a two-tuple as <f1(o), f2(o)>
 */

global class TwoTupleApply implements Function {

    private Function function1;
    private Function function2;

    global TwoTupleApply(Function function1, Function function2) {
        this.function1 = function1;
        this.function2 = function2;
    }

    global TwoTuple call(Object o) {
        Tuple twoTupleIn = (Tuple)o;
        return new TwoTuple(function1.call(twoTupleIn.get(0)), function2.call(twoTupleIn.get(1)));
    }
}