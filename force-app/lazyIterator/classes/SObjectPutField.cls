/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 2019-08-21
 */

global virtual class SObjectPutField extends BinaryFunctionWithConversion {

    private String field;
    private Function function;

    global SObjectPutField(SObjectField field, Object valueOrFunction) {
        this(field.getDescribe().getName(), valueOrFunction);
    }

    global SObjectPutField(String field, Object valueOrFunction) {
        this.field = field;
        if(valueOrFunction instanceof Function) {
            this.function =(Function)valueOrFunction;
        } else {
            this.function = new ConstantFunction(valueOrFunction);
        }
    }

    global override Object call(Object o1, Object o2) {
        SObject result = (SObject)o1;
        result.put(field, function.call(o2 == NoResult.NO_RESULT ? o1 : o2));
        return result;
    }
}