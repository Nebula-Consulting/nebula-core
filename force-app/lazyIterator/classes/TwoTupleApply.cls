/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 11/11/2021
 * @description (if required)
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