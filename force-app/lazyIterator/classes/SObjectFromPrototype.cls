/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 2019-08-21
 * @description Creates SObjects from a prototype, allowing field values to be set from
 * the input value using functions. Useful for transforming data into SObjects.
 */
global class SObjectFromPrototype implements Function{

    private SObject prototype;
    private BinaryComposition functions;

    /**
     * @description Creates a function that clones the prototype SObject
     * @param prototype The SObject to use as a template
     */
    global SObjectFromPrototype(SObject prototype) {
        this.prototype = prototype;
        this.functions = new BinaryComposition();
    }

    /**
     * @description Adds a custom binary function to apply to the prototype
     * @param function The function to apply
     * @return This SObjectFromPrototype for method chaining
     */
    global SObjectFromPrototype put(BinaryFunction function) {
        functions.compose(function);
        return this;
    }

    /**
     * @description Sets a field to a value or the result of a function
     * @param field The SObjectField to set
     * @param valueOrFunction A constant value or Function to derive the value
     * @return This SObjectFromPrototype for method chaining
     */
    global SObjectFromPrototype put(SObjectField field, Object valueOrFunction) {
        functions.compose(new SObjectPutField(field, valueOrFunction));
        return this;
    }

    /**
     * @description Sets a target field from a source field on the input SObject
     * @param targetField The field to set on the output
     * @param sourceField The field to read from the input
     * @return This SObjectFromPrototype for method chaining
     */
    global SObjectFromPrototype putField(SObjectField targetField, SObjectField sourceField) {
        functions.compose(new SObjectPutField(targetField, new FieldFromSObject(sourceField)));
        return this;
    }

    /**
     * @description Sets a field to the input value directly (identity function)
     * @param field The field to set
     * @return This SObjectFromPrototype for method chaining
     */
    global SObjectFromPrototype put(SObjectField field) {
        functions.compose(new SObjectPutField(field, new IdentityFunction()));
        return this;
    }

    /**
     * @description Creates a new SObject from the prototype with configured field values
     * @param o The input value to use for deriving field values
     * @return A new SObject cloned from the prototype with fields set
     */
    global Object call(Object o) {
        return functions.call(prototype.clone(), o);
    }
}
