/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 2019-03-01
 */

global inherited sharing abstract class TestRecordGenerator {

    global Test_Record_Generator__mdt metadata {get; private set;}
    global TestRecordSource parentHierarchy {get; private set;}

    public void setup(TestRecordSource parentHierarchy, Test_Record_Generator__mdt metadata) {
        this.parentHierarchy = parentHierarchy;
        this.metadata = metadata;
    }

    global abstract SObject getObjectNoInsert(Map<String, Object> params);

    private SObject record;

    global virtual SObject getObjectWithInsert(Map<String, Object> params) {
        if(record == null) {
            record = getObjectNoInsert(params);
            insert record;
        }
        return record;
    }
}