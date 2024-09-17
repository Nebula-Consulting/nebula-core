/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 29/12/2021
 * @description A ternary for composing functions. If the condition function evaluates to true, then calls thenFunction.
 * Otherwise, calls elseFunction (which defaults to nebc.IdentityFunction if absent)
 */
global class IfThen implements Function {

    private BooleanFunction condition;
    private Function thenFunction;
    private Function elseFunction = new IdentityFunction();

    global IfThen(BooleanFunction condition, Function thenFunction) {
        this.condition = condition;
        this.thenFunction = thenFunction;
    }

    global IfThen elseFunction(Function elseFunction) {
        this.elseFunction = elseFunction;
        return this;
    }

    global Object call(Object o) {
        if(condition.isTrueFor(o)) {
            return thenFunction.call(o);
        } else {
            return elseFunction.call(o);
        }
    }
}