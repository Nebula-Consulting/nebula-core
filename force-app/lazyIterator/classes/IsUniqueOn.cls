/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 2019-07-10
 */
global class IsUniqueOn implements BooleanFunction {

    private Function function;
    private Set<Object> seen = new Set<Object>();

    global IsUniqueOn(Function function) {
        this.function = function;
    }

    global IsUniqueOn(SObjectField field) {
        this.function = new FieldFromSObject(field);
    }

    global Boolean isTrueFor(Object o) {
        Object value = function.call(o);
        if(seen.contains(value)) {
            return false;
        } else {
            seen.add(value);
            return true;
        }
    }
}