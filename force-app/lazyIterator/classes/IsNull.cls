/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 2019-06-21
 * @description BooleanFunction that returns true if the value (or mapped value) is null
 */
global class IsNull implements BooleanFunction {

    private Function mappingFunction;

    /**
     * @description Creates an IsNull filter that applies a mapping function first
     * @param mappingFunction Function to apply before checking for null
     */
    global IsNull(Function mappingFunction) {
        this.mappingFunction = mappingFunction;
    }

    /**
     * @description Creates an IsNull filter for a specific SObject field
     * @param field The field to check for null
     */
    global IsNull(SObjectField field) {
        this.mappingFunction = new FieldFromSObject(field);
    }

    /**
     * @description Creates an IsNull filter that checks the value directly
     */
    global IsNull() {
        this(new IdentityFunction());
    }

    /**
     * @description Returns true if the value (after mapping) is null
     * @param o The value to check
     * @return True if null, false otherwise
     */
    global Boolean isTrueFor(Object o) {
        return mappingFunction.call(o) == null;
    }
}