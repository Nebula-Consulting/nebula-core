/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 2019-06-21
 */
global class IsSObjectFieldEqual implements BooleanFunction{

    private SObjectField field;
    private Function valueFunction;

    // Not using an overloaded sSObjectFieldEqual(SObjectField field, Function valueFunction) constructor to preserve
    // existing code which compares against null (which would become ambiguous)
    global IsSObjectFieldEqual(SObjectField field, Object valueOrFunction) {
        this.field = field;
        if(valueOrFunction instanceof Function) {
            this.valueFunction = (Function) valueOrFunction;
        } else {
            this.valueFunction = new ConstantFunction(valueOrFunction);
        }
    }

    global Boolean isTrueFor(Object o) {
        return ((SObject)o).get(field) == valueFunction.call(o);
    }
}