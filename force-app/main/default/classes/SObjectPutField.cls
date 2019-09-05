/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 2019-08-21
 */

global virtual class SObjectPutField extends BinaryFunctionWithConversion {

    private SObjectField field;
    private Function function;

    global SObjectPutField(SObjectField field, Object value) {
        this.field = field;
        this.function = new ConstantFunction(value);
    }

    global SObjectPutField(SObjectField field, Function function) {
        this.field = field;
        this.function = function;
    }

    global override Object call(Object o1, Object o2) {
        SObject result = (SObject)o1;
        result.put(field, function.call(o2 == NoResult.NO_RESULT ? o1 : o2));
        return result;
    }
}