/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 2019-06-21
 */
global class IsNotNull implements BooleanFunction {

    private Function mappingFunction;

    global IsNotNull(Function mappingFunction) {
        this.mappingFunction = mappingFunction;
    }

    global IsNotNull(SObjectField field) {
        this.mappingFunction = new FieldFromSObject(field);
    }

    global IsNotNull() {
        this(new IdentityFunction());
    }

    global Boolean isTrueFor(Object o) {
        return mappingFunction.call(o) != null;
    }
}