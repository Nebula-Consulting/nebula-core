/**
 * @author danb@nebulaconsulting.co.uk
 * @date 08/04/2022
 */

global class IsFieldChangedFrom extends TriggerContextBooleanFunction {

    private SObjectField field;
    private Function function;

    global IsFieldChangedFrom(SObjectField field, Object valueOrFunction) {
        this.field = field;
        if(valueOrFunction instanceof Function) {
            this.function = (Function)valueOrFunction;
        } else {
            this.function = new ConstantFunction(valueOrFunction);
        }
    }

    global override Boolean isTrueFor(SObject oldRecord, SObject newRecord) {
        return oldRecord != null && oldRecord.get(field) != newRecord.get(field) && oldRecord.get(field) == function.call(oldRecord);
    }

}