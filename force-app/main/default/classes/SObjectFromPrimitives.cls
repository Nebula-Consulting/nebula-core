/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 2019-08-12
 * @description A mapping function which creates a series of SObjects based on the provided prototype,
 */

global with sharing class SObjectFromPrimitives implements Function {

    private SObject prototype;
    private SObjectField field;

    global SObjectFromPrimitives(SObject prototype, SObjectField field) {
        this.prototype = prototype;
        this.field = field;
    }

    global Object call(Object o) {
        SObject returnVal = prototype.clone();
        returnVal.put(field, o);
        return returnVal;
    }
}