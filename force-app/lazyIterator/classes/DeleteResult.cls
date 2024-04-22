/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 10/09/2020
 */
global class DeleteResult extends TwoTuple implements DatabaseResult {

    global Database.DeleteResult deleteResult {get {return (Database.DeleteResult)left;} set; }
    global SObject record {get {return (SObject)right;} set; }
    public static NewInstance newInstance = new NewDeleteResult();

    global DeleteResult(Database.DeleteResult deleteResult, SObject record) {
        super(deleteResult, record);
    }

    global SObject getRecord() {
        return record;
    }

    global Boolean isSuccess() {
        return deleteResult.isSuccess();
    }

    global List<Database.Error> getErrors() {
        return deleteResult.getErrors();
    }

    private class NewDeleteResult implements NewInstance {
        public Object newInstance(List<Object> parameters) {
            return new DeleteResult((Database.DeleteResult)parameters[0], (SObject)parameters[1]);
        }
    }
}
