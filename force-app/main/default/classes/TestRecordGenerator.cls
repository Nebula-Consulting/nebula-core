/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 2019-03-01
 */

public inherited sharing abstract class TestRecordGenerator {

    protected Test_Record_Generator__mdt metadata;
    protected TestRecords parentHierarchy;

    public void setup(TestRecords parentHierarchy, Test_Record_Generator__mdt metadata) {
        this.parentHierarchy = parentHierarchy;
        this.metadata = metadata;
    }

    public abstract SObject getObjectNoInsert(Map<String, Object> params);

    private SObject record;

    public virtual SObject getObjectWithInsert(Map<String, Object> params) {
        if(record == null) {
            record = getObjectNoInsert(params);
            insert record;
        }
        return record;
    }
}