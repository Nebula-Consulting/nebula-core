/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 09/09/2020
 * @description A 2-Tuple of Database.SaveResult and SObject
 */

global class SaveResult extends TwoTuple implements DatabaseResult {

    global Database.SaveResult saveResult {get {return (Database.SaveResult)left;} set; }
    global SObject record {get {return (SObject)right;} set; }
    public static NewInstance newInstance = new NewSaveResult();

    global SaveResult(Database.SaveResult saveResult, SObject record) {
        super(saveResult, record);
    }

    global SObject getRecord() {
        return record;
    }

    global Boolean isSuccess() {
        return saveResult.isSuccess();
    }

    global List<Database.Error> getErrors() {
        return saveResult.getErrors();
    }

    private class NewSaveResult implements NewInstance {
        public Object newInstance(List<Object> parameters) {
            return new SaveResult((Database.SaveResult)parameters[0], (SObject)parameters[1]);
        }
    }
}
