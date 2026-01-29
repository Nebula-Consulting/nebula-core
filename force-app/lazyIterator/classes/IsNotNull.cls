/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 2019-06-21
 * @description BooleanFunction that returns true if the value (or mapped value) is not null
 */
global class IsNotNull implements BooleanFunction {

    private Function mappingFunction;

    /**
     * @description Creates an IsNotNull filter that applies a mapping function first
     * @param mappingFunction Function to apply before checking for null
     */
    global IsNotNull(Function mappingFunction) {
        this.mappingFunction = mappingFunction;
    }

    /**
     * @description Creates an IsNotNull filter for a specific SObject field
     * @param field The field to check for null
     */
    global IsNotNull(SObjectField field) {
        this.mappingFunction = new FieldFromSObject(field);
    }

    /**
     * @description Creates an IsNotNull filter that checks the value directly
     */
    global IsNotNull() {
        this(new IdentityFunction());
    }

    /**
     * @description Returns true if the value (after mapping) is not null
     * @param o The value to check
     * @return True if not null, false otherwise
     */
    global Boolean isTrueFor(Object o) {
        return mappingFunction.call(o) != null;
    }
}