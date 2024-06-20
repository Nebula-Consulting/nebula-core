/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 2019-06-21
 */
global class IsNull implements BooleanFunction {

    private Function mappingFunction;

    global IsNull(Function mappingFunction) {
        this.mappingFunction = mappingFunction;
    }

    global IsNull(SObjectField field) {
        this.mappingFunction = new FieldFromSObject(field);
    }

    global IsNull() {
        this(new IdentityFunction());
    }

    global Boolean isTrueFor(Object o) {
        return mappingFunction.call(o) == null;
    }
}