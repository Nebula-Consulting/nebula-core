/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 2019-08-21
 */

global class SObjectFromPrototype implements Function{

    private SObject prototype;
    private BinaryComposition functions;

    global SObjectFromPrototype(SObject prototype) {
        this.prototype = prototype;
        this.functions = new BinaryComposition();
    }

    global SObjectFromPrototype put(BinaryFunction function) {
        functions.compose(function);
        return this;
    }

    global SObjectFromPrototype put(SObjectField field, Object valueOrFunction) {
        functions.compose(new SObjectPutField(field, valueOrFunction));
        return this;
    }

    // Note that this cannot overload put(SObjectField field, Object valueOrFunction) or calling put(f, null) would
    // become ambiguous
    global SObjectFromPrototype putField(SObjectField targetField, SObjectField sourceField) {
        functions.compose(new SObjectPutField(targetField, new FieldFromSObject(sourceField)));
        return this;
    }

    global SObjectFromPrototype put(SObjectField field) {
        functions.compose(new SObjectPutField(field, new IdentityFunction()));
        return this;
    }

    global Object call(Object o) {
        return functions.call(prototype.clone(), o);
    }
}
