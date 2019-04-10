/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 2019-04-10
 * @description Function to extract field values from SObject instances using a string and SObjectGetter, so you can
 * follow through relationship fields
 */

global class FieldFromSObjectString implements Function {

    private String field;

    global FieldFromSObjectString(String field) {
        this.field = field;
    }

    public Object call(Object o) {
        return SObjectGetter.get(((SObject)o), field);
    }
}