/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 16/11/2022
 * @description A 2-Tuple of Database.UpsertResult and SObject
 */

global class UpsertResult extends TwoTuple implements DatabaseResult {

    public static NewInstance newInstance = new NewUpsertResult();

    global Database.UpsertResult upsertResult {get {return (Database.UpsertResult)left;} set; }
    global SObject record {get {return (SObject)right;} set; }

    global UpsertResult(Database.UpsertResult saveResult, SObject record) {
        super(saveResult, record);
    }

    global SObject getRecord() {
        return record;
    }

    global Boolean isSuccess() {
        return upsertResult.isSuccess();
    }

    global List<Database.Error> getErrors() {
        return upsertResult.getErrors();
    }

    private class NewUpsertResult implements NewInstance {
        public Object newInstance(List<Object> parameters) {
            return new UpsertResult((Database.UpsertResult)parameters[0], (SObject)parameters[1]);
        }
    }
}