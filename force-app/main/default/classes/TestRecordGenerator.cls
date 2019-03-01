/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 2019-03-01
 */

public abstract class TestRecordGenerator {

    public TestRecords parentTestRecords;

    public abstract SObject getObjectNoInsert(Map<String, Object> params);

    private SObject record;

    public virtual SObject getObjectWithInsert(Map<String, Object> params) {
        if(record == null) {
            record = getObjectNoInsert(params);
            insert record;
        }
        return record;
    }

    public SObject getObjectNoInsert() {
        return getObjectNoInsert(null);
    }

    public SObject getObjectWithInsert() {
        return getObjectWithInsert(null);
    }
}