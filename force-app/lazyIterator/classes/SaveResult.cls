/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 09/09/2020
 * @description A 2-Tuple of Database.SaveResult and SObject, providing access to both
 * the DML result and the record that was saved
 */
global class SaveResult extends TwoTuple implements DatabaseResult {

    global Database.SaveResult saveResult {get {return (Database.SaveResult)left;} set; }
    global SObject record {get {return (SObject)right;} set; }
    public static NewInstance newInstance = new NewSaveResult();

    /**
     * @description Creates a SaveResult from a Database.SaveResult and SObject
     * @param saveResult The save result from the DML operation
     * @param record The SObject that was saved
     */
    global SaveResult(Database.SaveResult saveResult, SObject record) {
        super(saveResult, record);
    }

    /**
     * @description Gets the SObject that was saved
     * @return The saved SObject
     */
    global SObject getRecord() {
        return record;
    }

    /**
     * @description Returns whether the save was successful
     * @return True if successful, false otherwise
     */
    global Boolean isSuccess() {
        return saveResult.isSuccess();
    }

    /**
     * @description Gets the list of errors if the save failed
     * @return List of Database.Error
     */
    global List<Database.Error> getErrors() {
        return saveResult.getErrors();
    }

    private class NewSaveResult implements NewInstance {
        public Object newInstance(List<Object> parameters) {
            return new SaveResult((Database.SaveResult)parameters[0], (SObject)parameters[1]);
        }
    }
}
