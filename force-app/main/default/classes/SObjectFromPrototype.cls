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
        functions.add(function);
        return this;
    }

    global SObjectFromPrototype put(SObjectField field, Object valueOrFunction) {
        functions.add(new SObjectPutField(field, valueOrFunction));
        return this;
    }

    global Object call(Object o) {
        return functions.call(prototype.clone(), o);
    }
}
